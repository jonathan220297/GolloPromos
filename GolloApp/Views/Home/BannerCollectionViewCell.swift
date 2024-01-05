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
    func bannerCell(_ bannerCollectionViewCell: BannerCollectionViewCell, willMoveToDetilWith data: Banner, position: Int)
}

class BannerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var dividerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageSlideShowView: ImageSlideshow!
    
    //FOMO
    @IBOutlet weak var fomoContainerView: UIView!
    @IBOutlet weak var firstHourView: UIStackView!
    @IBOutlet weak var firstHourLabel: UILabel!
    @IBOutlet weak var secondHourView: UIStackView!
    @IBOutlet weak var secondHourLabel: UILabel!
    @IBOutlet weak var firstSeparationView: UIView!
    @IBOutlet weak var secondSeparationView: UIView!
    @IBOutlet weak var firstMinuteView: UIStackView!
    @IBOutlet weak var firstMinuteLabel: UILabel!
    @IBOutlet weak var secondMinuteView: UIStackView!
    @IBOutlet weak var secondMinuteLabel: UILabel!
    @IBOutlet weak var thirdSeparationView: UIView!
    @IBOutlet weak var fourthSeparationView: UIView!
    @IBOutlet weak var firstSecondView: UIStackView!
    @IBOutlet weak var firstSecondLabel: UILabel!
    @IBOutlet weak var secondSecondView: UIStackView!
    @IBOutlet weak var secondSecondLabel: UILabel!
    
    @IBOutlet weak var topMarging: NSLayoutConstraint!
    @IBOutlet weak var leadingMargin: NSLayoutConstraint!
    @IBOutlet weak var trailingMargin: NSLayoutConstraint!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    var timer: Timer?
    var futureDate: Date = Date()
    
    let bag = DisposeBag()
    var delegate: BannerCellDelegate?
    var data: Banner?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
        configureRx()
    }
    
    // MARK: - Observers
    @objc func updateCountdown() {
        let currentDate = Date()
        let timeRemaining = Int(futureDate.timeIntervalSince(currentDate))
        let hours = timeRemaining / 3600
        let minutes = (timeRemaining % 3600) / 60
        let seconds = (timeRemaining % 3600) % 60
        
        let hoursString = String(format: "%02d", hours)
        firstHourLabel.text = hoursString.first?.uppercased()
        secondHourLabel.text = hoursString.last?.uppercased()
        let minutesString = String(format: "%02d", minutes)
        firstMinuteLabel.text = minutesString.first?.uppercased()
        secondMinuteLabel.text = minutesString.last?.uppercased()
        let secondsString = String(format: "%02d", seconds)
        firstSecondLabel.text = secondsString.first?.uppercased()
        secondSecondLabel.text = secondsString.last?.uppercased()
        
        if timeRemaining <= 0 {
            timer?.invalidate()
        }
    }
    
    @objc func swipeLeft() {
        imageSlideShowView.nextPage(animated: true)
    }
    
    @objc func swipeRight() {
        imageSlideShowView.previousPage(animated: true)
    }

    // MARK: - Functions
    func configureViews() {
        firstHourView.layer.cornerRadius = 3.0
        secondHourView.layer.cornerRadius = 3.0
        firstSeparationView.layer.cornerRadius = firstSeparationView.frame.size.height / 2
        secondSeparationView.layer.cornerRadius = secondSeparationView.frame.size.height / 2
        firstMinuteView.layer.cornerRadius = 3.0
        secondMinuteView.layer.cornerRadius = 3.0
        thirdSeparationView.layer.cornerRadius = thirdSeparationView.frame.size.height / 2
        fourthSeparationView.layer.cornerRadius = fourthSeparationView.frame.size.height / 2
        firstSecondView.layer.cornerRadius = 3.0
        secondSecondView.layer.cornerRadius = 3.0
        
        addLeftSwipeDownGesture()
        addRightSwipeDownGesture()
    }
    
    func addLeftSwipeDownGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeft))
        swipeGesture.direction = .left
        self.contentView.addGestureRecognizer(swipeGesture)
    }
    
    func addRightSwipeDownGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRight))
        swipeGesture.direction = .right
        self.contentView.addGestureRecognizer(swipeGesture)
    }
    
    func setBanner(with banner: Banner?) {
        fomoContainerView.isHidden = !(banner?.indFomo ?? false)
        if let indFomo = banner?.indFomo, indFomo {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            futureDate = dateFormatter.date(from: banner?.endFomo ?? "") ?? Date()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        }
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
        
        if let margin = banner?.borderWidth, margin > 0,
           let radius = banner?.borderRadio, radius > 0 {
            imageSlideShowView.layer.cornerRadius = CGFloat(radius)
            self.contentView.layer.cornerRadius = CGFloat(radius)
            topMarging.constant = CGFloat(margin)
            topMarging.isActive = true
            leadingMargin.constant = CGFloat(margin)
            leadingMargin.isActive = true
            trailingMargin.constant = CGFloat(margin)
            trailingMargin.isActive = true
            bottomMargin.constant = CGFloat(margin)
            bottomMargin.isActive = true
            imageSlideShowView.layoutIfNeeded()
        } else {
            imageSlideShowView.layer.cornerRadius = CGFloat(0)
            topMarging.constant = 0
            topMarging.isActive = true
            leadingMargin.constant = 0
            leadingMargin.isActive = true
            trailingMargin.constant = 0
            trailingMargin.isActive = true
            imageSlideShowView.layoutIfNeeded()
        }
        if let borderColor = banner?.borderColor, !borderColor.isEmpty {
            self.contentView.backgroundColor = hexStringToUIColor(hex: borderColor)
        } else {
            self.contentView.backgroundColor = .white
        }
    }
    
    func configureRx() {
        detailButton
            .rx
            .tap
            .subscribe(onNext: {
                guard let data = self.data else { return }
                self.delegate?.bannerCell(self, willMoveToDetilWith: data, position: self.imageSlideShowView.currentPage)
            })
            .disposed(by: bag)
    }
}
