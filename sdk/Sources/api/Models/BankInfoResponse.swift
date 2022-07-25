//
//  BankInfoResponse.swift
//  sdk
//
//  Created by Sergey Iskhakov on 29.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

public struct BankInfoResponse: Codable {
    public private(set) var success: Bool?
    public private(set) var message: String?
    public private(set) var model: BankInfo?
}
