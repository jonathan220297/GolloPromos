//
//  SliderTableViewCell.swift
//  Shoppi
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import ImageSlideshow

class SliderTableViewCell: UITableViewCell {
    @IBOutlet weak var bannerImageSlideShow: ImageSlideshow!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Function
    func setSliderContent(with banner: Banner) {
        guard let images = banner.images else { return }
        var imageSet: [AlamofireSource] = []
        for image in images {
            var imageSrc = image.image?.replacingOccurrences(of: " ", with: "%20")
            if let source = AlamofireSource(urlString: imageSrc ?? "") {
                imageSet.append(source)
            }
        }
        bannerImageSlideShow.setImageInputs(imageSet)
        bannerImageSlideShow.slideshowInterval = 2
        bannerImageSlideShow.contentScaleMode = .scaleAspectFill
    }
}
