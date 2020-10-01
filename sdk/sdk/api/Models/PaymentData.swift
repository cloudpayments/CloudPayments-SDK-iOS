//
//  PaymentConfiguration.swift
//  sdk
//
//  Created by Sergey Iskhakov on 22.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation

public class PaymentData {
    let publicId: String
    private (set) var amount: String = "0"
    private (set) var currency: Currency = .ruble
    private (set) var applePayMerchantId = "merchant.ru.cloudpayments"
    private (set) var scanner: PaymentCardScanner? = nil
    
    var cryptogram: String?
    
    public init(publicId: String) {
        self.publicId = publicId
    }
    
    public func setAmount(_ amount: String) -> PaymentData {
        self.amount = amount
        return self
    }
    
    public func setCurrency(_ currency: Currency) -> PaymentData {
        self.currency = currency
        return self
    }
    
    public func setApplePayMerchantId(_ applePayMerchantId: String) -> PaymentData {
        self.applePayMerchantId = applePayMerchantId
        return self
    }
    
    public func setScanner(_ scanner: PaymentCardScanner) -> PaymentData {
        self.scanner = scanner
        return self
    }
}
