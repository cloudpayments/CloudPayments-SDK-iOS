//
//  TinkoffPayRequest.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 16.06.2023.
//

import CloudpaymentsNetworking

class GatewayRequest {
    private class TinkoffPayRequestData<Model: Codable>: BaseRequest, CloudpaymentsRequestType {
        
        var data: CloudpaymentsNetworking.CloudpaymentsRequest
        typealias ResponseType = Model
        
        //MARK: - connect is on tinkoff pay button
        fileprivate init(baseURL: String, terminalPublicId: String?, paymentUrl: String?, language: String?) {
            let baseURL = baseURL + "merchant/configuration/"
            guard var path = URLComponents(string: baseURL) else {
                data = .init(path: "")
                return
            }
            
            let queryItems: [URLQueryItem] = [
                .init(name: "terminalPublicId", value: terminalPublicId),
                .init(name: "paymentUrl", value: paymentUrl),
                .init(name: "language", value: language),
            ]
            path.queryItems = queryItems
            
            let string = path.url?.absoluteString ?? ""
            data = .init(path: string)
        }
        
        //MARK: - QR Link
        fileprivate init(baseURL: String, model: TinkoffPayData) {
            let baseURL = baseURL + "payments/qr/tinkoffpay/link"
            
            var params = [
                "PublicId": model.publicId,
                "Amount" : model.amount,
                "AccountId": model.accountId,
                "InvoiceId": model.invoiceId,
                "Browser" : model.browser,
                "Currency" : model.currency,
                "Device" : "MobileApp",
                "Description" : model.description,
                "Email" : model.email,
                "IpAddress":model.ipAddress,
                "Os" : model.os,
                "Scheme" : model.scheme,
                "TtlMinutes" : model.ttlMinutes,
                "SuccessRedirectUrl" : model.successRedirectURL,
                "FailRedirectUrl" : model.failRedirectURL,
                "Webview" : true
            ] as [String : Any?]
            
            if let saveCard = model.saveCard {
                params["SaveCard"] = saveCard
            }
            
    
            data = .init(path: baseURL, method: .post, params: params)
        }
        
        //MARK: - get status transactionId
        fileprivate init(baseURL: String, transactionId: Int, publicId: String) {
            let baseURL = baseURL + "payments/qr/status/wait"
            
            let params = [
                "TransactionId": transactionId,
                "PublicId": publicId,
            ] as [String : Any?]
            
            data = .init(path: baseURL, method: .post, params: params)
        }
        
    }
}

extension GatewayRequest {
    
    public static func isOnTinkoffPayAction(baseURL: String, terminalPublicId: String?, paymentUrl: String?, language: String?, completion: @escaping (Bool, Int?) -> Void) {
        
        TinkoffPayRequestData<GatewayConfiguration>(baseURL: baseURL, terminalPublicId: terminalPublicId, paymentUrl: paymentUrl, language: language).execute { value in
           let array = value.model.externalPaymentMethods
            let id = value.model.features?.isSaveCard
            
            for element in array {
                guard let rawValue = element.type, let value = CaseOfBank(rawValue: rawValue) else { continue }
                
                if CaseOfBank.tinkoff == value {
                    return completion(element.enabled, id)
                }
            }
            
            return completion(false, id)
            
        } onError: { string in
            GatewayRequest.resultDataPrint(type: GatewayConfiguration.self, string.localizedDescription)
            return completion(false, nil)
        }
    }
    
    public static func isTinkoffQrLink(baseURL: String, model: TinkoffPayData, completion: @escaping (TinkoffResultModel?) -> Void) {
        TinkoffPayRequestData<TinkoffResultPayData>(baseURL: baseURL, model: model).execute { value in
//            GatewayRequest.resultDataPrint(type: ResultTinkoffPayData.self, value)
            return completion(value.model)
            
        } onError: { string in
            GatewayRequest.resultDataPrint(type: TinkoffResultPayData.self, string.localizedDescription)
            return completion(nil)
        }
    }
    
    public static func getStatusTransactionId(baseURL: String, publicId: String, transactionId: Int) {
        let model = TinkoffPayRequestData<TinkoffRepsonseTransactionModel>(baseURL: baseURL, transactionId: transactionId, publicId: publicId)
        
        model.execute { value in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TinkoffStatusPayObserver"), object: value)

        } onError: { string in
            GatewayRequest.resultDataPrint(type: TinkoffRepsonseTransactionModel.self, string.localizedDescription)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TinkoffStatusPayObserver"), object: string)
            return
        }
    }
    
    public static func resultDataPrint<T:Decodable>(type: T.Type, _ value: Any? ) {
        print("\n\n")
        print(#line)
        print("-----------------------", type.self, "-----------------------")
        print("\n", value, "\n")
        print("-----------------------", "end", "-----------------------")
        print("\n\n")
    }
}

enum StatusPay: String {
    case created = "Created"
    case pending = "Pending"
    case authorized = "Authorized"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case declined = "Declined"
}
