import ObjectMapper

struct Transaction: Mappable {
    
    private(set) var transactionId = Int()
    private(set) var reasonCode = Int()
    private(set) var cardHolderMessage = String()
    private(set) var paReq = String()
    private(set) var acsUrl = String()
    private(set) var threeDsCallbackId = String()
    
    public init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        transactionId       <- map["TransactionId"]
        reasonCode          <- map["ReasonCode"]
        cardHolderMessage   <- map["CardHolderMessage"]
        paReq               <- map["PaReq"]
        acsUrl              <- map["AcsUrl"]
        threeDsCallbackId   <- map["ThreeDsCallbackId"]
    }
}
