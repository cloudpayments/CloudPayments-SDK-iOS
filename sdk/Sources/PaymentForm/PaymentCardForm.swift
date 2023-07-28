//
//  BasePaymentForm.swift
//  sdk
//
//  Created by Sergey Iskhakov on 16.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import UIKit

enum EyeStatus: String {
    case open = "icn_eye_open"
    case closed = "icn_eye_closed"
    
    func toString() -> String {
        return self.rawValue
    }
    
    var image: UIImage? {
        switch self {
        case .open:
            return UIImage.named(rawValue)
        case .closed:
            return UIImage.named(rawValue)
        }
    }
}

enum ValidState {
    case border
    case error
    case normal
    case text
    
    var color: UIColor {
        switch self {
        case .border:
            return .border
        case .error:
            return .errorBorder
        case .normal:
            return .mainBlue
        case .text:
            return .mainText
        }
    }
}

enum PlaceholderType: String {
    case correctCard = "Номер карты"
    case incorrectCard = "Некорректный номер карты"
    case correctExpDate = "ММ / ГГ"
    case incorrectExpDate = "Ошибка в дате"
    case correctCvv = "СVV"
    case incorrectCvv = "Ошибка в CVV"
    
    func toString() -> String {
        return self.rawValue
    }
}

enum InputFieldType {
    case card
    case expDate
    case cvv
}

extension TextField {
    var cardExpText: String? {
        get {self.text?.replacingOccurrences(of: " ", with: "") }
        set {self.text = newValue?.onlyNumbers().formattedString(mask: "XX / XX", ignoredSymbols: nil)}
    }
}

public class PaymentCardForm: PaymentForm {
    // MARK: - Private properties
    @IBOutlet private weak var cardNumberTextField: TextField!
    @IBOutlet private weak var cardExpDateTextField: TextField!
    @IBOutlet private weak var cardCvvTextField: TextField!
    @IBOutlet private weak var containerCardBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var mainCardStackView: UIStackView!
    @IBOutlet private weak var iconCvvCard: UIImageView!
    @IBOutlet private weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var scanButton: Button!
    @IBOutlet private weak var payButton: Button!
    @IBOutlet private weak var cardTypeIcon: UIImageView!
    @IBOutlet private weak var cardLabel: UILabel!
    @IBOutlet private weak var cardView: View!
    @IBOutlet private weak var expDateView: View!
    @IBOutlet private weak var cvvView: View!
    @IBOutlet private weak var cardPlaceholder: UILabel!
    @IBOutlet private weak var expDatePlaceholder: UILabel!
    @IBOutlet private weak var cvvPlaceholder: UILabel!
    @IBOutlet private weak var stackInpitMainStackView: UIStackView!
    @IBOutlet private weak var eyeOpenButton: Button!
    
    lazy var defaultHeight: CGFloat = self.mainCardStackView.frame.height
    let dismissibleHigh: CGFloat = 400
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    lazy var currentContainerHeight: CGFloat = mainCardStackView.frame.height
    
    var onPayClicked: ((_ cryptogram: String, _ email: String?) -> ())?

    @discardableResult
    public class func present(with configuration: PaymentConfiguration, from: UIViewController, completion: (() -> ())?) -> PaymentForm? {
        let storyboard = UIStoryboard.init(name: "PaymentForm", bundle: Bundle.mainSdk)
        
        guard let controller = storyboard.instantiateViewController(withIdentifier: "PaymentForm") as? PaymentForm else {
            return nil
        }
        
        controller.configuration = configuration
        controller.show(inViewController: from, completion: completion)
        
        return controller
    }
    
    func updatePayButtonState() {
        let isValid = isValid()
        setButtonsAndContainersEnabled(isEnabled: isValid)
    }
    
    private func setButtonsAndContainersEnabled(isEnabled: Bool) {
        self.payButton.isUserInteractionEnabled = isEnabled
        self.payButton.setAlpha(isEnabled ? 1.0 : 0.3)
    }
    
