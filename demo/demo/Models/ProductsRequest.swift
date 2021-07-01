//
//  ProductsRequest.swift
//  demo
//
//  Created by Sergey Iskhakov on 01.07.2021.
//  Copyright © 2021 Cloudpayments. All rights reserved.
//

import Foundation
import Cloudpayments
import CloudpaymentsNetworking

class ProductsRequest: BaseRequest, CloudpaymentsRequestType {
    typealias ResponseType = [Product]
    var data: CloudpaymentsRequest {
        return CloudpaymentsRequest(path: "https://wp-demo.cloudpayments.ru/index.php/wp-json/wc/v3/products", method: .get, headers: getHeaders())
    }
    
    private func getHeaders() -> [String: String] {
        let userName = "ck_ddb320b48b89a170248545eb3bb8e822365aa917"
        let password = "cs_35ad6d0cf8e6b149e66968efdad87112ca2bc2d3"
        let credentialData = "\(userName):\(password)".data(using: .utf8)
        guard let cred = credentialData else { return ["" : ""] }
        let base64Credentials = cred.base64EncodedData(options: [])
        guard let base64Date = Data(base64Encoded: base64Credentials) else { return ["" : ""] }
        return ["Authorization": "Basic \(base64Date.base64EncodedString())"]
    }
}
