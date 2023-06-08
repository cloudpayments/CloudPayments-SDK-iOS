//
//  View.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 21.03.2023.
//

import UIKit

class View: UIView {
    @IBInspectable var activeColor: UIColor = UIColor.mainBlue
    
    @IBInspectable var borderWidth : CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth;
        }
    }
    @IBInspectable var borderColor : UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable var cornerRadius : CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    func setAlpha(_ alpha: CGFloat) {
           self.alpha = alpha
       }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
           let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
           let mask = CAShapeLayer()
           mask.path = path.cgPath
           layer.mask = mask
       }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
}

enum BorderEdge {
    case left
    case right
    case top
    case bottom
    case leftTop
    case leftBottom
    case rightTop
    case rightBottom
}

extension UIView {
    func addBorders(withEdges edges: [BorderEdge],
                    withColor color: UIColor,
                    withThickness thickness: CGFloat,
                    cornerRadius: CGFloat = 0) {
        layer.borderColor = color.cgColor
        layer.borderWidth = thickness
        layer.cornerRadius = cornerRadius
        edges.forEach({ edge in
            
            switch edge {
            
            case .left:
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                
            case .right:
                layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                
            case .top:
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            case .leftTop:
                layer.maskedCorners = [.layerMinXMinYCorner]
            case .rightTop:
                layer.maskedCorners = [.layerMaxXMinYCorner]
                
            case .bottom:
                layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                
            case .leftBottom:
                layer.maskedCorners = [.layerMinXMaxYCorner]
            case .rightBottom:
                layer.maskedCorners = [.layerMaxXMaxYCorner]

            }
        })
    }
}
