//
//  UILabel.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 08.07.2023.
//

import UIKit

extension UILabel {
    
    func addSpacing(text: String? = "", _ spacing: CGFloat) {
        
        guard let string = text  else {return}
        let defaultFont = self.font ?? .systemFont(ofSize: 15)
        let defaultColor = self.textColor ?? .black
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineSpacing = spacing
        paragraphStyle.lineBreakMode = self.lineBreakMode
        
        let attributedString = NSMutableAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle])
        
        if let attrText = self.attributedText {
            attributedString.append(attrText)
        }
        
        guard let range = string.range(of: text!) else { return }
        
        attributedString.addAttributes(
            [
                .font: defaultFont,
                .foregroundColor: defaultColor
            ],
            range: NSRange(range, in: string))
        
        self.attributedText = attributedString
    }
}

