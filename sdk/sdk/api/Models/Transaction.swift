import ObjectMapper

public struct Transaction: Mappable {
    public private(set) var transactionId = Int()
    public private(set) var amount = Double()
    public private(set) var currency = String()
    public private(set) var currencyCode = Int()
    public private(set) var invoiceId = String()
    public private(set) var accountId = String()
    public private(set) var email = String()
    public private(set) var description = String()
    public private(set) var createdDate = String()
    public private(set) var createdDateIso = String()
    public private(set) var authDate = String()
    public private(set) var authDateIso = String()
    public private(set) var confirmDate = String()
    public private(set) var confirmDateIso = String()
    public private(set) var authCode = String()
    public private(set) var testMode = false
    public private(set) var ipAddress = String()
    public private(set) var ipCountry = String()
    public private(set) var ipCity = String()
    public private(set) var ipRegion = String()
    public private(set) var ipDistrict = String()
    public private(set) var ipLatitude = String()
    public private(set) var ipLongitude = String()
    public private(set) var cardFirstSix = String()
    public private(set) var cardLastFour = String()
    public private(set) var cardExpDate = String()
    public private(set) var cardType = String()
    public private(set) var cardTypeCode = Int()
    public private(set) var issuer = String()
    public private(set) var issuerBankCountry = String()
    public private(set) var status = String()
    public private(set) var statusCode = Int()
    public private(set) var reason = String()
    public private(set) var reasonCode = Int()
    public private(set) var cardHolderMessage = String()
    public private(set) var name = String()
    public private(set) var token = String()
    public private(set) var paReq = String()
    public private(set) var acsUrl = String()
    public private(set) var threeDsCallbackId = String()
    
    public init?(map: Map) {
        
    }
    
    public mutating func mapping(map: Map) {
        transactionId       <- map["TransactionId"]
        amount              <- map["Amount"]
        currency            <- map["Currency"]
        currencyCode        <- map["CurrencyCode"]
        invoiceId           <- map["InvoiceId"]
        accountId           <- map["AccountId"]
        email               <- map["Email"]
        description         <- map["Description"]
        createdDate         <- map["CreatedDate"]
        createdDateIso      <- map["CreatedDateIso"]
        authDate            <- map["AuthDate"]
        authDateIso         <- map["AuthDateIso"]
        confirmDate         <- map["ConfirmDate"]
        confirmDateIso      <- map["ConfirmDateIso"]
        authCode            <- map["AuthCode"]
        testMode            <- map["TestMode"]
        ipAddress           <- map["IpAddress"]
        ipCountry           <- map["IpCountry"]
        ipCity              <- map["IpCity"]
        ipRegion            <- map["IpRegion"]
        ipDistrict          <- map["IpDistrict"]
        ipLatitude          <- map["IpLatitude"]
        ipLongitude         <- map["IpLongitude"]
        cardFirstSix        <- map["CardFirstSix"]
        cardLastFour        <- map["CardLastFour"]
        cardExpDate         <- map["CardExpDate"]
        cardType            <- map["CardType"]
        cardTypeCode        <- map["CardTypeCode"]
        issuer              <- map["Issuer"]
        issuerBankCountry   <- map["IssuerBankCountry"]
        status              <- map["Status"]
        statusCode          <- map["StatusCode"]
        reason              <- map["Reason"]
        reasonCode          <- map["ReasonCode"]
        name                <- map["Name"]
        token               <- map["Token"]
        cardHolderMessage   <- map["CardHolderMessage"]
        paReq               <- map["PaReq"]
        acsUrl              <- map["AcsUrl"]
        threeDsCallbackId   <- map["ThreeDsCallbackId"]
    }
}
