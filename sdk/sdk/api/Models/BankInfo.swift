//
//  BankInfo.swift
//  sdk
//
//  Created by Sergey Iskhakov on 09.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation
import ObjectMapper

public struct BankInfo: Mappable {
    public private(set) var bankName: String?
    public private(set) var logoUrl: String?
    
    public init?(map: Map) {
        
    }
    
    public mutating func mapping(map: Map) {
        bankName <- map["BankName"]
        logoUrl <- map["LogoUrl"]
    }
}
