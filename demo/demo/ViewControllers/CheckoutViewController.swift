//
//  CheckoutViewController.swift
//  demo
//

import UIKit
import PassKit
import Cloudpayments
import WebKit

class CheckoutViewController: BaseViewController {
    @IBOutlet weak var labelTotal: UILabel!
    @IBOutlet weak var textCardNumber: UITextField!
    @IBOutlet weak var textExpDate: UITextField!
    @IBOutlet weak var textCvcCode: UITextField!
    @IBOutlet weak var textCardHolderName: UITextField!
    @IBOutlet weak var buttonApplePay: UIButton!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var threeDsFormView: UIView!
    @IBOutlet weak var threeDsContainerView: UIView!
    
    var threeDsProcessor = ThreeDsProcessor()
    var total = 0

    private let api = CloudpaymentsApi.init(publicId: Constants.merchantPublicId)
    private var transactionResponse: TransactionResponse?
    private var paymentCompletion: ((_ succeeded: Bool, _ message: String?) ->())?
    
    // APPLE PAY
    
    var paymentNetworks: [PKPaymentNetwork] {
        get {
            var arr: [PKPaymentNetwork] = [.visa, .masterCard, .JCB, .amex]
            if #available(iOS 12.0, *) {
                arr.append(.maestro)
            }
            
            return arr
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for product in CartManager.shared.products {
            
            if let priceStr = product.price, let price = Int(priceStr) {
                total += price
            }
        }
        
        labelTotal.text = "Всего к оплате: \(total) Руб."
        
        buttonApplePay.isHidden = !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) // Проверяем возможно ли использовать Apple Pay
    }
    
    //MARK: - Actions -
    
    @IBAction func onPayClick(_ sender: Any) {
        
        // Получаем введенные данные банковской карты и проверяем их корректность
        guard let cardNumber = textCardNumber.text, !cardNumber.isEmpty else {
            self.showAlert(title: .errorWord, message: .enterCardNumber)
            return
        }
               
        if !Card.isCardNumberValid(cardNumber) {
            self.showAlert(title: .errorWord, message: .enterCorrectCardNumber)
            return
        }
        
        CloudpaymentsApi.getBankInfo(cardNumber: cardNumber) { (info, error) in
            if let error = error {
                print("error: \(error.message)")
            } else {
                if let bankName = info?.bankName {
                    print("BankName: \(bankName)")
                } else {
                    print("BankName is empty")
                }
                
                if let logoUrl = info?.logoUrl {
                    print("LogoUrl: \(logoUrl)")
                } else {
                    print("LogoUrl is empty")
                }
            }
        }
        
        guard let expDate = textExpDate.text, expDate.count == 5 else {
            self.showAlert(title: .errorWord, message: .enterExpirationDate)
            return
        }
        
        // Срок действия в формате MM/yy
        if !Card.isExpDateValid(expDate) {
            self.showAlert(title: .errorWord, message: .enterExpirationDate)
            return
        }
        
        guard let holderName = textCardHolderName.text, !holderName.isEmpty else {
            self.showAlert(title: .errorWord, message: .enterCardHolder)
            return
        }
        
        guard let cvv = textCvcCode.text, !cvv.isEmpty else {
            self.showAlert(title: .errorWord, message: .enterCVVCode)
            return
        }
        
        // Создаем криптограмму карточных данных
        // Чтобы создать криптограмму необходим PublicID (свой PublicID можно посмотреть в личном кабинете и затем заменить в файле Constants)
        let cardCryptogramPacket = Card.makeCardCryptogramPacket(with: cardNumber, expDate: expDate, cvv: cvv, merchantPublicID: Constants.merchantPublicId)
        
        guard let packet = cardCryptogramPacket else {
            self.showAlert(title: .errorWord, message: .errorCreatingCryptoPacket)
            return
        }
        
        // Используя методы API выполняем оплату по криптограмме
        // (charge (для одностадийного платежа) или auth (для двухстадийного))
 
        //charge(cardCryptogramPacket: packet, cardHolderName: holderName)
        self.progressView.isHidden = false
        self.view.endEditing(true)
        auth(cardCryptogramPacket: packet, cardHolderName: holderName){ [weak self] (status, message) in
            self?.progressView.isHidden = true
            
            if status {
                self?.showAlert(title: .successWord, message: message, completion: {
                    CartManager.shared.products.removeAll()
                    self?.navigationController?.popToRootViewController(animated: true)
                })
            } else {
                self?.showAlert(title: .errorWord, message: message)
            }
        }
    }
    
    @IBAction func onApplePayClick(_ sender: Any) {
        
        // Получение информации о товарах выбранных пользователем
        var paymentItems: [PKPaymentSummaryItem] = []
        for product in CartManager.shared.products {
            let paymentItem = PKPaymentSummaryItem.init(label: product.name ?? "Продукт", amount: NSDecimalNumber(value: Int(product.price ?? "0")!))
            paymentItems.append(paymentItem)
        }
           
        // Формируем запрос для Apple Pay
        let request = PKPaymentRequest()
        request.merchantIdentifier = Constants.applePayMerchantID
        request.supportedNetworks = paymentNetworks
        request.merchantCapabilities = PKMerchantCapability.capability3DS // Возможно использование 3DS
        request.countryCode = "RU" // Код страны
        request.currencyCode = "RUB" // Код валюты
        request.paymentSummaryItems = paymentItems
        if let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request) {
            applePayController.delegate = self
            self.present(applePayController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onCloseThreeDs(_ sender: UIButton) {
        self.hideThreeDs()
        self.progressView.isHidden = true
    }
    
    func hideThreeDs() {
        UIView.animate(withDuration: 0.25) {
            self.threeDsFormView.alpha = 0
        } completion: { (status) in
            self.threeDsFormView.isHidden = true
        }
    }
}


//MARK: - PKPaymentAuthorizationViewControllerDelegate -
// Обработка результата для Apple Pay
// ВНИМАНИЕ! Нельзя тестировать Apple Pay в симуляторе, так как в симуляторе payment.token.paymentData всегда nil
extension CheckoutViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        completion(PKPaymentAuthorizationStatus.success)
        
        // Конвертируем объект PKPayment в строку криптограммы
        guard let cryptogram = payment.convertToString() else {
            return
        }
               
        // Используя методы API выполняем оплату по криптограмме
        // (charge (для одностадийного платежа) или auth (для двухстадийного))
        //charge(cardCryptogramPacket: cryptogram, cardHolderName: "")
        
        
        auth(cardCryptogramPacket: cryptogram, cardHolderName: "") { [weak self] (status, message) in
            if status {
                self?.showAlert(title: .successWord, message: message)
            } else {
                self?.showAlert(title: .errorWord, message: message)
            }
        }
      
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//MARK: - ThreeDsDelegate -

extension CheckoutViewController: ThreeDsDelegate {
    func willPresentWebView(_ webView: WKWebView) {
        webView.frame = self.threeDsContainerView.bounds
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.threeDsContainerView.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: self.threeDsContainerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.threeDsContainerView.trailingAnchor),
            webView.topAnchor.constraint(equalTo: self.threeDsContainerView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.threeDsContainerView.bottomAnchor)
        ])
        
        self.threeDsFormView.alpha = 0
        self.threeDsFormView.isHidden = false
        
        UIView.animate(withDuration: 0.25) {
            self.threeDsFormView.alpha = 1
        }
    }

    func onAuthorizationCompleted(with md: String, paRes: String) {
        hideThreeDs()
        post3ds(transactionId: md, paRes: paRes)
    }

    func onAuthorizationFailed(with html: String) {
        hideThreeDs()
        self.paymentCompletion?(false, html)
        self.paymentCompletion = nil
        print("error: \(html)")
    }

}


