//
//  Product.swift
//  demo
//
//  Created by Anton Ignatov on 29/05/2019.
//  Copyright © 2019 Anton Ignatov. All rights reserved.
//

import Foundation

class Product {
    
    var id: Int
    var name: String
    var price: String
    var image: String
    
    init(id: Int, name: String, price: String, image: String) {
        self.id = id
        self.name = name
        self.price = price
        self.image = image
    }
}
