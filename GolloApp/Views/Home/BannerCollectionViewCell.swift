//
//  BannerCollectionViewCell.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 12/10/22.
//

import ImageSlideshow
import UIKit
import RxSwift

protocol BannerCellDelegate {
    func bannerCell(_ bannerCollectionViewCell: BannerCollectionViewCell, willMoveToDetilWith data: Banner)
}

class BannerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var dividerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageSlideShowView: ImageSlideshow!
    
    let bag = DisposeBag()
    var delegate: BannerCellDelegate?
    var data: Banner?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureRx()
    }

    // MARK: - Functions
    func setBanner(with banner: Banner?) {
        guard let images = banner?.images else { return }
        data = banner
        let seconds = (banner?.autoPlayDelay ?? 5000) / 1000
        var imageSet: [AlamofireSource] = []
        for image in images {
            let imageSrc = image.image?.replacingOccurrences(of: " ", with: "%20")
            if let source = AlamofireSource(urlString: imageSrc ?? "") {
                imageSet.append(source)
            }
        }
        imageSlideShowView.setImageInputs(imageSet)
        imageSlideShowView.slideshowInterval = Double(seconds)
        imageSlideShowView.contentScaleMode = .scaleToFill
    }
    
    func configureRx() {
        detailButton
            .rx
            .tap
            .subscribe(onNext: {
                guard let data = self.data else { return }
                self.delegate?.bannerCell(self, willMoveToDetilWith: data)
            })
            .disposed(by: bag)
    }
}
