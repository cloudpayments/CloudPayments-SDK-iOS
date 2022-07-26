//
//  PKPayment+Convert.swift
//  Cloudpayments-SDK
//
//  Created by Sergey Iskhakov on 08.09.2020.
//  Copyright © 2020 cloudpayments. All rights reserved.
//

import Foundation
import PassKit

extension PKPayment {
    public func convertToString() -> String? {
        let paymentDataDictionary = try? JSONSerialization.jsonObject(with: self.token.paymentData, options: .mutableContainers)
        
        let paymentType: String
        switch self.token.paymentMethod.type {
        case .debit:
            paymentType = "debit"
        case .credit:
            paymentType = "credit"
        case .store:
            paymentType = "store"
        case .prepaid:
            paymentType = "prepaid"
        default:
            paymentType = "unknown"
        }
        
        let paymentMethodDictionary: [String: Any?] = [
            "network"       : self.token.paymentMethod.network,
            "type"          : paymentType,
            "displayName"   : self.token.paymentMethod.displayName
        ]
        
        let cryptogramDictionary: [String: Any?] = [
            "paymentData": paymentDataDictionary,
            "transactionIdentifier": self.token.transactionIdentifier,
            "paymentMethod": paymentMethodDictionary
        ]
        
        guard let cardCryptogramPacketData = try? JSONSerialization.data(withJSONObject: cryptogramDictionary) else {
            return nil
        }
        
        let cardCryptogramPacketString = String.init(data: cardCryptogramPacketData, encoding: .utf8)
        return cardCryptogramPacketString
    }
}
