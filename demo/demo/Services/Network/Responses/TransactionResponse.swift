import ObjectMapper

class TransactionResponse: Mappable {
    
    private(set) var success = Bool()
    
    private(set) var message = String()
    
    private(set) var transaction: Transaction?
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        success     <- map["Success"]
        message     <- map["Message"]
        transaction <- map["Model"]
    }
}
