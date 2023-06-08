//
//  CartViewController.swift
//  demo
//
//  Created by Anton Ignatov on 31/05/2019.
//  Copyright © 2019 Cloudpayments. All rights reserved.
//

import UIKit
import Cloudpayments

final class CartViewController: BaseViewController {
    // MARK: - Private properties
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var apiUrl: UITextField!
    @IBOutlet private weak var publicId: UITextField!
    @IBOutlet private weak var amount: UITextField!
    @IBOutlet private weak var currency: UITextField!
    @IBOutlet private weak var invoiceId: UITextField!
    @IBOutlet private weak var desc: UITextField!
    @IBOutlet private weak var accountId: UITextField!
    @IBOutlet private weak var email: UITextField!
    @IBOutlet private weak var jsonData: UITextField!
    @IBOutlet private weak var payerFirstName: UITextField!
    @IBOutlet private weak var payerLastName: UITextField!
    @IBOutlet private weak var payerMiddleName: UITextField!
    @IBOutlet private weak var payerBirthday: UITextField!
    @IBOutlet private weak var payerAddress: UITextField!
    @IBOutlet private weak var payerStreet: UITextField!
    @IBOutlet private weak var payerCity: UITextField!
    @IBOutlet private weak var payerCountry: UITextField!
    @IBOutlet private weak var payerPhone: UITextField!
    @IBOutlet private weak var payerPostcode: UITextField!
    @IBOutlet private weak var dualMessagePaymentSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        registerForKeyboardNotifications()
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }
        
        let bottomInset = keyboardFrame.cgRectValue.height
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        scrollView.contentInset = contentInset
    }
    
    @objc private func keyboardWillHide() {
        scrollView.contentInset = .zero
    }
    
    @IBAction func run(_ sender: Any) {
                
        let sApiUrl = apiUrl.text ?? ""        
        let sPublicId = publicId.text ?? ""
        let sAmount = amount.text ?? ""
        let sCurrency = currency.text ?? ""
        let sInvoiceId = invoiceId.text ?? ""
        let sDesc = desc.text ?? ""
        let sAccountId = accountId.text ?? ""
        let sEmail = email.text ?? ""
        let sPayerFirstName = payerFirstName.text ?? ""
        let sPayerLastName = payerLastName.text ?? ""
        let sPayerMiddleName = payerMiddleName.text ?? ""
        let sPayerBirthday = payerBirthday.text ?? ""
        let sPayerAddress = payerAddress.text ?? ""
        let sPayerStreet = payerStreet.text ?? ""
        let sPayerCity = payerCity.text ?? ""
        let sPayerCountry = payerCountry.text ?? ""
        let sPayerPhone = payerPhone.text ?? ""
        let sPayerPostcode = payerPostcode.text ?? ""
        let sJsonData = jsonData.text ?? ""
        
        let payer = PaymentDataPayer(
            firstName: sPayerFirstName,
            lastName: sPayerLastName,
            middleName: sPayerMiddleName,
            birth: sPayerBirthday,
            address: sPayerAddress,
            street: sPayerStreet,
            city: sPayerCity,
            country: sPayerCountry,
            phone: sPayerPhone,
            postcode: sPayerPostcode
        )
        
        let paymentData = PaymentData()
            .setAmount(sAmount)
            .setCurrency(sCurrency)
            .setApplePayMerchantId(Constants.applePayMerchantID)
            .setYandexPayMerchantId(Constants.yandexPayMerchantID)
            .setCardholderName("CP SDK")
            .setIpAddress("98.21.123.32")
            .setInvoiceId(sInvoiceId)
            .setDescription(sDesc)
            .setAccountId(sAccountId)
            .setPayer(payer)
            .setEmail(sEmail)
            .setJsonData(sJsonData)
        
        let configuration = PaymentConfiguration(
            publicId: sPublicId,
            paymentData: paymentData,
            delegate: self,
            uiDelegate: self,
            scanner: nil,
            requireEmail: false,
            useDualMessagePayment: dualMessagePaymentSwitch.isOn,
            disableApplePay: false,
            disableYandexPay: false,
            apiUrl: sApiUrl,
            changedEmail: nil
        )
        
        PaymentForm.present(with: configuration, from: self)
    }
}

extension CartViewController: PaymentDelegate {
    func onPaymentFinished(_ transactionId: Int?) {
        navigationController?.popViewController(animated: true)
        
        if let transactionId = transactionId {
            print("Transaction finished with ID: \(transactionId)")
        }
    }
    
    func onPaymentFailed(_ errorMessage: String?) {
        if let errorMessage = errorMessage {
            print("Transaction failed with error: \(errorMessage)")
        }
    }
}

extension CartViewController: PaymentUIDelegate {
    func paymentFormWillDisplay() {
        print("Payment form will display")
    }
    
    func paymentFormDidDisplay() {
        print("Payment form did display")
    }
    
    func paymentFormWillHide() {
        print("Payment form will hide")
    }
    
    func paymentFormDidHide() {
        print("Payment form did hide")
    }
}
