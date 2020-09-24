//
//  Bundle+Extenstions.swift
//  sdk
//
//  Created by Sergey Iskhakov on 16.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation

extension Bundle {
    class var mainSdk: Bundle {
        let bundle = Bundle.init(for: PaymentForm.self)
        let bundleUrl = bundle.url(forResource: "Cloudpayments", withExtension: "bundle")
        return Bundle.init(url: bundleUrl!)!
    }
}
