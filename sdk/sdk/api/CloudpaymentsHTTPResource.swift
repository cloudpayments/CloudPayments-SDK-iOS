//
//  CloudpaymentsHTTPResource.swift
//  sdk
//
//  Created by Sergey Iskhakov on 02.07.2021.
//  Copyright © 2021 Cloudpayments. All rights reserved.
//

import Foundation

enum CloudpaymentsHTTPResource: String {
    private static let baseURLString = "https://api.cloudpayments.ru/"
    
    case charge = "payments/cards/charge"
    case auth = "payments/cards/auth"
    case post3ds = "payments/ThreeDSCallback"
    
    func asUrl() -> String {
        return CloudpaymentsHTTPResource.baseURLString.appending(self.rawValue)
    }
}
