//
//  SearchDocumentViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit

class SearchDocumentViewController: UIViewController {

    @IBOutlet weak var viewGlass: UIView!
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var documentPickerView: UIPickerView!
    @IBOutlet weak var documentTextField: UITextField!

    var arrayDocuments = ["C - Cédula", "J - Cédula Jurídica", "P - Pasaporte"]
    var selectedDocument = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewPopup.clipsToBounds = true
        navigationItem.title = "SearchViewController"
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closePopUp))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.viewGlass.addGestureRecognizer(tapRecognizer)
        self.viewGlass.isUserInteractionEnabled = true

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.hideKeyboardWhenTappedAround()

        documentPickerView.reloadAllComponents()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //documentTextField.subrallado()
    }

    @IBAction func search(_ sender: Any) {
        getClientInfo()
    }

    // MARK: - Observers
    @objc func closePopUp() {
        dismiss(animated: true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 150
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    // MARK: - Functions
    fileprivate func verifyFormData() -> Bool {
        let document = documentTextField.text!
        if document.isEmpty {
            return false
        } else {
            return true
        }
    }

    fileprivate func getClientInfo() {
        if verifyFormData() {

        }
    }

}

extension SearchDocumentViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayDocuments.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var title = UILabel()
        if let titlePicker = view {
            title = titlePicker as! UILabel
        }
        title.textAlignment = .center
        title.font = UIFont(name: "Raleway", size: 12)
        title.adjustsFontSizeToFitWidth = true
        title.text = arrayDocuments[row]
        return title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedDocument = arrayDocuments[row]
    }
}

extension SearchDocumentViewController: UIGestureRecognizerDelegate {
    // MARK: - UIGestureRecognizer Delegates
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: self.viewGlass) {
            return true
        }
        return false
    }
}
