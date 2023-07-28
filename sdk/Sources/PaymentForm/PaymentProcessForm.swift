//
//  PaymentProgressForm.swift
//  sdk
//
//  Created by Sergey Iskhakov on 24.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import UIKit
import WebKit

public class PaymentProcessForm: PaymentForm {
    public enum State {
        
        case inProgress
        case inProgressTinkoff
        case succeeded(Transaction?)
        case failed(String?)
        
        func getImage() -> UIImage? {
            switch self {
            case .inProgress, .inProgressTinkoff:
                return .iconProgress
            case .succeeded:
                return .iconSuccess
            case .failed:
                return .iconFailed
            }
        }
        
        func getMessage() -> String? {
            switch self {
            case .inProgress:
                return "Оплата в процессе"
            case .succeeded:
                return "Оплата прошла успешно"
            case .failed(let message):
                return message ?? "Операция отклонена"
            case .inProgressTinkoff:
                return "Ждем ответа от Тинькофф Pay"
            }
        }
        
        func getActionButtonTitle() -> String? {
            switch self {
            case .succeeded:
                return "Отлично!"
            case .failed:
                return "Повторить оплату"
            default:
                return nil
            }
        }
        
        func description() -> String? {
            switch self {
            case .inProgressTinkoff:
                return "Если перейти и оплатить в приложении не удалось, попробуйте снова или выберите другой способ оплаты"
            default: return nil
            }
        }
    }
    // MARK: - Private properties 
    @IBOutlet private weak var progressIcon: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var actionButton: Button!
    @IBOutlet private weak var secondDescriptionLabel: UILabel!
    @IBOutlet private weak var progressView: View!
    @IBOutlet private weak var errorView: View!
    @IBOutlet private weak var buttonView: View!
    @IBOutlet private weak var progressStackView: UIStackView!
    
    @IBOutlet private weak var tinkoffView: UIView!
    @IBOutlet private weak var tinkoffDescription: UILabel!
    
    @IBOutlet private weak var selectPaymentButton: Button!

    private var state: State = .inProgress
    private var cryptogram: String?
    private var email: String?
    private var transactionId: Int?
    private var tinkoffState: Bool = false
    private var isOnSaveCard: Bool? = nil
    
    @discardableResult
    public class func present(with configuration: PaymentConfiguration, cryptogram: String?, email: String?, state: State = .inProgress, from: UIViewController, isOnTinkoffPay: Bool = false, isOnSaveCard: Bool? = nil, completion: (() -> ())? = nil) -> PaymentForm? {
        let storyboard = UIStoryboard.init(name: "PaymentForm", bundle: Bundle.mainSdk)

        let controller = storyboard.instantiateViewController(withIdentifier: "PaymentProcessForm") as! PaymentProcessForm        
        controller.configuration = configuration
        controller.cryptogram = cryptogram
        controller.email = email
        controller.state = state
        controller.tinkoffState = isOnTinkoffPay
        controller.isOnSaveCard = isOnSaveCard
        
        controller.show(inViewController: from, completion: completion)
        
        return controller
    }
    
