//
//  Card.swift
//  Cloudpayments-SDK
//
//  Created by Sergey Iskhakov on 08.09.2020.
//  Copyright © 2020 cloudpayments. All rights reserved.
//

import Foundation
import UIKit

public enum CardType: String {
    case unknown = "Unknown"
    case visa = "Visa"
    case masterCard = "MasterCard"
    case maestro = "Maestro"
    case mir = "MIR"
    case jcb = "JCB"
    case americanExpress = "AmericanExpress"
    case troy = "Troy"
    
    public func toString() -> String {
        return self.rawValue
    }
    
    public func getIcon() -> UIImage? {
        let iconName: String?
        switch self {
        case .visa:
            iconName = "ic_visa"
        case .masterCard:
            iconName = "ic_master_card"
        case .maestro:
            iconName = "ic_maestro"
        case .mir:
            iconName = "ic_mir"
        case .jcb:
            iconName = "ic_jcb"
        case .americanExpress:
            iconName = "ic_american_express"
        case .troy:
            iconName = "ic_troy"
        default:
            iconName = nil
        }
        
        guard iconName != nil else {
            return nil
        }
        
        return UIImage.named(iconName!)
    }
}

public struct Card {
    private static let publicKey = "-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArBZ1NNjvszen6BNWsgyDUJvDUZDtvR4jKNQtEwW1iW7hqJr0TdD8hgTxw3DfH+Hi/7ZjSNdH5EfChvgVW9wtTxrvUXCOyJndReq7qNMo94lHpoSIVW82dp4rcDB4kU+q+ekh5rj9Oj6EReCTuXr3foLLBVpH0/z1vtgcCfQzsLlGkSTwgLqASTUsuzfI8viVUbxE1a+600hN0uBh/CYKoMnCp/EhxV8g7eUmNsWjZyiUrV8AA/5DgZUCB+jqGQT/Dhc8e21tAkQ3qan/jQ5i/QYocA/4jW3WQAldMLj0PA36kINEbuDKq8qRh25v+k4qyjb7Xp4W2DywmNtG3Q20MQIDAQAB-----END PUBLIC KEY-----"
    private static let publicKeyVersion = "04"
    
    public static func isCardNumberValid(_ cardNumber: String?) -> Bool {
        guard let cardNumber = cardNumber else {
            return false
        }
        let number = cardNumber.onlyNumbers()
        guard number.count >= 14 && number.count <= 19 else {
            return false
        }
        
        var digits = number.map { Int(String($0))! }
        stride(from: digits.count - 2, through: 0, by: -2).forEach { i in
            var value = digits[i] * 2
            if value > 9 {
                value = value % 10 + 1
            }
            digits[i] = value
        }
        
        let sum = digits.reduce(0, +)
        return sum % 10 == 0
    }

    public static func isExpDateValid(_ expDate: String?) -> Bool {
        guard let expDate = expDate else {
            return false
        }
        guard expDate.count == 5 else {
            return false
        }
        


        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"

        guard let date = dateFormatter.date(from: expDate) else {
            return false
        }

        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.current

        let dayRange = calendar.range(of: .day, in: .month, for: date)
        var comps = calendar.dateComponents([.year, .month, .day], from: date)
        comps.day = dayRange?.count ?? 1
        comps.hour = 24
        comps.minute = 0
        comps.second = 0

        guard let aNewDate = calendar.date(from: comps) else {
            return false
        }

        guard aNewDate.compare(Date()) == .orderedDescending else {
            return false
        }

        return true
    }
    
    public static func cardType(from cardNumber: String) -> CardType {
        let cleanCardNumber = self.cleanCreditCardNo(cardNumber)
        
        guard cleanCardNumber.count > 0 else {
            return .unknown
        }
        
        let first = String(cleanCardNumber.first!)
        
        guard first != "4" else {
            return .visa
        }
        
        guard first != "6" else {
            return .maestro
        }
        
        guard cleanCardNumber.count >= 2 else {
            return .unknown
        }
        
        let indexTwo = cleanCardNumber.index(cleanCardNumber.startIndex, offsetBy: 2)
        let firstTwo = String(cleanCardNumber[..<indexTwo])
        let firstTwoNum = Int(firstTwo) ?? 0
        
        if firstTwoNum == 35 {
            return .jcb
        } else if firstTwoNum == 34 || firstTwoNum == 37 {
            return .americanExpress
        } else if firstTwoNum == 50 || (firstTwoNum >= 56 && firstTwoNum <= 69) {
            return .maestro
        } else if (firstTwoNum >= 51 && firstTwoNum <= 55) {
            return .masterCard
        }
        
        guard cleanCardNumber.count >= 4 else {
            return .unknown
        }
        
        let indexFour = cleanCardNumber.index(cleanCardNumber.startIndex, offsetBy: 4)
        let firstFour = String(cleanCardNumber[..<indexFour])
        let firstFourNum = Int(firstFour) ?? 0
        
        if firstFourNum >= 2200 && firstFourNum <= 2204 {
            return .mir
        }
        
        if firstFourNum >= 2221 && firstFourNum <= 2720 {
            return .masterCard
        }
        
        guard cleanCardNumber.count >= 6 else {
            return .unknown
        }
        
        let indexSix = cleanCardNumber.index(cleanCardNumber.startIndex, offsetBy: 6)
        let firstSix = String(cleanCardNumber[..<indexSix])
        let firstSixNum = Int(firstSix) ?? 0

        if firstSixNum >= 979200 && firstSixNum <= 979289 {
            return .troy
        }
        
        return .unknown
    }
    
    public static func makeCardCryptogramPacket(with cardNumber: String, expDate: String, cvv: String, merchantPublicID: String) -> String? {
        guard self.isCardNumberValid(cardNumber) else {
            return nil
        }
        guard self.isExpDateValid(expDate) else {
            return nil
        }
        
        let cardDateComponents = expDate.components(separatedBy: "/")
        let cardDateString = "\(cardDateComponents[1])\(cardDateComponents[0])"
        
        let cleanCardNumber = self.cleanCreditCardNo(cardNumber)
        let decryptedCryptogram = String.init(format: "%@@%@@%@@%@", cleanCardNumber, cardDateString, cvv, merchantPublicID)
        
        guard let cryptogramData = try? RSAUtils.encryptWithRSAPublicKey(str: decryptedCryptogram, pubkeyBase64: self.publicKey) else {
            return nil
        }
        let cryptogramString = RSAUtils.base64Encode(cryptogramData)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        
        var packetString = "01"
        let startIndex = cleanCardNumber.index(cleanCardNumber.startIndex, offsetBy: 6)
        let endIndex = cleanCardNumber.index(cleanCardNumber.endIndex, offsetBy: -4)
        packetString.append(String(cleanCardNumber[cleanCardNumber.startIndex..<startIndex]))
        packetString.append(String(cleanCardNumber[endIndex..<cleanCardNumber.endIndex]))
        packetString.append(cardDateString)
        packetString.append(self.publicKeyVersion)
        packetString.append(cryptogramString)
        
        return packetString
    }
    
    public static func makeCardCryptogramPacket(with cvv: String) -> String? {
        guard let cryptogramData = try? RSAUtils.encryptWithRSAPublicKey(str: cvv, pubkeyBase64: self.publicKey) else {
            return nil
        }
        let cryptogramString = RSAUtils.base64Encode(cryptogramData)
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        
        var packetString = "03"
        packetString.append(self.publicKeyVersion)
        packetString.append(cryptogramString)
        
        return packetString
    }

    public static func cleanCreditCardNo(_ creditCardNo: String) -> String {
        return creditCardNo.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
    }
}
