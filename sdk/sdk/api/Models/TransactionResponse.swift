import ObjectMapper

public struct TransactionResponse: Mappable {
    
    private(set) var success = Bool()
    
    private(set) var message = String()
    
    private(set) var transaction: Transaction?
    
    public init?(map: Map) {
        
    }
    
    public mutating func mapping(map: Map) {
        success     <- map["Success"]
        message     <- map["Message"]
        transaction <- map["Model"]
    }
}
