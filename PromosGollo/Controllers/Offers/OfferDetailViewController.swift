//
//  OfferDetailViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import UIKit
import Nuke

class OfferDetailViewController: UIViewController {

    @IBOutlet weak var scrollImageView: UIScrollView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var imageConstraint: NSLayoutConstraint!

    @IBOutlet weak var modelView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var savingsLabel: UILabel!
    @IBOutlet weak var discountPriceLabel: UILabel!
    @IBOutlet weak var originalPrice: UILabel!

    @IBOutlet weak var pricesView: UIView!
    @IBOutlet weak var sepView: UIView!
    @IBOutlet weak var priceHeightView: NSLayoutConstraint!

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

    // Variables
    var offer: Offers?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Zoom
        scrollImageView.minimumZoomScale = 1
        scrollImageView.maximumZoomScale = 4

        showData()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Detalle de Promoción"
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.navigationController?.navigationBar.tintColor = UIColor.white
        let rigthButton = UIBarButtonItem(image: UIImage(named: "ic_share"), style: .plain, target: self, action: #selector(share))
        self.navigationItem.rightBarButtonItem = rigthButton
        self.navigationItem.rightBarButtonItem?.tintColor = .white
    }
    //MARK: - Functions
    private func showData() {
        if let offer = offer {
            let _:CGFloat = 0.0001

            if offer.image == "" || offer.image == "NA" {
                DispatchQueue.main.async {
                    self.imageConstraint.constant = 0
                    self.imageView.alpha = 0
                }
            } else {
                let url = URL(string: offer.image!)
                if let url = url {
                    Nuke.loadImage(with: url, into: offerImage)
                } else {
                    offerImage.image = UIImage(named: "empty_image")
                }
            }

            titleLabel.text = offer.name
            serialLabel.text = offer.productCode

            brandLabel.attributedText = formatHTML(header: "Marca: ", content: offer.brand ?? "")
            modelLabel.attributedText = formatHTML(header: "Modelo: ", content: offer.modelo ?? "")
            descriptionLabel.attributedText = formatHTML(header: "Descripción: ", content: offer.description ?? "")
            dateLabel.attributedText = formatHTML(header: "Fecha de Vencimiento: ", content: convertDate(date: offer.endDate ?? "") ?? "")

            if let original = offer.originalPrice, let final = offer.precioFinal {
                if original == 0 || final == 0 {
                    DispatchQueue.main.async {
                        self.pricesView.alpha = 0
                        self.sepView.alpha = 0
                        self.pricesView.layoutIfNeeded()
                    }
                } else {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = NumberFormatter.Style.decimal

                    let saving = original - final
                    let savingString = formatter.string(from: NSNumber(value: saving))!
                    savingsLabel.text = "\(offer.simboloMoneda ?? "$")\(savingString)"

                    let discountString = formatter.string(from: NSNumber(value: final))!
                    discountPriceLabel.text = "\(offer.simboloMoneda ?? "$")\(discountString)"

                    let originalString = formatter.string(from: NSNumber(value: original))!
                    let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(offer.simboloMoneda ?? "$")\(originalString)")
                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
                    originalPrice.attributedText = attributeString
                }
            } else {
                DispatchQueue.main.async {
                    self.pricesView.alpha = 0
                    self.sepView.alpha = 0
                }
            }

            let descuento = offer.tieneDescuento?.bool
            let regalia = offer.tieneRegalia?.bool
            let bono = offer.tieneBono?.bool

            if descuento! {
                discountLabel.text = "\(offer.simboloMoneda ?? "$")\(offer.montoDescuento ?? 0)"
            } else {
                DispatchQueue.main.async {
                    self.tintView.visibility = .gone
                    self.discountView.visibility = .gone
                    self.discountConstraint.constant = 0
                    self.discountView.layoutIfNeeded()
                }
            }

            if regalia! {
                giftLabel.text = "\(offer.product ?? "") - \(offer.productName ?? "")"
            } else {
                DispatchQueue.main.async {
                    self.tintViewGift.visibility = .gone
                    self.giftView.visibility = .gone
                    self.giftConstraint.constant = 0
                    self.giftView.layoutIfNeeded()
                }
            }

            if bono! {
                bonusLabel.text = "\(offer.simboloMoneda ?? "")\(offer.montoBono ?? 0)"
            } else {
                DispatchQueue.main.async {
                    self.tintViewBonus.visibility = .gone
                    self.bonusView.visibility = .gone
                    self.bonoConstraint.constant = 0
                    self.bonusView.layoutIfNeeded()
                }
            }

        } else { return }
    }

    @objc func share() {
        let someText:String = "https://www.gollotienda.com"
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
