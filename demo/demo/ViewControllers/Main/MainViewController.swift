import UIKit
import SDWebImage
import Cloudpayments

class MainViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var productsCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var badgeLabel: UILabel?
    
    var products = Array<Product>() //Array of dictionary
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productsCollectionView.dataSource = self
        productsCollectionView.delegate = self
        
        self.activityIndicator.startAnimating()
        
        ProductsRequest().execute { [weak self] products in
            guard let self = self else {
                return
            }
            
            self.activityIndicator.stopAnimating()
            
            self.products = products
            self.productsCollectionView.reloadData()
        } onError: { [weak self] error in
            guard let self = self else {
                return
            }
            
            self.activityIndicator.stopAnimating()
            
            print("Ошибка при запросе данных \(String(describing: error))")
        }
          
        self.createCartButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateBadge()
    }
    
    private func createCartButton() {
        let view = UIView.init(frame: .zero)
        
        let btnOpenCart = UIButton.init(frame: .zero)
        btnOpenCart.setImage(UIImage(named: "Cart"), for: .normal)
        btnOpenCart.translatesAutoresizingMaskIntoConstraints = false
        btnOpenCart.contentHorizontalAlignment = .center
        btnOpenCart.contentVerticalAlignment = .center
        btnOpenCart.addTarget(self, action: #selector(openCart), for: .touchUpInside)
        view.addSubview(btnOpenCart)
        
        NSLayoutConstraint.activate([
            btnOpenCart.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btnOpenCart.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            btnOpenCart.widthAnchor.constraint(equalToConstant: 30),
            btnOpenCart.heightAnchor.constraint(equalToConstant: 30),
            view.widthAnchor.constraint(equalToConstant: 40),
            view.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 9
        label.layer.backgroundColor = UIColor.red.cgColor
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.widthAnchor.constraint(equalToConstant: 18),
            label.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        self.badgeLabel = label
        
        let itemOpenCart = UIBarButtonItem(customView: view)
        
        self.navigationItem.setRightBarButtonItems([itemOpenCart], animated: true)
    }
    
    private func updateBadge(){
        let productsCount = CartManager.shared.products.count
        self.badgeLabel?.isHidden = productsCount == 0
        
        self.badgeLabel?.text = "\(productsCount)"
    }

    //MARK: - UICollectionViewDataSource -
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath as IndexPath) as! ProductViewCell
        
        let product = products[indexPath.item]
        
        cell.image.sd_cancelCurrentImageLoad()
        cell.image.image = nil
        cell.activityIndicator.stopAnimating()
        
        if let image = product.images?.first?.src {
            cell.activityIndicator.startAnimating()
            cell.image.alpha = 0
            cell.image.sd_setImage(with: URL.init(string: image), placeholderImage: nil, options: .avoidAutoSetImage) { (image, error, cacheType, url) in
                cell.activityIndicator.stopAnimating()
                
                if cacheType == .none {
                    cell.image.image = image
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.image.alpha = 1
                    })
                } else {
                    cell.image.image = image
                    cell.image.alpha = 1
                }
            }
        }
        
        cell.name.text = product.name
        cell.price.text = "\(product.price ?? "0")  Руб."
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8// make cell more visible in our example project
        
        return cell
    }
    
    //MARK: - UICollectionViewDelegate -
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(String(describing: products[indexPath.item].name))!")
        CartManager.shared.products.append(products[indexPath.item])
        
        self.updateBadge()
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout -
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  10
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/1.2)
    }
    
    //MARK: - Private -

    
    
    @objc func openCart() {
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
