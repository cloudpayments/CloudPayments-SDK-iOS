//
//  Transaction.swift
//  sdk
//
//  Created by Cloudpayments on 02/06/2021.
//  Copyright © 2021 Cloudpayments. All rights reserved.
//

public struct Transaction: Codable {
    public private(set) var transactionId: Int?
    public private(set) var amount: Double?
    public private(set) var currency: String?
    public private(set) var currencyCode: Int?
    public private(set) var invoiceId: String?
    public private(set) var accountId: String?
    public private(set) var email: String?
    public private(set) var description: String?
    public private(set) var authCode: String?
    public private(set) var testMode: Bool?
    public private(set) var ipAddress: String?
    public private(set) var ipCountry: String?
    public private(set) var ipCity: String?
    public private(set) var ipRegion: String?
    public private(set) var ipDistrict: String?
    public private(set) var ipLatitude: Double?
    public private(set) var ipLongitude: Double?
    public private(set) var cardFirstSix: String?
    public private(set) var cardLastFour: String?
    public private(set) var cardExpDate: String?
    public private(set) var cardType: String?
    public private(set) var cardTypeCode: Int?
    public private(set) var issuer: String?
    public private(set) var issuerBankCountry: String?
    public private(set) var status: String?
    public private(set) var statusCode: Int?
    public private(set) var reason: String?
    public private(set) var reasonCode: Int?
    public private(set) var cardHolderMessage: String?
    public private(set) var name: String?
    public private(set) var paReq: String?
    public private(set) var acsUrl: String?
    public private(set) var threeDsCallbackId: String?
}
