//
//  ContactUsViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit

class ContactUsViewController: UIViewController {
    
    @IBOutlet weak var versionNumberLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setAppVersion()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    // MARK: - Functions
    func setAppVersion() {
        versionNumberLabel.text = Bundle.main.releaseVersionNumber ?? ""
    }
}
