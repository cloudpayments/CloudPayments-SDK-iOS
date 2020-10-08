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
    let scanner: PaymentCardScanner?
    
    public init(paymentData: PaymentData, delegate: PaymentDelegate?, scanner: PaymentCardScanner?) {
        self.paymentData = paymentData
        self.paymentDelegate = PaymentDelegateImpl.init(delegate: delegate)
        self.scanner = scanner
    }
}
