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
    
    private var state: State = .inProgress
    private var cryptogram: String?
    private var email: String?
    
    @discardableResult
    public class func present(with paymentData: PaymentData, cryptogram: String?, email: String?, state: State = .inProgress, from: UIViewController) -> PaymentForm? {
        let storyboard = UIStoryboard.init(name: "PaymentForm", bundle: Bundle.mainSdk)

        guard let controller = storyboard.instantiateViewController(withIdentifier: "PaymentProcessForm") as? PaymentProcessForm else {
            return nil
        }
        
        controller.paymentData = paymentData
        controller.cryptogram = cryptogram
        controller.email = email
        controller.state = state
        
        controller.show(inViewController: from, completion: nil)
        
        return controller
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateUI(with: self.state)
        
        if let cryptogram = self.cryptogram {
            self.charge(cardCryptogramPacket: cryptogram, email: self.email) { status, errorMessage in
                if status {
                    self.updateUI(with: .succeeded)
                } else {
                    self.updateUI(with: .failed)
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
        self.actionButton.isHidden = self.state == .inProgress
        self.actionButton.setTitle(self.state.getActionButtonTitle(), for: .normal)
        
        if self.state == .succeeded {
            self.actionButton.onAction = {
                self.dismiss(animated: true, completion: nil)
            }
        } else if self.state == .failed {
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
    
    private func startAnimation(){
        self.stopAnimation()
        
        if self.state == .inProgress {
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
}

