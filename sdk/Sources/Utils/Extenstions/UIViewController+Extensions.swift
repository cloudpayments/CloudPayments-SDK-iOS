//
//  UIViewController+Extensions.swift
//  sdk
//
//  Created by Sergey Iskhakov on 21.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /* Shows default OK action if actions is nil */
    func showAlert(title: String?, message: String?, actions: [UIAlertAction]? = nil) {
        let alert = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        
        var alertActions = actions ?? []
        
        if alertActions.isEmpty {
            alertActions.append(UIAlertAction(title: "OK", style: .default))
        }
        
        alertActions.forEach { alert.addAction($0) }
        
        present(alert, animated: true)
    }
}
