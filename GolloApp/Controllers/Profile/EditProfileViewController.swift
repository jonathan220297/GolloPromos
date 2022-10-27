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
import Nuke

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
    let datePicker = UIDatePicker()

    private let userManager = UserManager.shared
    let userDefaults = UserDefaults.standard
    var imagePicker = UIImagePickerController()
    var documentType = ""
    var genderType = ""
    var sideMenuAcction = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureObservers()
        configureRx()
        createDatePicker()
        configureUserData()
        hideKeyboardWhenTappedAround()
        imagePicker.delegate = self
        documentNumberLabel.delegate = self
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        if sideMenuAcction {
            self.tabBarController?.navigationController?.navigationBar.isHidden = false
            self.tabBarController?.tabBar.isHidden = false
        }
    }

    // MARK: - Observers
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 && self.searchCustomerButton.visibility == UIView.Visibility.gone {
                self.view.frame.origin.y -= keyboardSize.height - 50
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @objc func donePressed() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        birthdateTextField.text = dateFormatter.string(from: datePicker.date)
        viewModel.birthDateSubject.accept(dateFormatter.string(from: datePicker.date))
        self.view.endEditing(true)
    }
    
    // MARK: - Functions
    func configureNavigationBar() {
        self.navigationItem.title = "Perfil de usuario"
        self.tabBarController?.tabBar.isHidden = true
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .primary
        barAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationItem.standardAppearance = barAppearance
        navigationItem.scrollEdgeAppearance = barAppearance
    }
    
    func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func createDatePicker() {
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date

        birthdateTextField.textAlignment = .justified
        birthdateTextField.inputView = datePicker
        birthdateTextField.inputAccessoryView = createToolbar()
    }

    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)

        return toolbar
    }
    
    fileprivate func configureUserData() {
        viewModel.isUpdating = (Variables.userProfile != nil && Variables.isRegisterUser)
        if let info = Variables.userProfile, Variables.isRegisterUser {
            let data = UserData(
                tipoIdentificacion: info.tipoIdentificacion,
                tarjetasDeCredito: "",
                estadoCivil: "",
                numeroIdentificacion: info.numeroIdentificacion,
                nombre: info.nombre,
                apellido1: info.apellido1,
                apellido2: info.apellido2,
                idRegistroBit: 0,
                salario: 0,
                direccion: info.direccion,
                fechaIngresoTrabajo: "",
                corporacion: "",
                lugarTrabajo: "",
                direccionTrabajo: "",
                telefonoTrabajo: "",
                nombreConyugue: "",
                casa: "",
                genero: info.genero,
                correoElectronico1: info.correoElectronico1,
                correoElectronico2: "",
                telefono1: info.telefono1,
                telefono2: info.telefono2,
                cantidadHijos: 0,
                fechaNacimiento: info.fechaNacimiento,
                nacionalidad: "",
                carroPropio: "",
                ocupacion: "",
                image: Variables.userProfile?.image
            )
            showData(with: data)
        }
    }

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

        nameTextField.rx.text.bind(to: viewModel.nameSubject).disposed(by: disposeBag)
        lastNameTextField.rx.text.bind(to: viewModel.lastnameSubject).disposed(by: disposeBag)
        secondLastNameTextField.rx.text.bind(to: viewModel.secondLastnameSubject).disposed(by: disposeBag)
        nameTextField.rx.text.bind(to: viewModel.nameSubject).disposed(by: disposeBag)
        birthdateTextField.rx.text.bind(to: viewModel.birthDateSubject).disposed(by: disposeBag)
        phoneNumberTextField.rx.text.bind(to: viewModel.phonenumberSubject).disposed(by: disposeBag)
        mobileTextField.rx.text.bind(to: viewModel.mobileNumberSubject).disposed(by: disposeBag)
        emailTextField.rx.text.bind(to: viewModel.emailSubject).disposed(by: disposeBag)
        addressTextField.rx.text.bind(to: viewModel.addressSubject).disposed(by: disposeBag)

        viewModel.isValidForm.bind(to: updateButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.isValidForm.map { $0 ? 1 : 0.4 }.bind(to: updateButton.rx.alpha).disposed(by: disposeBag)

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

        updateButton
            .rx
            .tap
            .subscribe(onNext: {
                self.saveUserData()
            })
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
            self.documentType = viewModel.docTypes[index].code
            self.documentTypeLabel.text = item
        }
    }

    func configureGenderTypeDropDown() {
        let dropDown = DropDown()
        dropDown.anchorView = genderTypeButton
        dropDown.dataSource = viewModel.genderTypes.map { $0.name }
        dropDown.show()
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            self.genderType = viewModel.genderTypes[index].code
            self.genderTypeLabel.text = item
            viewModel.genderSubject.accept(item)
        }
    }

    fileprivate func fetchUserData() {
        if documentType.isEmpty {
            showAlert(alertText: "GolloApp", alertMessage: "Seleccione el tipo de documento de idendidad")
        } else if documentNumberLabel.text?.isEmpty ?? true {
            showAlert(alertText: "GolloApp", alertMessage: "Ingrese documento de idendidad")
        } else if documentType == "C" && !isValidCelular(number: documentNumberLabel.text ?? "")  {
            showAlert(alertText: "GolloApp", alertMessage: "Cédula inválida")
        } else {
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
    }

    fileprivate func isValidCelular(number: String) -> Bool {
        let range = NSRange(location: 0, length: number.utf16.count)
        let regex = try! NSRegularExpression(pattern: "^[1-9]\\d{4}\\d{4}$")
        let valid = regex.firstMatch(in: number, options: [], range: range) != nil

        return valid
    }

    fileprivate func showData(with data: UserData?) {
        view.activityStopAnimating()
        searchCustomerButton.visibility = .gone
        searchCustomerHeight.constant = 0
        userDataStackView.alpha = 1
        profileImageView.isHidden = false
        self.unregisteredUserView.isHidden = true
        view.layoutIfNeeded()
        let _ = ImageLoadingOptions(
            placeholder: UIImage(named: "empty_image"),
            transition: .fadeIn(duration: 0.5),
            failureImage: UIImage(named: "empty_image")
        )
        if let data = data {
            if let decodedData = Data(base64Encoded: Variables.userProfile?.image ?? ""),
               let decodedimage = UIImage(data: decodedData) {
                userImageView.image = decodedimage
                addImageButton.alpha = 0
                editImageButton.alpha = 1
            } else {
                if let url = URL(string: Variables.userProfile?.image ?? "") {
                    Nuke.loadImage(with: url, into: userImageView)
                    addImageButton.alpha = 0
                    editImageButton.alpha = 1
                }
            }
            documentTypeLabel.text = viewModel.docTypes.first(where: { $0.code.elementsEqual(data.tipoIdentificacion ?? "C") })?.name ?? "ProfileViewController_cedula".localized
            documentType = viewModel.docTypes.first(where: { $0.code.elementsEqual(data.tipoIdentificacion ?? "C") })?.name ?? "C"
            documentTypeButton.isEnabled = false
            documentNumberLabel.text = data.numeroIdentificacion
            documentNumberLabel.isEnabled = false
            nameTextField.isEnabled = false
            lastNameTextField.isEnabled = false
            secondLastNameTextField.isEnabled = false
            if let date = data.fechaNacimiento, !date.isEmpty {
                if !date.convertDateFormater(with: "dd/MM/yyyy").isEmpty {
                    birthdateTextField.text = date.convertDateFormater(with: "dd/MM/yyyy")
                    viewModel.birthDateSubject.accept(date.convertDateFormater(with: "dd/MM/yyyy"))
                } else {
                    birthdateTextField.text = date
                    viewModel.birthDateSubject.accept(date)
                }
                birthdateTextField.isEnabled = false
            } else {
                birthdateTextField.isEnabled = true
            }
            if let gender = data.genero, !gender.isEmpty {
                genderType = gender
                genderTypeLabel.text = viewModel.genderTypes.first(where: { $0.code.elementsEqual(gender) })?.name ?? ""
                viewModel.genderSubject.accept(viewModel.genderTypes.first(where: { $0.code.elementsEqual(gender) })?.name)
                genderTypeButton.isEnabled = false
            } else {
                genderTypeButton.isEnabled = true
            }
            nameTextField.text = data.nombre
            viewModel.nameSubject.accept(data.nombre)
            lastNameTextField.text = data.apellido1
            viewModel.lastnameSubject.accept(data.apellido1)
            secondLastNameTextField.text = data.apellido2
            viewModel.secondLastnameSubject.accept(data.apellido2)
            phoneNumberTextField.text = data.telefono1
            viewModel.phonenumberSubject.accept(data.telefono1)
            mobileTextField.text = data.telefono2
            viewModel.mobileNumberSubject.accept(data.telefono2)
            emailTextField.text = data.correoElectronico1
            viewModel.emailSubject.accept(data.correoElectronico1)
            addressTextField.text = data.direccion
            viewModel.addressSubject.accept(data.direccion)
        }
    }

    fileprivate func saveUserData() {
        view.activityStarAnimating()
        let userInfo = UserInfo(
            idCliente: UserManager.shared.userData?.uid ?? "",
            nombre: viewModel.nameSubject.value,
            apellido1: viewModel.lastnameSubject.value,
            apellido2: viewModel.secondLastnameSubject.value,
            telefono1: viewModel.phonenumberSubject.value,
            telefono2: viewModel.mobileNumberSubject.value,
            tipoIdentificacion: documentType,
            numeroIdentificacion: documentNumberLabel.text,
            direccion: addressTextField.text,
            latitud: nil,
            longitud: nil,
            correoElectronico1: viewModel.emailSubject.value,
            fechaNacimiento: viewModel.birthDateSubject.value,
            image: viewModel.convertImageToBase64String(img: userImageView.image),
            genero: genderType
        )
        viewModel.updateUserData(with: userInfo)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                Variables.isRegisterUser = data.estadoRegistro
                Variables.isClientUser = data.estadoCliente
                Variables.isLoginUser = data.estadoLogin
                Variables.userProfile = userInfo
                do {
                    try self.userDefaults.setObject(userInfo, forKey: "Information")
                } catch {
                    print(error.localizedDescription)
                }
                self.view.activityStopAnimating()
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

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
