//
//  ThreeDSDialog.swift
//  sdk
//
//  Created by Sergey Iskhakov on 09.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation
import WebKit
import Alamofire

public protocol ThreeDsDelegate: class {
    func willPresentWebView(_ webView: WKWebView)
    func onAuthorizationCompleted(with md: String, paRes: String)
    func onAuthorizationFailed(with html: String)
}

public class ThreeDsProcessor: NSObject, WKNavigationDelegate {
    private static let POST_BACK_URL = "https://demo.cloudpayments.ru/WebFormPost/GetWebViewData"
    
    private weak var delegate: ThreeDsDelegate?
    
    public func make3DSPayment(with data: ThreeDsData, delegate: ThreeDsDelegate) {
        self.delegate = delegate
        
        if let url = URL.init(string: data.acsUrl) {
            var request = URLRequest.init(url: url)
            request.httpMethod = "POST"
            request.cachePolicy = .reloadIgnoringCacheData
            
            let requestBody = String.init(format: "MD=%@&PaReq=%@&TermUrl=%@", data.transactionId, data.paReq, ThreeDsProcessor.POST_BACK_URL).replacingOccurrences(of: "+", with: "%2B")
            request.httpBody = requestBody.data(using: .utf8)
            
            URLCache.shared.removeCachedResponse(for: request)
            
            AF.request(request)
                .response(completionHandler: { (dataResponse) in
                    if let httpResponse = dataResponse.response, (httpResponse.statusCode == 200 || httpResponse.statusCode == 201), let data = dataResponse.value {
                        let webView = WKWebView.init()
                        webView.navigationDelegate = self
                        if let mimeType = httpResponse.mimeType, let textEncodingName = httpResponse.textEncodingName, let url = httpResponse.url {
                            webView.load(data!, mimeType: mimeType, characterEncodingName: textEncodingName, baseURL: url)
                        }
                        
                        self.delegate?.willPresentWebView(webView)
                    } else {
                        let statusCode = dataResponse.response?.statusCode ?? 0
                        self.delegate?.onAuthorizationFailed(with: "Unable to load 3DS autorization page.\nStatus code: \(statusCode)")
                    }
                })
                .validate()
        }
    }

    //MARK: - WKNavigationDelegate -
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let url = webView.url
        
        if url?.absoluteString.elementsEqual(ThreeDsProcessor.POST_BACK_URL) == true {
            webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (result, error) in
                var str = result as? String ?? ""
                repeat {
                    let startIndex = str.firstIndex(of: "{")
                    if startIndex == nil {
                        break
                    }
                    
                    let endIndex = str.lastIndex(of: "}")
                    if endIndex == nil {
                        break
                    }
                    str = String(str[startIndex!...endIndex!])
                    if let data = str.data(using: .utf8), let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                        if let md = dict["MD"] as? String, let paRes = dict["PaRes"] as? String {
                            self.delegate?.onAuthorizationCompleted(with: md, paRes: paRes)
                        } else {
                            self.delegate?.onAuthorizationFailed(with: str)
                        }
                        
                        return
                    }
                } while false

                self.delegate?.onAuthorizationFailed(with: str)
            }
        }
    }
}
