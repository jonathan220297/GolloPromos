//
//  OfferDetailViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import Foundation
import UIKit
import Nuke
import RxSwift
import DropDown
import FirebaseDynamicLinks

class OfferDetailViewController: UIViewController {

    @IBOutlet weak var scrollImageView: UIScrollView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var imageConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var imagesView: UIView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    @IBOutlet weak var modelView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateView: UIStackView!
    
    @IBOutlet weak var savingHeader: UILabel!
    @IBOutlet weak var savingsLabel: UILabel!
    @IBOutlet weak var priceDivider: UIView!
    @IBOutlet weak var discountPriceLabel: UILabel!
    @IBOutlet weak var originalPrice: UILabel!

    @IBOutlet weak var pricesView: UIView!
    @IBOutlet weak var sepView: UIView!
    @IBOutlet weak var priceHeightView: NSLayoutConstraint!

    @IBOutlet weak var cartView: UIView!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var serviceButton: UIButton!
    @IBOutlet weak var addCartButton: UIButton!
    @IBOutlet weak var cartViewHeight: NSLayoutConstraint!

    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var tintView: UIView!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var discountConstraint: NSLayoutConstraint!

    @IBOutlet weak var giftView: UIView!
    @IBOutlet weak var tintViewGift: UIView!
    @IBOutlet weak var giftLabel: UILabel!
    @IBOutlet weak var giftConstraint: NSLayoutConstraint!

    @IBOutlet weak var bonusLabel: UILabel!
    @IBOutlet weak var tintViewBonus: UIView!
    @IBOutlet weak var bonusView: UIView!
    @IBOutlet weak var bonoConstraint: NSLayoutConstraint!

    @IBOutlet weak var offerDescriptionView: UIView!
    @IBOutlet weak var offerDescriptionLabel: UILabel!
    
    @IBOutlet weak var carView: UIView!
    @IBOutlet weak var carItemLabel: UILabel!
    @IBOutlet weak var carButton: UIButton!
    
    @IBOutlet weak var suggestedTitleLabel: UILabel!
    @IBOutlet weak var suggestedProductsView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Variables
    var offer: Product?
    let defaults = UserDefaults.standard

    lazy var viewModel: OfferDetailViewModel = {
        return OfferDetailViewModel()
    }()
    let bag = DisposeBag()

    var skuProduct: String?
    var bodegaProduct: String?
    var article: OfferDetail?
    var warrantyMonth = 0
    var warrantyAmount = 0.0
    var totalDiscount = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Zoom
        scrollImageView.minimumZoomScale = 1.0
        scrollImageView.maximumZoomScale = 10.0

        tabBarController?.navigationItem.hidesBackButton = false
        tabBarController?.navigationController?.navigationBar.tintColor = .white

        configureViews()
        configureRx()
        configureCollectionView()
        fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureAlternativeNavBar()
        carView.isHidden = true

