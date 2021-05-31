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
    private var resultTransaction: Transaction?
    private var errorMessage: String?
    
    var onCardOptionSelected: (() -> ())?

    @discardableResult
    public class func present(with configuration: PaymentConfiguration, from: UIViewController, completion: (() -> ())?) -> PaymentForm {
        let storyboard = UIStoryboard.init(name: "PaymentForm", bundle: Bundle.mainSdk)

        let controller = storyboard.instantiateViewController(withIdentifier: "PaymentOptionsForm") as! PaymentOptionsForm
        controller.configuration = configuration
        controller.show(inViewController: from, completion: completion)
        
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeApplePay()
    }
    
    private func initializeApplePay() {
        if let _  = self.configuration.paymentData.applePayMerchantId, PKPaymentAuthorizationViewController.canMakePayments() {
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
        errorMessage = nil
        resultTransaction = nil
        applePaymentSucceeded = false
        
        let paymentData = self.configuration.paymentData
        if let applePayMerchantId = paymentData.applePayMerchantId {
            let amount = Double(paymentData.amount) ?? 0.0
            
            let request = PKPaymentRequest()
            request.merchantIdentifier = applePayMerchantId
            request.supportedNetworks = self.supportedPaymentNetworks
            request.merchantCapabilities = PKMerchantCapability.capability3DS
            request.countryCode = "RU"
            request.currencyCode = paymentData.currency.rawValue
            
            
            let paymentSummaryItems = [PKPaymentSummaryItem(label: self.configuration.paymentData.description ?? "К оплате", amount: NSDecimalNumber.init(value: amount))]
            request.paymentSummaryItems = paymentSummaryItems
            
            if let applePayController = PKPaymentAuthorizationViewController(paymentRequest:
                    request) {
                applePayController.delegate = self
                applePayController.modalPresentationStyle = .formSheet
                self.present(applePayController, animated: true, completion: nil)
            }
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
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            if let status = self.applePaymentSucceeded {
                let state: PaymentProcessForm.State
                
                if status {
                    state = .succeeded(self.resultTransaction)
                } else {
                    state = .failed(self.errorMessage)
                }
                
                let parent = self.presentingViewController
                self.dismiss(animated: true) {
                    if parent != nil {
                        PaymentProcessForm.present(with: self.configuration, cryptogram: nil, email: nil, state: state, from: parent!, completion: nil)
                    }
                }
            }
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        if let cryptogram = payment.convertToString() {
            self.charge(cardCryptogramPacket: cryptogram, email: nil) { status, canceled, transaction, errorMessage in
                self.applePaymentSucceeded = status
                self.resultTransaction = transaction
                self.errorMessage = errorMessage
                
                if status {
                    completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                } else {
                    var errors = [Error]()
                    if let message = errorMessage {
                        let userInfo = [NSLocalizedDescriptionKey: message]
                        let error = PKPaymentError(.unknownError, userInfo: userInfo)
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
