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
    private (set) var applePayMerchantId: String?
    private (set) var cardholderName: String?
    private (set) var description: String?
    private (set) var accountId: String?
    private (set) var invoiceId: String?
    private (set) var ipAddress: String?
    private (set) var cultureName: String?
    private (set) var payer: String?
    private (set) var jsonData: String?
    
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
    
    public func setCardholderName(_ cardholderName: String?) -> PaymentData {
        self.cardholderName = cardholderName
        return self
    }
    
    public func setDescription(_ description: String?) -> PaymentData {
        self.description = description
        return self
    }
    
    public func setAccountId(_ accountId: String?) -> PaymentData {
        self.accountId = accountId
        return self
    }
    
    public func setInvoiceId(_ invoiceId: String?) -> PaymentData {
        self.invoiceId = invoiceId
        return self
    }
    
    public func setIpAddress(_ ipAddress: String?) -> PaymentData {
        self.ipAddress = ipAddress
        return self
    }
    
    public func setCultureName(_ cultureName: String?) -> PaymentData {
        self.cultureName = cultureName
        return self
    }
    
    public func setPayer(_ payer: String?) -> PaymentData {
        self.payer = payer
        return self
    }
    
    public func setJsonData(_ jsonData: [String: Any]) -> PaymentData {
        if let data = try? JSONSerialization.data(withJSONObject: jsonData, options: .sortedKeys) {
            let jsonString = String(data: data, encoding: .utf8)
            self.jsonData = jsonString
        }
        
        return self
    }
}
