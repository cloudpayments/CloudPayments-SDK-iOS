//
//  UIView-Ext.swift
//  demo
//
//  Created by Илья Белкин on 28.06.2023.
//  Copyright © 2023 Cloudpayments. All rights reserved.
//

import Foundation
extension UIView {
    static var identifier: String { return String(describing: Self.self)}
    
    var cornerRadius: CGFloat {
        get { layer.cornerRadius}
        set {
            layer.cornerRadius = newValue
            clipsToBounds = true
        }
    }
    
    var borderWidth: CGFloat {
        get { layer.borderWidth}
        set {
            layer.borderWidth = newValue
        }
    }
    
    var borderColor: UIColor? {
        get { return .clear}
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
