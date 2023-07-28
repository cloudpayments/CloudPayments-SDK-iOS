//
//  AlertInfoView.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 06.07.2023.
//

import UIKit

final class AlertInfoView: UIView {
    private var trianleConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    var trianglPosition: CGFloat {
        get { trianleConstraint.constant}
        set {
            trianleConstraint.constant = newValue
            self.layoutIfNeeded()
        }
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        let array = [
            "Нажимая галочку, вы соглашаетесь с тем, что данные вашей карты сохранятся. Это означает, что при повторной оплате вам не надо будет вводить платежные реквизиты заново.",
            "Мы не сможем проводить никакие операции по вашей карте без вашего согласия"
        ]
            .map ({ string in
                let label = UILabel()
                label.font = .systemFont(ofSize: 13)
                label.textColor = .whiteColor
                label.numberOfLines = 0
                label.addSpacing(text: string, 5)
                label.sizeToFit()
                let view = UIView()
                view.addSubview(label)
                view.backgroundColor = .clear
                label.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: view.topAnchor),
                    label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                ])
                return view
            })
            .map { labelView in
                let height = 10.0
                let dot = UIView()
                dot.backgroundColor = .mainBlue
                dot.layer.cornerRadius = height / 2
                dot.heightAnchor.constraint(equalToConstant: height).isActive = true
                dot.widthAnchor.constraint(equalTo: dot.heightAnchor, multiplier: 1).isActive = true
                let view = UIView()
                view.backgroundColor = .clear
                view.addSubview(dot)
                dot.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    dot.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
                    dot.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    dot.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    dot.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
                ])
                
                let stackView = UIStackView(.horizontal, .fill, .fill, 15, [view, labelView])
                return stackView
            }
        
        let stackView = UIStackView(.vertical, .equalSpacing, .fill, 10, array)
        
        let triangleView = UIView()
        triangleView.backgroundColor = .colorAlertView
        let transform = CGAffineTransform(rotationAngle: .pi / 1 / 4)
        triangleView.transform = transform
        triangleView.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        view.backgroundColor = .colorAlertView
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        
        view.addSubview(stackView)
        stackView.fullConstraint(top: 22, bottom: -22, leading: 10, trailing: -10 )
        self.addSubview(triangleView)
        self.addSubview(view)
        view.fullConstraint(bottom: -10, leading: 30, trailing: -30)
        
        NSLayoutConstraint.activate([
            triangleView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2),
            triangleView.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
            triangleView.widthAnchor.constraint(equalTo: triangleView.heightAnchor, multiplier: 1)
        ])
        
        trianleConstraint = triangleView.centerXAnchor.constraint(equalTo: self.leadingAnchor)
        trianleConstraint.isActive = true
    }
}
