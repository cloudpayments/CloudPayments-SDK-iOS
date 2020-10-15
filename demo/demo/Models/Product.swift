//
//  Product.swift
//  demo
//
//  Created by Anton Ignatov on 29/05/2019.
//  Copyright © 2019 Anton Ignatov. All rights reserved.
//

import Foundation
import ObjectMapper

class Product: Mappable {
    var id: Int?
    var name: String?
    var price: String?
    var image: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["dict"]
        name <- map["name"]
        price <- map["price"]
        
        if let images = map.JSON["images"] as? [[String : AnyObject]], !images.isEmpty {
            image = images.first?["src"] as? String
        }
    }
}