        let isFavorite = CoreDataService().isFavoriteProduct(with: skuProduct ?? "")
        if let _ = isFavorite {
            self.favoriteButton.setImage(UIImage(named: "ic_added_heart"), for: .normal)
            self.favoriteButton.tintColor = .red
        } else {
            self.favoriteButton.setImage(UIImage(named: "ic_heart"), for: .normal)
            self.favoriteButton.tintColor = .gray
        }
    }
    
    // MARK: - Observers
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func shareContent() {
        generateDynamicLink { url in
            var sharedObjects : [Any]
            if !url.isEmpty {
                sharedObjects = [url]
            } else {
                let someText:String = "Oferta: \(self.self.self.article?.articulo?.nombre ?? "")\nSKU: \(self.self.article?.articulo?.sku ?? "")\n\nPrecio Original: \(numberFormatter.string(from: NSNumber(value: Double(self.article?.articulo?.precio ?? "0.0") ?? 0.0)) ?? "")\n\nDescuento total: \(numberFormatter.string(from: NSNumber(value: self.totalDiscount)) ?? "")\n\nNuevo precio: \(numberFormatter.string(from: NSNumber(value: Double(self.article?.articulo?.precioDescuento ?? "0.0") ?? 0.0)) ?? "")"
                var objectsToShare:UIImage?
                if let image = self.offerImage.image {
                    objectsToShare = image
                }
                sharedObjects = [objectsToShare as Any, someText]
            }
            let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view

            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook, UIActivity.ActivityType.postToTwitter]

            self.present(activityViewController, animated: true, completion: nil)
        }
    }

    fileprivate func saveFavorite() {
        if let product = self.offer {
            let isFavorite = CoreDataService().isFavoriteProduct(with: product.productCode ?? "")
            if let id = isFavorite {
                let _ = CoreDataService().deleteFavorite(with: id)
                self.favoriteButton.setImage(UIImage(named: "ic_heart"), for: .normal)
                self.favoriteButton.tintColor = .gray
            } else {
                CoreDataService().addProductFavorite(with: product, name: offer?.name)
                self.favoriteButton.setImage(UIImage(named: "ic_added_heart"), for: .normal)
                self.favoriteButton.tintColor = .red
                self.showAlert(alertText: "GolloApp", alertMessage: "Favorito guardado correctamente.")
            }

        }
    }

    //MARK: - Functions
    func configureViews() {
        carView.layer.cornerRadius = 20.0
    }
    
    fileprivate func configureRx() {
        viewModel.errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self else { return }
                if !error.isEmpty {
                    self.showAlert(alertText: "GolloApp", alertMessage: error)
                    self.viewModel.errorMessage.accept("")
                }
            })
            .disposed(by: bag)

        favoriteButton
            .rx
            .tap
            .subscribe(onNext: {
                self.saveFavorite()
            })
            .disposed(by: bag)

        shareButton
            .rx
            .tap
            .subscribe(onNext: {
                self.shareContent()
            })
            .disposed(by: bag)

        serviceButton
            .rx
            .tap
            .subscribe(onNext: {
                self.configureServiceDropDown()
            })
            .disposed(by: bag)

        addCartButton
            .rx
            .tap
            .subscribe(onNext: {
                self.addToCart()
            })
            .disposed(by: bag)
        
        carButton
            .rx
            .tap
            .subscribe(onNext: {
                NotificationCenter.default.post(name: Notification.Name("moveToCar"), object: nil)
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
    }
    
    func configureCollectionView() {
        self.imagesCollectionView.register(UINib(nibName: "OfferImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OfferImagesCollectionViewCell")
        self.collectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
    }

    private func fetchData() {
        self.view.activityStartAnimatingFull()
        let skuCode = offer?.productCode ?? skuProduct
        if let sku = skuCode {
            viewModel.fetchOfferDetail(sku: sku, bodega: bodegaProduct ?? "1")
                .asObservable()
                .subscribe(onNext: {[weak self] data in
                    guard let self = self,
                          let data = data else { return }
                    if let images = data.articulo?.imagenes {
                        self.viewModel.images = images
                    }
                    if let complements = data.articulo?.complementos {
                        var products: [Product] = []
                        for o in complements {
                            let p = Product(
                                productCode: o.productCode,
                                descriptionDetailDescuento: o.descriptionDetailDescuento,
                                descriptionDetailRegalia: o.descriptionDetailRegalia,
                                originalPrice: o.originalPrice,
                                image: o.image,
                                montoBono: o.montoBono,
                                porcDescuento: o.porcDescuento,
                                brand: o.brand,
                                descriptionDetailBono: o.descriptionDetailRegalia,
                                tieneBono: o.tieneBono,
                                name: o.name,
                                modelo: o.modelo,
                                endDate: o.endDate,
                                tieneRegalia: o.tieneRegalia,
                                simboloMoneda: SimboloMoneda.empty,
                                id: o.id,
                                montoDescuento: o.montoDescuento,
                                idUsuario: o.idUsuario,
                                product: o.product,
                                idEmpresa: o.idempresa,
                                startDate: o.startDate,
                                precioFinal: o.precioFinal,
                                productName: o.productName,
                                tieneDescuento: o.tieneDescuento,
                                tipoPromoApp: 0,
                                productoDescription: "",
                                muestraDescuento: o.muestraDescuento
                            )
                            products.append(p)
                        }
                        self.viewModel.products = products
                    }
                    self.article = data
                    self.showData(with: data)
                })
                .disposed(by: bag)
        }
    }

    private func addToCart() {
        if let article = article?.articulo {
            var param: [CartItemDetail] = []
            let item = CartItemDetail(
                urlImage: article.urlImagen,
                cantidad: 1,
                idLinea: CoreDataService().fetchCarItems().count + 1,
                mesesExtragar: warrantyMonth,
                descripcion: article.nombre ?? "",
                sku: article.sku ?? "",
                descuento: Double(article.precioDescuento ?? "0.0") ?? 0.0,
                montoDescuento: Double(article.montoDescuento ?? "0.0") ?? 0.0,
                montoExtragar: warrantyAmount,
                porcDescuento: 0.0,
                precioExtendido: (Double(article.precio ?? "0.0") ?? 0.0 - (Double(article.montoDescuento ?? "0.0") ?? 0.0)),
                precioUnitario: Double(article.precio ?? "0.0") ?? 0.0,
                montoBonoProveedor: Double(article.montoBonoProveedor ?? "0.0") ?? 0.0,
                codRegalia: article.regalias?.codigo,
                descRegalia: article.regalias?.descripcion
            )
            param.append(item)
            viewModel.addCart(parameters: param)
                .asObservable()
                .subscribe(onNext: {[weak self] data in
                    guard let self = self,
                          let _ = data else { return }
                    DispatchQueue.main.async {
                        self.carView.isHidden = false
                        // change to desired number of seconds (in this case 5 seconds)
                        let when = DispatchTime.now() + 2
                        DispatchQueue.main.asyncAfter(deadline: when){
                          // your code with delay
                            self.carView.isHidden = true
                        }
                        let id = CoreDataService().addCarItems(with: param, warranty: self.viewModel.documents)
                        self.carItemLabel.text = "El artículo ha sido agregado al carrito!"
                        self.configureAlternativeNavBar()
                        if self.viewModel.documents.count > 1 && self.warrantyMonth == 0 {
                            let offerServiceProtectionViewController = OfferServiceProtectionViewController(services: self.viewModel.documents)
                            offerServiceProtectionViewController.delegate = self
                            offerServiceProtectionViewController.selectedId = id
                            offerServiceProtectionViewController.modalPresentationStyle = .overCurrentContext
                            offerServiceProtectionViewController.modalTransitionStyle = .crossDissolve
                            self.present(offerServiceProtectionViewController, animated: true)
                        }
                    }
                })
                .disposed(by: bag)
        }
    }
    
    private func showData(with data: OfferDetail) {
        self.initGolloPlus(with: data)
        self.view.activityStopAnimatingFull()
        let _:CGFloat = 0.0001

        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "empty_image"),
            transition: .fadeIn(duration: 0.5),
            failureImage: UIImage(named: "empty_image")
        )

        if data.articulo?.urlImagen == "" || data.articulo?.urlImagen == "NA" {
            DispatchQueue.main.async {
                self.imageConstraint.constant = 0
                self.imageView.alpha = 0
            }
        } else {
            let url = URL(string: data.articulo?.urlImagen ?? "")
            if let url = url {
                Nuke.loadImage(with: url, options: options, into: offerImage)
            } else {
                offerImage.image = UIImage(named: "empty_image")
            }
        }

        titleLabel.text = data.articulo?.nombre ?? ""
        serialLabel.text = data.articulo?.sku ?? ""

        brandLabel.attributedText = formatHTML(header: "Marca: ", content: (data.articulo?.marca ?? ""))
        modelLabel.attributedText = formatHTML(header: "Modelo: ", content: (data.articulo?.modelo ?? ""))
        descriptionLabel.attributedText = formatHTML(header: "Descripción: ", content: data.articulo?.especificaciones ?? "")
        if let endDate = article?.articulo?.endDate, !endDate.isEmpty {
            let endFormattedDate = endDate.convertStringToDate()
            let timeDifference = Date() - endFormattedDate
            let numberOfDays = Int(timeDifference.day ?? 0)
            let hours = Int((timeDifference.hour ?? 0) - (numberOfDays * 24))
            
            print("Formatted difference time \(numberOfDays) ~~ \(hours)")
            var stringDays = "día"
            if numberOfDays > 1 {
                stringDays = "días"
            }
            dateLabel.attributedText = formatHTML(header: "Finaliza en ", content: "\(numberOfDays) \(stringDays) y \(hours) horas".replace(string: "-", replacement: ""))
        } else {
            dateLabel.alpha = 0
            dateView.alpha = 0
        }

        totalDiscount = ((Double(article?.articulo?.montoDescuento ?? "0.0") ?? 0.0) + (Double(article?.articulo?.montoBonoProveedor ?? "0.0") ?? 0.0))

        let originalString = numberFormatter.string(from: NSNumber(value: Double(data.articulo?.precio ?? "0.0") ?? 0.0))!
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\("₡")\(originalString)")
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))

        if totalDiscount > 0.0,
           let price = Double(data.articulo?.precio ?? "0.0"), price > 0.0 {
            let savingString = numberFormatter.string(from: NSNumber(value: totalDiscount))!
            savingsLabel.text = "\("₡")\(savingString)"

            let discountString = numberFormatter.string(from: NSNumber(value: Double(data.articulo?.precioDescuento ?? "0.0") ?? 0.0))!
            discountPriceLabel.text = "\("₡")\(discountString)"
            self.originalPrice.attributedText = attributeString
        } else {
            self.originalPrice.text = "\("₡")\(originalString)"
            self.savingHeader.alpha = 0
            self.priceDivider.alpha = 0
            self.savingsLabel.alpha = 0
            self.discountLabel.alpha = 0
        }

        if let totalDiscount = Double(data.articulo?.montoDescuento ?? "0.0"), totalDiscount > 0.0 {
            discountLabel.text = "\("₡")\(numberFormatter.string(from: NSNumber(value: totalDiscount))!)"
        } else {
            DispatchQueue.main.async {
                self.tintView.visibility = .gone
                self.discountView.visibility = .gone
                self.discountConstraint.constant = 0
                self.discountView.layoutIfNeeded()
            }
        }

        if let royalties = article?.articulo?.regalias {
            giftLabel.text = "\(royalties.codigo ?? "") - \(royalties.descripcion ?? "")"
        } else {
            DispatchQueue.main.async {
                self.tintViewGift.visibility = .gone
                self.giftView.visibility = .gone
                self.giftConstraint.constant = 0
                self.giftView.layoutIfNeeded()
            }
        }

        if let bonus = Double(data.articulo?.montoBonoProveedor ?? "0.0"), bonus > 0.0 {
            bonusLabel.text = "\("₡")\(numberFormatter.string(from: NSNumber(value: bonus))!)"
        } else {
            DispatchQueue.main.async {
                self.tintViewBonus.visibility = .gone
                self.bonusView.visibility = .gone
                self.bonoConstraint.constant = 0
                self.bonusView.layoutIfNeeded()
            }
        }

        if let description = data.articulo?.descripcionDetalle, !description.trimmingCharacters(in: .whitespaces).isEmpty {
            self.offerDescriptionView.isHidden = false
            let decodeString = description.removingPercentEncoding
            if let htmlString = decodeString {
                let formatedHtml = "<html><head><style type='text/css'>@font-face { font-family: MyFont;src: url('font/jost_variable_font.ttf') } body {font-family: MyFont;font-size: medium;text-align: justify;} </style></head><body>\(htmlString)</body></html>"
                self.offerDescriptionLabel.attributedText = formatedHtml.htmlToAttributedString

            } else {
                self.offerDescriptionView.isHidden = true
            }
        } else {
            self.offerDescriptionView.isHidden = true
        }
        
        if let images = data.articulo?.imagenes, !images.isEmpty {
            self.imagesView.isHidden = false
            self.imagesCollectionView.reloadData()
        } else {
            self.imagesView.isHidden = true
        }
        
        if let complements = data.articulo?.complementos, !complements.isEmpty {
            self.suggestedTitleLabel.isHidden = false
            self.suggestedProductsView.isHidden = false
            self.collectionView.reloadData()
        } else {
            self.suggestedTitleLabel.isHidden = true
            self.suggestedProductsView.isHidden = true
        }
    }

    private func initGolloPlus(with data: OfferDetail) {
        var documents: [Warranty] = []
        let lovN = Warranty(plazoMeses: 0, porcentaje: 0.0, montoExtragarantia: 0.0, impuestoExtragarantia: 0.0, titulo: "Sin gollo plus")
        documents.append(lovN)
        if let warranty = data.articulo?.extragarantia {
            for w in warranty {
                let amount = String(w.montoExtragarantia ?? 0.0).currencyFormatting()
                let lov = Warranty(
                    plazoMeses: w.plazoMeses,
                    porcentaje: w.porcentaje,
                    montoExtragarantia: w.montoExtragarantia,
                    impuestoExtragarantia: w.impuestoExtragarantia,
                    titulo: "\(w.plazoMeses ?? 0) meses + \(amount)"
                )
                documents.append(lov)
            }
        }
        if let first = documents.first {
            warrantyMonth = first.plazoMeses ?? 0
            warrantyAmount = first.montoExtragarantia ?? 0.0
            serviceLabel.text = first.titulo
        }
        viewModel.documents = documents
    }

    private func configureServiceDropDown() {
        let dropDown = DropDown()
        dropDown.anchorView = serviceButton
        dropDown.dataSource = viewModel.documents.map { $0.titulo ?? "" }
        dropDown.show()
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            warrantyMonth = viewModel.documents[index].plazoMeses ?? 0
            warrantyAmount = viewModel.documents[index].montoExtragarantia ?? 0.0
            serviceLabel.text = item
        }
    }

    private func isFavorite() -> UIImage? {
        if let data = article?.articulo {
            let list = defaults.object(forKey: "Favorites") as? [Product] ?? [Product]()
            if list.contains(where: { dataO in
                dataO.productCode == data.sku
            }) {
                return UIImage(named: "ic_added_heart")
            } else {
                return UIImage(named: "ic_heart")
            }
        } else {
            return UIImage(named: "ic_heart")
        }
    }
    
    private func generateDynamicLink(handler: @escaping (String) -> Void) {
        let dynamicLinkDomain = "https://gollo.page.link"
        let _:[String : String] = [
            "product": article?.articulo?.sku ?? ""
        ]
        
        var generatedLink = ""

        guard let deepLink = URL(string:"https://gollo.page.link/product/\(article?.articulo?.sku ?? "")") else { return }
        print("deepLink is \(deepLink)")
        
        let components = DynamicLinkComponents(link: deepLink, domainURIPrefix: dynamicLinkDomain)
        
        if let components = components {
            let url = URL(string: article?.articulo?.urlImagen ?? "")
            if let url = url {
                components.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
                components.socialMetaTagParameters?.imageURL = url
            }
            
            //1. Build the dynamic long link
            let longlLink = components.url
            generatedLink = longlLink?.absoluteString ?? ""
            print("The long link is \(longlLink!)")

            //Set the length of a short Dynamic Link
            let options = DynamicLinkComponentsOptions()
            options.pathLength = .unguessable
            components.options = options

            //2. Or create a shortened dynamic link
            components.shorten { (shortURL, warnings, error) in
                if let error = error {
                    print("shortURL error is \(error.localizedDescription)")
                    handler(generatedLink)
                    return
                }

                // TODO: Handle shortURL.
                generatedLink = shortURL?.absoluteString ?? ""
                handler(generatedLink)
                print("shortURL is \(String(describing: shortURL))")
            }
        }
    }
}