// MARK: - Private methods -

private extension CheckoutViewController {

    func charge(cardCryptogramPacket: String, cardHolderName: String, completion: ((_ succeeded: Bool, _ message: String?) ->())?) {
        self.transactionResponse = nil
        self.paymentCompletion = nil
        
        let paymentData = PaymentData(publicId: Constants.merchantPublicId)
            .setAmount(String(total))
            .setCardholderName(cardHolderName)
        
        api.charge(cardCryptogramPacket: cardCryptogramPacket, email: nil, paymentData: paymentData) { [weak self] (response, error) in
            if let response = response {
                print("success")
                self?.checkTransactionResponse(transactionResponse: response, completion: completion)
            } else if let error = error {
                print("error: \(error.localizedDescription)")
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    func auth(cardCryptogramPacket: String, cardHolderName: String, completion: ((_ succeeded: Bool, _ message: String?) ->())?) {
        self.transactionResponse = nil
        self.paymentCompletion = nil
        
        let paymentData = PaymentData(publicId: Constants.merchantPublicId)
            .setAmount(String(total))
            .setCardholderName(cardHolderName)
        
        api.auth(cardCryptogramPacket: cardCryptogramPacket, email: nil, paymentData: paymentData) { [weak self] (response, error) in
            if let response = response {
                print("success")
                self?.checkTransactionResponse(transactionResponse: response, completion: completion)
            } else if let error = error {
                print("error: \(error.localizedDescription)")
                completion?(false, error.localizedDescription)
            }
        }
    }
    
    // Проверяем необходимо ли подтверждение с использованием 3DS
    func checkTransactionResponse(transactionResponse: TransactionResponse, completion: ((_ succeeded: Bool, _ message: String?) ->())?) {
        if (transactionResponse.success == true) {
            completion?(true, transactionResponse.model?.cardHolderMessage)
        } else {
            let message = transactionResponse.message ?? ""
            if (!message.isEmpty) {
                completion?(false, transactionResponse.message)
            } else if (transactionResponse.model?.paReq != nil && transactionResponse.model?.acsUrl != nil) {
                self.transactionResponse = transactionResponse
                self.paymentCompletion = completion
                
                let transactionId = String(transactionResponse.model?.transactionId ?? 0)
                
                if let paReq = transactionResponse.model?.paReq, let acsUrl = transactionResponse.model?.acsUrl {
//                    Показываем 3DS форму
                    let data = ThreeDsData.init(transactionId: transactionId, paReq: paReq, acsUrl: acsUrl)
                    threeDsProcessor.make3DSPayment(with: data, delegate: self)
                }
            } else {
                completion?(false, transactionResponse.model?.cardHolderMessage)
            }
        }
    }
    
    func post3ds(transactionId: String, paRes: String) {
        if let threeDsCallbackId = self.transactionResponse?.model?.threeDsCallbackId {
            api.post3ds(transactionId: transactionId, threeDsCallbackId: threeDsCallbackId, paRes: paRes) { [weak self] (response) in
                self?.paymentCompletion?(response.success, response.cardHolderMessage)
                self?.paymentCompletion = nil
            }
        }
    }
}

