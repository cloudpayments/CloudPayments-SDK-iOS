//
//  CloudpaymentsURLSessionNetworkDispatcher.swift
//  Cloudpayments
//
//  Created by Sergey Iskhakov on 01.07.2021.
//

import Foundation

public protocol CloudpaymentsNetworkDispatcher {
    func dispatch(request: CloudpaymentsRequest,
                  onSuccess: @escaping (Data) -> Void,
                  onError: @escaping (Error) -> Void,
                  onRedirect: ((URLRequest) -> Bool)?)
}

public class CloudpaymentsURLSessionNetworkDispatcher: NSObject, CloudpaymentsNetworkDispatcher {
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    
    public static let instance = CloudpaymentsURLSessionNetworkDispatcher()
    
    private var onRedirect: ((URLRequest) -> Bool)?
    
    public func dispatch(request: CloudpaymentsRequest,
                         onSuccess: @escaping (Data) -> Void,
                         onError: @escaping (Error) -> Void,
                         onRedirect: ((URLRequest) -> Bool)? = nil) {
        self.onRedirect = onRedirect
        
        guard let url = URL(string: request.path) else {
            onError(CloudpaymentsConnectionError.invalidURL)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        do {
            if !request.params.isEmpty {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: request.params, options: [])
            }
        } catch let error {
            onError(error)
            return
        }
        
        var headers = request.headers
        headers["Content-Type"] = "application/json"
        urlRequest.allHTTPHeaderFields = headers
        
        session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                onError(error)
                return
            }
            
            guard let data = data else {
                onError(CloudpaymentsConnectionError.noData)
                return
            }
            
            onSuccess(data)
        }.resume()
    }
}

extension CloudpaymentsURLSessionNetworkDispatcher: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let _ = onRedirect?(request) {
            completionHandler(request)
        } else {
            completionHandler(nil)
        }
    }
}
