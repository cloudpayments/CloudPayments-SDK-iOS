//
//  PaymentSourceForm.swift
//  sdk
//
//  Created by Sergey Iskhakov on 16.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation
import UIKit
import PassKit
import YandexPaySDK

class PaymentOptionsForm: PaymentForm, PKPaymentAuthorizationViewControllerDelegate, YandexPayButtonDelegate {
    
    @IBOutlet private weak var yandexPayContainer: UIView!
    @IBOutlet private weak var applePayContainer: UIView!
    @IBOutlet private weak var payWithCardButton: Button!
    
    private var supportedPaymentNetworks: [PKPaymentNetwork] {
        get {
            var arr: [PKPaymentNetwork] = [.visa, .masterCard, .JCB]
            if #available(iOS 12.0, *) {
                arr.append(.maestro)
            }
            if #available(iOS 14.5, *) {
                arr.append(.mir)
            }
            
            return arr
        }
    }
    
    private var applePaymentSucceeded: Bool?
    private var resultTransaction: Transaction?
    private var errorMessage: String?
    
    var onCardOptionSelected: (() -> ())?
    
    @discardableResult
    public class func present(with configuration: PaymentConfiguration, from: UIViewController, completion: (() -> ())?) -> PaymentForm {
        let storyboard = UIStoryboard.init(name: "PaymentForm", bundle: Bundle.mainSdk)
        
        let controller = storyboard.instantiateViewController(withIdentifier: "PaymentOptionsForm") as! PaymentOptionsForm
        controller.configuration = configuration
        controller.show(inViewController: from, completion: completion)
        
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.applePayContainer.isHidden = true
        self.yandexPayContainer.isHidden = true
        
        
        if (!self.configuration.disableApplePay) {
            self.initializeApplePay()
        }
        if (!self.configuration.disableYandexPay) {
            self.initializeYandexPay()
        }
    }
    
    private func initializeYandexPay() {
        
        self.yandexPayContainer.isHidden = false
        
        // Укажите тему для кнопки
        let theme: YandexPayButtonTheme
        if #available(iOS 13.0, *) {
            // Параметр `dynamic` позволяет указать, нужно ли кнопке
            // менять свою цветовую палитру вместе со сменой системной темы
            theme = YandexPayButtonTheme(appearance: .dark, dynamic: true)
        } else {
            theme = YandexPayButtonTheme(appearance: .dark)
        }
        
        // Инициализируйте конфигурацию
        let configuration = YandexPayButtonConfiguration(theme: theme)
        
        // Создайте кнопку
        let button = YandexPaySDKApi.instance.createButton(configuration: configuration, delegate: self)
        
        // Укажите скругления для кнопки (по умолчанию - 8px)
        button.layer.cornerRadius = 8
        
        // Добавьте кнопку в иерархию
        yandexPayContainer.addSubview(button)
        
        // Установите layout для кнопки
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        yandexPayContainer.addSubview(button)
        button.bindFrameToSuperviewBounds()
    }
    
    private func initializeApplePay() {
        
        self.applePayContainer.isHidden = false
        
        if let _  = self.configuration.paymentData.applePayMerchantId, PKPaymentAuthorizationViewController.canMakePayments() {
            let button: PKPaymentButton!
            if PKPaymentAuthorizationController.canMakePayments(usingNetworks: self.supportedPaymentNetworks) {
                button = PKPaymentButton.init(paymentButtonType: .plain, paymentButtonStyle: .black)
                button.addTarget(self, action: #selector(onApplePay(_:)), for: .touchUpInside)
            } else {
                button = PKPaymentButton.init(paymentButtonType: .setUp, paymentButtonStyle: .black)
                button.addTarget(self, action: #selector(onSetupApplePay(_:)), for: .touchUpInside)
            }
            button.translatesAutoresizingMaskIntoConstraints = false
            
            if #available(iOS 12.0, *) {
                button.cornerRadius = 8
            } else {
                button.layer.cornerRadius = 8
                button.layer.masksToBounds = true
            }
            
            self.applePayContainer.isHidden = false
            self.applePayContainer.addSubview(button)
            button.bindFrameToSuperviewBounds()
        } else {
            self.applePayContainer.isHidden = true
        }
    }
    
    @objc private func onApplePay(_ sender: UIButton) {
        errorMessage = nil
        resultTransaction = nil
        applePaymentSucceeded = false
        
        let paymentData = self.configuration.paymentData
        if let applePayMerchantId = paymentData.applePayMerchantId {
            let amount = Double(paymentData.amount) ?? 0.0
            
            let request = PKPaymentRequest()
            request.merchantIdentifier = applePayMerchantId
            request.supportedNetworks = self.supportedPaymentNetworks
            request.merchantCapabilities = PKMerchantCapability.capability3DS
            request.countryCode = "RU"
            request.currencyCode = paymentData.currency.rawValue
            
            
            let paymentSummaryItems = [PKPaymentSummaryItem(label: self.configuration.paymentData.description ?? "К оплате", amount: NSDecimalNumber.init(value: amount))]
            request.paymentSummaryItems = paymentSummaryItems
            
            if let applePayController = PKPaymentAuthorizationViewController(paymentRequest:
                                                                                request) {
                applePayController.delegate = self
                applePayController.modalPresentationStyle = .formSheet
                self.present(applePayController, animated: true, completion: nil)
            }
        }
    }
    
    @objc private func onSetupApplePay(_ sender: UIButton) {
        PKPassLibrary().openPaymentSetup()
    }
    
    @IBAction private func onCard(_ sender: UIButton) {
        openCardForm()
    }
    
    private func openCardForm() {
        self.hide { [weak self] in
            guard let self = self else {
                return
            }
            self.onCardOptionSelected?()
        }
    }
    
    //MARK: - PKPaymentAuthorizationViewControllerDelegate -
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            if let status = self.applePaymentSucceeded {
                let state: PaymentProcessForm.State
                
                if status {
                    state = .succeeded(self.resultTransaction)
                } else {
                    state = .failed(self.errorMessage)
                }
                
                let parent = self.presentingViewController
                self.dismiss(animated: true) { [weak self] in
                    guard let self = self else {
                        return
                    }
                    if parent != nil {
                        PaymentProcessForm.present(with: self.configuration, cryptogram: nil, email: nil, state: state, from: parent!, completion: nil)
                    }
                }
            }
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        if let cryptogram = payment.convertToString() {
            if (configuration.useDualMessagePayment) {
                self.auth(cardCryptogramPacket: cryptogram, email: nil) { [weak self] status, canceled, transaction, errorMessage in
                    guard let self = self else {
                        return
                    }
                    self.applePaymentSucceeded = status
                    self.resultTransaction = transaction
                    self.errorMessage = errorMessage
                    
                    if status {
                        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                    } else {
                        var errors = [Error]()
                        if let message = errorMessage {
                            let userInfo = [NSLocalizedDescriptionKey: message]
                            let error = PKPaymentError(.unknownError, userInfo: userInfo)
                            errors.append(error)
                        }
                        completion(PKPaymentAuthorizationResult(status: .failure, errors: errors))
                    }
                }
            } else {
                self.charge(cardCryptogramPacket: cryptogram, email: nil) { [weak self] status, canceled, transaction, errorMessage in
                    guard let self = self else {
                        return
                    }
                    self.applePaymentSucceeded = status
                    self.resultTransaction = transaction
                    self.errorMessage = errorMessage
                    
                    if status {
                        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                    } else {
                        var errors = [Error]()
                        if let message = errorMessage {
                            let userInfo = [NSLocalizedDescriptionKey: message]
                            let error = PKPaymentError(.unknownError, userInfo: userInfo)
                            errors.append(error)
                        }
                        completion(PKPaymentAuthorizationResult(status: .failure, errors: errors))
                    }
                }
            }
        } else {
            completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.failure, errors: []))
        }
    }
    
    // Обработайте результат оплаты
    func yandexPayButton(_ button: YandexPayButton, didCompletePaymentWithResult result: YPPaymentResult) {
        switch result {
        case .succeeded(let paymentInfo):
            // Оплата была совершена успешно
            if let decodedData = Data(base64Encoded: paymentInfo.paymentToken),
               let decodedToken = String(data: decodedData, encoding: .utf8) {
                if (configuration.useDualMessagePayment) {
                    self.auth(cardCryptogramPacket: decodedToken, email: nil) { [weak self] status, canceled, transaction, errorMessage in
                        guard let self = self else {
                            return
                        }
                        
                        let state: PaymentProcessForm.State
                        
                        if status {
                            state = .succeeded(self.resultTransaction)
                        } else {
                            state = .failed(self.errorMessage)
                        }
                        
                        let parent = self.presentingViewController
                        self.dismiss(animated: true) { [weak self] in
                            guard let self = self else {
                                return
                            }
                            if parent != nil {
                                PaymentProcessForm.present(with: self.configuration, cryptogram: nil, email: nil, state: state, from: parent!, completion: nil)
                            }
                        }
                    }
                } else {
                    self.charge(cardCryptogramPacket: decodedToken, email: nil) { [weak self] status, canceled, transaction, errorMessage in
                        guard let self = self else {
                            return
                        }
                        
                        let state: PaymentProcessForm.State
                        
                        if status {
                            state = .succeeded(self.resultTransaction)
                        } else {
                            state = .failed(self.errorMessage)
                        }
                        
                        let parent = self.presentingViewController
                        self.dismiss(animated: true) { [weak self] in
                            guard let self = self else {
                                return
                            }
                            if parent != nil {
                                PaymentProcessForm.present(with: self.configuration, cryptogram: nil, email: nil, state: state, from: parent!, completion: nil)
                            }
                        }
                    }
                }
            }
            break
        case .failed(let paymentError):
            print("Error!: \(paymentError)")
            break
            // В процессе оплаты произошла ошибка
        case .cancelled: break
            // Пользователь закрыл/смахнул форму YandexPay
        @unknown default: break
            
        }
    }
    
    // Предоставьте UIViewController, с которого необходимо показать форму YandexPay по нажатию на кнопку
    func yandexPayButtonDidRequestViewControllerForPresentation(_ button: YandexPayButton) -> UIViewController? {
        return self
    }
    
    // Предоставьте информацию о продавце и о корзине
    func yandexPayButtonDidRequestPaymentSheet(_ button: YandexPayButton) -> YPPaymentSheet? {
        
        return YPPaymentSheet(
            // Код страны
            countryCode: .ru,
            // Код валюты
            currencyCode: .rub,
            // Информация о мерчанте
            merchant: YPMerchant(
                // ID мерчанта в системе YandexPay
                id: self.configuration.paymentData.yandexPayMerchantId ?? "",
                name: "Cloud",
                url: "cp.ru"
            ),
            // Информация о заказе
            order: YPOrder(
                // ID заказа
                id: "ORDER-ID",
                // Стоимость заказа
                amount: self.configuration.paymentData.amount
            ),
            // Доступные способы оплаты
            paymentMethods: [
                // Пока что доступна только оплата картой
                .card(
                    YPCardPaymentMethod(
                        // ID поставщика платежных услуг
                        gateway: "cloudpayments",
                        // ID продавца в системе поставщика платежных услуг
                        gatewayMerchantId: self.configuration.paymentData.accountId ?? "",
                        // Что будет содержаться в платежном токене: зашифрованные данные банковской карты или токенизированная карта
                        allowedAuthMethods: [
                            .panOnly
                        ],
                        // Список поддерживаемых платежных систем
                        allowedCardNetworks: [
                            .mastercard,
                            .visa,
                            .mir
                        ]
                    )
                )
            ]
        )
    }
}

