//
//  OfferProductImageViewController.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 23/7/23.
//

import UIKit
import Nuke
import RxSwift

class OfferProductImageViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var scrollImageView: UIScrollView!
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let bag = DisposeBag()
    var imageUrl: String? = ""
    var productImages: [ArticleImages]? = []
    var lastIndexActive: IndexPath = [1, 0]
    
    // MARK: - Lifecycle
    init(imageUrl: String?, productImages: [ArticleImages]?) {
        self.imageUrl = imageUrl
        self.productImages = productImages
        super.init(nibName: "OfferProductImageViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Zoom
        scrollImageView.minimumZoomScale = 1.0
        scrollImageView.maximumZoomScale = 10.0
        
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "empty_image"),
            transition: .fadeIn(duration: 0.5),
            failureImage: UIImage(named: "empty_image")
        )
        
        configureCollectionView()
        configureRx()
        
        if let url = URL(string: imageUrl ?? "") {
            Nuke.loadImage(with: url, options: options, into: offerImage)
        } else {
            self.offerImage.image = UIImage(named: "empty_image")
        }
        
        if productImages?.isEmpty == false {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Functions
    func configureRx() {
        closeButton
            .rx
            .tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            })
            .disposed(by: bag)
    }
    
    func configureCollectionView() {
        self.collectionView.register(UINib(nibName: "OfferImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OfferImagesCollectionViewCell")
    }
    
}

extension OfferProductImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.offerImage
    }
}

extension OfferProductImageViewController: UICollectionViewDelegate,
                                           UICollectionViewDataSource,
                                           UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.productImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getImageCell(collectionView, cellForItemAt: indexPath)
    }
    
    func getImageCell(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferImagesCollectionViewCell", for: indexPath) as! OfferImagesCollectionViewCell
        cell.setImageData(with: self.productImages?[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "empty_image"),
            transition: .fadeIn(duration: 0.5),
            failureImage: UIImage(named: "empty_image")
        )
        
        let url = URL(string: self.productImages?[indexPath.row].imagen ?? "")
        if let url = url {
            Nuke.loadImage(with: url, options: options, into: self.offerImage)
        } else {
            self.offerImage.image = UIImage(named: "empty_image")
        }
        
        if self.lastIndexActive != indexPath {
            let selected = collectionView.cellForItem(at: indexPath) as! OfferImagesCollectionViewCell
            selected.content.backgroundColor = UIColor.primaryLight
            
            let previous = collectionView.cellForItem(at: lastIndexActive) as? OfferImagesCollectionViewCell
            previous?.content.backgroundColor = UIColor.lightGray
            
            self.lastIndexActive = indexPath
        }
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.layer.borderColor = UIColor.blue.cgColor
//        cell?.layer.borderWidth = 1
//        cell?.isSelected = true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = 70 * (self.productImages?.count ?? 0)
        let totalSpacingWidth = 8 * ((self.productImages?.count ?? 0) - 1)
        
        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}
