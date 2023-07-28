//
//  CryptogramType.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 05.06.2023.
//

import Foundation

struct CryptogramType: Codable {
    let `Type`: String
    let CardInfo: CardInfo
    let KeyVersion: String
    let Value: String
    let Format: Int
    
    init(CardInfo: CardInfo, version: String, value: String) {
        self.`Type` = "CloudCard"
        self.CardInfo = CardInfo
        self.KeyVersion = version
        self.Value = value
        self.Format = 1
    }
}

struct CardInfo: Codable {
    let FirstSixDigits: String
    let LastFourDigits: String
    let ExpDateMonth: String
    let ExpDateYear: String
}
