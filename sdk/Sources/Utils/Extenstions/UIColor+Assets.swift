//
//  UIColor+Assets.swift
//  sdk
//
//  Created by Sergey Iskhakov on 18.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

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
    
    public class var inputCardView: UIColor! {
        return color(named: "color_text_button")
    }
    
    public class var errorBorder: UIColor {
        return color(named: "color_red")
    }
    
    public class var blackColor: UIColor {
        return color(named: "color_black")
    }
    
    public class var whiteColor: UIColor {
        return color(named: "color_text_white")
    }
    
    public class var colorAlertView: UIColor {
        return color(named: "color_alert_view")
    }
    
    private class func color(named colorName: String) -> UIColor! {
        return UIColor.init(named: colorName, in: Bundle.mainSdk, compatibleWith: .none)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat) {
        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
}
