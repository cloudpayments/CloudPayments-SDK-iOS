//
//  PaymentConfiguration.swift
//  sdk
//
//  Created by Sergey Iskhakov on 08.10.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation

public class PaymentConfiguration {
    let paymentData: PaymentData
    let paymentDelegate: PaymentDelegateImpl
    let paymentUIDelegate: PaymentUIDelegateImpl
    let scanner: PaymentCardScanner?
    let showEmailField: Bool
    let email: String
    let useDualMessagePayment: Bool
    let disableApplePay: Bool
    let disableYandexPay: Bool
    
    public init(paymentData: PaymentData, delegate: PaymentDelegate?, uiDelegate: PaymentUIDelegate?, scanner: PaymentCardScanner?,
                showEmailField: Bool = false, email: String = "", useDualMessagePayment: Bool = false, disableApplePay: Bool = false,
                disableYandexPay: Bool = false) {
        
        self.paymentData = paymentData
        self.paymentDelegate = PaymentDelegateImpl.init(delegate: delegate)
        self.paymentUIDelegate = PaymentUIDelegateImpl.init(delegate: uiDelegate)
        self.scanner = scanner
        self.showEmailField = showEmailField
        self.email = email
        self.useDualMessagePayment = useDualMessagePayment
        self.disableApplePay = disableApplePay
        self.disableYandexPay = disableYandexPay
    }
}
