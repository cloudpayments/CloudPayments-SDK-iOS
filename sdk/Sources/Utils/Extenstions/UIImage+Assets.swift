//
//  UIImage+Assets.swift
//  sdk
//
//  Created by Sergey Iskhakov on 24.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import UIKit

extension UIImage {
    public class func named(_ name: String) -> UIImage {
        
        let image2 = UIImage.init(named: name, in: Bundle.cocoapods, compatibleWith: nil)
        if image2 != nil {
            return image2!
        }
        return UIImage()
    }
    
    public class var iconProgress: UIImage {
        return self.named("ic_progress")
    }
    
    public class var iconSuccess: UIImage {
        return self.named("ic_success")
    }
    
    public class var iconFailed: UIImage {
        return self.named("ic_failed")
    }
    
    public class var iconUnselected: UIImage {
        return self.named("ic_checkbox_unselected")
    }
    
    public class var iconSelected: UIImage {
        return self.named("ic_checkbox_selected")
    }
    
    public class var icn_attention: UIImage {
        return self.named("icn_attention")
    }
}

extension UIImageView {
    
    var colorRenderForImage:UIColor {
        get {return self.tintColor}
        set {
            self.image = self.image?.withRenderingMode(.alwaysTemplate)
            self.tintColor = newValue
        }
    }
}
