import Foundation

class CartManager {
    
    static let shared = CartManager()
    
    var products: Array<Product> = []
    
    private init(){}
}
