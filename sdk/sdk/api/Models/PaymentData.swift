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
    let amount: String
    let currency: Currency
    
    var cryptogram: String?
    
    public init(publicId: String, amount: String, currency: Currency = .ruble) {
        self.publicId = publicId
        self.amount = amount
        self.currency = currency
    }
}