extension OfferDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return offerImage
    }
}

extension OfferDetailViewController: UICollectionViewDelegate,
                                            UICollectionViewDataSource,
                                            UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return self.viewModel.products.count
        } else if collectionView == self.imagesCollectionView {
            return self.viewModel.images.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            return getProductCell(collectionView, cellForItemAt: indexPath)
        } else {
            return getImageCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    func getImageCell(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferImagesCollectionViewCell", for: indexPath) as! OfferImagesCollectionViewCell
        cell.setImageData(with: self.viewModel.images[indexPath.row])
        return cell
    }

    func getProductCell(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        cell.setProductData(with: viewModel.products[indexPath.row])
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.imagesCollectionView {
            return CGSize(width: 70, height: 70)
        } else {
            let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
            let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
            let size: CGFloat = (collectionView.frame.size.width - space) / 2.0
            return CGSize(width: size, height: 300)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.imagesCollectionView {
            let options = ImageLoadingOptions(
                placeholder: UIImage(named: "empty_image"),
                transition: .fadeIn(duration: 0.5),
                failureImage: UIImage(named: "empty_image")
            )
            
            let url = URL(string: self.viewModel.images[indexPath.row].imagen ?? "")
            if let url = url {
                Nuke.loadImage(with: url, options: options, into: self.offerImage)
            } else {
                self.offerImage.image = UIImage(named: "empty_image")
            }
        }
    }
}

extension OfferDetailViewController: OfferServiceProtectionDelegate {
    func protectionSelected(with id: UUID, month: Int, amount: Double) {
        let _ = CoreDataService().addGolloPlus(for: id, month: month, amount: amount)
    }
}

extension OfferDetailViewController: OffersCellDelegate {
    func offerssCell(_ offersTableViewCell: OffersTableViewCell, shouldMoveToDetailWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension OfferDetailViewController: ProductCellDelegate {
    func productCell(_ productCollectionViewCell: ProductCollectionViewCell, willMoveToDetilWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension NSAttributedString {
    internal convenience init?(html: String) {
        guard let data = html.data(using: String.Encoding.utf16, allowLossyConversion: false) else {
            // not sure which is more reliable: String.Encoding.utf16 or String.Encoding.unicode
            return nil
        }
        guard let attributedString = try? NSMutableAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return nil
        }
        self.init(attributedString: attributedString)
    }
}
