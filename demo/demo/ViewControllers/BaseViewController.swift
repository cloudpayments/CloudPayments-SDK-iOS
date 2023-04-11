//
//  BaseViewController.swift
//  demo
//
//  Created by Sergey Iskhakov on 15.10.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation

class BaseViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
}
