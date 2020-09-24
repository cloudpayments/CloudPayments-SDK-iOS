//
//  PaymentSourceForm.swift
//  sdk
//
//  Created by Sergey Iskhakov on 16.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation
import UIKit
import PassKit

class PaymentOptionsForm: PaymentForm, PKPaymentAuthorizationViewControllerDelegate {
    @IBOutlet private weak var applePayContainer: UIView!
    @IBOutlet private weak var payWithCardButton: Button!
    
    private var supportedPaymentNetworks: [PKPaymentNetwork] {
        get {
            var arr: [PKPaymentNetwork] = [.visa, .masterCard, .JCB]
            if #available(iOS 12.0, *) {
                arr.append(.maestro)
            }
            
            return arr
        }
    }
    
    private var applePaymentSucceeded: Bool?
    
    var onCardOptionSelected: (() -> ())?
    var onApplePaySelected: ((_ cryptogram: String) -> ())?

    @discardableResult
    public override class func present(with paymentData: PaymentData, from: UIViewController) -> PaymentForm? {
        let storyboard = UIStoryboard.init(name: "PaymentForm", bundle: Bundle.mainSdk)

        guard let controller = storyboard.instantiateViewController(withIdentifier: "PaymentOptionsForm") as? PaymentOptionsForm else {
            return nil
        }
        
        controller.paymentData = paymentData
        

        controller.show(inViewController: from, completion: nil)
        
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeApplePay()
    }
    
    private func initializeApplePay() {
        if PKPaymentAuthorizationViewController.canMakePayments() {
            let button: PKPaymentButton!
            if PKPaymentAuthorizationController.canMakePayments(usingNetworks: self.supportedPaymentNetworks) {
                button = PKPaymentButton.init(paymentButtonType: .plain, paymentButtonStyle: .black)
                button.addTarget(self, action: #selector(onApplePay(_:)), for: .touchUpInside)
            } else {
                button = PKPaymentButton.init(paymentButtonType: .setUp, paymentButtonStyle: .black)
                button.addTarget(self, action: #selector(onSetupApplePay(_:)), for: .touchUpInside)
            }
            button.translatesAutoresizingMaskIntoConstraints = false
            
            if #available(iOS 12.0, *) {
                button.cornerRadius = 8
            } else {
                button.layer.cornerRadius = 8
                button.layer.masksToBounds = true
            }
            
            
            self.applePayContainer.isHidden = false
            self.applePayContainer.addSubview(button)
            button.bindFrameToSuperviewBounds()
        } else {
            self.applePayContainer.isHidden = true
        }
    }
    
    @objc private func onApplePay(_ sender: UIButton) {
        let amount = Double(self.paymentData.amount) ?? 0.0
        
        let request = PKPaymentRequest()
        request.merchantIdentifier = self.paymentData.applePayMerchantId
        request.supportedNetworks = self.supportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.countryCode = "RU"
        request.currencyCode = self.paymentData.currency.rawValue
        request.paymentSummaryItems = [PKPaymentSummaryItem(label: "К оплате", amount: NSDecimalNumber.init(value: amount))]
        if let applePayController = PKPaymentAuthorizationViewController(paymentRequest:
                request) {
            applePayController.delegate = self
            applePayController.modalPresentationStyle = .formSheet
            self.present(applePayController, animated: true, completion: nil)
        }
    }
    
    @objc private func onSetupApplePay(_ sender: UIButton) {
        PKPassLibrary().openPaymentSetup()
    }
    
    @IBAction private func onCard(_ sender: UIButton) {
        self.hide {
            self.onCardOptionSelected?()
        }
    }
    
    //MARK: - PKPaymentAuthorizationViewControllerDelegate -
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) {
            if let status = self.applePaymentSucceeded {
                let state: PaymentProcessForm.State
                
                if status {
                    state = .succeeded
                } else {
                    state = .failed
                }
                
                let parent = self.presentingViewController
                self.dismiss(animated: true) {
                    if parent != nil {
                        PaymentProcessForm.present(with: self.paymentData, cryptogram: nil, email: nil, state: state, from: parent!)
                    }
                }
            }
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        if let cryptogram = payment.convertToString() {
            self.charge(cardCryptogramPacket: cryptogram, email: nil) { status, errorMessage in
                self.applePaymentSucceeded = status
                if status {
                    completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                } else {
                    var errors = [Error]()
                    if let message = errorMessage {
                        let error = CloudpaymentsError.init(message: message)
                        errors.append(error)
                    }
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: errors))
                }
            }

        } else {
            completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: []))
        }
    }
}
