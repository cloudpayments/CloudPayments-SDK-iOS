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
    
    private let applePayMerchantID = "merchant.ru.cloudpayments" // Ваш ID для Apple Pay
    private var supportedPaymentNetworks: [PKPaymentNetwork] {
        get {
            var arr: [PKPaymentNetwork] = [.visa, .masterCard]
            if #available(iOS 12.0, *) {
                arr.append(.maestro)
            }
            
            return arr
        }
    }
    
    var onCardOptionSelected: (() -> ())?

    @discardableResult
    public override class func present(with paymentData: PaymentData, from: UIViewController) -> PaymentForm? {
        let storyboard = UIStoryboard.init(name: "PaymentForm", bundle: Bundle.mainSdk)

        guard let controller = storyboard.instantiateViewController(withIdentifier: "PaymentOptionsForm") as? PaymentOptionsForm else {
            return nil
        }
        
        controller.paymentData = paymentData
        

        controller.show(inViewController: from)
        
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
        request.merchantIdentifier = self.applePayMerchantID
        request.supportedNetworks = self.supportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.countryCode = "RU"
        request.currencyCode = "RUB"
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
//            self.onApplePayFinish!(self.applePaymentSucceeded)
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        if let cryptogram = payment.convertToString() {
//            if let contact = payment.shippingContact {
//                self.onEmail?(contact.emailAddress ?? "")
//
//                var nameComponents = [String]()
//                if let familyName = contact.name?.familyName {
//                    nameComponents.append(familyName)
//                }
//                if let givenName = contact.name?.givenName {
//                    nameComponents.append(givenName)
//                }
//                let name = nameComponents.joined(separator: " ")
//                self.onFio?(name)
//            }
//
//            self.onApplePay?(cryptogram, { status, error in
//                var errors = [Error]()
//                if error != nil {
//                    errors.append(error!)
//                }
//
//                if status {
//                    self.applePaymentSucceeded = true
//                    completion(PKPaymentAuthorizationResult(status: .success, errors: errors))
//                } else {
//                    completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
//                }
//
//            })
        } else {
            completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: []))
        }
    }
}
