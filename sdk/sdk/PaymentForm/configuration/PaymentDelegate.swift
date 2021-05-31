//
//  PaymentDelegate.swift
//  sdk
//
//  Created by Sergey Iskhakov on 08.10.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation

public protocol PaymentDelegate: class {
    func onPaymentFinished(_ transactionId: Int?)
    func onPaymentFailed(_ errorMessage: String?)
}

public protocol PaymentUIDelegate: class {
    func paymentFormWillDisplay()
    func paymentFormDidDisplay()
    func paymentFormWillHide()
    func paymentFormDidHide()
}

internal class PaymentDelegateImpl {
    weak var delegate: PaymentDelegate?
    
    init(delegate: PaymentDelegate?) {
        self.delegate = delegate
    }
    
    func paymentFinished(_ transaction: Transaction?){
        self.delegate?.onPaymentFinished(transaction?.transactionId)
    }
    
    func paymentFailed(_ errorMessage: String?) {
        self.delegate?.onPaymentFailed(errorMessage)
    }
}

internal class PaymentUIDelegateImpl {
    weak var delegate: PaymentUIDelegate?
    
    init(delegate: PaymentUIDelegate?) {
        self.delegate = delegate
    }
    
    func paymentFormWillDisplay() {
        self.delegate?.paymentFormWillDisplay()
    }
    
    func paymentFormDidDisplay() {
        self.delegate?.paymentFormDidDisplay()
    }
    
    func paymentFormWillHide() {
        self.delegate?.paymentFormWillHide()
    }
    
    func paymentFormDidHide() {
        self.delegate?.paymentFormDidHide()
    }
}
