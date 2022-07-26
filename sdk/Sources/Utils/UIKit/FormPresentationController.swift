//
//  FormPresentationController.swift
//  sdk
//
//  Created by Sergey Iskhakov on 17.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation
import UIKit

final class FormPresentationController: UIPresentationController {
    private var blackView: UIView!

    private func configureDimming() {
        self.blackView = UIView()
        self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        self.blackView.translatesAutoresizingMaskIntoConstraints = false

        let superview = self.containerView!
        superview.addSubview(self.blackView)
        self.blackView.bindFrameToSuperviewBounds()
    }

    override func presentationTransitionWillBegin() {
        self.configureDimming()
        self.blackView.alpha = 0

        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            guard let `self` = self else {
                return
            }
            self.blackView.alpha = 1
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] ctx in
            /* Somehow, animation inside this block is as always immediate. This hacky solution retrieves proper duration
             * in order to run our animations with UIView.animate */
            guard let `self` = self else {
                return
            }

            UIView.animate(withDuration: ctx.transitionDuration, animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.blackView?.alpha = 0
            })
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        self.blackView.removeFromSuperview()
    }
}
