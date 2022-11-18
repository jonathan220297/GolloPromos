//
//  BannerCollectionViewCell.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 12/10/22.
//

import ImageSlideshow
import UIKit

class BannerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var dividerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageSlideShowView: ImageSlideshow!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: - Functions
    func setBanner(with banner: Banner?) {
        guard let images = banner?.images else { return }
        var imageSet: [AlamofireSource] = []
        for image in images {
            let imageSrc = image.image?.replacingOccurrences(of: " ", with: "%20")
            if let source = AlamofireSource(urlString: imageSrc ?? "") {
                imageSet.append(source)
            }
        }
        imageSlideShowView.setImageInputs(imageSet)
        imageSlideShowView.slideshowInterval = 2
        imageSlideShowView.contentScaleMode = .scaleToFill
    }
}
