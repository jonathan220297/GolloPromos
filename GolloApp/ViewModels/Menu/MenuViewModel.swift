//
//  MenuViewModel.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import Foundation

class MenuViewModel {
    var menuArray: [Menu] = []

    func initializeMenu() {
        menuArray.append(Menu(image: "ic_heart", title: "My Whishlist", subtitle: "The products in my whishlist"))
    }
}
