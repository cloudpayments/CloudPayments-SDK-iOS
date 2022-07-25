//
//  CloudpaymentsError.swift
//  sdk
//
//  Created by Sergey Iskhakov on 25.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation

public class CloudpaymentsError: Error {
    static let defaultCardError = CloudpaymentsError.init(message: "Unable to determine bank")
    
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}
