//
//  CartViewController.swift
//  demo
//
//  Created by Anton Ignatov on 31/05/2019.
//  Copyright © 2019 Cloudpayments. All rights reserved.
//

import UIKit
import Cloudpayments

class CartViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var apiUrl: UITextField!
    @IBOutlet weak var publicId: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var currency: UITextField!
    @IBOutlet weak var invoiceId: UITextField!
    @IBOutlet weak var desc: UITextField!
    @IBOutlet weak var accountId: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var jsonData: UITextField!
    @IBOutlet weak var payerFirstName: UITextField!
    @IBOutlet weak var payerLastName: UITextField!
    @IBOutlet weak var payerMiddleName: UITextField!
    @IBOutlet weak var payerBirthday: UITextField!
    @IBOutlet weak var payerAddress: UITextField!
    @IBOutlet weak var payerStreet: UITextField!
    @IBOutlet weak var payerCity: UITextField!
    @IBOutlet weak var payerCountry: UITextField!
    @IBOutlet weak var payerPhone: UITextField!
    @IBOutlet weak var payerPostcode: UITextField!
    @IBOutlet weak var dualMessagePaymentSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        registerForKeyboardNotifications()
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func kbWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let kbFrameSize = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        scrollView.contentInset.bottom = kbFrameSize.height
    }
        
    @objc func kbWillHide() {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
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
        
        let payer = PaymentDataPayer(firstName: sPayerFirstName, lastName: sPayerLastName, middleName: sPayerMiddleName, birth: sPayerBirthday, address: sPayerAddress, street: sPayerStreet, city: sPayerCity, country: sPayerCountry, phone: sPayerPhone, postcode: sPayerPostcode)
                
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

        let configuration = PaymentConfiguration.init(
                            publicId: sPublicId,
                            paymentData: paymentData,
                            delegate: self,
                            uiDelegate: self,
                            scanner: nil,
                            showEmailField: true,
                            useDualMessagePayment: dualMessagePaymentSwitch.isOn,
                            disableApplePay: true,
                            disableYandexPay: false,
                            apiUrl: sApiUrl)
    
        PaymentForm.present(with: configuration, from: self)
    }
}

extension CartViewController: PaymentDelegate {
    func onPaymentFinished(_ transactionId: Int?) {
        self.navigationController?.popViewController(animated: true)
        
        if let transactionId = transactionId {
            print("finished with transactionId: \(transactionId)")
        }
    }
    
    func onPaymentFailed(_ errorMessage: String?) {
        if let error = errorMessage {
            print("finished with error: \(error)")
        }
    }
}

extension CartViewController: PaymentUIDelegate {
    func paymentFormWillDisplay() {
        print("paymentFormWillDisplay")
    }
    
    func paymentFormDidDisplay() {
        print("paymentFormDidDisplay")
    }
    
    func paymentFormWillHide() {
        print("paymentFormWillHide")
    }
    
    func paymentFormDidHide() {
        print("paymentFormDidHide")
    }
}
