//
//  PaymentSourceForm.swift
//  sdk
//
//  Created by Cloudpayments on 16.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import UIKit
import PassKit
import YandexPaySDK

enum EmailType: String {
    case incorrectEmail = "Некорректный e-mail"
    case receiptEmail = "E-mail для квитанции"
    case defaultEmail = "E-mail"

    func toString() -> String {
        return self.rawValue
    }
}

final class PaymentOptionsForm: PaymentForm, PKPaymentAuthorizationViewControllerDelegate, YandexPayButtonDelegate {
    // MARK: - Private Properties
    // main stackView
    @IBOutlet private weak var mainStackView: UIStackView!
    // containers
    @IBOutlet private weak var yandexPayContainer: View!
    @IBOutlet private weak var applePayContainer: View!
    @IBOutlet private weak var payWithCardButton: Button!
    // mainViewInputReceiptButton and button
    @IBOutlet private weak var mainViewInputReceiptButton: FooterForPresentCard!
    // emailView,emailInputView,attentionView and attentionImage
    private var emailTextField: TextField {
        get { return mainViewInputReceiptButton.emailTextField }
        set { mainViewInputReceiptButton.emailTextField = newValue }
    }
    private var emailPlaceholder: UILabel! {
        get { return mainViewInputReceiptButton.emailLabel }
        set { mainViewInputReceiptButton.emailLabel = newValue}
    }
    // container constraints
    @IBOutlet private weak var containerViewHeightConstraint:NSLayoutConstraint!
    @IBOutlet private weak var bottomContainerViewConstraint: NSLayoutConstraint!
    // main container views
    @IBOutlet private weak var mainAppleView: View!
    @IBOutlet private weak var mainYandexView: View!
    @IBOutlet private weak var mainTinkoffView: View!
    @IBOutlet private weak var tinkoffButton: Button!

    private let alertInfoView = AlertInfoView()
    private var constraint: NSLayoutConstraint!
    
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
    
    // MARK: - Public Properties
    lazy var defaultHeight: CGFloat = mainStackView.frame.height 
    let dismissibleHigh: CGFloat = 300
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    lazy var currentContainerHeight: CGFloat = mainStackView.frame.height
    
    // MARK: - Public methods
    var onCardOptionSelected: (() -> ())?
    
    @discardableResult
    public class func present(with configuration: PaymentConfiguration, from: UIViewController, completion: (() -> ())?) -> PaymentForm {
        let storyboard = UIStoryboard.init(name: "PaymentForm", bundle: Bundle.mainSdk)
        
        let controller = storyboard.instantiateViewController(withIdentifier: "PaymentOptionsForm") as! PaymentOptionsForm
    
        controller.configuration = configuration
        controller.show(inViewController: from, completion: completion)
        
        return controller
    }
    
    // MARK: - Lifecycle app
    override func viewDidLoad() {
        super.viewDidLoad()
        isReceiptButtonEnabled(configuration.requireEmail)
        alertInfoView.isHidden = true
        setupButton()
        configureContainers()
        self.hideKeyboardWhenTappedAround()
        emailTextField.delegate = self
        setupEmailPlaceholder()
        setupPanGesture()
        isOnTinkoffPay(configuration: configuration)

        view.addSubview(alertInfoView)
        alertInfoView.translatesAutoresizingMaskIntoConstraints = false
        alertInfoView.alpha = 0

        NSLayoutConstraint.activate([
            alertInfoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertInfoView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])

        constraint = alertInfoView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        constraint.isActive = true
    }

    private func isOnTinkoffPay(configuration: PaymentConfiguration) {
        let terminalPublicId = configuration.publicId
        let baseUrl = configuration.apiUrl
        GatewayRequest.isOnTinkoffPayAction(baseURL: baseUrl, terminalPublicId: terminalPublicId) { [weak self] isOn, isOnSaveCard in
            DispatchQueue.main.async {
                self?.tinkoffButton.superview?.isHidden = !isOn
                self?.tinkoffButton.isHidden = !isOn
                self?.setupCheckbox(isOnSaveCard)
            }
        }
    }
    
