//
//  Card.swift
//  Cloudpayments-SDK
//
//  Created by Sergey Iskhakov on 08.09.2020.
//  Copyright © 2020 cloudpayments. All rights reserved.
//

import Foundation

public enum CardType: String {
    case unknown = "Unknown"
    case visa = "Visa"
    case masterCard = "MasterCard"
    case maestro = "Maestro"
    case mir = "MIR"
    case jcb = "JCB"
    
    public func toString() -> String {
        return self.rawValue
    }
}

public struct Card {
    private static let publicKey = "-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArBZ1NNjvszen6BNWsgyDUJvDUZDtvR4jKNQtEwW1iW7hqJr0TdD8hgTxw3DfH+Hi/7ZjSNdH5EfChvgVW9wtTxrvUXCOyJndReq7qNMo94lHpoSIVW82dp4rcDB4kU+q+ekh5rj9Oj6EReCTuXr3foLLBVpH0/z1vtgcCfQzsLlGkSTwgLqASTUsuzfI8viVUbxE1a+600hN0uBh/CYKoMnCp/EhxV8g7eUmNsWjZyiUrV8AA/5DgZUCB+jqGQT/Dhc8e21tAkQ3qan/jQ5i/QYocA/4jW3WQAldMLj0PA36kINEbuDKq8qRh25v+k4qyjb7Xp4W2DywmNtG3Q20MQIDAQAB-----END PUBLIC KEY-----"
    private static let publicKeyVersion = "04"
    
    public static func isCardNumberValid(_ cardNumber: String) -> Bool {
        return true
    }

    public static func isExpDateValid(_ expDate: String) -> Bool {
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
        
        if firstTwoNum == 50 {
            return .jcb
        } else if firstTwoNum == 50 || (firstTwoNum >= 56 && firstTwoNum <= 58) {
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
        
        var packetString = "02"
        let startIndex = cleanCardNumber.index(cleanCardNumber.startIndex, offsetBy: 6)
        let endIndex = cleanCardNumber.index(cleanCardNumber.endIndex, offsetBy: -4)
        packetString.append(String(cleanCardNumber[cleanCardNumber.startIndex..<startIndex]))
        packetString.append(String(cleanCardNumber[endIndex..<cleanCardNumber.endIndex]))
        packetString.append(cardDateString)
        packetString.append(self.publicKeyVersion)
        packetString.append(cryptogramString)
        
        return packetString
    }

    public static func cleanCreditCardNo(_ creditCardNo: String) -> String {
        return creditCardNo.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
    }
}
