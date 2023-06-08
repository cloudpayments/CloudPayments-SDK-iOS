//
//  ThreeDsData.swift
//  sdk
//
//  Created by Sergey Iskhakov on 25.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

public class ThreeDsData {
    private(set) var transactionId = String()
    private(set) var paReq = String()
    private(set) var acsUrl = String()
    
    public init(transactionId: String, paReq: String, acsUrl: String) {
        self.transactionId = transactionId
        self.paReq = paReq
        self.acsUrl = acsUrl
    }
}
