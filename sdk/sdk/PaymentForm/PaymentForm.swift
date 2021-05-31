//
//  PaymentForm.swift
//  sdk
//
//  Created by Sergey Iskhakov on 16.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation
import UIKit
import PassKit
import WebKit

typealias PaymentCallback = (_ status: Bool, _ canceled: Bool, _ trasaction: Transaction?, _ errorMessage: String?) -> ()

public class PaymentForm: BaseViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var containerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var threeDsCloseButton: Button?
    @IBOutlet weak var threeDsFormView: UIView?
    @IBOutlet weak var threeDsContainerView: UIView?
    
    var configuration: PaymentConfiguration!
    
    lazy var network: CloudpaymentsApi = CloudpaymentsApi.init(publicId: self.configuration.paymentData.publicId, source: .cpForm)
    lazy var customTransitionDelegateInstance = FormTransitioningDelegate(viewController: self)
    
    private lazy var threeDsProcessor: ThreeDsProcessor = ThreeDsProcessor.init()
    private var threeDsCallbackId: String = ""
    
    private var threeDsCompletion: PaymentCallback?
    private var transaction: Transaction?
    
    @discardableResult
    public class func present(with configuration: PaymentConfiguration, from: UIViewController) -> PaymentForm? {
        let completion = {
            configuration.paymentUIDelegate.paymentFormDidDisplay()
        }
        configuration.paymentUIDelegate.paymentFormWillDisplay()
        
        if PKPaymentAuthorizationViewController.canMakePayments() {
            let controller = PaymentOptionsForm.present(with: configuration, from: from, completion: completion) as! PaymentOptionsForm
            controller.onCardOptionSelected = {
                self.showCardForm(with: configuration, from: from, completion: nil)
            }
            return controller
        } else {
            return self.showCardForm(with: configuration, from: from, completion: completion)
        }
    }
    
    @discardableResult
    private class func showCardForm(with configuration: PaymentConfiguration, from: UIViewController, completion: (() -> ())?) -> PaymentForm {
        let controller = PaymentCardForm.present(with: configuration, from: from, completion: completion) as! PaymentCardForm
        controller.onPayClicked = { cryptogram, email in
            PaymentProcessForm.present(with: configuration, cryptogram: cryptogram, email: email, from: from, completion: nil)
        }
        return controller
    }
    
    internal func show(inViewController controller: UIViewController, completion: (() -> ())?) {
        self.transitioningDelegate = customTransitionDelegateInstance
        self.modalPresentationStyle = .custom
        controller.present(self, animated: true, completion: completion)
    }
    
    func hide(completion: (()->())?) {
        self.dismiss(animated: true) {
            completion?()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.threeDsCloseButton?.onAction = {
            self.closeThreeDs {
                self.threeDsCompletion?(false, true, nil, nil)
            }
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.makeContainerCorners()
    }
    
    @IBAction private func onClose(_ sender: UIButton) {
        self.configuration.paymentUIDelegate.paymentFormWillHide()
        self.hide {
            self.configuration.paymentUIDelegate.paymentFormDidHide()
        }
    }
    
    internal func makeContainerCorners(){
        let path = UIBezierPath(roundedRect: self.containerView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.containerView.layer.mask = mask
    }
    
    internal func charge(cardCryptogramPacket: String, email: String?, completion: PaymentCallback?) {
        network.charge(cardCryptogramPacket: cardCryptogramPacket,
                       email: email,
                       paymentData: self.configuration.paymentData) { [weak self] response, error in
            if let response = response {
                self?.checkTransactionResponse(transactionResponse: response, completion: completion)
            } else if let error = error {
                completion?(false, false, nil, error.localizedDescription)
            }
        }
    }
    
    internal func auth(cardCryptogramPacket: String, email: String?, completion: PaymentCallback?) {
        network.auth(cardCryptogramPacket: cardCryptogramPacket,
                     email: email,
                     paymentData: self.configuration.paymentData) { [weak self] response, error in
            if let response = response {
                self?.checkTransactionResponse(transactionResponse: response, completion: completion)
            } else if let error = error {
                completion?(false, false, nil, error.localizedDescription)
            }
        }
    }
    
    // Проверяем необходимо ли подтверждение с использованием 3DS
    internal func checkTransactionResponse(transactionResponse: TransactionResponse, completion: PaymentCallback?) {
        self.threeDsCompletion = nil
        self.transaction = nil
        
        if (transactionResponse.success) {
            completion?(true, false, transactionResponse.transaction, nil)
        } else {
            if (!transactionResponse.message.isEmpty) {
                completion?(false, false, transactionResponse.transaction, transactionResponse.message)
            } else if let paReq = transactionResponse.transaction?.paReq, !paReq.isEmpty, let acsUrl = transactionResponse.transaction?.acsUrl, !acsUrl.isEmpty {
                self.threeDsCallbackId = transactionResponse.transaction?.threeDsCallbackId ?? ""
                
                let transactionId = String(transactionResponse.transaction?.transactionId ?? 0)
                
                let paReq = transactionResponse.transaction!.paReq
                let acsUrl = transactionResponse.transaction!.acsUrl
                               
                // Показываем 3DS форму
                
                let threeDsData = ThreeDsData.init(transactionId: transactionId, paReq: paReq, acsUrl: acsUrl)
                threeDsProcessor.make3DSPayment(with: threeDsData, delegate: self)
                
                self.threeDsCompletion = completion
                self.transaction = transactionResponse.transaction
            } else {
                completion?(false, false, transactionResponse.transaction, transactionResponse.transaction?.cardHolderMessage)
            }
        }
    }
    
    internal func post3ds(transactionId: String, paRes: String, completion: @escaping ((_ response: ThreeDsResponse) -> ())) {
        network.post3ds(transactionId: transactionId, threeDsCallbackId: self.threeDsCallbackId, paRes: paRes, completion: completion)
    }

    private func closeThreeDs(completion: (() -> ())?) {
        if let form = self.threeDsFormView {
            UIView.animate(withDuration: 0.25) {
                form.alpha = 0
            } completion: { [weak self] (status) in
                form.isHidden = true
                if let container = self?.threeDsContainerView {
                    container.subviews.forEach { $0.removeFromSuperview()}
                }

                completion?()
            }
        } else {
            completion?()
        }
    }
    
    
}

extension PaymentForm: ThreeDsDelegate {
    public func onAuthorizationCompleted(with md: String, paRes: String) {
        self.closeThreeDs { [weak self] in
            guard let self = self else {
                return
            }
            self.post3ds(transactionId: md, paRes: paRes) { [weak self] response in
                guard let self = self else {
                    return
                }
                self.threeDsCompletion?(response.success, false, self.transaction, response.cardHolderMessage)
            }
        }
    }

    public func onAuthorizationFailed(with html: String) {
        self.threeDsCompletion?(false, false, nil, html)
        print("error: \(html)")
    }

    public func willPresentWebView(_ webView: WKWebView) {
        if let container = self.threeDsContainerView {
            container.addSubview(webView)
            webView.bindFrameToSuperviewBounds()
            
            if let form = self.threeDsFormView {
                form.alpha = 0
                form.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    form.alpha = 1
                }
            }
        }
    }
}

class FormTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    weak var formController: PaymentForm!

    init(viewController: PaymentForm) {
        self.formController = viewController
        super.init()
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return FormPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}
