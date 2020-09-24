import ObjectMapper

class Transaction: Mappable {
    
    private(set) var transactionId = Int()
    
    private(set) var reasonCode = Int()
    
    private(set) var cardHolderMessage = String()
    
    private(set) var paReq = String()
    
    private(set) var acsUrl = String()
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        transactionId       <- map["TransactionId"]
        reasonCode          <- map["ReasonCode"]
        cardHolderMessage   <- map["CardHolderMessage"]
        paReq               <- map["PaReq"]
        acsUrl              <- map["AcsUrl"]
    }
}
