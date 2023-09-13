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
    @IBOutlet weak var imagePageController: UIPageControl!
    
    @IBOutlet weak var productInformatioView: UIView!
    @IBOutlet weak var imagesView: UIView!
    @IBOutlet weak var productImagesCollectionView: UICollectionView!
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
    @IBOutlet weak var uniqueOriginalPriceLabel: UILabel!
    @IBOutlet weak var priceHeightView: NSLayoutConstraint!
    
    @IBOutlet weak var cartView: UIView!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var serviceButton: UIButton!
    @IBOutlet weak var addCartButton: UIButton!
    @IBOutlet weak var cartViewHeight: NSLayoutConstraint!
    @IBOutlet weak var buyNowButton: UIButton!
    @IBOutlet weak var warantySelectionLabel: UILabel!
    @IBOutlet weak var dropDownSelectionView: UIView!
    
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
    
    @IBOutlet weak var optionalExpensesView: UIView!
    @IBOutlet weak var optionalTableView: UITableView!
    @IBOutlet weak var otherExpensesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var otherExpensesView: UIView!
    @IBOutlet weak var otherExpensesStackView: UIStackView!
    @IBOutlet weak var tooltipVMIView: UIView!
    @IBOutlet weak var tooltipVMILabel: UILabel!
    
    // Variables
    var offer: Product?
    let defaults = UserDefaults.standard
    
    lazy var viewModel: OfferDetailViewModel = {
        return OfferDetailViewModel()
    }()
    let bag = DisposeBag()
    
    var skuProduct: String?
    var centerProduct: String = "144"
    var bodegaProduct: String?
    var scannerFlowActivate: Bool = false
    var article: OfferDetail?
    var warrantyMonth: Int?
    var warrantyAmount: Double?
    var totalDiscount = 0.0
    var currentPage = 0
    var priceToShow: Double = 0.0
    var newExpensesPrice = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Zoom
        scrollImageView.minimumZoomScale = 1.0
        scrollImageView.maximumZoomScale = 10.0
        
        tabBarController?.navigationItem.hidesBackButton = false
        tabBarController?.navigationController?.navigationBar.tintColor = .white
        
        configureViews()
        configureRx()
        configureTableView()
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
                let someText:String = "Oferta: \(self.article?.articulo?.nombre ?? "")\nSKU: \(self.article?.articulo?.sku ?? "")\n\nPrecio Original: \(numberFormatter.string(from: NSNumber(value: Double(self.article?.articulo?.precio ?? "0.0") ?? 0.0)) ?? "")\n\nDescuento total: \(numberFormatter.string(from: NSNumber(value: self.totalDiscount)) ?? "")\n\nNuevo precio: \(numberFormatter.string(from: NSNumber(value: Double(self.article?.articulo?.precioDescuento ?? "0.0") ?? 0.0)) ?? "")"
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
        if let article = self.article?.articulo {
            let isFavorite = CoreDataService().isFavoriteProduct(with: article.sku ?? "")
            if let id = isFavorite {
                let _ = CoreDataService().deleteFavorite(with: id)
                self.favoriteButton.setImage(UIImage(named: "ic_heart"), for: .normal)
                self.favoriteButton.tintColor = .gray
            } else {
                let product = Product(
                    productCode: article.sku,
                    descriptionDetailDescuento: article.descripcionDetalle,
                    descriptionDetailRegalia: "",
                    originalPrice: Double(article.precio ?? "0.0"),
                    image: article.urlImagen ?? "",
                    montoBono: Double(article.montoBonoProveedor ?? "0.0"),
                    porcDescuento: Double(article.precioDescuento ?? "0.0"),
                    brand: article.marca,
                    descriptionDetailBono: "",
                    tieneBono: "false",
                    name: article.nombre,
                    modelo: article.modelo,
                    endDate: article.endDate ?? "",
                    tieneRegalia: "true",
                    simboloMoneda: SimboloMoneda.empty,
                    id: 1,
                    montoDescuento: Double(article.montoDescuento ?? "0.0"),
                    idUsuario: Variables.userProfile?.idCliente ?? "",
                    product: article.nombre,
                    idEmpresa: 0,
                    startDate: article.startDate ?? "",
                    precioFinal: Double(article.precioDescuento ?? "0.0"),
                    productName: article.nombre ?? "",
                    tieneDescuento: "false",
                    tipoPromoApp: 0,
                    productoDescription: "",
                    muestraDescuento: "false",
                    tiene2x1: "false",
                    tieneNuevo: "false",
                    tieneTopVentas: "false",
                    tieneExclusivo: "false",
                    tienetranspGratis: "false",
                    indMostrarTop: false
                )
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
        
        productInformatioView.clipsToBounds = true
        productInformatioView.layer.cornerRadius = 10
        productInformatioView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        buyNowButton.backgroundColor = .white
        buyNowButton.layer.cornerRadius = 15
        buyNowButton.layer.borderWidth = 1
        buyNowButton.layer.borderColor = UIColor.gray.cgColor
        
        dropDownSelectionView.backgroundColor = .white
        dropDownSelectionView.layer.cornerRadius = 10
        dropDownSelectionView.layer.borderWidth = 1
        dropDownSelectionView.layer.borderColor = UIColor.lightGray.cgColor
        
        tooltipVMIView.layer.cornerRadius = 10
        tooltipVMIView.layer.borderWidth = 1
        tooltipVMIView.layer.borderColor = hexStringToUIColor(hex: "#FFD180").cgColor
    }
    
    fileprivate func configureRx() {
        viewModel
            .errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] error in
                guard let self = self else { return }
                if !error.isEmpty {
                    self.showAlertWithActions(alertText: "GolloApp", alertMessage: error, action: {
                        self.navigationController?.popViewController(animated: true)
                    })
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
                if self.validateSelectedWaranty() {
                    if let carManagerType = self.viewModel.verifyCarManagerTypeState() {
                        if CoreDataService().fetchCarItems().isEmpty {
                            self.addToCart()
                        } else {
                            if carManagerType == CarManagerType.SCAN_AND_GO.rawValue && self.scannerFlowActivate {
                                self.addToCart()
                            } else if carManagerType == CarManagerType.PRODUCT_LIST.rawValue && !self.scannerFlowActivate {
                                self.addToCart()
                            } else {
                                let refreshAlert = UIAlertController(title: "GolloApp", message: "No se puede hacer un carrito con productos en línea y productos de agencia. ¿Deseas limpiar el carrito e inciar uno nuevo?", preferredStyle: UIAlertController.Style.alert)
                                
                                refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action: UIAlertAction!) in
                                    refreshAlert.dismiss(animated: true)
                                }))
                                
                                refreshAlert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { (action: UIAlertAction!) in
                                    if CoreDataService().deleteAllItems() {
                                        self.viewModel.deleteCarManagerTypeState()
                                        var type = ""
                                        if self.scannerFlowActivate {
                                            type = CarManagerType.SCAN_AND_GO.rawValue
                                        } else {
                                            type = CarManagerType.PRODUCT_LIST.rawValue
                                        }
                                        self.viewModel.setCarManagerTypeToUserDefaults(with: type)
                                        self.addToCart()
                                        refreshAlert.dismiss(animated: true)
                                    }
                                }))
                                
                                self.present(refreshAlert, animated: true, completion: nil)
                            }
                        }
                    } else {
                        var type = ""
                        if self.scannerFlowActivate {
                            type = CarManagerType.SCAN_AND_GO.rawValue
                        } else {
                            type = CarManagerType.PRODUCT_LIST.rawValue
                        }
                        self.viewModel.setCarManagerTypeToUserDefaults(with: type)
                        self.addToCart()
                    }
                } else {
                    self.showAlert(alertText: "GolloApp", alertMessage: "Por favor seleccione el servicio de reparación")
                    self.warantySelectionLabel.textColor = UIColor.red
                    self.dropDownSelectionView.layer.borderColor = UIColor.red.cgColor
                }
            })
            .disposed(by: bag)
        
        buyNowButton
            .rx
            .tap
            .subscribe(onNext: {
                if self.validateSelectedWaranty() {
                    if let carManagerType = self.viewModel.verifyCarManagerTypeState() {
                        if CoreDataService().fetchCarItems().isEmpty {
                            self.addToCart(with: true)
                        } else {
                            if carManagerType == CarManagerType.SCAN_AND_GO.rawValue && self.scannerFlowActivate {
                                self.addToCart(with: true)
                            } else if carManagerType == CarManagerType.PRODUCT_LIST.rawValue && !self.scannerFlowActivate {
                                self.addToCart(with: true)
                            } else {
                                let refreshAlert = UIAlertController(title: "GolloApp", message: "No se puede hacer un carrito con productos en línea y productos de agencia. ¿Deseas limpiar el carrito e inciar uno nuevo?", preferredStyle: UIAlertController.Style.alert)
                                
                                refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action: UIAlertAction!) in
                                    refreshAlert.dismiss(animated: true)
                                }))
                                
                                refreshAlert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { (action: UIAlertAction!) in
                                    if CoreDataService().deleteAllItems() {
                                        self.viewModel.deleteCarManagerTypeState()
                                        var type = ""
                                        if self.scannerFlowActivate {
                                            type = CarManagerType.SCAN_AND_GO.rawValue
                                        } else {
                                            type = CarManagerType.PRODUCT_LIST.rawValue
                                        }
                                        self.viewModel.setCarManagerTypeToUserDefaults(with: type)
                                        self.addToCart(with: true)
                                        refreshAlert.dismiss(animated: true)
                                    }
                                }))
                                
                                self.present(refreshAlert, animated: true, completion: nil)
                            }
                        }
                    } else {
                        var type = ""
                        if self.scannerFlowActivate {
                            type = CarManagerType.SCAN_AND_GO.rawValue
                        } else {
                            type = CarManagerType.PRODUCT_LIST.rawValue
                        }
                        self.viewModel.setCarManagerTypeToUserDefaults(with: type)
                        self.addToCart(with: true)
                    }
                } else {
                    self.showAlert(alertText: "GolloApp", alertMessage: "Por favor seleccione el servicio de reparación")
                    self.warantySelectionLabel.textColor = UIColor.red
                    self.dropDownSelectionView.layer.borderColor = UIColor.red.cgColor
                }
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
    
    fileprivate func configureTableView() {
        self.optionalTableView.register(
            UINib(
                nibName: "OptionalExpensesTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "OptionalExpensesTableViewCell"
        )
    }
    
    func configureCollectionView() {
        self.productImagesCollectionView.register(UINib(nibName: "ProductImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductImageCollectionViewCell")
        self.imagesCollectionView.register(UINib(nibName: "OfferImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OfferImagesCollectionViewCell")
        self.collectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
    }
    
    private func validateSelectedWaranty() -> Bool {
        if let waranty = self.article?.articulo?.extraGarantia, !waranty.isEmpty {
            if let _ = self.warrantyMonth, let _ = self.warrantyAmount {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    private func fetchData() {
        self.view.activityStartAnimatingFull()
        let skuCode = offer?.productCode ?? skuProduct
        if let sku = skuCode {
            viewModel.fetchOfferDetail(
                sku: sku,
                centro: centerProduct,
                bodega: bodegaProduct ?? nil
            )
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                if let images = data.articulo?.imagenes {
                    if images.isEmpty {
                        var firstImage: [ArticleImages] = []
                        let imageData = ArticleImages(tipo: 0, imagen: data.articulo?.urlImagen)
                        firstImage.append(imageData)
                        self.viewModel.images = firstImage
                    } else {
                        self.viewModel.images = images
                    }
                } else {
                    var firstImage: [ArticleImages] = []
                    let imageData = ArticleImages(tipo: 0, imagen: data.articulo?.urlImagen)
                    firstImage.append(imageData)
                    self.viewModel.images = firstImage
                }
                self.imagePageController.numberOfPages = self.viewModel.images.count
                self.imagePageController.currentPage = self.currentPage
                
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
                            muestraDescuento: o.muestraDescuento,
                            tiene2x1: o.tiene2x1,
                            tieneNuevo: o.tieneNuevo,
                            tieneTopVentas: o.tieneTopVentas,
                            tieneExclusivo: o.tieneExclusivo,
                            tienetranspGratis: o.tienetranspGratis,
                            indMostrarTop: o.indMostrarTop
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
    
    private func addToCart(with automaticRedirect: Bool = false) {
        var totalExpenses = 0.0
        let userSelectedExpenses = self.viewModel.mandatoryExpenses + self.viewModel.optionalExpenses.filter({ tax in tax.obligatorio == 0 && tax.selected == true })
        userSelectedExpenses.forEach { e in
            totalExpenses += (e.monto ?? 0.0)
        }
        if let article = article?.articulo {
            var param: [CartItemDetail] = []
            let item = CartItemDetail(
                urlImage: article.urlImagen,
                cantidad: 1,
                idLinea: CoreDataService().fetchCarItems().count + 1,
                mesesExtragar: warrantyMonth ?? 0,
                descripcion: article.nombre ?? "",
                sku: article.sku ?? "",
                descuento: Double(article.precioDescuento ?? "0.0") ?? 0.0,
                montoDescuento: Double(article.montoDescuento ?? "0.0") ?? 0.0,
                montoExtragar: warrantyAmount ?? 0.0,
                porcDescuento: 0.0,
                precioExtendido: (Double(article.precio ?? "0.0") ?? 0.0 - (Double(article.montoDescuento ?? "0.0") ?? 0.0)),
                precioUnitario: Double(article.precio ?? "0.0") ?? 0.0,
                montoBonoProveedor: Double(article.montoBonoProveedor ?? "0.0") ?? 0.0,
                codRegalia: article.regalias?.codigo,
                descRegalia: article.regalias?.descripcion,
                totalExpenses: totalExpenses,
                indVMI: article.existeVMI ?? 0
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
                        let userSelectedTaxes = self.viewModel.optionalExpenses.filter({ tax in tax.obligatorio == 0 && tax.selected == true })
                        let expenses = self.viewModel.mandatoryExpenses + userSelectedTaxes
                        _ = CoreDataService().addCarItems(with: param, warranty: self.viewModel.documents, expenses: expenses)
                        self.carItemLabel.text = "El artículo ha sido agregado al carrito!"
                        self.configureAlternativeNavBar()
                        if automaticRedirect {
                            let carTab = CarTabViewController(
                                viewModel: CarTabViewModel()
                            )
                            carTab.modalPresentationStyle = .fullScreen
                            self.navigationController?.pushViewController(carTab, animated: true)
                        }
                        //                        if self.viewModel.documents.count > 1 && self.warrantyMonth == 0 {
                        //                            let offerServiceProtectionViewController = OfferServiceProtectionViewController(services: self.viewModel.documents)
                        //                            offerServiceProtectionViewController.delegate = self
                        //                            offerServiceProtectionViewController.selectedId = id
                        //                            offerServiceProtectionViewController.modalPresentationStyle = .overCurrentContext
                        //                            offerServiceProtectionViewController.modalTransitionStyle = .crossDissolve
                        //                            self.present(offerServiceProtectionViewController, animated: true)
                        //                        }
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
        serialLabel.attributedText = formatHTML(header: "Código del artículo: ", content: (data.articulo?.sku ?? ""))
        
        brandLabel.attributedText = formatHTML(header: "Marca: ", content: (data.articulo?.marca ?? ""))
        modelLabel.attributedText = formatHTML(header: "Modelo: ", content: (data.articulo?.modelo ?? ""))
        descriptionLabel.attributedText = formatHTML(header: "Descripción: ", content: data.articulo?.especificaciones ?? "")
        if let endDate = article?.articulo?.endDate, !endDate.isEmpty {
            let endFormattedDate = endDate.convertStringToDate()
            let timeDifference = Date() - endFormattedDate
            let numberOfDays = Int(timeDifference.day ?? 0)
            let hours = Int((timeDifference.hour ?? 0) - (numberOfDays * 24))
            
            var stringDays = "día"
            if numberOfDays > 1 {
                stringDays = "días"
            }
            dateLabel.attributedText = formatHTML(header: "Finaliza en ", content: "\(numberOfDays) \(stringDays) y \(hours) horas".replace(string: "-", replacement: ""))
        } else {
            dateLabel.alpha = 0
            dateView.isHidden = true
        }
        
        totalDiscount = ((Double(article?.articulo?.montoDescuento ?? "0.0") ?? 0.0) + (Double(article?.articulo?.montoBonoProveedor ?? "0.0") ?? 0.0))
        
        self.drawPrices()
        
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
            self.imagesView.isHidden = true
            self.productImagesCollectionView.reloadData()
            self.imagesCollectionView.reloadData()
        } else if !self.viewModel.images.isEmpty {
            self.productImagesCollectionView.reloadData()
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
        
        self.drawTaxes()
        self.drawMandatoryExpenses(with: priceToShow)
        
        if data.articulo?.existeVMI == 1 {
            self.tooltipVMIView.isHidden = false
            self.tooltipVMILabel.text = data.articulo?.texto_vmi ?? ""
        } else {
            self.tooltipVMIView.isHidden = true
        }
    }
    
    private func drawPrices() {
        let originalString = numberFormatter.string(from: NSNumber(value: Double(self.article?.articulo?.precio ?? "0.0") ?? 0.0))!
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\("₡")\(originalString)")
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        
        if totalDiscount > 0.0,
           let price = Double(self.article?.articulo?.precio ?? "0.0"), price > 0.0 {
            self.pricesView.isHidden = false
            self.uniqueOriginalPriceLabel.isHidden = true
            let savingString = numberFormatter.string(from: NSNumber(value: totalDiscount))!
            savingsLabel.text = "\("₡")\(savingString)"
            
            let discountString = numberFormatter.string(from: NSNumber(value: Double(self.article?.articulo?.precioDescuento ?? "0.0") ?? 0.0))!
            self.discountPriceLabel.attributedText = attributeString
            self.originalPrice.text = "\("₡")\(discountString)"
            priceToShow = Double(self.article?.articulo?.precioDescuento ?? "0.0") ?? 0.0
        } else {
            self.pricesView.isHidden = true
            self.uniqueOriginalPriceLabel.isHidden = false
            self.uniqueOriginalPriceLabel.text = "\("₡")\(originalString) IVAi"
            self.originalPrice.text = "\("₡")\(originalString) IVAi"
            self.originalPrice.textColor = .black
            self.originalPrice.font = self.originalPrice.font.withSize(17)
            self.savingHeader.alpha = 0
            self.priceDivider.alpha = 0
            self.savingsLabel.alpha = 0
            self.savingsLabel.isHidden = true
            self.discountLabel.alpha = 0
            self.discountLabel.isHidden = true
            priceToShow = Double(self.article?.articulo?.precio ?? "0.0") ?? 0.0
        }
    }
    
    private func initGolloPlus(with data: OfferDetail) {
        var documents: [Warranty] = []
        let lovN = Warranty(plazoMeses: 0, porcentaje: 0.0, montoExtragarantia: 0.0, impuestoExtragarantia: 0.0, titulo: "Sin gollo plus")
        documents.append(lovN)
        if let warranty = data.articulo?.extraGarantia, !warranty.isEmpty {
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
        } else {
            self.cartView.isHidden = true
        }
        //        if let first = documents.first {
        //            warrantyMonth = first.plazoMeses ?? 0
        //            warrantyAmount = first.montoExtragarantia ?? 0.0
        //            serviceLabel.text = first.titulo
        //        }
        viewModel.documents = documents
    }
    
    private func drawTaxes() {
        if let tax = article?.articulo?.otrosGastos, !tax.isEmpty{
            let filteredTaxes = tax.filter({ tax in tax.obligatorio == 0 })
            self.viewModel.optionalExpenses = filteredTaxes
            if !filteredTaxes.isEmpty {
                self.optionalExpensesView.isHidden = false
                self.otherExpensesHeightConstraint.constant = CGFloat(((self.viewModel.optionalExpenses.count) * 45))
                
                self.optionalTableView.layoutIfNeeded()
                self.optionalTableView.reloadData()
            } else {
                self.optionalExpensesView.isHidden = true
            }
        } else {
            self.optionalExpensesView.isHidden = true
        }
    }
    
    private func drawMandatoryExpenses(with price: Double) {
        if let tax = article?.articulo?.otrosGastos, !tax.isEmpty{
            let filteredTaxes = tax.filter({ tax in tax.obligatorio == 1 })
            let userSelectedTaxes = self.viewModel.optionalExpenses.filter({ tax in tax.obligatorio == 0 && tax.selected == true })
            self.viewModel.mandatoryExpenses = filteredTaxes
            if !filteredTaxes.isEmpty || !userSelectedTaxes.isEmpty {
                self.otherExpensesStackView.removeAllArrangedSubviews()
                self.otherExpensesView.isHidden = false
                
                let includesLabel = UILabel()
                includesLabel.font = UIFont.systemFont(ofSize: 12)
                includesLabel.backgroundColor = UIColor.clear
                includesLabel.textColor = .darkGray
                includesLabel.text = "Incluye:"
                
                let articlePriceExpense = OtherExpenses(
                    skuGasto: "",
                    descripcion: "Precio del artículo",
                    monto: price,
                    obligatorio: -1
                )
                otherExpensesStackView.addArrangedSubview(includesLabel)
                otherExpensesStackView.addArrangedSubview(taxesLabel(with: articlePriceExpense))
                
                let totalShowTaxes = filteredTaxes + userSelectedTaxes
                
                totalShowTaxes.forEach { t in
                    otherExpensesStackView.addArrangedSubview(taxesLabel(with: t))
                }
            } else {
                self.otherExpensesView.isHidden = true
            }
        } else {
            self.otherExpensesView.isHidden = true
        }
    }
    
    private func taxesLabel(with t: OtherExpenses) -> UILabel {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "ic_ok")?.withTintColor(UIColor.systemGreen)
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: 12, height: 12)
        
        let expensesLabel = UILabel()
        expensesLabel.font = UIFont.systemFont(ofSize: 12)
        expensesLabel.backgroundColor = UIColor.clear
        expensesLabel.textColor = .darkGray
        let taxPrice = (numberFormatter.string(from: NSNumber(value: t.monto ?? 0.0)) ?? "").currencyFormatting()
        
        let attributedText = NSMutableAttributedString(attachment: imageAttachment)
        attributedText.append(NSAttributedString(string: " "))
        attributedText.append(NSAttributedString(attributedString: formatHTML(header: "\(t.descripcion ?? ""): ", content: "+\(taxPrice)")))
        expensesLabel.attributedText = attributedText
        
        return expensesLabel
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
            self.warantySelectionLabel.textColor = UIColor.primary
            self.dropDownSelectionView.layer.borderColor = UIColor.lightGray.cgColor
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
        var generatedLink = ""
        
        guard let deepLink = URL(string:"\(dynamicLinkDomain)/product/\(article?.articulo?.sku ?? "")") else { return }
        
        let linkBuilder = DynamicLinkComponents(link: deepLink, domainURIPrefix: dynamicLinkDomain)
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.merckers.golloapp")
        linkBuilder?.iOSParameters?.appStoreID = "1643795423"
        
        linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: "com.merckers.golloapp")
        
        let url = URL(string: article?.articulo?.urlImagen ?? "")
        
        linkBuilder?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkBuilder?.socialMetaTagParameters?.title = self.article?.articulo?.nombre ?? ""
        linkBuilder?.socialMetaTagParameters?.descriptionText = self.article?.articulo?.descripcionDetalle ?? (self.article?.articulo?.sku ?? "")
        linkBuilder?.socialMetaTagParameters?.imageURL = url
        
        let longlLink = linkBuilder?.url
        generatedLink = linkBuilder?.url?.absoluteString ?? ""
        
        print("The long link is \(longlLink!)")
        
        linkBuilder?.options = DynamicLinkComponentsOptions()
        linkBuilder?.options?.pathLength = .short
        linkBuilder?.shorten() { url, warnings, error in
            guard let url = url, error != nil else {
                print("The short URL error.")
                handler(generatedLink)
                return
            }
            // TODO: Handle shortURL.
            generatedLink = url.absoluteString
            handler(generatedLink)
            print("The short URL is: \(url)")
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
        } else if collectionView == self.imagesCollectionView || collectionView == self.productImagesCollectionView {
            return self.viewModel.images.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            return getProductCell(collectionView, cellForItemAt: indexPath)
        } else if collectionView == self.productImagesCollectionView {
            return getProductImageCell(collectionView, cellForItemAt: indexPath)
        } else {
            return getImageCell(collectionView, cellForItemAt: indexPath)
        }
    }
    
    func getProductImageCell(_ collectionView: UICollectionView,
                             cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImageCollectionViewCell", for: indexPath) as! ProductImageCollectionViewCell
        cell.setImageData(with: self.viewModel.images[indexPath.row])
        return cell
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
        } else if collectionView == self.productImagesCollectionView {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        } else {
            let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
            let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
            let size: CGFloat = (collectionView.frame.size.width - space) / 2.0
            return CGSize(width: size, height: 300)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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
        } else if collectionView == self.productImagesCollectionView {
            let offerServiceProtectionViewController = OfferProductImageViewController(imageUrl: article?.articulo?.urlImagen ?? "", productImages: self.viewModel.images)
            offerServiceProtectionViewController.modalPresentationStyle = .fullScreen
            offerServiceProtectionViewController.modalTransitionStyle = .crossDissolve
            navigationController?.pushViewController(offerServiceProtectionViewController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.productImagesCollectionView {
            self.currentPage = indexPath.row
            self.imagePageController.currentPage = indexPath.row
        }
    }
}

extension OfferDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.optionalExpenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getOptionalExpensesCell(tableView, cellForRowAt: indexPath)
    }
    
    func getOptionalExpensesCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OptionalExpensesTableViewCell", for: indexPath) as? OptionalExpensesTableViewCell else {
            return UITableViewCell()
        }
        cell.setTaxesData(with: viewModel.optionalExpenses[indexPath.row])
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
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
        vc.skuProduct = data.productCode
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension OfferDetailViewController: ProductCellDelegate {
    func productCell(_ productCollectionViewCell: ProductCollectionViewCell, willMoveToDetilWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.skuProduct = data.productCode
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension OfferDetailViewController: OptionalExpensesCellDelegate {
    func didSelectOptionalExpense(at indexPath: IndexPath) {
        let expenseSelected = !(self.viewModel.optionalExpenses[indexPath.row].selected ?? false)
        self.viewModel.optionalExpenses[indexPath.row].selected = expenseSelected
        
        if expenseSelected {
            self.newExpensesPrice = (self.newExpensesPrice == 0.0 ? self.priceToShow : self.newExpensesPrice) + (self.viewModel.optionalExpenses[indexPath.row].monto ?? 0.0)
        } else {
            self.newExpensesPrice = self.newExpensesPrice - (self.viewModel.optionalExpenses[indexPath.row].monto ?? 0.0)
        }
        
        if totalDiscount > 0.0,
           let price = Double(self.article?.articulo?.precio ?? "0.0"), price > 0.0 {
            let discountString = numberFormatter.string(from: NSNumber(value: self.newExpensesPrice))!
            self.originalPrice.text = "\("₡")\(discountString)"
            priceToShow = Double(self.article?.articulo?.precioDescuento ?? "0.0") ?? 0.0
        } else {
            let originalString = numberFormatter.string(from: NSNumber(value: self.newExpensesPrice))!
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\("₡")\(originalString)")
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
            self.uniqueOriginalPriceLabel.text = "\("₡")\(originalString) IVAi"
            self.originalPrice.text = "\("₡")\(originalString) IVAi"
        }
        
        self.drawMandatoryExpenses(with: priceToShow)
        self.optionalTableView.reloadData()
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
