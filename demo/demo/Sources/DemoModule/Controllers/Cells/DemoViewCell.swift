//
//  DemoViewCell.swift
//  demo
//
//  Created by Cloudpayments on 27.06.2023.
//  Copyright © 2023 Cloudpayments. All rights reserved.
//

import UIKit

enum ColorType: String {
    case blue = "color_blue"
    
    func toString() -> String { return self.rawValue }
}

class DemoViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet private weak var demoLabel: UILabel!
    @IBOutlet private weak var demoTextField: UITextField!

    override class func awakeFromNib() { super.awakeFromNib() }
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) { super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    // MARK: - Setup viewModel
    func setupView(viewModel: PaymentViewModel) {
        demoLabel.text = viewModel.type.title
        demoTextField.placeholder = viewModel.type.placeholder
        demoTextField.text = viewModel.text
        layoutFields()
    }
    
    // MARK: - Private methods
    private func layoutFields() {
        demoTextField.cornerRadius = 8
        demoTextField.borderWidth = 1
        demoTextField.borderColor = UIColor(named: ColorType.blue.toString())
        demoTextField.borderStyle = .none
        demoTextField.indent(10)
    }
    
    func addTarget(_ target: Any, action: Selector, row: Int) {
        demoTextField.tag = row
        demoTextField.addTarget(target, action: action, for: .editingChanged)
    }
}
