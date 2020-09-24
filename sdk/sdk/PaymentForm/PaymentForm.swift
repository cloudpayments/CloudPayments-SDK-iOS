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

public class PaymentForm: BaseViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var containerBottomConstraint: NSLayoutConstraint!
    
    lazy var network: CloudpaymentsApi = CloudpaymentsApi.init(publicId: self.paymentData.publicId)
    lazy var d3ds: ThreeDSHandler = ThreeDSHandler.init()
    lazy var customTransitionDelegateInstance = FormTransitioningDelegate(viewController: self)
    
    var threeDsCallbackId: String = ""
    var paymentData: PaymentData!
    
    @discardableResult
    public class func present(with paymentData: PaymentData, from: UIViewController) -> PaymentForm? {
        if PKPaymentAuthorizationViewController.canMakePayments() {
            if let controller = PaymentOptionsForm.present(with: paymentData, from: from) as? PaymentOptionsForm {
                controller.onCardOptionSelected = {
                    self.showCardForm(with: paymentData, from: from)
                }
                return controller
            }
        } else {
            return self.showCardForm(with: paymentData, from: from)
        }
        
        return nil
    }
    
    @discardableResult
    private class func showCardForm(with paymentData: PaymentData, from: UIViewController) -> PaymentForm? {
        guard let controller = PaymentCardForm.present(with: paymentData, from: from) as? PaymentCardForm else {
            return nil
        }
        
        controller.onPayClicked = { cryptogram in
            PaymentProcessForm.present(with: paymentData, cryptogram: cryptogram, from: from)
        }
        return controller
    }
    
    internal func show(inViewController controller: UIViewController) {
        self.transitioningDelegate = customTransitionDelegateInstance
        self.modalPresentationStyle = .custom
        controller.present(self, animated: true, completion: nil)
    }
    
    func hide(completion: (()->())?) {
        self.dismiss(animated: true) {
            completion?()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.makeContainerCorners()
    }
    
    @IBAction private func onClose(_ sender: UIButton) {
        self.hide(completion: nil)
    }
    
    internal func makeContainerCorners(){
        let path = UIBezierPath(roundedRect: self.containerView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.containerView.layer.mask = mask
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
//        DefaultPopupPresentationAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
//        DefaultPopupPresentationAnimator(forDismiss: true)
    }
}
