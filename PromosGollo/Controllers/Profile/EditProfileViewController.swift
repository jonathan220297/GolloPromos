//
//  EditProfileViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import UIKit
import RxSwift
import RxCocoa
import DropDown

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet weak var documentTypeLabel: UILabel!
    @IBOutlet weak var documentTypeButton: UIButton!
    @IBOutlet weak var documentNumberLabel: UITextField!
    @IBOutlet weak var searchCustomerButton: UIButton!
    @IBOutlet weak var searchCustomerHeight: NSLayoutConstraint!
    @IBOutlet weak var unregisteredUserView: UIView!
    @IBOutlet weak var registerUserButton: UIButton!
    // User data
    @IBOutlet weak var userDataStackView: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameRequiredLabel: UILabel!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var lastnameRequiredLabel: UILabel!
    @IBOutlet weak var secondLastNameTextField: UITextField!
    @IBOutlet weak var secondLastnameRequiredLabel: UILabel!
    @IBOutlet weak var birthdateTextField: UITextField!
    @IBOutlet weak var birthdateRequiredLabel: UILabel!
    @IBOutlet weak var genderTypeLabel: UILabel!
    @IBOutlet weak var genderRequiredLabel: UILabel!
    @IBOutlet weak var genderTypeButton: UIButton!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var phoneNumberRequiredLabel: UILabel!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var mobileRequiredLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailRequiredLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var addressRequiredLabel: UILabel!
    @IBOutlet weak var updateButton: LoadingButton!

    lazy var viewModel: EditProfileViewModel = {
        let vm = EditProfileViewModel()
        vm.processDocTypes()
        vm.processGenderTypes()
        return vm
    }()
    let disposeBag = DisposeBag()

    private let userManager = UserManager.shared
    var imagePicker = UIImagePickerController()
    var documentType = ""
    var genderType = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()

        // Delegate of Image Picker
        imagePicker.delegate = self

        hideKeyboardWhenTappedAround()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
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
    fileprivate func configureRx() {
        viewModel.errorMessage
            .asObservable()
            .subscribe(onNext: {[weak self] message in
                guard let self = self else { return }
                self.view.activityStopAnimating()
                if !message.isEmpty {
                    if message == "Identificación no existe en la base de datos" {
                        self.unregisteredUserView.alpha = 1
                    } else if self.unregisteredUserView.alpha != 1 {
                        self.showAlert(alertText: "GolloApp", alertMessage: message)
                    }
                    self.viewModel.errorMessage.accept("")
                }
            })
            .disposed(by: disposeBag)

        addImageButton
            .rx
            .tap
            .subscribe(onNext: {
                self.changeImage()
            })
            .disposed(by: disposeBag)

        editImageButton
            .rx
            .tap
            .subscribe(onNext: {
                self.changeImage()
            })
            .disposed(by: disposeBag)
        
        documentTypeButton
            .rx
            .tap
            .subscribe(onNext: {
                self.configureDocumentTypeDropDown()
            })
            .disposed(by: disposeBag)

        registerUserButton
            .rx
            .tap
            .subscribe(onNext: {
                self.showData(with: nil)
            })
            .disposed(by: disposeBag)

        genderTypeButton
            .rx
            .tap
            .subscribe(onNext: {
                self.configureGenderTypeDropDown()
            })
            .disposed(by: disposeBag)

        searchCustomerButton
            .rx
            .tap
            .subscribe(onNext: {
                self.fetchUserData()
            })
            .disposed(by: disposeBag)

        documentNumberLabel
            .rx
            .controlEvent([.editingDidBegin,.editingDidEnd])
            .asObservable()
            .subscribe(onNext: {
                if self.unregisteredUserView.alpha == 1 {
                    self.unregisteredUserView.alpha = 0
                }
            }).disposed(by: disposeBag)

        let phoneValidation = phoneNumberTextField
            .rx
            .text
            .orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)

        let mobileValidation = mobileTextField
            .rx
            .text
            .orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)

        let emailValidation = emailTextField
            .rx
            .text
            .orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)

        let addressValidation = addressTextField
            .rx
            .text
            .orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)

        let everythingValid = Observable.combineLatest(
            phoneValidation,
            mobileValidation,
            emailValidation,
            addressValidation
        ) { $0 && $1 && $2 && $3 }
            .share(replay: 1)

        everythingValid
            .bind(to: updateButton.rx.isEnabled)
            .disposed(by: disposeBag)

        everythingValid
            .map { $0 ? 1 : 0.4 }
            .bind(to: updateButton.rx.alpha)
            .disposed(by: disposeBag)

        updateButton
            .rx
            .tap
            .subscribe(onNext: {
                self.saveUserData()
            })
            .disposed(by: disposeBag)
    }

    func configureNuewUserRx() {
        let usernameValidation = nameTextField
            .rx
            .text
            .orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)

        let lastnameValidation = lastNameTextField
            .rx
            .text
            .orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)

        let secondLastnameValidation = secondLastNameTextField
            .rx
            .text
            .orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)

        let birthDateValidation = birthdateTextField
            .rx
            .text
            .orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)

        let phoneValidation = phoneNumberTextField
            .rx
            .text
            .orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)

        let mobileValidation = mobileTextField
            .rx
            .text
            .orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)

        let emailValidation = emailTextField
            .rx
            .text
            .orEmpty
            .map { $0.count > 0 && $0.isValidEmail() }
            .share(replay: 1)

        let addressValidation = addressTextField
            .rx
            .text
            .orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)

        let everythingValid = Observable.combineLatest(
            usernameValidation,
            lastnameValidation,
            secondLastnameValidation,
            birthDateValidation,
            phoneValidation,
            mobileValidation,
            emailValidation,
            addressValidation
        ) { $0 && $1 && $2 && $3 && $4 && $5 && $6 && $7 }
            .share(replay: 1)

        everythingValid
            .bind(to: updateButton.rx.isEnabled)
            .disposed(by: disposeBag)

        everythingValid
            .map { $0 ? 1 : 0.4 }
            .bind(to: updateButton.rx.alpha)
            .disposed(by: disposeBag)
    }

    func changeImage() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func configureDocumentTypeDropDown() {
        let dropDown = DropDown()
        dropDown.anchorView = documentTypeButton
        dropDown.dataSource = viewModel.docTypes.map { $0.name }
        dropDown.show()
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            documentType = viewModel.docTypes[index].code
            documentTypeLabel.text = item
        }
    }

    func configureGenderTypeDropDown() {
        let dropDown = DropDown()
        dropDown.anchorView = genderTypeButton
        dropDown.dataSource = viewModel.genderTypes.map { $0.name }
        dropDown.show()
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            genderType = viewModel.genderTypes[index].code
            genderTypeLabel.text = item
        }
    }

    fileprivate func fetchUserData() {
        view.activityStarAnimating()
        viewModel.fetchUserData(id: self.documentNumberLabel.text ?? "", type: documentType)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                self.view.activityStopAnimating()
                if let _ = data.numeroIdentificacion, let _ = data.numeroIdentificacion {
                    self.showData(with: data)
                } else {
                    self.unregisteredUserView.alpha = 1
                }
            })
            .disposed(by: disposeBag)
    }

    fileprivate func showData(with data: UserData?) {
        view.activityStopAnimating()
        searchCustomerButton.visibility = .gone
        searchCustomerHeight.constant = 0
        userDataStackView.alpha = 1
        profileImageView.isHidden = false
        self.unregisteredUserView.isHidden = true
        view.layoutIfNeeded()
        if let data = data {
            documentTypeButton.isEnabled = false
            documentNumberLabel.isEnabled = false
            nameTextField.isEnabled = false
            lastNameTextField.isEnabled = false
            secondLastNameTextField.isEnabled = false
            if let date = data.fechaNacimiento, !date.isEmpty {
                birthdateTextField.text = date
                birthdateTextField.isEnabled = false
            } else {
                birthdateTextField.isEnabled = true
            }
            if let gender = data.genero, !gender.isEmpty {
                genderType = gender
                genderTypeLabel.text = viewModel.genderTypes.first(where: { $0.code.elementsEqual(gender) })?.name ?? ""
                genderTypeButton.isEnabled = false
            } else {
                genderTypeButton.isEnabled = true
            }
            nameTextField.text = data.nombre
            lastNameTextField.text = data.apellido1
            secondLastNameTextField.text = data.apellido2
            phoneNumberTextField.text = data.telefonoTrabajo
            mobileTextField.text = data.telefono1
            emailTextField.text = data.correoElectronico1
            addressTextField.text = data.direccion
        }
    }

    fileprivate func saveUserData() {
        let userInfo = UserInfo(
            idCliente: UserManager.shared.userData?.uid ?? "",
            nombre: nameTextField.text,
            apellido1: lastNameTextField.text,
            apellido2: secondLastNameTextField.text,
            telefono1: phoneNumberTextField.text,
            telefono2: mobileTextField.text,
            tipoIdentificacion: documentType,
            numeroIdentificacion: documentNumberLabel.text,
            direccion: addressTextField.text,
            latitud: nil,
            longitud: nil,
            correoElectronico1: emailTextField.text,
            fechaNacimiento: birthdateTextField.text,
            image: viewModel.convertImageToBase64String(img: userImageView.image),
            genero: genderType
        )
        view.activityStarAnimating()
        viewModel.updateUserData(with: userInfo)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let _ = data else { return }
                Variables.isRegisterUser = true
                Variables.isClientUser = true
                Variables.isLoginUser = true
                Variables.userProfile = userInfo
                self.showAlert(alertText: "GolloApp", alertMessage: "Usuario actualizado exitosamente.")
            })
            .disposed(by: disposeBag)
    }

}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            userImageView.image = image
        }
        addImageButton.alpha = 0
        editImageButton.alpha = 1
        dismiss(animated: true)
    }
}
