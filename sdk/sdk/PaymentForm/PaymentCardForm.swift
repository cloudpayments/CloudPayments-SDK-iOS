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
    @IBOutlet private weak var cardNumberTextField: UnderlineTextField!
    @IBOutlet private weak var cardExpDateTextField: UnderlineTextField!
    @IBOutlet private weak var cardCvcTextField: UnderlineTextField!
    @IBOutlet private weak var emailTextField: UnderlineTextField!
    @IBOutlet private weak var receiptButton: Button!
    @IBOutlet private weak var scanButton: Button!
    @IBOutlet private weak var payButton: Button!
    @IBOutlet private weak var cardTypeIcon: UIImageView!
    @IBOutlet private weak var helperSafeAreaBottomView: UIView!
    
    var onPayClicked: ((_ cryptogram: String, _ email: String?) -> ())?
    
    @discardableResult
    public override class func present(with paymentData: PaymentData, from: UIViewController) -> PaymentForm? {
        let storyboard = UIStoryboard.init(name: "PaymentForm", bundle: Bundle.mainSdk)

        guard let controller = storyboard.instantiateViewController(withIdentifier: "PaymentForm") as? PaymentForm else {
            return nil
        }
        
        controller.paymentData = paymentData

        controller.show(inViewController: from, completion: nil)
        
        return controller
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.receiptButton.onAction = {
            self.receiptButton.isSelected = !self.receiptButton.isSelected
            self.emailTextField.isHidden = !self.receiptButton.isSelected
        }
        
        self.payButton.setTitle("Оплатить \(self.paymentData.amount) \(self.paymentData.currency.currencySign())", for: .normal)
        self.payButton.onAction = {
            if let cryptogram = Card.makeCardCryptogramPacket(with: self.cardNumberTextField.text!, expDate: self.cardExpDateTextField.text!, cvv: self.cardCvcTextField.text!, merchantPublicID: self.paymentData.publicId) {
                self.dismiss(animated: true) {
                    self.onPayClicked?(cryptogram, self.emailTextField.text)
                }
            }
        }
        
        if self.paymentData.scanner == nil {
            self.scanButton.isHidden = true
        } else {
            self.scanButton.onAction = {
                if let controller = self.paymentData.scanner?.startScanner(completion: { number, month, year, cvv in
                    self.cardNumberTextField.text = number?.formattedCardNumber()
                    if let month = month, let year = year {
                        let y = year % 100
                        self.cardExpDateTextField.text = String(format: "%02d/%02d", month, y)
                    }
                    self.cardCvcTextField.text = cvv
                    
                    self.validate()
                    
                    self.updatePaymentSystemIcon(cardNumber: number)
                }) {
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
        
        self.configureTextFields()
        self.hideKeyboardWhenTappedAround()
        self.validate()
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
                
                if cardNumber.cardNumberIsValid() {
                    self.cardExpDateTextField.becomeFirstResponder()
                }
                
                self.updatePaymentSystemIcon(cardNumber: cardNumber)
                
                self.validate()
            }
        }
        
        self.cardExpDateTextField.didChange = {
            if let cardExp = self.cardExpDateTextField.text?.formattedCardExp() {
                self.cardExpDateTextField.text = cardExp
                
                if cardExp.count == 5 {
                    self.cardCvcTextField.becomeFirstResponder()
                }
                
                self.validate()
            }
        }

        self.cardCvcTextField.didChange = {
            if let text = self.cardCvcTextField.text?.formattedCardCVV() {
                self.cardCvcTextField.text = text
                
                if text.count == 3 {
                    self.cardCvcTextField.resignFirstResponder()
                }
                
                self.validate()
            }
        }
        
        self.cardNumberTextField.shouldReturn = {
            if let cardNumber = self.cardNumberTextField.text?.formattedCardNumber() {
                if cardNumber.cardNumberIsValid() {
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
    
    private func validate() {
        let cardNumberIsValid = self.cardNumberTextField.text?.formattedCardNumber().cardNumberIsValid() == true
        let cardExpIsValid = self.cardExpDateTextField.text?.formattedCardExp().count == 5
        let cardCvcIsValid = self.cardCvcTextField.text?.formattedCardCVV().count == 3
        
        self.payButton.isEnabled = cardNumberIsValid && cardExpIsValid && cardCvcIsValid
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
                self.scanButton.isHidden = self.paymentData.scanner == nil
            }
        } else {
            self.cardTypeIcon.isHidden = true
            self.scanButton.isHidden = self.paymentData.scanner == nil
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
