//
//  UnderlineTextField.swift
//  sdk
//
//  Created by Sergey Iskhakov on 18.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation
import UIKit

class UnderlineTextField: UITextField, UITextFieldDelegate {
    private var underlineView : UIView?
    
    @IBInspectable var activeColor: UIColor = UIColor.mainBlue
    @IBInspectable var passiveColor: UIColor = UIColor.border

    
    var shouldBeginEditing : (() -> Bool)? {
        didSet {
            delegateIfNeeded()
        }
    }
    var didBeginEditing : (() -> ())? {
        didSet {
            delegateIfNeeded()
        }
    }
    var shouldEndEditing : (() -> Bool)? {
        didSet {
            delegateIfNeeded()
        }
    }
    var didEndEditing : (() -> ())? {
        didSet {
            delegateIfNeeded()
        }
    }
    var shouldChangeCharactersInRange : ((_ range: NSRange, _ replacement: String) -> Bool)?{
        didSet{
            delegateIfNeeded()
        }
    }
    var shouldClear : (() -> Bool)?{
        didSet {
            delegateIfNeeded()
        }
    }
    var shouldReturn : (() -> Bool)?{
        didSet {
            delegateIfNeeded()
        }
    }
    var didChange : (() -> ())?
    
    @IBInspectable var leftImage : UIImage?{
        didSet {
            let imageView = UIImageView.init(image:leftImage)
            imageView.contentMode = UIView.ContentMode.center
            imageView.frame = CGRect.init(origin: CGPoint.zero, size: self.leftViewSize)
            self.leftView = imageView
            self.leftViewMode = UITextField.ViewMode.always
        }
    }
    @IBInspectable var leftViewSize = CGSize.zero {
        didSet{
            if let view = self.leftView {
                view.frame = CGRect.init(origin: CGPoint.zero, size: leftViewSize)
            }
        }
    }
    
    @IBInspectable var rightImage : UIImage?{
        didSet {
            let imageView = UIImageView.init(image:rightImage)
            imageView.contentMode = UIView.ContentMode.center
            imageView.frame = CGRect.init(origin: CGPoint.zero, size: self.rightViewSize)
            self.rightView = imageView
            self.rightViewMode = UITextField.ViewMode.always
        }
    }
    @IBInspectable var rightViewSize = CGSize.zero {
        didSet{
            if let view = self.rightView {
                view.frame = CGRect.init(origin: CGPoint.zero, size: rightViewSize)
            }
        }
    }
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
        self.addTarget(self, action:#selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    func delegateIfNeeded() -> Void {
        if self.delegate == nil {
            self.delegate = self
        } else if !self.delegate!.isEqual(self){
            self.delegate = self
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) -> Void {
        didChange?()
        setNeedsDisplay()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return shouldBeginEditing?() ?? true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.underlineView?.backgroundColor = activeColor
        didBeginEditing?()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return shouldEndEditing?() ?? true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.underlineView?.backgroundColor = passiveColor
        
        didEndEditing?()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return shouldChangeCharactersInRange?(range, string) ?? true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return shouldClear?() ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return shouldReturn?() ?? true
    }
    
    private func initialize(){
        self.clipsToBounds = false
        self.delegateIfNeeded()
        
        self.underlineView = UIView.init(frame: CGRect.init(x: 0, y: self.frame.height, width: self.frame.width, height: 1))
        if let underlineView = self.underlineView {
            self.addSubview(underlineView)
            underlineView.translatesAutoresizingMaskIntoConstraints = false
            underlineView.backgroundColor = self.passiveColor
            
            NSLayoutConstraint.activate([
                underlineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
                underlineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
                underlineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 1),
                underlineView.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    }
}
