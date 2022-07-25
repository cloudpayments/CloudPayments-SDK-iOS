//
//  BankInfoRequest.swift
//  Cloudpayments
//
//  Created by Sergey Iskhakov on 01.07.2021.
//

import CloudpaymentsNetworking

class BankInfoRequest: BaseRequest, CloudpaymentsRequestType {
    private let firstSix: String
    init(firstSix: String) {
        self.firstSix = firstSix
    }
    typealias ResponseType = BankInfoResponse
    var data: CloudpaymentsRequest {
        return CloudpaymentsRequest(path: "https://api.cloudpayments.ru/bins/info/\(firstSix)", method: .get)
    }
}
