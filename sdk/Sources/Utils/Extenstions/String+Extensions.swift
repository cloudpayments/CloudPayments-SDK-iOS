//
//  Strings+Extensions.swift
//  sdk
//
//  Created by Sergey Iskhakov on 16.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation

extension String {
    static let bundleName = "CloudpaymentsSdkResources"
    static let errorWord = "Ошибка"
    static let informationWord = "Информация"
    
    static let RUBLE_SIGN = "\u{20BD}"
    static let EURO_SIGN = "\u{20AC}"
    static let GBP_SIGN = "\u{00A3}"
}

extension String {
    func formattedCardNumber() -> String {
        let mask = "XXXX XXXX XXXX XXXX XXX"
        return self.onlyNumbers().formattedString(mask: mask, ignoredSymbols: nil)
    }
    
    func clearCardNumber() -> String {
        return self.onlyNumbers()
    }
    
    func formattedCardExp() -> String {
        let mask = "XX/XX"
        return self.onlyNumbers().formattedString(mask: mask, ignoredSymbols: nil)
    }
    
    func cleanCardExp() -> String {
        return self.onlyNumbers()
    }
    
    func formattedCardCVV() -> String {
        let mask = "XXX"
        return self.onlyNumbers().formattedString(mask: mask, ignoredSymbols: nil)
    }

    func emailIsValid() -> Bool {
        let emailRegex = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with:self)
    }
    
    func formattedString(mask: String, ignoredSymbols: String?) -> String {
        let cleanString = self.onlyNumbers()
        
        var result = ""
        var index = cleanString.startIndex
        for ch in mask {
            if index == cleanString.endIndex {
                break
            }
            if ch == "X" {
                result.append(cleanString[index])
                index = cleanString.index(after: index)
            } else {
                result.append(ch)
                
                if ignoredSymbols?.contains(ch) == true {
                    index = cleanString.index(after: index)
                }
            }
        }
        return result
    }
    
    func onlyNumbers() -> String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}
