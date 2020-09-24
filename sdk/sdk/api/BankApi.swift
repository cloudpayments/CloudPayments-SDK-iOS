//
//  CardApi.swift
//  sdk
//
//  Created by Sergey Iskhakov on 09.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation

public class CardApiError: Error {
    static let defaultError = CardApiError.init(errorMessage: "Unable to determine bank")
    
    public let errorMessage: String
    
    public init(errorMessage: String) {
        self.errorMessage = errorMessage
    }
}

public class BankApi {
    public class func getBankInfo(cardNumber: String, completion: ((_ bankInfo: BankInfo?, _ error: CardApiError?) -> ())?) {
        let cleanCardNumber = Card.cleanCreditCardNo(cardNumber)
        guard cleanCardNumber.count >= 6 else {
            completion?(nil, CardApiError.init(errorMessage: "You must specify at least the first 6 digits of the card number"))
            return
        }
        
        let firstSixIndex = cleanCardNumber.index(cleanCardNumber.startIndex, offsetBy: 6)
        let firstSixDigits = String(cleanCardNumber[..<firstSixIndex])
        
        if let url = URL.init(string: String.init(format: "https://widget.cloudpayments.ru/Home/BinInfo?firstSixDigits=%@", firstSixDigits)) {
            let session = URLSession.init(configuration: URLSessionConfiguration.default)
            var request = URLRequest.init(url: url)
            request.httpMethod = "GET"
            
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                if let data = data, let results = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    if let success = results["Success"] as? Bool, success, let model = results["Model"] as? [String: Any] {
                        let bankName = model["BankName"] as? String
                        let logoUrl = model["LogoUrl"] as? String
                        
                        completion?(BankInfo.init(bankName: bankName, logoUrl: logoUrl), nil)
                    } else {
                        completion?(nil, CardApiError.defaultError)
                    }
                } else if let errorMessage = error?.localizedDescription {
                        completion?(nil, CardApiError.init(errorMessage: errorMessage))
                } else {
                    completion?(nil, CardApiError.defaultError)
                }
            }
            
            dataTask.resume()
        } else {
            completion?(nil, nil)
        }
    }
}
