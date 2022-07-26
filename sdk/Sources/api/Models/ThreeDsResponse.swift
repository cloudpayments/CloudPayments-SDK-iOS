//
//  ThreeDsResponse.swift
//  sdk
//
//  Created by Sergey Iskhakov on 24.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation

public struct ThreeDsResponse {
    public private(set) var success: Bool
    public private(set) var cardHolderMessage: String?
    
    init(success: Bool, cardHolderMessage: String?) {
        self.success = success
        self.cardHolderMessage = cardHolderMessage
    }
}
