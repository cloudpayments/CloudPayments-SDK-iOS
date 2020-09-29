//
//  BankInfoResponse.swift
//  sdk
//
//  Created by Sergey Iskhakov on 29.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation
import ObjectMapper

public struct BankInfoResponse: Mappable {
    public private(set) var success: Bool?
    public private(set) var message: String?
    public private(set) var bankInfo: BankInfo?
    
    public init?(map: Map) {
        
    }
    
    public mutating func mapping(map: Map) {
        success <- map["Success"]
        message <- map["Message"]
        bankInfo <- map["Model"]
    }
}
