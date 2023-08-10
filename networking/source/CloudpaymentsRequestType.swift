//
//  CloudpaymentsRequestType.swift
//  Cloudpayments
//
//  Created by Sergey Iskhakov on 01.07.2021.
//

public protocol CloudpaymentsRequestType {
    associatedtype ResponseType: Codable
    var data: CloudpaymentsRequest { get }
}

public extension CloudpaymentsRequestType {
    
    
//    func resultDataPrint<T:Decodable>(type: T.Type, _ value: Data) {
//        print("\n\n")
//        print(#file, "\n", #line, #function)
//        print("-----------------------", type.self, "-----------------------")
//        if let string = String(data: value, encoding: .utf8) {
//            print("\n", string, "\n")
//        }
//        print("-----------------------", "end", "-----------------------")
//        print("\n\n")
//    }
    
    
    func execute(dispatcher: CloudpaymentsNetworkDispatcher = CloudpaymentsURLSessionNetworkDispatcher.instance,
                 keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                 onSuccess: @escaping (ResponseType) -> Void,
                 onError: @escaping (Error) -> Void,
                 onRedirect: ((URLRequest) -> Bool)? = nil) {
        dispatcher.dispatch(
            request: self.data,
            onSuccess: { (responseData: Data) in
                do {
                    
//                    resultDataPrint(type: ResponseType.self, responseData)
                    
                    
                    
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
                    let result = try jsonDecoder.decode(ResponseType.self, from: responseData)
                    DispatchQueue.main.async {
                        onSuccess(result)
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        if error is DecodingError {
                            onError(CloudpaymentsError.parseError)
                        } else {
                            onError(error)
                        }
                    }
                }
            },
            onError: { (error: Error) in
                DispatchQueue.main.async {
                    onError(error)
                }
            }, onRedirect: onRedirect
        )
    }
}

