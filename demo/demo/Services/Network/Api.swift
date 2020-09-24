import Alamofire

extension NetworkService {
    
    func charge(cardCryptogramPacket: String, cardHolderName: String, amount: Int, completion: @escaping (AFResult<TransactionResponse>) -> Void) {
        
        // Параметры:
        let parameters: Parameters = [
            "amount" : "\(amount)", // Сумма платежа (Обязательный)
            "currency" : "RUB", // Валюта (Обязательный)
            "name" : cardHolderName, // Имя держателя карты в латинице (Обязательный для всех платежей кроме Apple Pay и Google Pay)
            "card_cryptogram_packet" : cardCryptogramPacket, // Криптограмма платежных данных (Обязательный)
            "invoice_id" : "1111", // Номер счета или заказа в вашей системе (Необязательный)
            "description" : "Оплата цветов", // Описание оплаты в свободной форме (Необязательный)
            "account_id" : "222", // Идентификатор пользователя в вашей системе (Необязательный)
            "JsonData" : "{\"age\":27,\"name\":\"Ivan\",\"phone\":\"+79998881122\"}" // Любые другие данные, которые будут связаны с транзакцией (Необязательный)
        ]
        
        let request = HTTPRequest(resource: .charge, method: .post, parameters: parameters)
        makeObjectRequest(request, completion: completion)
    }
    
    func auth(cardCryptogramPacket: String, cardHolderName: String, amount: Int, completion: @escaping (AFResult<TransactionResponse>) -> Void) {
        
        // Параметры:
        let parameters: Parameters = [
            "amount" : "\(amount)", // Сумма платежа (Обязательный)
            "currency" : "RUB", // Валюта (Обязательный)
            "name" : cardHolderName, // Имя держателя карты в латинице (Обязательный для всех платежей кроме Apple Pay и Google Pay)
            "card_cryptogram_packet" : cardCryptogramPacket, // Криптограмма платежных данных (Обязательный)
            "invoice_id" : "1111", // Номер счета или заказа в вашей системе (Необязательный)
            "description" : "Оплата цветов", // Описание оплаты в свободной форме (Необязательный)
            "account_id" : "222", // Идентификатор пользователя в вашей системе (Необязательный)
            "json_data" : "{\"age\":27,\"name\":\"Ivan\",\"phone\":\"+79998881122\"}" // Любые другие данные, которые будут связаны с транзакцией (Необязательный)
        ]
        
        let request = HTTPRequest(resource: .auth, method: .post, parameters: parameters)
        
        /*let parameters: [String: String] = [
            "amount" : "111",
            "currency" : "RUB"
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        
        let request = HTTPRequest(resource: .auth, method: .post, parameters: [:], encoding: "myBody", headers: [:])*/
                        
        makeObjectRequest(request, completion: completion)
    }
    
    func post3ds(transactionId: String, paRes: String, completion: @escaping (AFResult<TransactionResponse>) -> Void) {
        
        let parameters: Parameters = [
            "transaction_id" : transactionId,
            "pa_res" : paRes
        ]
        
        let request = HTTPRequest(resource: .post3ds, method: .post, parameters: parameters)
        makeObjectRequest(request, completion: completion)
    }
}
