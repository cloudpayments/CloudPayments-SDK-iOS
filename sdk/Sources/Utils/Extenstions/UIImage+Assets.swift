//
//  UIImage+Assets.swift
//  sdk
//
//  Created by Sergey Iskhakov on 24.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    public class func named(_ name: String) -> UIImage {
        return UIImage.init(named: name, in: Bundle.mainSdk, compatibleWith: nil)!
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
}
