//
//  UIView+Extension.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius,
                                                    height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    func activityStartAnimatingFull() {
        let backgroundView = UIView()
        backgroundView.frame = CGRect.init(x: 0,
                                           y: 0,
                                           width: self.bounds.width,
                                           height: self.bounds.height)
        if #available(iOS 13.0, *) {
            backgroundView.backgroundColor = .systemBackground
        } else {
            backgroundView.backgroundColor = .white
        }
        backgroundView.center = self.center
        backgroundView.tag = 29387423

        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0,
                                                                       y: 0,
                                                                       width: 50,
                                                                       height: 50))
        activityIndicator.center = self.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false

        backgroundView.addSubview(activityIndicator)

        self.addSubview(backgroundView)
    }

    func activityStopAnimatingFull() {
        if let background = viewWithTag(29387423){
            background.removeFromSuperview()
        }
        self.isUserInteractionEnabled = true
    }

    func activityStarAnimating() {
        let loader = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        loader.color = .darkGray
        loader.center = CGPoint(x: self.frame.size.width  / 2, y: self.frame.size.height / 2 )
        loader.startAnimating()
        loader.tag = 475647
        self.addSubview(loader)
    }

    func activityStarAnimating(with color: UIColor) {
        let loader: UIActivityIndicatorView?
        loader = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        loader?.color = color
        loader?.center = self.center
        loader?.startAnimating()
        loader?.tag = 475647
        if let loader = loader {
            self.addSubview(loader)
        }
    }

    func activityStopAnimating() {
        if let loader = viewWithTag(475647) {
            loader.removeFromSuperview()
        }
    }

    enum Visibility: String {
        case visible = "visible"
        case invisible = "invisible"
        case gone = "gone"
    }

    var visibility: Visibility {
        get {
            let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)
            if let constraint = constraint, constraint.isActive {
                return .gone
            } else {
                return self.isHidden ? .invisible : .visible
            }
        }
        set {
            if self.visibility != newValue {
                self.setVisibility(newValue)
            }
        }
    }

    private func setVisibility(_ visibility: Visibility) {
        let constraints = self.constraints.filter({$0.firstAttribute == .height && $0.constant == 0 && $0.secondItem == nil && ($0.firstItem as? UIView) == self})
        let constraint = (constraints.first)

        switch visibility {
        case .visible:
            constraint?.isActive = false
            self.isHidden = false
            break
        case .invisible:
            constraint?.isActive = false
            self.isHidden = true
            break
        case .gone:
            self.isHidden = true
            if let constraint = constraint {
                constraint.isActive = true
            } else {
                let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
                self.addConstraint(constraint)
                constraint.isActive = true
            }
            self.setNeedsLayout()
            self.setNeedsUpdateConstraints()
        }
    }
}


