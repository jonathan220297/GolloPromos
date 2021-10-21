//
//  EditProfileViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import RxSwift
import RxCocoa

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var namesTextField: UITextField!
    @IBOutlet weak var lastNamesTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!

    let disposeBag = DisposeBag()
    let dateFormatter = DateFormatter()

    var imagePicker = UIImagePickerController()

    private var datePicker: UIDatePicker?

    lazy var viewModel: EditProfileViewModel = {
        return EditProfileViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation Bar Configuration
        let rigthButton = UIBarButtonItem(image: UIImage(named: "ic_save"), style: .plain, target: self, action: #selector(loadPhoto))
        rigthButton.tintColor = .terracotta
        self.navigationItem.rightBarButtonItem = rigthButton
        self.navigationController?.navigationBar.tintColor = .white

        // Date Picker
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(EditProfileViewController.dateChange(datePicker:)), for: .valueChanged)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.viewTapped(gestureRecognized:)))
        view.addGestureRecognizer(tapGesture)

        birthdayTextField.inputView = datePicker

        // Delegate of Image Picker
        imagePicker.delegate = self

        configureRx()

        hideKeyboardWhenTappedAround()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        profileImageView.layer.borderColor = UIColor.white.cgColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        setUserData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    // MARK: - Functions
    fileprivate func setUserData() {
        if let user = viewModel.userManager.userData {
            if let displayName = user.displayName {
                namesTextField.text = displayName
            }
            if let email = user.email {
                emailTextField.text = email
            }
        }
    }

    // MARK: - Observers
    @objc func dateChange(datePicker: UIDatePicker) {
        dateFormatter.dateFormat = "MM/dd/yyyy"
        birthdayTextField.text = dateFormatter.string(from: datePicker.date)
    }

    @objc func viewTapped(gestureRecognized: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @objc func loadPhoto() {
        viewModel.uploadPhoto(profileImage: profileImageView.image, firstName: namesTextField.text, lastNames: lastNamesTextField.text, birthDate: datePicker?.date)
    }

}

extension EditProfileViewController {
    fileprivate func configureRx() {
        editProfileButton.rx.tap.bind {
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true)
        }
        .disposed(by: disposeBag)

        viewModel.errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] message in
                guard let self = self else { return }
                if !message.isEmpty {
                    self.showAlert(alertText: "GolloPromos", alertMessage: message)
                    self.viewModel.errorMessage.accept("")
                }
            })
            .disposed(by: disposeBag)
    }
}


extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            editProfileButton.alpha = 0
            profileImageView.image = image
        }
        dismiss(animated: true)
    }
}

