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

public class PaymentProcessForm: PaymentForm {
    public enum State {
        case inProgress
        case succeeded(Transaction?)
        case failed(String?)
        
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
            case .failed(let message):
                return message ?? "Произошла ошибка!"
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
    
    private var state: State = .inProgress
    private var cryptogram: String?
    private var email: String?
    
    @discardableResult
    public class func present(with configuration: PaymentConfiguration, cryptogram: String?, email: String?, state: State = .inProgress, from: UIViewController, completion: (() -> ())?) -> PaymentForm? {
        let storyboard = UIStoryboard.init(name: "PaymentForm", bundle: Bundle.mainSdk)

        let controller = storyboard.instantiateViewController(withIdentifier: "PaymentProcessForm") as! PaymentProcessForm        
        controller.configuration = configuration
        controller.cryptogram = cryptogram
        controller.email = email
        controller.state = state
        
        controller.show(inViewController: from, completion: completion)
        
        return controller
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateUI(with: self.state)
        
        if let cryptogram = self.cryptogram {
            self.charge(cardCryptogramPacket: cryptogram, email: self.email) { status, canceled, transaction, errorMessage in
                if status {
                    self.updateUI(with: .succeeded(transaction))
                } else if !canceled {
                    self.updateUI(with: .failed(errorMessage))
                } else {
                    self.configuration.paymentUIDelegate.paymentFormWillHide()
                    self.dismiss(animated: true) {
                        self.configuration.paymentUIDelegate.paymentFormDidHide()
                    }
                }
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.startAnimation()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.stopAnimation()
    }
    
    private func updateUI(with state: State){
        self.state = state
        self.stopAnimation()
        
        self.progressIcon.image = self.state.getImage()
        self.messageLabel.text = self.state.getMessage()
        self.actionButton.setTitle(self.state.getActionButtonTitle(), for: .normal)
        
        if case .inProgress = self.state {
            self.actionButton.isHidden = true
        } else {
            self.actionButton.isHidden = false
        }
        
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
                self.dismiss(animated: true) {
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
        self.dismiss(animated: true) {
            self.configuration.paymentUIDelegate.paymentFormDidHide()
            completion?()
        }
    }
}

