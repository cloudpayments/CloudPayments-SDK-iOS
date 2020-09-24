//
//  PaymentProgressForm.swift
//  sdk
//
//  Created by Sergey Iskhakov on 24.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class PaymentProcessForm: PaymentForm {
    enum State {
        case inProgress
        case succeeded
        case failed
        
        func getImage() -> UIImage? {
            switch self {
            case .inProgress:
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
                return "Оплата выполняется..."
            case .succeeded:
                return "Оплата завершена"
            case .failed:
                return "Произошла ошибка!"
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
    }
    
    @IBOutlet private weak var progressIcon: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var actionButton: Button!
    @IBOutlet private weak var threeDsContainerView: UIView?
    
    private var state: State = .inProgress {
        didSet {
            updateUI()
        }
    }
    
    private var cryptogram: String!
    
    @discardableResult
    public class func present(with paymentData: PaymentData, cryptogram: String, from: UIViewController) -> PaymentForm? {
        let storyboard = UIStoryboard.init(name: "PaymentForm", bundle: Bundle.mainSdk)

        guard let controller = storyboard.instantiateViewController(withIdentifier: "PaymentProcessForm") as? PaymentProcessForm else {
            return nil
        }
        
        controller.paymentData = paymentData
        controller.cryptogram = cryptogram

        controller.show(inViewController: from)
        
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.threeDsContainerView?.isHidden = true
        self.updateUI()
        self.charge(cardCryptogramPacket: self.cryptogram, cardHolderName: "")
    }
    
    private func updateUI(){
        self.progressIcon.image = self.state.getImage()
        self.messageLabel.text = self.state.getMessage()
        self.actionButton.isHidden = self.state == .inProgress
        self.actionButton.setTitle(self.state.getActionButtonTitle(), for: .normal)
        
        if self.state == .succeeded {
            self.actionButton.onAction = {
                self.dismiss(animated: true, completion: nil)
            }
        } else if state == .failed {
            self.actionButton.onAction = {
                let parent = self.presentingViewController
                self.dismiss(animated: true) {
                    if let parent = parent {
                        PaymentForm.present(with: self.paymentData, from: parent)
                    }
                }
            }
        }
    }
    
    override internal func makeContainerCorners(){
        let path = UIBezierPath(roundedRect: self.containerView.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.containerView.layer.mask = mask
    }
    
    private func charge(cardCryptogramPacket: String, cardHolderName: String) {
        network.charge(cardCryptogramPacket: cardCryptogramPacket, cardHolderName: cardHolderName, amount: self.paymentData.amount, currency: self.paymentData.currency) { [weak self] response, error in
            if let response = response {
                self?.checkTransactionResponse(transactionResponse: response)
            } else if let error = error {
                self?.showAlert(title: .errorWord, message: error.localizedDescription)
            }
        }
    }
    
    private func auth(cardCryptogramPacket: String, cardHolderName: String) {
        network.auth(cardCryptogramPacket: cardCryptogramPacket, cardHolderName: cardHolderName, amount: self.paymentData.amount, currency: self.paymentData.currency) { [weak self] response, error in
            if let response = response {
                self?.checkTransactionResponse(transactionResponse: response)
            } else if let error = error {
                self?.onPaymentFailed(with: error.localizedDescription)
            }
        }
    }
    
    // Проверяем необходимо ли подтверждение с использованием 3DS
    private func checkTransactionResponse(transactionResponse: TransactionResponse) {
        if (transactionResponse.success) {
            self.onPaymentSucceeded()
        } else {
            if (!transactionResponse.message.isEmpty) {
                self.onPaymentFailed(with: transactionResponse.message)
            } else if (transactionResponse.transaction?.paReq != nil && transactionResponse.transaction?.acsUrl != nil) {
                self.threeDsCallbackId = transactionResponse.transaction?.threeDsCallbackId ?? ""
                
                let transactionId = String(describing: transactionResponse.transaction?.transactionId ?? 0)
                
                let paReq = transactionResponse.transaction!.paReq
                let acsUrl = transactionResponse.transaction!.acsUrl
                               
                // Показываем 3DS форму
                
                d3ds.make3DSPayment(with: self, acsUrl: acsUrl, paReq: paReq, transactionId: transactionId)
            } else {
                self.onPaymentFailed(with: transactionResponse.transaction?.cardHolderMessage)
            }
        }
    }
    
    func post3ds(transactionId: String, paRes: String) {
        
        network.post3ds(transactionId: transactionId, threeDsCallbackId: self.threeDsCallbackId, paRes: paRes) {[weak self] result in
            
            if result.success {
                self?.onPaymentSucceeded()
            } else {
                self?.onPaymentFailed(with: result.cardHolderMessage)
            }
        }
    }
    
    func onPaymentSucceeded(){
        self.state = .succeeded
    }
    
    func onPaymentFailed(with message: String?) {
        self.state = .failed
    }
}

extension PaymentProcessForm: D3DSDelegate {
    public func onAuthotizationCompleted(with md: String, paRes: String) {
        if let container = self.threeDsContainerView {
            UIView.animate(withDuration: 0.25) {
                container.alpha = 0
            } completion: { [weak self] (status) in
                container.isHidden = true
                container.subviews.forEach { $0.removeFromSuperview()}
                
                self?.post3ds(transactionId: md, paRes: paRes)
            }
        }
    }
    
    public func onAuthorizationFailed(with html: String) {
        self.showAlert(title: .errorWord, message: html)
        self.state = .failed
        print("error: \(html)")
    }
    
    public func willPresentWebView(_ webView: WKWebView) {
        if let container = self.threeDsContainerView {
            container.addSubview(webView)
            webView.bindFrameToSuperviewBounds()
            
            container.alpha = 0
            container.isHidden = false
            UIView.animate(withDuration: 0.25) {
                container.alpha = 1
            }
        }
    }
}

