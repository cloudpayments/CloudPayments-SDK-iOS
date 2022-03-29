import Foundation
import CloudpaymentsNetworking

public class CloudpaymentsApi {
    enum Source: String {
        case cpForm = "Cloudpayments SDK iOS (Default form)"
        case ownForm = "Cloudpayments SDK iOS (Custom form)"
    }
    
    private static let baseURLString = "https://api.cloudpayments.ru/"
    
    private let defaultCardHolderName = "Cloudpayments SDK"
    
    private let threeDsSuccessURL = "https://demo.cloudpayments.ru/success"
    private let threeDsFailURL = "https://demo.cloudpayments.ru/fail"
    
    private let publicId: String
    private let source: Source
        
    public required convenience init(publicId: String) {
        self.init(publicId: publicId, source: .ownForm)
    }
    
    init(publicId: String, source: Source) {
        self.publicId = publicId
        self.source = source
    }
    
    public class func getBankInfo(cardNumber: String, completion: ((_ bankInfo: BankInfo?, _ error: CloudpaymentsError?) -> ())?) {
        let cleanCardNumber = Card.cleanCreditCardNo(cardNumber)
        guard cleanCardNumber.count >= 6 else {
            completion?(nil, CloudpaymentsError.init(message: "You must specify at least the first 6 digits of the card number"))
            return
        }
        
        let firstSixIndex = cleanCardNumber.index(cleanCardNumber.startIndex, offsetBy: 6)
        let firstSixDigits = String(cleanCardNumber[..<firstSixIndex])
        
        BankInfoRequest(firstSix: firstSixDigits).execute(keyDecodingStrategy: .convertToUpperCamelCase, onSuccess: { response in
            completion?(response.model, nil)
        }, onError: { error in
            if !error.localizedDescription.isEmpty  {
                completion?(nil, CloudpaymentsError.init(message: error.localizedDescription))
            } else {
                completion?(nil, CloudpaymentsError.defaultCardError)
            }
        })
    }
    
    public func charge(cardCryptogramPacket: String,
                       email: String?,
                       paymentData: PaymentData,
                       completion: @escaping CloudpaymentsRequestCompletion<TransactionResponse>) {
        let parameters = generateParams(cardCryptogramPacket: cardCryptogramPacket,
                                        email: email,
                                        paymentData: paymentData)
        ChargeRequest(params: patch(params: parameters), headers: getDefaultHeaders()).execute(keyDecodingStrategy: .convertToUpperCamelCase, onSuccess: { response in
            completion(response, nil)
        }, onError: { error in
            completion(nil, error)
        })
    }
    
    public func auth(cardCryptogramPacket: String,
                     email: String?,
                     paymentData: PaymentData,
                     completion: @escaping CloudpaymentsRequestCompletion<TransactionResponse>) {
        let parameters = generateParams(cardCryptogramPacket: cardCryptogramPacket,
                                        email: email,
                                        paymentData: paymentData)
        AuthRequest(params: patch(params: parameters), headers: getDefaultHeaders()).execute(keyDecodingStrategy: .convertToUpperCamelCase, onSuccess: { response in
            completion(response, nil)
        }, onError: { error in
            completion(nil, error)
        })
    }
    
    public func post3ds(transactionId: String, threeDsCallbackId: String, paRes: String, completion: @escaping (_ result: ThreeDsResponse) -> ()) {
        let mdParams = ["TransactionId": transactionId,
                        "ThreeDsCallbackId": threeDsCallbackId,
                        "SuccessUrl": self.threeDsSuccessURL,
                        "FailUrl": self.threeDsFailURL]
        if let mdParamsData = try? JSONSerialization.data(withJSONObject: mdParams, options: .sortedKeys), let mdParamsStr = String.init(data: mdParamsData, encoding: .utf8) {
            let parameters: [String: Any] = [
                "MD" : mdParamsStr,
                "PaRes" : paRes
            ]

            PostThreeDsRequest(params: parameters, headers: getDefaultHeaders()).execute(keyDecodingStrategy: .convertToUpperCamelCase, onSuccess: { r in
            }, onError: { error in
            }, onRedirect: { [weak self] request in
                guard let self = self else {
                    return true
                }
                
                if let url = request.url {
                    let items = url.absoluteString.split(separator: "&").filter { $0.contains("CardHolderMessage")}
                    var message: String? = nil
                    if !items.isEmpty, let params = items.first?.split(separator: "="), params.count == 2 {
                        message = String(params[1]).removingPercentEncoding
                    }

                    if url.absoluteString.starts(with: self.threeDsSuccessURL) {
                        DispatchQueue.main.async {
                            let r = ThreeDsResponse.init(success: true, cardHolderMessage: message)
                            completion(r)
                        }
                        
                        return false
                    } else if url.absoluteString.starts(with: self.threeDsFailURL) {
                        DispatchQueue.main.async {
                            let r = ThreeDsResponse.init(success: false, cardHolderMessage: message)
                            completion(r)
                        }
                        
                        return false
                    } else {
                        return true
                    }
                } else {
                    return true
                }
            })
        } else {
            completion(ThreeDsResponse.init(success: false, cardHolderMessage: ""))
        }
    }
    
    private func generateParams(cardCryptogramPacket: String,
                                email: String?,
                                paymentData: PaymentData) -> [String: Any] {
        let parameters: [String: Any] = [
            "Amount" : paymentData.amount, // Сумма платежа (Обязательный)
            "Currency" : paymentData.currency.rawValue, // Валюта (Обязательный)
            "IpAddress" : paymentData.ipAddress ?? "",
            "Name" : paymentData.cardholderName ?? defaultCardHolderName, // Имя держателя карты в латинице (Обязательный для всех платежей кроме Apple Pay и Google Pay)
            "CardCryptogramPacket" : cardCryptogramPacket, // Криптограмма платежных данных (Обязательный)
            "Email" : email ?? "", // E-mail, на который будет отправлена квитанция об оплате
            "InvoiceId" : paymentData.invoiceId ?? "", // Номер счета или заказа в вашей системе (Необязательный)
            "Description" : paymentData.description ?? "", // Описание оплаты в свободной форме (Необязательный)
            "AccountId" : paymentData.accountId ?? "", // Идентификатор пользователя в вашей системе (Необязательный)
            "JsonData" : paymentData.jsonData ?? "" // Любые другие данные, которые будут связаны с транзакцией, в том числе инструкции для создания подписки или формирования онлайн-чека (Необязательный)
        ]
        
        return parameters
    }

    private func patch(params: [String: Any]) -> [String: Any] {
        var parameters = params
        parameters["PublicId"] = self.publicId
        return parameters
    }
    
    private func getDefaultHeaders() -> [String: String] {
        var headers = [String: String]()
        headers["MobileSDKSource"] = self.source.rawValue
        return headers
    }
}

public typealias CloudpaymentsRequestCompletion<T> = (_ response: T?, _ error: Error?) -> Void

private struct CloudpaymentsCodingKey: CodingKey {
    var stringValue: String

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int? {
        return nil
    }

    init?(intValue: Int) {
        return nil
    }
}

extension JSONDecoder.KeyDecodingStrategy {
    static var convertToUpperCamelCase: JSONDecoder.KeyDecodingStrategy {
        return .custom({ keys -> CodingKey in
            let lastKey = keys.last!
            if lastKey.intValue != nil {
                return lastKey
            }
            
            let firstLetter = lastKey.stringValue.prefix(1).lowercased()
            let modifiedKey = firstLetter + lastKey.stringValue.dropFirst()
            return CloudpaymentsCodingKey(stringValue: modifiedKey)
        })
    }
}
