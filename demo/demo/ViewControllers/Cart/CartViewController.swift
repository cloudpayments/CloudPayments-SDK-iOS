//
//  CartViewController.swift
//  demo
//
//  Created by Anton Ignatov on 31/05/2019.
//  Copyright © 2019 Anton Ignatov. All rights reserved.
//

import UIKit
import Cloudpayments
import SDWebImage

class CartViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var labelTotal: UILabel!
    
    private var scannerCompletion: ((_ number: String?, _ month: UInt?, _ year: UInt?, _ cvv: String?) -> ())?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CartManager.shared.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell")!
        
        let product = CartManager.shared.products[indexPath.item]
        
        cell.textLabel?.text = product.name*/
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath as IndexPath) as! CartViewCell
        
        let product = CartManager.shared.products[indexPath.item]
        
        cell.picture.sd_cancelCurrentImageLoad()
        cell.picture.image = nil
        
        if let image = product.image {
            cell.picture.sd_setImage(with: URL.init(string: image), completed: nil)
        }
        
        cell.name.text = product.name
        cell.price.text = "\(product.price ?? "0")  Руб."
            
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        
        var total = 0;
        
        for product in CartManager.shared.products {
            if let priceStr = product.price, let price = Int(priceStr) {
                total += price
            }
        }
        
        labelTotal.text = "Итого: \(total) Руб."
        
        CardIOUtilities.preloadCardIO()
    }
    
    @IBAction func onPay(_ sender: UIButton) {
        let controller = UIAlertController.init(title: "Выберите способ оплаты", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction.init(title: "Своя форма оплаты", style: .default, handler: { (action) in
            controller.dismiss(animated: true) {
                self.performSegue(withIdentifier: "CartToCheckoutSegue", sender: self)
            }
            
        }))
        controller.addAction(UIAlertAction.init(title: "Форма оплаты Cloudpayments", style: .default, handler: { (action) in
            controller.dismiss(animated: true) {
                var totalAmount = 0
                for product in CartManager.shared.products {

                    if let priceStr = product.price, let price = Int(priceStr) {
                        totalAmount += price
                    }
                }

                let paymentData = PaymentData.init(publicId: Constants.merchantPulicId)
                    .setAmount(String(totalAmount))
                    .setCurrency(.ruble)
                    .setApplePayMerchantId(Constants.applePayMerchantID)

                let configuration = PaymentConfiguration.init(paymentData: paymentData, delegate: self, scanner: self)
                PaymentForm.present(with: configuration, from: self)
            }
            
        }))
        controller.addAction(UIAlertAction.init(title: "Отмена", style: .cancel, handler: { (action) in
            controller.dismiss(animated: true, completion: nil)
        }))
        
        if let presenter = controller.popoverPresentationController {
            presenter.sourceView = self.payButton
            presenter.sourceRect = self.payButton.bounds
        }
        
        self.present(controller, animated: true, completion: nil)
        
    }
}

extension CartViewController: CardIOPaymentViewControllerDelegate {
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        self.scannerCompletion?(cardInfo.cardNumber, cardInfo.expiryMonth, cardInfo.expiryYear, cardInfo.cvv)
        paymentViewController.dismiss(animated: true, completion: nil)
    }
}

extension CartViewController: PaymentCardScanner {
    func startScanner(completion: @escaping (String?, UInt?, UInt?, String?) -> Void) -> UIViewController? {
        self.scannerCompletion = completion
        
        let scanController = CardIOPaymentViewController.init(paymentDelegate: self)
        return scanController
    }
}

extension CartViewController: PaymentDelegate {
    func onPaymentFinished() {
        self.navigationController?.popViewController(animated: true)
        CartManager.shared.products.removeAll()
    }
}