    @objc private func tinkoffAction(_ sender: UIButton) {
        let parent = self.presentingViewController
        self.dismiss(animated: true) {
            if let parent = parent {
                if !self.configuration.disableApplePay || !self.configuration.disableYandexPay {
                    PaymentForm.present(with: self.configuration, from: parent)
                } else {
                    PaymentForm.present(with: self.configuration, from: parent)
                }
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tinkoffDescription.text = State.inProgressTinkoff.description()
        self.updateUI(with: self.state)
        selectPaymentButton.addTarget(self, action: #selector(tinkoffAction(_:)), for: .touchUpInside)
        
        if let cryptogram = self.cryptogram {
            if (configuration.useDualMessagePayment) {
                self.auth(cardCryptogramPacket: cryptogram, email: self.email) { [weak self] status, canceled, transaction, errorMessage in
                    guard let self = self else {
                        return
                    }
                    if status {
                        self.updateUI(with: .succeeded(transaction))
                    } else if !canceled {
                        let apiErrorDescription = ApiError.getFullErrorDescription(code: String(transaction?.reasonCode ?? 5204))
                        self.updateUI(with: .failed(apiErrorDescription))
                    } else {
                        self.configuration.paymentUIDelegate.paymentFormWillHide()
                        self.dismiss(animated: true) { [weak self] in
                            guard let self = self else {
                                return
                            }
                            self.configuration.paymentUIDelegate.paymentFormDidHide()
                        }
                    }
                }
            } else {
                self.charge(cardCryptogramPacket: cryptogram, email: self.email) { [weak self] status, canceled, transaction, errorMessage in
                    guard let self = self else {
                        return
                    }
                    if status {
                        self.updateUI(with: .succeeded(transaction))
                    } else if !canceled {
                        let apiErrorDescription = ApiError.getFullErrorDescription(code: String(transaction?.reasonCode ?? 5204))
                        self.updateUI(with: .failed(apiErrorDescription))
                    } else {
                        self.configuration.paymentUIDelegate.paymentFormWillHide()
                        self.dismiss(animated: true) { [weak self] in
                            guard let self = self else {
                                return
                            }
                            self.configuration.paymentUIDelegate.paymentFormDidHide()
                        }
                    }
                }
            }
        }
        
        if tinkoffState { pushPayForTinkoff(state: .inProgressTinkoff) }
    }
    
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.startAnimation()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.stopAnimation()
    }
    
    private func updateUI(with state: State){
        self.state = state
        self.stopAnimation()
        

        switch state {
            
        case .inProgress:
            buttonView.isHidden = true
            errorView.isHidden = true
            tinkoffView.isHidden = true
            selectPaymentButton.superview?.isHidden = true
        case .inProgressTinkoff:
            selectPaymentButton.superview?.isHidden = false
            tinkoffView.isHidden = false
            buttonView.isHidden = true
            errorView.isHidden = true
        case .succeeded(_):
            selectPaymentButton.superview?.isHidden = true
            tinkoffView.isHidden = true
            buttonView.isHidden = false
            errorView.isHidden = true
        case .failed(_):
            selectPaymentButton.superview?.isHidden = true
            tinkoffView.isHidden = true
            buttonView.isHidden = false
        }
        
        if let message = self.state.getMessage(), message.contains("#") {
            let messages: [String] = message.components(separatedBy: "#")
            self.messageLabel.text = messages[0]
            self.secondDescriptionLabel.text = messages[1]
            self.errorView.isHidden = false
        } else {
            self.messageLabel.text = self.state.getMessage()
            self.secondDescriptionLabel.text = nil
            self.errorView.isHidden = true
        }
        
        self.progressIcon.image = self.state.getImage()
        self.actionButton.setTitle(self.state.getActionButtonTitle(), for: .normal)
        
        if case .succeeded(let transaction) = self.state {
            
            self.configuration.paymentDelegate.paymentFinished(transaction)
            self.actionButton.onAction = { [weak self] in
                self?.hide()
            }
        } else if case .failed(let errorMessage) = self.state {
            self.configuration.paymentDelegate.paymentFailed(errorMessage)
            self.actionButton.onAction = { [weak self] in
                guard let self = self else {
                    return
                }
                
                let parent = self.presentingViewController
                self.dismiss(animated: true) { [weak self] in
                    guard let self = self else {
                        return
                    }
                    if let parent = parent {
                        PaymentForm.present(with: self.configuration, from: parent)
                    }
                }
            }
        }
    }
    
    private func startAnimation(){
        self.stopAnimation()
        
        if case .inProgress = self.state {
            let animation = CABasicAnimation.init(keyPath: "transform.rotation")
            animation.toValue = NSNumber.init(value: Double.pi * 2.0)
            animation.duration = 1.0
            animation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
            animation.isCumulative = true
            animation.repeatCount = Float.greatestFiniteMagnitude
            self.progressIcon.layer.add(animation, forKey: "rotationAnimation")
        }
    }
    
    private func stopAnimation(){
        self.progressIcon.layer.removeAllAnimations()
    }
    
    override internal func makeContainerCorners(){
        let path = UIBezierPath(roundedRect: self.containerView.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.containerView.layer.mask = mask
    }
    
    private func hide(_ completion: (() -> ())? = nil) {
        self.configuration.paymentUIDelegate.paymentFormWillHide()
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            self.configuration.paymentUIDelegate.paymentFormDidHide()
            completion?()
        }
    }
}

extension PaymentProcessForm {
    func pushPayForTinkoff(state: PaymentProcessForm.State) {
        
        let publicId = configuration.publicId
        let sheme: Scheme = configuration.useDualMessagePayment ? .auth : .charge
        let invoiceID = configuration.paymentData.invoiceId
        
        let model = TinkoffPayData(publicId: publicId, amount: self.configuration.paymentData.amount,
                                   accountId: self.configuration.paymentData.accountId,
                                   invoiceId: invoiceID,
                                   browser: nil,
                                   description: self.configuration.paymentData.description,
                                   currency: self.configuration.paymentData.currency,
                                   email: self.configuration.paymentData.email,
                                   ipAddress: "123.123.123.123",
                                   os: nil,
                                   scheme: sheme.rawValue,
                                   ttlMinutes: 30,
                                   successRedirectURL: "https://cp.ru",
                                   failRedirectURL: "https://cp.ru",
                                   saveCard: isOnSaveCard)
        
        let baseURL = self.configuration.apiUrl
        
        GatewayRequest.isTinkoffQrLink(baseURL: baseURL, model: model) { value in
            let message = value?.message
            
            guard let string = value?.qrURL,  let id = value?.transactionId else {
                return
            }
            
            self.transactionId = id
            
            var status: StatusPay {
                guard let message = message, let value = StatusPay(rawValue: message) else { return .declined}
                return value
            }
            
            switch status {
            case .created, .pending:
                self.checkstatusTransactionId()
            default:
                return
            }
            
            guard let url = URL(string: string) else { return }
            guard UIApplication.shared.canOpenURL(url) else {
                let vc = SafariViewController(url: url)
                if let viewController = UIApplication.topViewController() {
                    viewController.present(vc, animated: true)
                }
                return
            }
            
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func observerPayStatus(_ notification: NSNotification) {
        guard let vc = self.presentingViewController else { return }
        
        guard let result = notification.object as? TinkoffRepsonseTransactionModel,
              let rawValue = result.model?.status,
              let status = StatusPay(rawValue: rawValue)
        else {
            if let error = notification.object as? Error {
                let code = error._code
                let string = String(code)
                let descriptionError = ApiError.getFullErrorDescription(code: string)
                presentError(descriptionError, vc: vc)
                return
            }
            
            checkstatusTransactionId()
            return
        }
        
        switch status {
        case .created, .pending:
        checkstatusTransactionId()
            
        case .authorized,.completed, .cancelled:
            transactionId = nil
            guard let vc = self.presentingViewController else { return }

            dismiss(animated: true) {
                PaymentProcessForm.present(with: self.configuration, cryptogram: nil, email: nil, state: .succeeded(Transaction()), from: vc)
            }
            
        case .declined:
            transactionId = nil
            let error = notification.object as? Error
            let code = error?._code
            let string = code == nil ? "" : String(code!)
            let descriptionError = ApiError.getFullErrorDescription(code: string)
            presentError(descriptionError, vc: vc)
        }
    }
    
    private func presentError(_ error: String, vc: UIViewController) {
        dismiss(animated: true) {
            PaymentProcessForm.present(with: self.configuration, cryptogram: nil, email: nil, state: .failed(error), from: vc)
        }
    }
    
    private func checkstatusTransactionId() {
        guard let id = transactionId else { return }
        let url = configuration.apiUrl
        let publicId = configuration.publicId
        //TinkoffStatusPayObserver
        NotificationCenter.default.addObserver(self, selector: #selector(observerPayStatus(_:)), name: NSNotification.Name(rawValue: "TinkoffStatusPayObserver"), object: nil)
        GatewayRequest.getStatusTransactionId(baseURL: url, publicId: publicId, transactionId: id)
    }
}
