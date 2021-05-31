//
//  BasePaymentForm.swift
//  sdk
//
//  Created by Sergey Iskhakov on 16.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation
import UIKit

public class PaymentCardForm: PaymentForm {
    @IBOutlet private weak var cardNumberTextField: TextField!
    @IBOutlet private weak var cardExpDateTextField: TextField!
    @IBOutlet private weak var cardCvcTextField: TextField!
    @IBOutlet private weak var emailTextField: TextField!
    @IBOutlet private weak var receiptButton: Button!
    @IBOutlet private weak var scanButton: Button!
    @IBOutlet private weak var closeButton: Button!
    @IBOutlet private weak var payButton: Button!
    @IBOutlet private weak var cardTypeIcon: UIImageView!
    @IBOutlet private weak var helperSafeAreaBottomView: UIView!
    
    var onPayClicked: ((_ cryptogram: String, _ email: String?) -> ())?
    
    @discardableResult
    public class func present(with configuration: PaymentConfiguration, from: UIViewController, completion: (() -> ())?) -> PaymentForm? {
        let storyboard = UIStoryboard.init(name: "PaymentForm", bundle: Bundle.mainSdk)

        guard let controller = storyboard.instantiateViewController(withIdentifier: "PaymentForm") as? PaymentForm else {
            return nil
        }
        
        controller.configuration = configuration

        controller.show(inViewController: from, completion: completion)
        
        return controller
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.receiptButton.onAction = {
            self.receiptButton.isSelected = !self.receiptButton.isSelected
            self.emailTextField.isHidden = !self.receiptButton.isSelected
            
            if !self.receiptButton.isSelected {
                self.emailTextField.text = ""
                self.emailTextField.isErrorMode = false
            }
        }
        
        self.closeButton.onAction = {
            let parent = self.presentingViewController
            self.dismiss(animated: true) {
                if let parent = parent {
                    PaymentForm.present(with: self.configuration, from: parent)
                }
            }
        }
        
        let paymentData = self.configuration.paymentData
        
        self.payButton.setTitle("Оплатить \(paymentData.amount) \(paymentData.currency.currencySign())", for: .normal)
        self.payButton.onAction = {
            if self.isValid(), let cryptogram = Card.makeCardCryptogramPacket(with: self.cardNumberTextField.text!, expDate: self.cardExpDateTextField.text!, cvv: self.cardCvcTextField.text!, merchantPublicID: paymentData.publicId) {
                self.dismiss(animated: true) {
                    self.onPayClicked?(cryptogram, self.emailTextField.text)
                }
            }
        }
        
