//
//  PublicKeyData.swift
//  Cloudpayments
//
//  Created by CloudPayments on 31.05.2023.
//

import Foundation

struct PublicKeyData: Codable {
    let Pem: String?
    let Version: Int?
    
    private static let key = "ApiURLKeyCrypto"
    
    public var version: String { return String(Version ?? 0)}
    
    private static var keyChain: String { return "PublicBaseKey64"}
    
    public static var apiURL: String! {
        get {
            let url =  UserDefaults.standard.string(forKey: key) ?? "https://api.cloudpayments.ru/"
            return url
        }
        
        set {
            guard let newValue = newValue,
                  let api =  UserDefaults.standard.string(forKey: key),
                  api == newValue
            else {
                UserDefaults.standard.set(newValue, forKey: key)
                UserDefaults.standard.synchronize()
                updateData()
                return
            }
        }
    }
    
    public static var getValue: PublicKeyData? {
        guard let data = UserDefaults.standard.data(forKey: PublicKeyData.keyChain) else {
            Network.updatePublicCryptoKey()
            return nil
        }
        guard let value = try? JSONDecoder().decode(PublicKeyData.self, from: data) else {
            print("ошибка в парсинге данных\n:", #function, "\nline:", #line)
            return nil
        }
        
        return value
    }
    
    public func save() {
        let data = try? JSONEncoder().encode(self)
        UserDefaults.standard.set(data, forKey: PublicKeyData.keyChain)
        UserDefaults.standard.synchronize()
    }
    
    public static func updateData() {
        Network.updatePublicCryptoKey()
    }
}
