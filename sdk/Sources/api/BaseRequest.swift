//
//  BaseRequest.swift
//  Cloudpayments
//
//  Created by Sergey Iskhakov on 01.07.2021.
//

import Foundation

open class BaseRequest {
    var params: [String: Any?]
    var headers: [String: String]
    var apiUrl: String
    
    public init(params: [String: Any?] = [:],
                headers: [String: String] = [:],
                apiUrl: String = "") {
        self.params = params
        self.headers = headers
        self.apiUrl = apiUrl
    }
}
