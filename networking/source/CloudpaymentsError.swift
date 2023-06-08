//
//  CloudpaymentsError.swift
//  sdk
//
//  Created by Sergey Iskhakov on 25.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

public class CloudpaymentsError: Error {
    public static let defaultCardError = CloudpaymentsError.init(message: "Unable to determine bank")
    
    public static let parseError = CloudpaymentsError.init(message: "Не удалось получить ответ")
    
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
    
    public class func invalidURL(url: String?) -> CloudpaymentsError {
        return CloudpaymentsError.init(message: "Invalid url: \(String(describing: url))")
    }
}
