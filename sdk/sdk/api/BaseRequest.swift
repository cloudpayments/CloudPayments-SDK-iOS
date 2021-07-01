//
//  BaseRequest.swift
//  Cloudpayments
//
//  Created by Sergey Iskhakov on 01.07.2021.
//

import Foundation

open class BaseRequest {
    var params: [String: Any?]?
    var headers: [String: String]?
    
    public init(params: [String: Any?]? = nil,
         headers: [String: String]? = nil) {
        self.params = params
        self.headers = headers
    }
}
