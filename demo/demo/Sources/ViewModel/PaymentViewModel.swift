//
//  PaymentViewModel.swift
//  demo
//
//  Created by Cloudpayments on 27.06.2023.
//  Copyright © 2023 Cloudpayments. All rights reserved.
//

enum PaymentViewModelType: Codable {
    case api
    case publicId
    case amount
    case currency
    case invoiceId
    case description
    case accountId
    case email
    case payerFirstName
    case payerLastName
    case payerMiddleName
    case payerBirthday
    case payerAddress
    case payerStreet
    case payerCity
    case payerCountry
    case payerPhone
    case payerPostcode
    case jsonData
    
    //title
    var title: String {
        switch self {
        case .api: return "Api (Only for testing):"
        case .publicId: return "PublicId:"
        case .amount: return "Amount:"
        case .currency: return "Currency (Optional):"
        case .invoiceId: return "InvoiceId (Optional):"
        case .description: return "Description (Optional):"
        case .accountId: return "AccountId (Optional):"
        case .email: return "Email (Optional):"
        case .payerFirstName: return "Payer.FirstName (Optional):"
        case .payerLastName: return "Payer.LastName (Optional):"
        case .payerMiddleName: return "Payer.MiddleName (Optional):"
        case .payerBirthday: return "Payer.Birthday (Optional):"
        case .payerAddress: return "Payer.Address (Optional):"
        case .payerStreet: return "Payer.Street (Optional):"
        case .payerCity: return "Paver.City (Optional):"
        case .payerCountry: return "Payer.Country (Optional):"
        case .payerPhone: return "Payer.Phone (Optional):"
        case .payerPostcode: return "Payer.Postcode (Optional):"
        case .jsonData: return "JsonData (Optional):"
        }
    }
    
    //text
    var `default`: String {
        switch self {
        case .api: return "https://api-preprod.cloudpayments.ru/"
        case .publicId: return "test_api_00000000000000000000002"
        case .amount: return "100"
        case .currency: return "RUB"
        case .invoiceId: return "AB1234"
        case .description: return "A basket of oranges"
        case .accountId: return "AB12"
        case .email: return "test@cp.ru"
        case .payerFirstName: return "Vasya"
        case .payerLastName: return  "Ivanov"
        case .payerMiddleName: return "Semionovich"
        case .payerBirthday: return "1955-02-24"
        case .payerAddress: return "home 8, room 36"
        case .payerStreet: return "Lenina"
        case .payerCity: return "Moscow"
        case .payerCountry: return "RU-ru"
        case .payerPhone: return "89991234567"
        case .payerPostcode: return "123456"
        case .jsonData: return "{\"name\": \"Ivan\"}"
        }
    }
    
    //placeholder
    var placeholder: String { return "Введите текст" }
}

struct PaymentViewModel: Codable {
    private static var key: String { return "PaymentViewModel_Key"}
    
    let type: PaymentViewModelType
    var text: String?
    
    init(_ type: PaymentViewModelType) {
        self.type = type
        self.text = type.default
    }
    
    static func getViewModel() -> [PaymentViewModel] {
        guard let data = UserDefaults.standard.data(forKey: PaymentViewModel.key),
              let array = try? JSONDecoder().decode([PaymentViewModel].self, from: data)
        else {
            return [
                .init(.api),
                .init(.publicId),
                .init(.amount),
                .init(.currency),
                .init(.invoiceId),
                .init(.description),
                .init(.accountId),
                .init(.email),
                .init(.payerFirstName),
                .init(.payerLastName),
                .init(.payerMiddleName),
                .init(.payerBirthday),
                .init(.payerAddress),
                .init(.payerStreet),
                .init(.payerCity),
                .init(.payerCountry),
                .init(.payerPhone),
                .init(.payerPostcode),
                .init(.jsonData)
            ]
        }
        
        return array
    }
    
    static func saving(_ model: [PaymentViewModel]) {
        let data = try? JSONEncoder().encode(model)
        UserDefaults.standard.set(data, forKey: PaymentViewModel.key)
        UserDefaults.standard.synchronize()
    }
}