    @IBAction func dismissModalButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentContainer()
    }
    
    func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Drag to top will be minus value and vice versa
        
        // Get drag direction
        _ = translation.y > 0

        // New height is based on value of dragging plus current container height
        let newHeight = currentContainerHeight - translation.y
        
        // Handle based on gesture state
        switch gesture.state {
        case .changed:
            //This state will occur when user is dragging
            if newHeight < maximumContainerHeight {
                // Keep updating the height constraint
                
                // refresh layout
                view.layoutIfNeeded()
            }
            
//            if newHeight > defaultHeight && !isDraggingDown  {
//            }
        
            if newHeight < defaultHeight {
                // Condition 2: If new height is below default, animate back to default
                animateContainerHeight(defaultHeight)
                //containerViewHeightConstraint?.constant = newHeight
            }
        default:
            break
        }
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        
        UIView.animate(withDuration: 0.4) {
            // Update container height
            self.bottomContainerViewConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismiss(animated: false)
        }
        // Save current height
        currentContainerHeight = height
    }
    
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.bottomContainerViewConstraint?.constant = 0
            // call this to trigger refresh constraint
            
            self.view.layoutIfNeeded()
        }
    }
    
    func animateDismissView() {
        // hide main view by updating bottom constraint in animation block
        self.dismiss(animated: false)
        UIView.animate(withDuration: 0.5) {
            self.bottomContainerViewConstraint?.constant = self.defaultHeight
            
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Private methods
    private func setButtonsAndContainersEnabled(isEnabled: Bool) {
        let views: [UIView?] = [payWithCardButton, applePayContainer, yandexPayContainer, tinkoffButton]

        views.forEach {
            guard let view = $0 else { return }

            view.isUserInteractionEnabled = isEnabled
            view.alpha = isEnabled ? 1.0 : 0.3
        }
    }
    
    private func resetEmailView(isReceiptSelected: Bool, isEmailViewHidden: Bool, isEmailTextFieldHidden: Bool) {
        mainViewInputReceiptButton.isSelectedReceipt = isReceiptSelected
        mainViewInputReceiptButton.emailView.isHidden = isEmailViewHidden
        emailTextField.isHidden = isEmailTextFieldHidden
    }
    
    @objc private func tinkoffButtonAction(_ sender: UIButton) {
        guard let parent = self.presentingViewController else { return }

        self.dismiss(animated: true) { [weak self] in
            self?.pushPayForTinkoff(state: .inProgressTinkoff, parent)
        }
    }

    func pushPayForTinkoff(state: PaymentProcessForm.State, _ vc: UIViewController) {
        let isOnSaveCard = mainViewInputReceiptButton.isSelectedSave
        PaymentProcessForm.present(with: self.configuration, cryptogram: nil, email: nil, state: .inProgressTinkoff, from: vc, isOnTinkoffPay: true, isOnSaveCard: isOnSaveCard)
    }

    private func setupButton() {
        emailTextField.text = configuration.paymentData.email
        configuration.changedEmail = configuration.paymentData.email
        
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.baseBackgroundColor = .blackColor
            configuration.baseForegroundColor = .whiteColor
            configuration.imagePadding = 10
            tinkoffButton.configuration = configuration
        } else {
            tinkoffButton.imageEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
            tinkoffButton.titleEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        }

        tinkoffButton.semanticContentAttribute = .forceRightToLeft
        tinkoffButton.addTarget(self, action: #selector(tinkoffButtonAction(_:)), for: .touchUpInside)
        

        if configuration.requireEmail {
            resetEmailView(isReceiptSelected: false, isEmailViewHidden: false, isEmailTextFieldHidden: false)
            
            if emailTextField.isEmpty {
                setButtonsAndContainersEnabled(isEnabled: false)
            }
        }
        
        if configuration.requireEmail == false {
            resetEmailView(isReceiptSelected: true, isEmailViewHidden: true, isEmailTextFieldHidden: true)
            emailTextField.isUserInteractionEnabled = true

            if emailTextField.isEmpty {
                resetEmailView(isReceiptSelected: false, isEmailViewHidden: true, isEmailTextFieldHidden: true)
                self.setButtonsAndContainersEnabled(isEnabled: true)
                
            }
            else {
                resetEmailView(isReceiptSelected: true, isEmailViewHidden: false, isEmailTextFieldHidden: false)
            }
        }
        
        mainViewInputReceiptButton.addTarget(self, action: #selector(receiptButtonAction(_:)), type: .receipt)
        mainViewInputReceiptButton.addTarget(self, action: #selector(saveButtonAction(_:)), type: .saving)
        mainViewInputReceiptButton.addTarget(self, action: #selector(infoButtonAction(_:)), type: .info)
    }
    
    private func normalEmailState() {
        self.emailPlaceholder.text = EmailType.defaultEmail.toString()
        self.mainViewInputReceiptButton.emailBorderColor = UIColor.mainBlue
        self.emailTextField.textColor = UIColor.mainText
        self.emailPlaceholder.textColor = UIColor.border
        self.setButtonsAndContainersEnabled(isEnabled: false)
    }
    
    private func isReceiptButtonEnabled(_ isEnabled: Bool ) {
        mainViewInputReceiptButton.isHiddenAttentionView = !isEnabled
        mainViewInputReceiptButton.isHiddenCardView = isEnabled
        
        if isEnabled {
            mainViewInputReceiptButton.emailView.isHidden = false
            emailTextField.isHidden = false
        }
    }
    
    private func setupEmailPlaceholder() {
        emailPlaceholder.text = configuration.requireEmail ? EmailType.receiptEmail.toString() : EmailType.defaultEmail.toString()
    }
    
    private func configureContainers() {
        
        if configuration.disableApplePay == true {
            mainAppleView.isHidden = true
            applePayContainer.isHidden = true
        } else {
            initializeApplePay()
            
        }
        
        if configuration.disableYandexPay == true {
            mainYandexView.isHidden = true
            yandexPayContainer.isHidden = true
        } else {
            initializeYandexPay()
        }
    }
    
    @objc private func receiptButtonAction(_ sender: UIButton) {
        sender.isSelected.toggle()

        if sender.isSelected {
            self.configuration.changedEmail = self.emailTextField.text
        } else {
            self.configuration.changedEmail = nil
        }

        let isEmailValid = self.emailTextField.text?.emailIsValid() ?? false
        if sender.isSelected && isEmailValid == false {
            self.emailTextField.becomeFirstResponder()

            self.normalEmailState()

        } else {
            self.setButtonsAndContainersEnabled(isEnabled: true)

        }
        self.emailTextField.isHidden.toggle()
        self.mainViewInputReceiptButton.emailView.isHidden.toggle()
    }

    @objc private func saveButtonAction(_ sender: UIButton) {
        sender.isSelected.toggle()
    }

    @objc private func infoButtonAction(_ sender: UIButton) {
        sender.isSelected.toggle()
        setupPositionAlertView(sender)
        animation(sender.isSelected)
    }

    //MARK: - AlertView
    private func setupPositionAlertView(_ sender: UIButton) {
        let frame = sender.convert(sender.bounds, to: view)
        let height = view.bounds.height - frame.minY
        let x = frame.midX
        constraint.constant = -height
        alertInfoView.trianglPosition =  x
    }

    //MARK: - animation AlertView
    private func animation(_ preview: Bool) {
        self.alertInfoView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.alertInfoView.alpha = preview ? 1 : 0
        } completion: { _ in
            if !preview { self.alertInfoView.isHidden = true}
        }
    }

    //MARK: - setup Checkbox
    private func setupCheckbox(_ isSaveCard: Int?) {

        // accountId
        let accountId = configuration.paymentData.accountId
        let isOnAccountId = accountId != nil

        // recurrent
        var isOnRecurrent: Bool {
            guard let jsonData = configuration.paymentData.jsonData,
                  let data = jsonData.data(using: .utf8),
                  let value = try? JSONDecoder().decode(CloudPaymentsModel.self, from: data),
                  let _ = value.cloudPayments?.recurrent
            else { return false }
            return true
        }

        var checkBox: SaveCardState {
            switch (isOnAccountId, isOnRecurrent, isSaveCard) {
            case (false, _, _): return .none
            case (_, _, 0): return .none
            case (true, true, 1): return .isOnHint
            case (true, true, 2): return .isOnHint
            case (true, true, 3): return .isOnHint
            case (true, false, 1): return .none
            case (true, false, 2): return .isOnCheckbox
            case (true, false, 3): return .isOnHint
            default: return .none
            }
        }

        mainViewInputReceiptButton.setup(checkBox)
    }


    //MARK: - Keyboard
    @objc override func onKeyboardWillShow(_ notification: Notification) {
        super.onKeyboardWillShow(notification)
        self.bottomContainerViewConstraint.constant = -self.keyboardFrame.height
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    @objc override func onKeyboardWillHide(_ notification: Notification) {
        super.onKeyboardWillHide(notification)
        self.bottomContainerViewConstraint.constant = 0

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    private func isValid(email: String? = nil) -> Bool {
        // если email обязателен, то проверка на валидность
        if configuration.requireEmail, let emailIsValid = email?.emailIsValid() {
            return emailIsValid
        }
        
        if let email = email {
            let emailIsValid = !self.mainViewInputReceiptButton.isSelectedReceipt || email.emailIsValid() == true
            return emailIsValid
        }
        let emailIsValid = !self.mainViewInputReceiptButton.isSelectedReceipt || self.emailTextField.text?.emailIsValid() == true
        return emailIsValid
    }
    
    private func initializeYandexPay() {
              
        mainYandexView.isHidden = false
        yandexPayContainer.isHidden = false
        
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
        
        // Установите layout для кнопки
        yandexPayContainer.addSubview(button)
        button.bindFrameToSuperviewBounds()
    }
    
    private func initializeApplePay() {
        
        mainAppleView.isHidden = false
        applePayContainer.isHidden = false
        
        if let _  = configuration.paymentData.applePayMerchantId, PKPaymentAuthorizationViewController.canMakePayments() {
            let button: PKPaymentButton!
            if PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedPaymentNetworks) {
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
            
            applePayContainer.isHidden = false
            applePayContainer.addSubview(button)
            button.bindFrameToSuperviewBounds()
        } else {
            applePayContainer.isHidden = true
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
            request.currencyCode = paymentData.currency
            
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
                let parent = self.presentingViewController
                self.dismiss(animated: true) { [weak self] in
                    guard let self = self else {
                        return

                    }

                    if parent != nil {
                        PaymentProcessForm.present(with: self.configuration, cryptogram: decodedToken, email: nil, state: .inProgress, from: parent!, completion: nil)
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

extension PaymentOptionsForm: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,with: string)
            
            if isValid(email: updatedText) || updatedText.isEmpty {
                self.setButtonsAndContainersEnabled(isEnabled: true)
                configureEmailFieldToDefault(borderView: .mainBlue, textColor: .mainText, placeholderColor: .border)
                setupEmailPlaceholder()
                configuration.changedEmail = updatedText
                
                if updatedText.isEmpty {
                    mainViewInputReceiptButton.emailBorderColor = UIColor.mainBlue
                    self.setButtonsAndContainersEnabled(isEnabled: false)
                }
                
            }
            else {
                self.setButtonsAndContainersEnabled(isEnabled: false)
            }
        }
        return true
    }
    
    func configureEmailFieldToDefault(borderView: UIColor?, textColor: UIColor?, placeholderColor: UIColor?) {
        mainViewInputReceiptButton.emailBorderColor = borderView ?? .clear
        emailTextField.textColor = textColor
        emailPlaceholder.textColor = placeholderColor
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        configureEmailFieldToDefault(borderView: .mainBlue, textColor: .mainText, placeholderColor: .border)
        setupEmailPlaceholder()
    }
    
    func showErrorStateForEmail(with message: String, borderView: UIColor?, textColor: UIColor?, placeholderColor: UIColor?) {
        emailTextField.textColor = textColor
        mainViewInputReceiptButton.emailBorderColor = borderView ?? .clear
        emailPlaceholder.textColor = placeholderColor
        emailPlaceholder.text = message
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let emailIsValid = emailTextField.text?.emailIsValid()
        
        if emailIsValid == false {
            setButtonsAndContainersEnabled(isEnabled: false)
            showErrorStateForEmail(with: EmailType.incorrectEmail.toString() , borderView: .errorBorder, textColor: .errorBorder, placeholderColor: .errorBorder)
        } else {
            mainViewInputReceiptButton.emailBorderColor = UIColor.border
            setButtonsAndContainersEnabled(isEnabled: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
