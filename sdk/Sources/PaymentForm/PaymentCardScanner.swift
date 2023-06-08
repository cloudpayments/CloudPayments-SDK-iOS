//
//  PaytmentCardScanner.swift
//  sdk
//
//  Created by Sergey Iskhakov on 01.10.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import UIKit

public protocol PaymentCardScanner {
    func startScanner(completion: @escaping (_ number: String?, _ mm: UInt?, _ yy: UInt?, _ cvv: String?) -> Void) -> UIViewController?
}
