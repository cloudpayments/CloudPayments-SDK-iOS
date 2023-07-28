//
//  RecurrentModel.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 10.07.2023.
//

import Foundation

// MARK: - CloudPaymentsModel
struct CloudPaymentsModel: Codable {
    let cloudPayments: CloudPayments?
}

// MARK: - CloudPayments
struct CloudPayments: Codable {
    let recurrent: Recurrent?
}

// MARK: - Recurrent
struct Recurrent: Codable {
    let interval, period: String?
    let amount: Int?
}
