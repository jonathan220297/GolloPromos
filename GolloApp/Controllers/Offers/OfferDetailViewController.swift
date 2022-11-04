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

class OfferDetailViewController: UIViewController {

    @IBOutlet weak var scrollImageView: UIScrollView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var imageConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var modelView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
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
    
    // Variables
    var offer: Product?
    let defaults = UserDefaults.standard

    lazy var viewModel: OfferDetailViewModel = {
        return OfferDetailViewModel()
    }()
    let bag = DisposeBag()

    var article: OfferDetail?
    var warrantyMonth = 0
    var warrantyAmount = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Zoom
        scrollImageView.minimumZoomScale = 1
        scrollImageView.maximumZoomScale = 4
        
        tabBarController?.navigationItem.hidesBackButton = false
        tabBarController?.navigationController?.navigationBar.tintColor = .white

        configureRx()
        fetchData()
        configureViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureAlternativeNavBar()
        carView.isHidden = true

        let isFavorite = CoreDataService().isFavoriteProduct(with: offer?.productCode ?? "")
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
        let someText:String = "Oferta: \(offer?.productName ?? "")\nSKU: \(offer?.productCode ?? "")\n\nPrecio Original: \(originalPrice.text ?? "")"
        var objectsToShare:UIImage?
        if let image = self.offerImage.image {
            objectsToShare = image
        }
        let sharedObjects:[Any] = [objectsToShare as Any, someText]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook, UIActivity.ActivityType.postToTwitter]

        self.present(activityViewController, animated: true, completion: nil)
    }

    fileprivate func saveFavorite() {
        if let product = self.offer {
            let isFavorite = CoreDataService().isFavoriteProduct(with: product.productCode ?? "")
            if let id = isFavorite {
                let _ = CoreDataService().deleteFavorite(with: id)
                self.favoriteButton.setImage(UIImage(named: "ic_heart"), for: .normal)
                self.favoriteButton.tintColor = .gray
            } else {
                CoreDataService().addProductFavorite(with: product)
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

    private func fetchData() {
        self.view.activityStartAnimatingFull()
        if let sku = offer?.productCode {
            viewModel.fetchOfferDetail(sku: sku)
                .asObservable()
                .subscribe(onNext: {[weak self] data in
                    guard let self = self,
                          let data = data else { return }
                    self.article = data
                    self.showData(with: data)
                })
                .disposed(by: bag)
        }
    }

    private func addToCart() {
        if let offer = offer, let article = article {
            var param: [CartItemDetail] = []
            let item = CartItemDetail(
                urlImage: offer.image,
                cantidad: 1,
                idLinea: CoreDataService().fetchCarItems().count + 1,
                mesesExtragar: warrantyMonth,
                descripcion: offer.name ?? "",
                sku: offer.productCode ?? "",
                descuento: article.articulo?.precioDescuento ?? 0.0,
                montoDescuento: article.articulo?.montoDescuento ?? 0.0,
                montoExtragar: warrantyAmount,
                porcDescuento: 0.0,
                precioExtendido: (article.articulo?.precio ?? 0.0 - (article.articulo?.montoDescuento ?? 0.0)),
                precioUnitario: article.articulo?.precio ?? 0.0,
                montoBonoProveedor: article.articulo?.montoBonoProveedor ?? 0.0,
                codRegalia: article.articulo?.regalias?.codigo,
                descRegalia: article.articulo?.regalias?.descripcion
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

        if let offer = offer {
            self.view.activityStopAnimatingFull()
            let _:CGFloat = 0.0001

            let options = ImageLoadingOptions(
                placeholder: UIImage(named: "empty_image"),
                transition: .fadeIn(duration: 0.5),
                failureImage: UIImage(named: "empty_image")
            )

            if offer.image == "" || offer.image == "NA" {
                DispatchQueue.main.async {
                    self.imageConstraint.constant = 0
                    self.imageView.alpha = 0
                }
            } else {
                let url = URL(string: offer.image!)
                if let url = url {
                    Nuke.loadImage(with: url, options: options, into: offerImage)
                } else {
                    offerImage.image = UIImage(named: "empty_image")
                }
            }

            titleLabel.text = offer.name
            serialLabel.text = offer.productCode

            brandLabel.attributedText = formatHTML(header: "Marca: ", content: offer.brand ?? "")
            modelLabel.attributedText = formatHTML(header: "Modelo: ", content: offer.modelo ?? "")
            descriptionLabel.attributedText = formatHTML(header: "Descripción: ", content: data.articulo?.especificaciones ?? "")
            if let endDate = offer.endDate, !endDate.isEmpty {
                let calendar = Calendar.current
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let toDate = dateFormatter.date(from: endDate)

                // Replace the hour (time) of both dates with 00:00
                let date1 = calendar.startOfDay(for: Date())
                let date2 = calendar.startOfDay(for: toDate ?? Date())

                let days = calendar.numberOfDaysBetween(date1, and: date2)
                let hours = calendar.dateComponents([.hour], from: date1, to: date2).hour
                var stringDays = "día"
                if days > 1 {
                    stringDays = "días"
                }
                var stringHours = "hora"
                if let hours = hours, hours > 1 {
                    stringHours = "horas"
                    dateLabel.attributedText = formatHTML(header: "Finaliza en ", content: "3 días y 0 horas")
                } else {
                    dateLabel.attributedText = formatHTML(header: "Finaliza en ", content: "\(days) \(stringDays)")
                }
            } else {
                dateLabel.alpha = 0
            }

            let originalString = numberFormatter.string(from: NSNumber(value: data.articulo?.precio ?? 0.0))!
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\("₡")\(originalString)")
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))

            if let totalDiscount = data.articulo?.montoDescuento, totalDiscount > 0.0,
               let price = data.articulo?.precio, price > 0.0 {
                let savingString = numberFormatter.string(from: NSNumber(value: totalDiscount))!
                savingsLabel.text = "\("₡")\(savingString)"

                let discountString = numberFormatter.string(from: NSNumber(value: data.articulo?.precioDescuento ?? 0.0))!
                discountPriceLabel.text = "\("₡")\(discountString)"
                self.originalPrice.attributedText = attributeString
            } else {
                self.originalPrice.text = "\("₡")\(originalString)"
                self.savingHeader.alpha = 0
                self.priceDivider.alpha = 0
                self.savingsLabel.alpha = 0
                self.discountLabel.alpha = 0
            }

            if let totalDiscount = data.articulo?.montoDescuento, totalDiscount > 0.0 {
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

            if let bonus = data.articulo?.montoBonoProveedor, bonus > 0.0 {
                bonusLabel.text = "\("₡")\(numberFormatter.string(from: NSNumber(value: bonus))!)"
            } else {
                DispatchQueue.main.async {
                    self.tintViewBonus.visibility = .gone
                    self.bonusView.visibility = .gone
                    self.bonoConstraint.constant = 0
                    self.bonusView.layoutIfNeeded()
                }
            }

            if let description = data.articulo?.descripcionDetalle, !description.isEmpty {
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

        } else { return }
    }

    private func initGolloPlus(with data: OfferDetail) {
        var documents: [Warranty] = []
        let lovN = Warranty(plazoMeses: 0, porcentaje: 0.0, montoExtragarantia: 0.0, impuestoExtragarantia: 0.0, titulo: "Sin gollo plus")
        documents.append(lovN)
        if let warranty = data.articulo?.extraGarantia {
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
        if let data = offer {
            let list = defaults.object(forKey: "Favorites") as? [Product] ?? [Product]()
            if list.contains(where: { dataO in
                dataO.id == data.id
            }) {
                return UIImage(named: "ic_added_heart")
            } else {
                return UIImage(named: "ic_heart")
            }
        } else {
            return UIImage(named: "ic_heart")
        }
    }
}

extension OfferDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return offerImage
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = offerImage.image {
                let ratioW = offerImage.frame.width / image.size.width
                let ratioH = offerImage.frame.height / image.size.height

                let ratio = ratioW > ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio

                let conditionLeft = newWidth*scrollView.zoomScale > offerImage.frame.width

                let left = 0.5 * (conditionLeft ? newWidth - offerImage.frame.width : (scrollView.frame.width - scrollView.contentSize.width))

                let conditionTop = newHeight*scrollView.zoomScale > offerImage.frame.height

                let top = 0.5 * (conditionTop ? newHeight - offerImage.frame.height : (scrollView.frame.height - scrollView.contentSize.height))

                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = .zero
        }
    }
}

extension OfferDetailViewController: OfferServiceProtectionDelegate {
    func protectionSelected(with id: UUID, month: Int, amount: Double) {
        let _ = CoreDataService().addGolloPlus(for: id, month: month, amount: amount)
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
