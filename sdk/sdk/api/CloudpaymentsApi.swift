import Alamofire
import ObjectMapper

public class CloudpaymentsApi {
    enum Source: String {
        case cpForm = "Cloudpayments SDK iOS (Default form)"
        case ownForm = "Cloudpayments SDK iOS (Custom form)"
    }
    
    private let defaultCardHolderName = "Cloudpayments SDK"
    
    private let threeDsSuccessURL = "https://demo.cloudpayments.ru/success"
    private let threeDsFailURL = "https://demo.cloudpayments.ru/fail"
    
    private let session: Session
    private let publicId: String
    private let source: Source
    
    private var threeDsCompletion: ((_ result: ThreeDsResponse) -> ())?
    
    lazy var redirectHandler = self
    
    public required convenience init(publicId: String) {
        self.init(publicId: publicId, source: .ownForm)
    }
    
    init(publicId: String, source: Source) {
        let handler = ThreeDsRedirectHandler(threeDsSuccessURL: threeDsSuccessURL, threeDsFailURL: threeDsFailURL)
        self.session = Session.init(redirectHandler: handler)
        self.publicId = publicId
        self.source = source
        
        handler.api = self
    }
    
    public class func getBankInfo(cardNumber: String, completion: ((_ bankInfo: BankInfo?, _ error: CloudpaymentsError?) -> ())?) {
        let cleanCardNumber = Card.cleanCreditCardNo(cardNumber)
        guard cleanCardNumber.count >= 6 else {
            completion?(nil, CloudpaymentsError.init(message: "You must specify at least the first 6 digits of the card number"))
            return
        }
        
        let firstSixIndex = cleanCardNumber.index(cleanCardNumber.startIndex, offsetBy: 6)
        let firstSixDigits = String(cleanCardNumber[..<firstSixIndex])
        
        AF.request(String.init(format: "https://widget.cloudpayments.ru/Home/BinInfo?firstSixDigits=%@", firstSixDigits), method: .get, parameters: nil, headers: nil).responseObject { (response: DataResponse<BankInfoResponse, AFError>) in
            if let bankInfo = response.value?.bankInfo {
                completion?(bankInfo, nil)
            } else if let message = response.error?.localizedDescription {
                completion?(nil, CloudpaymentsError.init(message: message))
            } else {
                completion?(nil, CloudpaymentsError.defaultCardError)
            }
        }
    }
    
    public func charge(cardCryptogramPacket: String,
                       email: String?,
                       paymentData: PaymentData,
                       completion: @escaping HTTPRequestCompletion<TransactionResponse>) {
        self.threeDsCompletion = nil
        
        let parameters = generateParams(cardCryptogramPacket: cardCryptogramPacket,
                                        email: email,
                                        paymentData: paymentData)
        
        let request = HTTPRequest(resource: .charge, method: .post, parameters: parameters)
        makeObjectRequest(request, completion: completion)
    }
    
    public func auth(cardCryptogramPacket: String,
                     email: String?,
                     paymentData: PaymentData,
                     completion: @escaping HTTPRequestCompletion<TransactionResponse>) {
        self.threeDsCompletion = nil
        
        let parameters = generateParams(cardCryptogramPacket: cardCryptogramPacket,
                                        email: email,
                                        paymentData: paymentData)
        
        let request = HTTPRequest(resource: .auth, method: .post, parameters: parameters)
        makeObjectRequest(request, completion: completion)
    }
    
    public func post3ds(transactionId: String, threeDsCallbackId: String, paRes: String, completion: @escaping (_ result: ThreeDsResponse) -> ()) {
        let mdParams = ["TransactionId": transactionId,
                        "ThreeDsCallbackId": threeDsCallbackId,
                        "SuccessUrl": self.threeDsSuccessURL,
                        "FailUrl": self.threeDsFailURL]
        if let mdParamsData = try? JSONSerialization.data(withJSONObject: mdParams, options: .sortedKeys), let mdParamsStr = String.init(data: mdParamsData, encoding: .utf8) {
            let parameters: Parameters = [
                "MD" : mdParamsStr,
                "PaRes" : paRes
            ]
            
            self.threeDsCompletion = completion
            
            let completion: HTTPRequestCompletion<TransactionResponse> = { r, e in }
            
            let request = HTTPRequest(resource: .post3ds, method: .post, parameters: parameters)
            makeObjectRequest(request, completion: completion)
        } else {
            completion(ThreeDsResponse.init(success: false, cardHolderMessage: ""))
        }
    }
    
