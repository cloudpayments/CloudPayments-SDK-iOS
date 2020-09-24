//
//  ThreeDsResponse.swift
//  sdk
//
//  Created by Sergey Iskhakov on 24.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation

public struct ThreeDsResponse {
    private(set) var success: Bool
    private(set) var cardHolderMessage: String?
    
    init(success: Bool, cardHolderMessage: String?) {
        self.success = success
        self.cardHolderMessage = cardHolderMessage
    }
}
