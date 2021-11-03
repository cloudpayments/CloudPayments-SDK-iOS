//
//  Product.swift
//  demo
//
//  Created by Anton Ignatov on 29/05/2019.
//  Copyright © 2019 Cloudpayments. All rights reserved.
//

struct Product: Codable {
    var id: Int?
    var name: String?
    var price: String?
    var images: [Image]?
    
    enum CodingKeys: String, CodingKey {
        case id = "dict"
        case name
        case price
        case images
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try? container.decode(Int.self, forKey: .id)
        self.name = try? container.decode(String.self, forKey: .name)
        self.price = try? container.decode(String.self, forKey: .price)
        self.images = try? container.decode([Image].self, forKey: .images)
    }
    
    init(id: Int, name: String, price: String) {
        self.id = id
        self.name = name
        self.price = price
    }
}

struct Image: Codable {
    var id: Int?
    var src: String?
}
