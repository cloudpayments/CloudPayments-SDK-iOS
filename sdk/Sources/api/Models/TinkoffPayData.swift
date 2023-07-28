//
//  TinkoffPayData.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 19.06.2023.
//

import Foundation

enum Scheme: String, Codable {
    case charge = "0"
    case auth = "1"
}

// MARK: - TinkoffPayData
struct TinkoffPayData: Codable {
    let publicId: String?
    let amount: String?
    let accountId: String?
    let invoiceId: String?
    let browser: String?
    let description: String?
    let currency: String?
    let email, ipAddress, os: String?
    let scheme: Scheme.RawValue
    let ttlMinutes: Int?
    let successRedirectURL: String?
    let failRedirectURL: String?
    let saveCard: Bool?

    enum CodingKeys: String, CodingKey {
        case publicId = "PublicId"
        case amount = "Amount"
        case accountId = "AccountId"
        case invoiceId = "InvoiceId"
        case browser = "Browser"
        case currency = "Currency"
        case description = "Description"
        case email = "Email"
        case ipAddress = "IpAddress"
        case os = "Os"
        case scheme = "Scheme"
        case ttlMinutes = "TtlMinutes"
        case successRedirectURL = "SuccessRedirectUrl"
        case failRedirectURL = "FailRedirectUrl"
        case saveCard = "SaveCard"
    }
}

// MARK: - TinkoffResultPayData
struct TinkoffResultPayData: Codable {
    let model: TinkoffResultModel?
    let success: Bool
    let message: String?

    enum CodingKeys: String, CodingKey {
        case model = "Model"
        case success = "Success"
        case message = "Message"
    }
}

// MARK: - TinkoffResultModel
struct TinkoffResultModel: Codable {
    let qrURL: String?
    let qrImage: String?
    let transactionId: Int?
    let merchantOrderId: String?
    let amount: Int?
    let message: String?
    let isTest: Bool?

    enum CodingKeys: String, CodingKey {
        case qrURL = "QrUrl"
        case qrImage = "QrImage"
        case transactionId = "TransactionId"
        case merchantOrderId = "MerchantOrderId"
        case amount = "Amount"
        case message = "Message"
        case isTest = "IsTest"
    }
}

// MARK: - TinkoffRepsonseTransactionModel
struct TinkoffRepsonseTransactionModel: Codable {
    let success: Bool?
    let message: String?
    let model: TinkoffRepsonseStatusModel?
    
    enum CodingKeys: String, CodingKey {
        case success = "Success"
        case message = "Message"
        case model = "Model"
    }
}

// MARK: - TinkoffRepsonseStatusModel
struct TinkoffRepsonseStatusModel: Codable {
    let transactionId: Int?
    let status: StatusPay.RawValue?
    let statusCode: Int?
    let providerQrId: String?
//  let escrowAccumulationId: String?
    
    enum CodingKeys: String, CodingKey {
        case transactionId = "TransactionId"
        case status = "Status"
        case statusCode = "StatusCode"
        case providerQrId = "ProviderQrId"
        //case escrowAccumulationId = "EscrowAccumulationId"
    }
}
