//
//  UINavigationBar+Extension.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit

extension UINavigationBar {
    func setupNavigationBar() {
        let titleImageWidth = frame.size.width * 0.6
        let titleImageHeight = frame.size.height * 0.98
        let navigationBarIconimageView = UIImageView()
        navigationBarIconimageView.widthAnchor.constraint(equalToConstant: titleImageWidth).isActive = true
        navigationBarIconimageView.heightAnchor.constraint(equalToConstant: titleImageHeight).isActive = true
        navigationBarIconimageView.contentMode = .scaleAspectFit
        navigationBarIconimageView.image = UIImage(named: "logo_golloapp")
        topItem?.titleView = navigationBarIconimageView
    }
}
