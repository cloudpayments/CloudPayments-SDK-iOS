import Alamofire
import AlamofireObjectMapper
import ObjectMapper

public class CloudpaymentsApi {
    private let defaultCardHolderName = "Cloudpayments SDK"
    
    private let threeDsSuccessURL = "https://demo.cloudpayments.ru/success"
    private let threeDsFailURL = "https://demo.cloudpayments.ru/fail"
    
    private let session: Session
    private let publicId: String
    
    private var threeDsCompletion: ((_ result: ThreeDsResponse) -> ())?
    
    lazy var redirectHandler = self
    
    required init(publicId: String) {
        let handler = ThreeDsRedirectHandler(threeDsSuccessURL: threeDsSuccessURL, threeDsFailURL: threeDsFailURL)
        self.session = Session.init(redirectHandler: handler)
        self.publicId = publicId
        
        handler.api = self
    }
    
    
    public func charge(cardCryptogramPacket: String, cardHolderName: String?, amount: String, currency: Currency = .ruble, completion: @escaping HTTPRequestCompletion<TransactionResponse>) {
        self.threeDsCompletion = nil
        
        let parameters: Parameters = [
            "Amount" : "\(amount)", // Сумма платежа (Обязательный)
            "Currency" : currency.rawValue, // Валюта (Обязательный)
            "IpAddress" : "", // IP адрес плательщика (Обязательный)
            "Name" : cardHolderName ?? defaultCardHolderName, // Имя держателя карты в латинице (Обязательный для всех платежей кроме Apple Pay и Google Pay)
            "CardCryptogramPacket" : cardCryptogramPacket, // Криптограмма платежных данных (Обязательный)
        ]
        
        let request = HTTPRequest(resource: .charge, method: .post, parameters: parameters)
        makeObjectRequest(request, completion: completion)
    }
    
    public func auth(cardCryptogramPacket: String, cardHolderName: String?, amount: String, currency: Currency = .ruble, completion: @escaping HTTPRequestCompletion<TransactionResponse>) {
        self.threeDsCompletion = nil
        
        let parameters: Parameters = [
            "Amount" : "\(amount)", // Сумма платежа (Обязательный)
            "Currency" : currency.rawValue, // Валюта (Обязательный)
            "IpAddress" : "",
            "Name" : cardHolderName ?? defaultCardHolderName, // Имя держателя карты в латинице (Обязательный для всех платежей кроме Apple Pay и Google Pay)
            "CardCryptogramPacket" : cardCryptogramPacket, // Криптограмма платежных данных (Обязательный)
        ]
        
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
        validatedDataRequest(from: request).responseObject { (dataResponse) in
            completion?(dataResponse.value, dataResponse.error)
        }
    }
    
    func makeArrayRequest<T: BaseMappable>(_ request: HTTPRequest, completion: HTTPRequestCompletion<[T]>?) {
        validatedDataRequest(from: request).responseArray(completionHandler: { (dataResponse) in
            completion?(dataResponse.value, dataResponse.error)
        })
    }
}

// MARK: - Private methods

private extension CloudpaymentsApi {
    
    func validatedDataRequest(from httpRequest: HTTPRequest) -> DataRequest {
        var parameters = httpRequest.parameters
        parameters["PublicId"] = self.publicId
        
        return session
            .request(httpRequest.resource,
                     method: httpRequest.method,
                     parameters: parameters,
                     encoding: JSONEncoding.default,
                     headers: httpRequest.headers)
            .validate()
    }
}
