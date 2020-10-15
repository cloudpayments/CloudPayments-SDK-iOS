import ObjectMapper

public struct Transaction: Mappable {
    public private(set) var transactionId = Int()
    public private(set) var reasonCode = Int()
    public private(set) var cardHolderMessage = String()
    public private(set) var paReq = String()
    public private(set) var acsUrl = String()
    public private(set) var threeDsCallbackId = String()
    
    public init?(map: Map) {
        
    }
    
    public mutating func mapping(map: Map) {
        transactionId       <- map["TransactionId"]
        reasonCode          <- map["ReasonCode"]
        cardHolderMessage   <- map["CardHolderMessage"]
        paReq               <- map["PaReq"]
        acsUrl              <- map["AcsUrl"]
        threeDsCallbackId   <- map["ThreeDsCallbackId"]
    }
}
