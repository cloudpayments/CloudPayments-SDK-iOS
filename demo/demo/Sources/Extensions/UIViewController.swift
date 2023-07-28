//
//  UIViewController+Extensions.swift
//  demo
//
//  Created by Cloudpayments on 31/05/2019.
//  Copyright © 2019 Cloudpayments. All rights reserved.
//

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
    func showAlert(title: String?, message: String?, actions: [UIAlertAction]? = nil, completion: (() -> ())? = nil) {
        let alert = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        
        var alertActions = actions ?? []
        
        if alertActions.isEmpty {
            alertActions.append(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
                alert.dismiss(animated: true) {
                    completion?()
                }
            }))
        }
        
        alertActions.forEach { alert.addAction($0) }
        
        present(alert, animated: true)
    }
}
