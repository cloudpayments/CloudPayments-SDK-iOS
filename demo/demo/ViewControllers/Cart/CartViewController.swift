//
//  CartViewController.swift
//  demo
//
//  Created by Anton Ignatov on 31/05/2019.
//  Copyright © 2019 Cloudpayments. All rights reserved.
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
        
//        cell.picture.sd_cancelCurrentImageLoad()
//        cell.picture.image = nil
//
//        if let image = product.images?.first?.src {
//            cell.picture.sd_setImage(with: URL.init(string: image), completed: nil)
//        }
        
        cell.name.text = product.name
        cell.price.text = "\(product.price ?? "0")  Руб."
            
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        
        let product = Product(id: 1, name: "Букет \"Нежность\"", price: "1")
        
        CartManager.shared.products.append(product)
        
        var total = 0;
        
        for product in CartManager.shared.products {
            if let priceStr = product.price, let price = Int(priceStr) {
                total += price
            }
        }
        
        labelTotal.text = "Итого: \(total) Руб."
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

                let jsonData: [String: Any] = ["age":27,
                                               "name":"Ivan",
                                               "phone":"+79998881122"]
                let paymentData = PaymentData.init(publicId: Constants.merchantPublicId)
                    .setAmount(String(totalAmount))
                    .setCurrency(.ruble)
                    .setApplePayMerchantId(Constants.applePayMerchantID)
                    .setCardholderName("Демо приложение")
                    .setDescription("Корзина цветов")
                    .setAccountId("111")
                    .setIpAddress("98.21.123.32")
                    .setInvoiceId("123")
                    .setJsonData(jsonData)

                let configuration = PaymentConfiguration.init(
                    paymentData: paymentData,
                    delegate: self,
                    uiDelegate: self,
                    scanner: nil,
                    useDualMessagePayment: true,
                    disableApplePay: true)
                
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

extension CartViewController: PaymentDelegate {
    func onPaymentFinished(_ transactionId: Int?) {
        self.navigationController?.popViewController(animated: true)
        CartManager.shared.products.removeAll()
        
        if let transactionId = transactionId {
            print("finished with transactionId: \(transactionId)")
        }
    }
    
    func onPaymentFailed(_ errorMessage: String?) {
        if let error = errorMessage {
            print("finished with error: \(error)")
        }
    }
}

extension CartViewController: PaymentUIDelegate {
    func paymentFormWillDisplay() {
        print("paymentFormWillDisplay")
    }
    
    func paymentFormDidDisplay() {
        print("paymentFormDidDisplay")
    }
    
    func paymentFormWillHide() {
        print("paymentFormWillHide")
    }
    
    func paymentFormDidHide() {
        print("paymentFormDidHide")
    }
}
