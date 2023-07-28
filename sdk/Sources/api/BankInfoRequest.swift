//
//  BankInfoRequest.swift
//  Cloudpayments
//
//  Created by Sergey Iskhakov on 01.07.2021.
//

import CloudpaymentsNetworking

class BankInfoRequest: BaseRequest, CloudpaymentsRequestType {
    private let firstSix: String
    init(firstSix: String) {
        self.firstSix = firstSix
    }
    typealias ResponseType = BankInfoResponse
    var data: CloudpaymentsRequest {
        return CloudpaymentsRequest(path: "https://api.cloudpayments.ru/bins/info/\(firstSix)", method: .get)
    }
}


extension BankInfoRequest {
    
    func downloadPublicKey() {
      

        
        let string = PublicKeyData.apiURL + "payments/publickey"
        guard let url = URL(string: string) else {return}
        let request = URLRequest(url: url, timeoutInterval: 10.0)
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
           
            guard let data = data else {
                //TODO: open result for error
                print(error?.localizedDescription ?? "")
                return
            }
            
            print(String.init(data: data, encoding: .utf8)!)
            
            guard let value = try? JSONDecoder().decode(PublicKeyData.self, from: data) else {
                print(#line, #function)
                //TODO: open result for error
                return
            }
            value.save()
        }
        task.resume()
    }
}
