//
//  PaymentConfiguration.swift
//  sdk
//
//  Created by Sergey Iskhakov on 08.10.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation

public class PaymentConfiguration {
    let publicId: String
    let paymentData: PaymentData
    let paymentDelegate: PaymentDelegateImpl
    let paymentUIDelegate: PaymentUIDelegateImpl
    let scanner: PaymentCardScanner?
    let showEmailField: Bool
    let useDualMessagePayment: Bool
    let disableApplePay: Bool
    let disableYandexPay: Bool
    let apiUrl: String
    
    
    public init(publicId: String, paymentData: PaymentData, delegate: PaymentDelegate?, uiDelegate: PaymentUIDelegate?, scanner: PaymentCardScanner?,
                showEmailField: Bool = false, useDualMessagePayment: Bool = false, disableApplePay: Bool = false,
disableYandexPay: Bool = false, apiUrl: String = "") {
        self.publicId = publicId
        self.paymentData = paymentData
        self.paymentDelegate = PaymentDelegateImpl.init(delegate: delegate)
        self.paymentUIDelegate = PaymentUIDelegateImpl.init(delegate: uiDelegate)
        self.scanner = scanner
        self.showEmailField = showEmailField
        self.useDualMessagePayment = useDualMessagePayment
        self.disableApplePay = disableApplePay
        self.disableYandexPay = disableYandexPay
        self.apiUrl = apiUrl
    }
}
