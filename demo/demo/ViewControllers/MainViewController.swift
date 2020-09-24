import UIKit
import Alamofire
import SwiftyJSON

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var productsCollectionView: UICollectionView!
    
    //let products: [String] = ["Букет1", "Букет2", "Букет3", "Букет4"]
    var products = Array<Product>() //Array of dictionary
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productsCollectionView.dataSource = self
        productsCollectionView.delegate = self
        AF.request("https://wp-demo.cloudpayments.ru/index.php/wp-json/wc/v3/products", method: .get, parameters: nil, headers: getHeaders()).responseJSON {
            response in
            
            guard response.value != nil else {
                print("Ошибка при запросе данных \(String(describing: response.error))")
                return
            }
            
            let swiftyJsonVar = JSON(response.value!)
            print(swiftyJsonVar)
            if let resData = swiftyJsonVar.arrayObject {
                let data = resData as! [[String:AnyObject]]
                for dict in data {
                    let id = dict["id"] as? Int
                    let name = dict["name"] as? String
                    let images = dict["images"] as! [[String:AnyObject]]
                    let image = images[0]["src"] as! String
                    let price = dict["price"] as? String
                    
                    let product = Product(id: id!, name: name!, price: price!, image: image)
                    self.products.append(product)
                }
            }
            if self.products.count > 0 {
                self.productsCollectionView.reloadData()
            }
        }
        
        let btnOpenCart = UIButton(type: .custom)
        btnOpenCart.setImage(UIImage(named: "Cart"), for: .normal)
        btnOpenCart.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnOpenCart.addTarget(self, action: #selector(MainViewController.openCart), for: .touchUpInside)
        let itemOpenCart = UIBarButtonItem(customView: btnOpenCart)
        
        self.navigationItem.setRightBarButtonItems([itemOpenCart], animated: true)
    
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath as IndexPath) as! ProductViewCell
        
        let product = products[indexPath.item]
                
        let url = URL(string: product.image)
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        cell.image.image = UIImage(data: data!)
        cell.name.text = product.name
        cell.price.text = "\(product.price)  Руб."
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8// make cell more visible in our example project
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(products[indexPath.item].name)!")
        CartManager.shared.products.append(products[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  10
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/1.2)
    }

    private func getHeaders() -> HTTPHeaders {
        let userName = "ck_ddb320b48b89a170248545eb3bb8e822365aa917"
        let password = "cs_35ad6d0cf8e6b149e66968efdad87112ca2bc2d3"
        let credentialData = "\(userName):\(password)".data(using: .utf8)
        guard let cred = credentialData else { return ["" : ""] }
        let base64Credentials = cred.base64EncodedData(options: [])
        guard let base64Date = Data(base64Encoded: base64Credentials) else { return ["" : ""] }
        return ["Authorization": "Basic \(base64Date.base64EncodedString())"]
    }
    
    @objc
    func openCart() {
        if CartManager.shared.products.count > 0 {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let cartViewController = storyBoard.instantiateViewController(withIdentifier: "cartViewController") as! CartViewController
            self.navigationController?.pushViewController(cartViewController, animated: true)
        } else {
            let alertController = UIAlertController(title: "Корзина пуста", message: "Добавьте один или несколько товаров чтобы продолжить", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
