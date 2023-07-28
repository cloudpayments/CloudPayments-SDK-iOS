//
//  UIStackView.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 06.07.2023.
//

import UIKit
extension UIStackView {
    
    convenience init(_ axis: NSLayoutConstraint.Axis,
                           _ distribution:UIStackView.Distribution,
                           _ alignment: UIStackView.Alignment,
                           _ spacing: CGFloat,
                           _ arrangedSubviews: [UIView] ) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
        self.backgroundColor = .clear
    }
    
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach({self.addArrangedSubview($0)})
    }
}
