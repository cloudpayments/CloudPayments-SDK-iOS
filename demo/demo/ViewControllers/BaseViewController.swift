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
    
    @IBAction func onPhoneClicked(_ sender: UIButton) {
        let URLString = "tel://" + Constants.salesPhone
        let url = URL.init(string: URLString)
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func onEmailClicked(_ sender: UIButton) {
        let mailto = "mailto:" + Constants.salesEmail
        let url = URL.init(string: mailto)
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
}