    @objc private func secureButtonTapped(_ sender: UIButton) {
        cardCvvTextField.becomeFirstResponder()
        let isSelected = sender.isSelected
        sender.isSelected = !isSelected
        cardCvvTextField.isSecureTextEntry = !isSelected
        
        let image = isSelected ? EyeStatus.open.image : EyeStatus.closed.image
        eyeOpenButton.setImage(image, for: .normal)
    }
    
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    func setupEyeButton() {
        eyeOpenButton.addTarget(self, action: #selector(secureButtonTapped), for: .touchUpInside)
        eyeOpenButton.setImage(UIImage(named: EyeStatus.closed.toString()), for: .normal)
        eyeOpenButton.tintColor = .clear
        eyeOpenButton.isSelected = true
        cardCvvTextField.isSecureTextEntry = true
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupEyeButton()
        setupPanGesture()
        containerHeightConstraint.constant = mainCardStackView.frame.height
        
        let paymentData = self.configuration.paymentData
        
        self.payButton.setTitle("Оплатить \(paymentData.amount) \(Currency.getCurrencySign(code: paymentData.currency))", for: .normal)
        
        self.payButton.onAction = { [weak self] in
            guard let self = self else {
                return
            }

            guard self.isValid(), let cryptogram = Card.makeCardCryptogramPacket(self.cardNumberTextField.text!, expDate: self.cardExpDateTextField.cardExpText!, cvv: self.cardCvvTextField.text!, merchantPublicID: self.configuration.publicId)
            else {
                self.showAlert(title: .errorWord, message: String.errorCreatingCryptoPacket)
                return
            }

            DispatchQueue.main.async {
                self.dismiss(animated: true) { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.onPayClicked?(cryptogram, self.configuration.changedEmail)
                }
            }
        }
        
        if configuration.scanner == nil {
            scanButton.isHidden = true
        } else {
            self.scanButton.onAction = { [weak self] in
                guard let self = self else {
                    return
                }
                if let controller = self.configuration.scanner?.startScanner(completion: { number, month, year, cvv in
                    self.cardNumberTextField.text = number?.formattedCardNumber()
                    if let month = month, let year = year {
                        let y = year % 100
                        self.cardExpDateTextField.cardExpText = String(format: "%02d/%02d", month, y)
                    }
                    self.cardCvvTextField.text = cvv
                    
                    self.updatePaymentSystemIcon(cardNumber: number)
                }) {
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
        configureTextFields()
        hideKeyboardWhenTappedAround()
        setButtonsAndContainersEnabled(isEnabled: false)
    }
    
    func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentContainer()
        containerHeightConstraint.constant = defaultHeight
    }
    
    // MARK: Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Drag to top will be minus value and vice versa
        
        // Get drag direction
        let isDraggingDown = translation.y > 0
        
        // New height is based on value of dragging plus current container height
        let newHeight = currentContainerHeight - translation.y
        
        // Handle based on gesture state
        switch gesture.state {
        case .changed:
            // This state will occur when user is dragging
            if newHeight < maximumContainerHeight {
                // Keep updating the height constraint
                containerHeightConstraint?.constant = newHeight
                // refresh layout
                view.layoutIfNeeded()
            }
            
            if newHeight > defaultHeight && !isDraggingDown  {
                //self.emailTextField.becomeFirstResponder()
                UIView.animate(withDuration: 0.9) {
                    self.containerHeightConstraint?.constant = self.defaultHeight
                }
            }
        case .ended:
            // This happens when user stop drag,
            // so we will get the last height of container
            
            // Condition 1: If new height is below min, dismiss controller
            if newHeight < dismissibleHigh {
                self.animateDismissView()
                let parent = self.presentingViewController
                self.dismiss(animated: true) {
                    if let parent = parent {
                        if !self.configuration.disableApplePay || !self.configuration.disableYandexPay {
                            PaymentForm.present(with: self.configuration, from: parent)
                        } else {
                            PaymentForm.present(with: self.configuration, from: parent)
                        }
                    }
                }
                
            }
            else if newHeight < defaultHeight {
                // Condition 2: If new height is below default, animate back to default
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                // Condition 3: If new height is below max and going down, set to default height
                animateContainerHeight(defaultHeight)
            }
        default:
            break
        }
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            // Update container height
            self.containerCardBottomConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }
    
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerCardBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    func animateDismissView() {
        // hide main view by updating bottom constraint in animation block
        self.dismiss(animated: false)
        UIView.animate(withDuration: 0.3) {
            self.containerCardBottomConstraint?.constant = self.defaultHeight
            
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }

    func setInputFieldValues(fieldType: InputFieldType, placeholderColor: UIColor, placeholderText: String, borderViewColor: UIColor, textFieldColor: UIColor? = .mainText ) {
        switch fieldType {
        case .card:
            self.cardPlaceholder.textColor = placeholderColor
            self.cardPlaceholder.text = placeholderText
            self.cardView.layer.borderColor = borderViewColor.cgColor
            self.cardNumberTextField.textColor = textFieldColor
        case .expDate:
            self.expDatePlaceholder.textColor = placeholderColor
            self.expDatePlaceholder.text = placeholderText
            self.expDateView.layer.borderColor = borderViewColor.cgColor
            self.cardExpDateTextField.textColor = textFieldColor
        case .cvv:
            self.cvvPlaceholder.textColor = placeholderColor
            self.cvvPlaceholder.text = placeholderText
            self.cvvView.layer.borderColor = borderViewColor.cgColor
            self.cardCvvTextField.textColor = textFieldColor
        }
    }
    
    private func configureTextFields() {
        
        [cardNumberTextField, cardExpDateTextField, cardCvvTextField].forEach { textField in
            textField.addTarget(self, action: #selector(didChange(_:)), for: .editingChanged)
            textField.addTarget(self, action: #selector(didBeginEditing(_:)), for: .editingDidBegin)
            textField.addTarget(self, action: #selector(didEndEditing(_:)), for: .editingDidEnd)
            textField.addTarget(self, action: #selector(shouldReturn(_:)), for: .editingDidEndOnExit)
        }
    }
    
    private func isValid() -> Bool {
        let cardNumberIsValid = Card.isCardNumberValid(self.cardNumberTextField.text?.formattedCardNumber())
        let cardExpIsValid = Card.isExpDateValid(self.cardExpDateTextField.cardExpText?.formattedCardExp())
        let cardCvvIsValid = Card.isCvvValid(self.cardNumberTextField.text?.formattedCardNumber(), self.cardCvvTextField.text?.formattedCardCVV())
        
        self.validateAndErrorCardNumber()
        self.validateAndErrorCardExp()
        self.validateAndErrorCardCVV()
        
        return cardNumberIsValid && cardExpIsValid && cardCvvIsValid
    }
    
    private func validateAndErrorCardNumber(){
        if let cardNumber = self.cardNumberTextField.text?.formattedCardNumber() {
            self.cardNumberTextField.isErrorMode = !Card.isCardNumberValid(cardNumber)
        }
    }
    
    private func validateAndErrorCardExp(){
        if let cardExp = self.cardExpDateTextField.cardExpText?.formattedCardExp() {
            let text = cardExp.replacingOccurrences(of: " ", with: "")
            self.cardExpDateTextField.isErrorMode = !Card.isExpDateValid(text)
        }
    }
    
    private func validateAndErrorCardCVV(){
        self.cardCvvTextField.isErrorMode = !Card.isCvvValid(self.cardNumberTextField.text?.formattedCardNumber(), self.cardCvvTextField.text)
    }
    
    private func updatePaymentSystemIcon(cardNumber: String?){
        if let number = cardNumber {
            let cardType = Card.cardType(from: number)
            if cardType != .unknown {
                self.cardTypeIcon.image = cardType.getIcon()
                self.cardTypeIcon.isHidden = false
                self.scanButton.isHidden = true
            } else {
                self.cardTypeIcon.isHidden = true
                self.scanButton.isHidden = self.configuration.scanner == nil
            }
        } else {
            self.cardTypeIcon.isHidden = true
            self.scanButton.isHidden = self.configuration.scanner == nil
        }
    }
    
    @objc internal override func onKeyboardWillShow(_ notification: Notification) {
        super.onKeyboardWillShow(notification)
        
        self.containerCardBottomConstraint.constant = self.keyboardFrame.height
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    @objc internal override func onKeyboardWillHide(_ notification: Notification) {
        super.onKeyboardWillHide(notification)
        
        self.containerCardBottomConstraint.constant = 0
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
}


//MARK: - Delegates for TextField
extension PaymentCardForm {
    /// Did Begin Editings
    /// - Parameter textField:
    @objc private func didBeginEditing(_ textField: UITextField) {
        
        switch textField {
            
        case cardNumberTextField:
            if let cardNumber = cardNumberTextField.text?.formattedCardNumber() {
                cardNumberTextField.text = cardNumber
                
                if !cardNumber.isEmpty || !Card.isCardNumberValid(cardNumber) {
                    setInputFieldValues(fieldType: .card, placeholderColor: ValidState.border.color, placeholderText: PlaceholderType.correctCard.toString(), borderViewColor: ValidState.normal.color, textFieldColor: ValidState.text.color)
                }
            }
            
        case cardExpDateTextField:
            if let cardExp = cardExpDateTextField.cardExpText?.formattedCardExp() {
                cardExpDateTextField.cardExpText = cardExp
                
                if !cardExp.isEmpty || !Card.isExpDateValid(cardExp) {
                    setInputFieldValues(fieldType: .expDate, placeholderColor: ValidState.border.color, placeholderText: PlaceholderType.correctExpDate.toString(), borderViewColor: ValidState.normal.color, textFieldColor: ValidState.text.color)
                }
            }
            
        case cardCvvTextField:
            if let text = cardCvvTextField.text?.formattedCardCVV() {
                cardCvvTextField.text = text
                
                let cardNumber = cardNumberTextField.text?.formattedCardNumber()
                
                if !cardCvvTextField.isEmpty || !Card.isCvvValid(cardNumber, text) {
                    setInputFieldValues(fieldType: .cvv, placeholderColor: ValidState.border.color, placeholderText: PlaceholderType.correctCvv.toString(), borderViewColor: ValidState.normal.color, textFieldColor: ValidState.text.color)
                }
            }
        default: break
        }
    }
    
    /// Did Change
    /// - Parameter textField:
    @objc private func didChange(_ textField: UITextField) {
        
        switch textField {
            
        case cardNumberTextField:
            updatePayButtonState()
            
            if let cardNumber = cardNumberTextField.text?.formattedCardNumber() {
                cardNumberTextField.text = cardNumber
                
                updatePaymentSystemIcon(cardNumber: cardNumber)
                
                if cardNumber.isEmpty {
                    setInputFieldValues(fieldType: .card, placeholderColor: ValidState.border.color, placeholderText: PlaceholderType.correctCard.toString(), borderViewColor: ValidState.normal.color)
                    return
                }
                
                if Card.isCardNumberValid(cardNumber) {
                    setInputFieldValues(fieldType: .card, placeholderColor: ValidState.border.color, placeholderText: PlaceholderType.correctCard.toString(), borderViewColor: ValidState.normal.color)
                }
                
                let cleanCardNumber = cardNumber.clearCardNumber()
                
                //MAX CARD NUMBER LENGHT
                cardNumberTextField.isErrorMode = cleanCardNumber.count == 19
            }
            
        case cardExpDateTextField:
            updatePayButtonState()
            
            if let cardExp = cardExpDateTextField.cardExpText?.formattedCardExp() {
                cardExpDateTextField.cardExpText = cardExp
                cardExpDateTextField.isErrorMode = false
                
                if cardExp.isEmpty {
                    setInputFieldValues(fieldType: .expDate, placeholderColor: ValidState.border.color, placeholderText: PlaceholderType.correctExpDate.toString(), borderViewColor: ValidState.normal.color)
                    return
                }
                
                if Card.isExpDateValid(cardExp) {
                    setInputFieldValues(fieldType: .expDate, placeholderColor: ValidState.border.color, placeholderText: PlaceholderType.correctExpDate.toString(), borderViewColor: ValidState.normal.color)
                }
            }
            
        case cardCvvTextField:
            updatePayButtonState()
            
            if let text = cardCvvTextField.text?.formattedCardCVV() {
                cardCvvTextField.text = text
                
                iconCvvCard.isHidden = !cardCvvTextField.isEmpty
                eyeOpenButton.isHidden = cardCvvTextField.isEmpty
                cardCvvTextField.isErrorMode = false
                
                if text.isEmpty {
                    setInputFieldValues(fieldType: .cvv, placeholderColor: ValidState.border.color, placeholderText: PlaceholderType.correctCvv.toString(), borderViewColor: ValidState.normal.color)
                    iconCvvCard.isHidden = false
                    return
                }
                
                let cardNumber = cardNumberTextField.text?.formattedCardNumber()
                
                if Card.isCvvValid(cardNumber, text) {
                    setInputFieldValues(fieldType: .cvv, placeholderColor: ValidState.border.color, placeholderText: PlaceholderType.correctCvv.toString(), borderViewColor: ValidState.normal.color)
                }
                
                if text.count == 4 {
                    cardCvvTextField.resignFirstResponder()
                }
            }
        default: break
        }
    }
    
    /// Did End Editing
    /// - Parameter textField:
    @objc private func didEndEditing(_ textField: UITextField) {
        
        switch textField {
            
        case cardNumberTextField:
            if let cardNumber = cardNumberTextField.text?.formattedCardNumber() {
                cardNumberTextField.text = cardNumber
                
                if !Card.isCardNumberValid(cardNumber) {
                    setInputFieldValues(fieldType: .card, placeholderColor: ValidState.error.color, placeholderText: PlaceholderType.incorrectCard.toString(), borderViewColor: ValidState.error.color)
                    
                    if cardNumber.isEmpty {
                        setInputFieldValues(fieldType: .card, placeholderColor: ValidState.error.color, placeholderText: PlaceholderType.correctCard.toString(), borderViewColor: ValidState.error.color)
                    }
                }
                else {
                    cardView.layer.borderColor = ValidState.border.color.cgColor
                }
                validateAndErrorCardNumber()
            }
            
        case cardExpDateTextField:
            if let cardExp = cardExpDateTextField.cardExpText?.formattedCardExp() {
                cardExpDateTextField.cardExpText = cardExp
                
                if !Card.isExpDateValid(cardExp) {
                    setInputFieldValues(fieldType: .expDate, placeholderColor: ValidState.error.color, placeholderText: PlaceholderType.incorrectExpDate.toString(), borderViewColor: ValidState.error.color)
                    
                    if cardExp.isEmpty {
                        setInputFieldValues(fieldType: .expDate, placeholderColor: ValidState.error.color, placeholderText: PlaceholderType.correctExpDate.toString(), borderViewColor: ValidState.error.color)
                    }
                }
                else {
                    expDateView.layer.borderColor = ValidState.border.color.cgColor
                }
                validateAndErrorCardExp()
            }
            
        case cardCvvTextField:
            if let cardCvv = cardCvvTextField.text?.formattedCardCVV() {
                cardCvvTextField.text = cardCvv
                
                let cardNumber = cardNumberTextField.text?.formattedCardNumber()
                
                if !Card.isCvvValid(cardNumber, cardCvv) {
                    setInputFieldValues(fieldType: .cvv, placeholderColor: ValidState.error.color, placeholderText: PlaceholderType.incorrectCvv.toString(), borderViewColor: ValidState.error.color)
                    
                    if cardCvv.isEmpty {
                        setInputFieldValues(fieldType: .cvv, placeholderColor: ValidState.error.color, placeholderText: PlaceholderType.correctCvv.toString(), borderViewColor: ValidState.error.color)
                    }
                }
                else {
                    cvvView.layer.borderColor = ValidState.border.color.cgColor
                    cvvPlaceholder.textColor = ValidState.border.color
                    
                }
                validateAndErrorCardCVV()
            }
        default: break
        }
    }

    /// Should Return
        /// - Parameter textField:
        @objc private func shouldReturn(_ textField: UITextField) {

            switch textField {

            case cardNumberTextField:

                if let cardNumber = self.cardNumberTextField.text?.formattedCardNumber() {
                    self.cardNumberTextField.resignFirstResponder()
                    if Card.isCardNumberValid(cardNumber) {
                        self.cardExpDateTextField.becomeFirstResponder()
                    }
                }
            case cardExpDateTextField:

                if let cardExp = self.cardExpDateTextField.text?.formattedCardExp() {
                    if cardExp.count == 5 {
                        self.cardCvvTextField.becomeFirstResponder()
                    }
                }

            case cardCvvTextField:

                if let text = self.cardCvvTextField.text?.formattedCardCVV() {
                    if text.count == 3 || text.count == 4 {
                        self.cardCvvTextField.resignFirstResponder()
                    }
                }
            default: break
            }
        }
}