    private func generateParams(cardCryptogramPacket: String,
                                email: String?,
                                paymentData: PaymentData) -> Parameters {
        let parameters: Parameters = [
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
    
    private class ThreeDsRedirectHandler: RedirectHandler {
        private let threeDsSuccessURL: String
        private let threeDsFailURL: String
        var api: CloudpaymentsApi?
        
        init(threeDsSuccessURL: String, threeDsFailURL: String) {
            self.threeDsSuccessURL = threeDsSuccessURL
            self.threeDsFailURL = threeDsFailURL
        }
        
        public func task(_ task: URLSessionTask, willBeRedirectedTo request: URLRequest, for response: HTTPURLResponse, completion: @escaping (URLRequest?) -> Void) {
            if let url = request.url {
                let items = url.absoluteString.split(separator: "&").filter { $0.contains("CardHolderMessage")}
                var message: String? = nil
                if !items.isEmpty, let params = items.first?.split(separator: "="), params.count == 2 {
                    message = String(params[1]).removingPercentEncoding
                }
                
                if url.absoluteString.starts(with: threeDsSuccessURL) {
                    self.threeDsFinished(with: true, message: message)
                    completion(nil)
                } else if url.absoluteString.starts(with: threeDsFailURL) {
                    self.threeDsFinished(with: false, message: message)
                    completion(nil)
                } else {
                    completion(request)
                }
            } else {
                completion(request)
            }
        }
        
        private func threeDsFinished(with success: Bool, message: String?) {
            DispatchQueue.main.async {
                let result = ThreeDsResponse.init(success: success, cardHolderMessage: message)
                self.api?.threeDsCompletion?(result)
            }
        }
    }
}


// MARK: - Internal methods

extension CloudpaymentsApi {
    
    func makeObjectRequest<T: BaseMappable>(_ request: HTTPRequest, completion: HTTPRequestCompletion<T>?) {
        let url = (try? request.resource.asURL())?.absoluteString ?? ""
        
        print("--------------------------")
        print("sending request: \(url)")
        print("parameters: \(request.parameters as NSDictionary?)")
        print("--------------------------")
        
        validatedDataRequest(from: request).responseObject { (dataResponse) in
//            if let data = dataResponse.data, let dataStr = String.init(data: data, encoding: .utf8) {
//                print("--------------------------")
//                print("response for (\(url): \(dataStr)")
//                print("--------------------------")
//            }
            
            completion?(dataResponse.value, dataResponse.error)
        }
    }
    
    func makeArrayRequest<T: BaseMappable>(_ request: HTTPRequest, completion: HTTPRequestCompletion<[T]>?) {
        let url = (try? request.resource.asURL())?.absoluteString ?? ""
        
        print("--------------------------")
        print("sending request: \(url)")
        print("parameters: \(request.parameters as NSDictionary?)")
        print("--------------------------")
        
        validatedDataRequest(from: request).responseArray(completionHandler: { (dataResponse) in
//            if let data = dataResponse.data, let dataStr = String.init(data: data, encoding: .utf8) {
//                print("--------------------------")
//                print("response for (\(url): \(dataStr)")
//                print("--------------------------")
//            }
            
            completion?(dataResponse.value, dataResponse.error)
        })
    }
}

// MARK: - Private methods

private extension CloudpaymentsApi {
    
    func validatedDataRequest(from httpRequest: HTTPRequest) -> DataRequest {
        var parameters = httpRequest.parameters
        parameters["PublicId"] = self.publicId
        
        var headers = httpRequest.headers
        headers["MobileSDKSource"] = self.source.rawValue
        
        return session
            .request(httpRequest.resource,
                     method: httpRequest.method,
                     parameters: parameters,
                     encoding: JSONEncoding.default,
                     headers: httpRequest.headers)
            .validate()
    }
}
