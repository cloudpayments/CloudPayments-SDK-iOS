import ObjectMapper

public struct TransactionResponse: Mappable {
    public private(set) var success = Bool()
    public private(set) var message = String()
    public private(set) var transaction: Transaction?
    
    public init?(map: Map) {
        
    }
    
    public mutating func mapping(map: Map) {
        success     <- map["Success"]
        message     <- map["Message"]
        transaction <- map["Model"]
    }
}
