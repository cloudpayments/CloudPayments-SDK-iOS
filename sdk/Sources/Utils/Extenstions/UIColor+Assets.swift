//
//  UIColor+Assets.swift
//  sdk
//
//  Created by Sergey Iskhakov on 18.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    public class var mainText: UIColor {
        return color(named: "color_text_main")
    }
    
    public class var mainTextPlaceholder: UIColor {
        return color(named: "color_text_placeholder")
    }
    
    public class var mainBlue: UIColor! {
        return color(named: "color_blue")
    }
    
    public class var border: UIColor! {
        return color(named: "color_border")
    }
    
    private class func color(named colorName: String) -> UIColor! {
        return UIColor.init(named: colorName, in: Bundle.mainSdk, compatibleWith: .none)
    }
}
