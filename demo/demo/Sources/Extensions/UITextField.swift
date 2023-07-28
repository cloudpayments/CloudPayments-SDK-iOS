//
//  UITextField.swift
//  demo
//
//  Created by Cloudpayments on 27.06.2023.
//  Copyright © 2023 Cloudpayments. All rights reserved.
//

import UIKit

extension UITextField {
    func indent(_ point: CGFloat) {
        let frame = self.frame
        self.leftView = UIView(frame: .init(x: frame.minX, y: frame.minY, width: point, height: frame.height))
        self.leftViewMode = .always
    }
}

