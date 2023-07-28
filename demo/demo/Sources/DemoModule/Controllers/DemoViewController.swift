//
//  DemoViewController.swift
//  demo
//
//  Created by Cloudpayments on 31/05/2019.
//  Copyright © 2019 Cloudpayments. All rights reserved.
//

import UIKit
import Cloudpayments

class DemoViewController: BaseViewController {
    // MARK: - Private properties
    @IBOutlet private weak var tableView: UITableView!
    
    private var viewModels = PaymentViewModel.getViewModel()
    private let header = LogoHeaderView()
    private let footer = FooterActionView()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // MARK: - Private methods
    private func setupTableView() {
        view.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        configureHeaderAndFooter(tableView)
    }
    
    private func configureHeaderAndFooter(_ tableView: UITableView) {
        
        enum Constants: CGFloat {
            case headerHeight = 80
            case footerWidth = 250
            case footerHeight = 120
            case position = 0
            
            func toCGFloat() -> CGFloat { return self.rawValue }
        }
        
        header.frame = CGRect(x: Constants.position.toCGFloat(), y: Constants.position.toCGFloat(), width: view.bounds.width, height: Constants.headerHeight.toCGFloat())
        tableView.tableHeaderView = header
        
        footer.frame = CGRect(x: Constants.position.toCGFloat(), y: Constants.position.toCGFloat(), width: Constants.footerWidth.toCGFloat(), height: Constants.footerHeight.toCGFloat())
        footer.addTarget(target: self, action: #selector(run(_:)))
        tableView.tableFooterView = footer
    }
    
    func getText(_ type: PaymentViewModelType) -> String? {
        for value in viewModels {
            if value.type == type { return value.text }
        }
        return nil
    }
    
    // MARK: - Button run
    @objc private func run(_ sender: UIButton) {
        PaymentViewModel.saving(viewModels)
        
        guard let apiUrl = getText(.api),
              let publicId =  getText(.publicId),
              let amount = getText(.amount),
              let currency = getText(.currency),
              let invoiceId =  getText(.invoiceId),
              let descript = getText(.description),
              let account = getText(.accountId),
              let email = getText(.email),
              let payerFirstName = getText(.payerFirstName),
              let payerLastName = getText(.payerLastName),
              let payerMiddleName = getText(.payerMiddleName),
              let payerBirthday = getText(.payerBirthday),
              let payerAddress = getText(.payerAddress),
              let payerStreet = getText(.payerStreet),
              let payerCity = getText(.payerCity),
              let payerCountry = getText(.payerCountry),
              let payerPhone = getText(.payerPhone),
              let payerPostcode = getText(.payerPostcode),
              let jsonData = getText(.jsonData)
        else { return }
        
        
        let payer = PaymentDataPayer(
            firstName: payerFirstName,
            lastName: payerLastName,
            middleName: payerMiddleName,
            birth: payerBirthday,
            address: payerAddress,
            street: payerStreet,
            city: payerCity,
            country: payerCountry,
            phone: payerPhone,
            postcode: payerPostcode
        )

        let paymentData = PaymentData()
            .setAmount(amount)
            .setCurrency(currency)
            .setApplePayMerchantId(Constants.applePayMerchantID)
            .setYandexPayMerchantId(Constants.yandexPayMerchantID)
            .setCardholderName("CP SDK")
            .setIpAddress("98.21.123.32")
            .setInvoiceId(invoiceId)
            .setDescription(descript)
            .setAccountId(account)
            .setPayer(payer)
            .setEmail(email)
            .setJsonData(jsonData)

        let configuration = PaymentConfiguration(
            publicId: publicId,
            paymentData: paymentData,
            delegate: self,
            uiDelegate: self,
            scanner: nil,
            requireEmail: false,
            useDualMessagePayment: footer.demoActionSwitch.isOn,
            disableApplePay: true,
            disableYandexPay: true,
            apiUrl: apiUrl,
            changedEmail: nil
        )

        PaymentForm.present(with: configuration, from: self)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DemoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DemoViewCell.identifier, for: indexPath) as? DemoViewCell else {
            return UITableViewCell()
        }
        let value = viewModels[indexPath.row]
        cell.setupView(viewModel: value)
        cell.addTarget(self, action: #selector(textFieldEditing(_:)), row: indexPath.row)
        return cell
    }
    
    @objc private func textFieldEditing(_ textField: UITextField) {
        let row = textField.tag
        viewModels[row].text = textField.text
    }
}

// MARK: - PaymentDelegate
extension DemoViewController: PaymentDelegate {
    func onPaymentFinished(_ transactionId: Int?) {
        navigationController?.popViewController(animated: true)
        
        if let transactionId = transactionId {
            print("Transaction finished with ID: \(transactionId)")
        }
    }
    
    func onPaymentFailed(_ errorMessage: String?) {
        if let errorMessage = errorMessage {
            print("Transaction failed with error: \(errorMessage)")
        }
    }
}

extension DemoViewController: PaymentUIDelegate {
    func paymentFormWillDisplay() {
        print("Payment form will display")
    }
    
    func paymentFormDidDisplay() {
        print("Payment form did display")
    }
    
    func paymentFormWillHide() {
        print("Payment form will hide")
    }
    
    func paymentFormDidHide() {
        print("Payment form did hide")
    }
}

