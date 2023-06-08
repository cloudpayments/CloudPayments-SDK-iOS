//
//  PaymentConfiguration.swift
//  sdk
//
//  Created by Sergey Iskhakov on 22.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

public struct PaymentDataPayer: Codable {
    let firstName: String
    let lastName: String
    let middleName: String
    let birth: String
    let address: String
    let street: String
    let city: String
    let country: String
    let phone: String
    let postcode: String
    
    public init(firstName: String = "",
                lastName: String = "",
                middleName: String = "",
                birth: String = "",
                address: String = "",
                street: String = "",
                city: String = "",
                country: String = "",
                phone: String = "",
                postcode: String = "") {
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        self.birth = birth
        self.address = address
        self.street = street
        self.city = city
        self.country = country
        self.phone = phone
        self.postcode = postcode
    }
    
    var dictionary: [String: String] { return ["FirstName": firstName,
                                               "LastName": lastName,
                                               "MiddleName": middleName,
                                               "Birth": birth,
                                                "Address": address,
                                                "Street": street,
                                                "City": city,
                                                "Country": country,
                                                "Phone": phone,
                                                "Postcode": postcode] }
}

public class PaymentData {
    private (set) var email: String?
    private (set) var payer: PaymentDataPayer?
    private (set) var amount: String = "0"
    private (set) var currency: String = "RUB"
    private (set) var applePayMerchantId: String?
    private (set) var yandexPayMerchantId: String?
    private (set) var cardholderName: String?
    private (set) var description: String?
    private (set) var accountId: String?
    private (set) var invoiceId: String?
    private (set) var ipAddress: String?
    private (set) var cultureName: String?
    private (set) var jsonData: String?
    
    var cryptogram: String?
    
    public init() {
    }
    
    public func setAmount(_ amount: String) -> PaymentData {
        self.amount = amount
        return self
    }
    
    public func setCurrency(_ currency: String) -> PaymentData {
        if (currency.isEmpty) {
            self.currency = "RUB"
        } else {
            self.currency = currency
        }
        return self
    }
    
    public func setApplePayMerchantId(_ applePayMerchantId: String) -> PaymentData {
        self.applePayMerchantId = applePayMerchantId
        return self
    }
    
    public func setYandexPayMerchantId(_ yandexPayMerchantId: String) -> PaymentData {
        self.yandexPayMerchantId = yandexPayMerchantId
        return self
    }
    
    public func setCardholderName(_ cardholderName: String?) -> PaymentData {
        self.cardholderName = cardholderName
        return self
    }
    
    public func setDescription(_ description: String?) -> PaymentData {
        self.description = description
        return self
    }
    
    public func setAccountId(_ accountId: String?) -> PaymentData {
        self.accountId = accountId
        return self
    }
    
    public func setInvoiceId(_ invoiceId: String?) -> PaymentData {
        self.invoiceId = invoiceId
        return self
    }
    
    public func setIpAddress(_ ipAddress: String?) -> PaymentData {
        self.ipAddress = ipAddress
        return self
    }
    
    public func setCultureName(_ cultureName: String?) -> PaymentData {
        self.cultureName = cultureName
        return self
    }
    
    public func setPayer(_ payer: PaymentDataPayer?) -> PaymentData {
        self.payer = payer
        return self
    }
    
    public func setEmail(_ email: String?) -> PaymentData {
        self.email = email
        return self
    }
    
    public func setJsonData(_ jsonData: String) -> PaymentData {
        
        let map = convertStringToDictionary(text: jsonData)
        
        if (map == nil) {
            self.jsonData = nil
            return self
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: map as Any, options: .sortedKeys) {
            let jsonString = String(data: data, encoding: .utf8)
            self.jsonData = jsonString
        }
        
        print("JSONDATA")
        print(self.jsonData as Any)
        
        return self
    }

    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
}
