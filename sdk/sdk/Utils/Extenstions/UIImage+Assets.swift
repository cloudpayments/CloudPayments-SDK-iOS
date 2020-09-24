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
    public class var iconProgress: UIImage {
        return UIImage.init(named: "ic_progress", in: Bundle.mainSdk, compatibleWith: nil)!
    }
    
    public class var iconSuccess: UIImage {
        return UIImage.init(named: "ic_success", in: Bundle.mainSdk, compatibleWith: nil)!
    }
    
    public class var iconFailed: UIImage {
        return UIImage.init(named: "ic_failed", in: Bundle.mainSdk, compatibleWith: nil)!
    }
}
