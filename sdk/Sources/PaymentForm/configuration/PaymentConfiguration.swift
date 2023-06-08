//
//  PaymentConfiguration.swift
//  sdk
//
//  Created by Sergey Iskhakov on 08.10.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

public class PaymentConfiguration {
    let publicId: String
    let paymentData: PaymentData
    let paymentDelegate: PaymentDelegateImpl
    let paymentUIDelegate: PaymentUIDelegateImpl
    let scanner: PaymentCardScanner?
    let requireEmail: Bool
    let useDualMessagePayment: Bool
    let disableApplePay: Bool
    let disableYandexPay: Bool
    let apiUrl: String
    var changedEmail: String?
    
    
    public init(publicId: String, paymentData: PaymentData, delegate: PaymentDelegate?, uiDelegate: PaymentUIDelegate?, scanner: PaymentCardScanner?,
                requireEmail: Bool = true, useDualMessagePayment: Bool = false, disableApplePay: Bool = false,
                disableYandexPay: Bool = false, apiUrl: String = "", changedEmail: String?) {
        self.publicId = publicId
        self.paymentData = paymentData
        self.paymentDelegate = PaymentDelegateImpl.init(delegate: delegate)
        self.paymentUIDelegate = PaymentUIDelegateImpl.init(delegate: uiDelegate)
        self.scanner = scanner
        self.requireEmail = requireEmail
        self.useDualMessagePayment = useDualMessagePayment
        self.disableApplePay = disableApplePay
        self.disableYandexPay = disableYandexPay
        self.apiUrl = apiUrl
        self.changedEmail = changedEmail
    }
}
