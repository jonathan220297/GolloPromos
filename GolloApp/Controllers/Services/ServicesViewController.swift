//
//  ServicesViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/7/22.
//

import UIKit

class ServicesViewController: UIViewController {

    @IBOutlet weak var viewGlass: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closePopUp))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.viewGlass.addGestureRecognizer(tapRecognizer)
        self.viewGlass.isUserInteractionEnabled = true
    }

    // MARK: - Observers
    @objc func closePopUp() {
        dismiss(animated: true)
    }

}

extension ServicesViewController: UIGestureRecognizerDelegate {
    // MARK: - UIGestureRecognizer Delegates
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: self.viewGlass) {
            return true
        }
        return false
    }
}
