//
//  MenuTabViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 13/9/22.
//

import UIKit

class MenuTabViewController: UIViewController {
    
    init() {
        super.init(nibName: "MenuTabViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.title = "Menu"
    }
}