        if self.configuration.scanner == nil {
            self.scanButton.isHidden = true
        } else {
            self.scanButton.onAction = {
                if let controller = self.configuration.scanner?.startScanner(completion: { number, month, year, cvv in
                    self.cardNumberTextField.text = number?.formattedCardNumber()
                    if let month = month, let year = year {
                        let y = year % 100
                        self.cardExpDateTextField.text = String(format: "%02d/%02d", month, y)
                    }
                    self.cardCvcTextField.text = cvv
                    
                    self.updatePaymentSystemIcon(cardNumber: number)
                }) {
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
        
        self.configureTextFields()
        self.hideKeyboardWhenTappedAround()
    }
    
    private func configureTextFields(){
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.mainTextPlaceholder]
        self.cardNumberTextField.attributedPlaceholder = NSAttributedString.init(string: "Номер карты", attributes: attributes)
        self.cardExpDateTextField.attributedPlaceholder = NSAttributedString.init(string: "ММ/ГГ", attributes: attributes)
        self.cardCvcTextField.attributedPlaceholder = NSAttributedString.init(string: "CVC", attributes: attributes)
        self.emailTextField.attributedPlaceholder = NSAttributedString.init(string: "E-mail", attributes: attributes)
        
        self.cardNumberTextField.didChange = {
            if let cardNumber = self.cardNumberTextField.text?.formattedCardNumber() {
                self.cardNumberTextField.text = cardNumber
                
                if Card.isCardNumberValid(cardNumber) {
                    self.cardExpDateTextField.becomeFirstResponder()
                    self.cardNumberTextField.isErrorMode = false
                } else {
                    let cleanCardNumber = cardNumber.clearCardNumber()
                    
                    //MAX CARD NUMBER LENGHT
                    self.cardNumberTextField.isErrorMode = cleanCardNumber.count == 19
                }
                
                self.updatePaymentSystemIcon(cardNumber: cardNumber)
            }
        }
        
        self.cardNumberTextField.didEndEditing = {
            self.validateAndErrorCardNumber()
        }
        
        self.cardExpDateTextField.didChange = {
            if let cardExp = self.cardExpDateTextField.text?.formattedCardExp() {
                self.cardExpDateTextField.text = cardExp
                
                if Card.isExpDateValid(cardExp) {
                    self.cardCvcTextField.becomeFirstResponder()
                    self.cardExpDateTextField.isErrorMode = false
                } else {
                    self.cardExpDateTextField.isErrorMode = cardExp.count == 19
                }
            }
        }
        
        self.cardExpDateTextField.didEndEditing = {
            self.validateAndErrorCardExp()
        }

        self.cardCvcTextField.didChange = {
            if let text = self.cardCvcTextField.text?.formattedCardCVV() {
                self.cardCvcTextField.text = text
                
                self.cardCvcTextField.isErrorMode = false
                if text.count == 3 {
                    self.cardCvcTextField.resignFirstResponder()
                }
            }
        }
        
        self.cardCvcTextField.didEndEditing = {
            self.validateAndErrorCardCVV()
        }
        
        self.emailTextField.didChange = {
            self.emailTextField.isErrorMode = false
        }
        
        self.cardNumberTextField.shouldReturn = {
            if let cardNumber = self.cardNumberTextField.text?.formattedCardNumber() {
                if Card.isCardNumberValid(cardNumber) {
                    self.cardExpDateTextField.becomeFirstResponder()
                }
            }
            return false
        }
        
        self.cardExpDateTextField.shouldReturn = {
            if let cardExp = self.cardExpDateTextField.text?.formattedCardExp() {
                if cardExp.count == 5 {
                    self.cardCvcTextField.becomeFirstResponder()
                }
            }
            
            return false
        }

        self.cardCvcTextField.shouldReturn = {
            if let text = self.cardCvcTextField.text?.formattedCardCVV() {
                if text.count == 3 {
                    self.cardCvcTextField.resignFirstResponder()
                }
            }
            
            return false
        }
    }
    
    private func isValid() -> Bool {
        let cardNumberIsValid = Card.isCardNumberValid(self.cardNumberTextField.text?.formattedCardNumber())
        let cardExpIsValid = Card.isExpDateValid(self.cardExpDateTextField.text?.formattedCardExp())
        let cardCvcIsValid = self.cardCvcTextField.text?.formattedCardCVV().count == 3
        let emailIsValid = !self.receiptButton.isSelected || self.emailTextField.text?.emailIsValid() == true
        
        self.validateAndErrorCardNumber()
        self.validateAndErrorCardExp()
        self.validateAndErrorCardCVV()
        self.validateAndErrorEmail()
        
        return cardNumberIsValid && cardExpIsValid && cardCvcIsValid && emailIsValid
    }
    
    private func validateAndErrorCardNumber(){
        if let cardNumber = self.cardNumberTextField.text?.formattedCardNumber() {
            self.cardNumberTextField.isErrorMode = !Card.isCardNumberValid(cardNumber)
        }
    }
    
    private func validateAndErrorCardExp(){
        if let cardExp = self.cardExpDateTextField.text?.formattedCardExp() {
            self.cardExpDateTextField.isErrorMode = !Card.isExpDateValid(cardExp)
        }
    }
    
    private func validateAndErrorCardCVV(){
        self.cardCvcTextField.isErrorMode = self.cardCvcTextField.text?.count != 3
    }
    
    private func validateAndErrorEmail(){
        self.emailTextField.isErrorMode = self.receiptButton.isSelected && self.emailTextField.text?.emailIsValid() != true
    }
    
    private func updatePaymentSystemIcon(cardNumber: String?){
        if let number = cardNumber {
            let cardType = Card.cardType(from: number)
            if cardType != .unknown {
                self.cardTypeIcon.image = cardType.getIcon()
                self.cardTypeIcon.isHidden = false
                self.scanButton.isHidden = true
            } else {
                self.cardTypeIcon.isHidden = true
                self.scanButton.isHidden = self.configuration.scanner == nil
            }
        } else {
            self.cardTypeIcon.isHidden = true
            self.scanButton.isHidden = self.configuration.scanner == nil
        }
    }
    
    @objc internal override func onKeyboardWillShow(_ notification: Notification) {
        super.onKeyboardWillShow(notification)

        self.containerBottomConstraint.constant = self.keyboardFrame.height - self.helperSafeAreaBottomView.frame.height
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    @objc internal override func onKeyboardWillHide(_ notification: Notification) {
        super.onKeyboardWillHide(notification)

        self.containerBottomConstraint.constant = 0
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

}
