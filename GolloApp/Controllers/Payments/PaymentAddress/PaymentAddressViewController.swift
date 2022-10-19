//
//  PaymentAddressViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 22/9/22.
//

import DropDown
import RxSwift
import UIKit

class PaymentAddressViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var documentTypeLabel: UILabel!
    @IBOutlet weak var documentTypeButton: UIButton!
    @IBOutlet weak var identificationNumberTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var selectAddressView: UIView!
    @IBOutlet weak var selectAddressButton: UIButton!
    @IBOutlet weak var locationPickerView: UIView!
    @IBOutlet weak var locationPickerButton: UIButton!
    @IBOutlet weak var countyLabel: UILabel!
    @IBOutlet weak var countyButton: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var districtButton: UIButton!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var saveAddressView: UIView!
    @IBOutlet weak var saveAddressButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    // MARK: - Constants
    var viewModel: PaymentAddressViewModel
    let bag = DisposeBag()

    init(viewModel: PaymentAddressViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "PaymentAddressViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Info. personal"
        tabBarController?.navigationItem.hidesBackButton = false
        tabBarController?.navigationController?.navigationBar.tintColor = .white
        configureViews()
        configureObservers()
        configureRx()
        hideKeyboardWhenTappedAround()
        initSpinners()
        setUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Observers
    @objc func keyboardWillShow(notification: NSNotification) {

        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {

        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    // MARK: - Functions
    fileprivate func setUserData() {
        firstNameTextField.text = Variables.userProfile?.nombre
        viewModel.firstNameSubject.accept(Variables.userProfile?.nombre)
        lastNameTextField.text = Variables.userProfile?.apellido1
        viewModel.lastNameSubject.accept(Variables.userProfile?.apellido1)
        emailTextField.text = Variables.userProfile?.correoElectronico1
        viewModel.emailSubject.accept(Variables.userProfile?.correoElectronico1)
        phoneNumberTextField.text = Variables.userProfile?.telefono1
        viewModel.phoneNumberSubject.accept(Variables.userProfile?.telefono1)
        if let document = viewModel.documentTypeArray.first {
            self.documentTypeLabel.text = document
            self.viewModel.documentTypeSubject.accept(document)
        }
        identificationNumberTextField.text = Variables.userProfile?.numeroIdentificacion
        viewModel.identificationNumberSubject.accept(Variables.userProfile?.numeroIdentificacion)
    }
    
    fileprivate func configureRx() {
        firstNameTextField.rx.text.bind(to: viewModel.firstNameSubject).disposed(by: bag)
        lastNameTextField.rx.text.bind(to: viewModel.lastNameSubject).disposed(by: bag)
        emailTextField.rx.text.bind(to: viewModel.emailSubject).disposed(by: bag)
        phoneNumberTextField.rx.text.bind(to: viewModel.phoneNumberSubject).disposed(by: bag)
        documentTypeButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayDocumentTypeList()
            })
            .disposed(by: bag)
        identificationNumberTextField.rx.text.bind(to: viewModel.identificationNumberSubject).disposed(by: bag)
        selectAddressButton.rx
            .tap
            .subscribe(onNext: {
                self.showAddressListPage()
            })
            .disposed(by: bag)
        stateButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayStatesList()
            })
            .disposed(by: bag)
        countyButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayCountyList()
            })
            .disposed(by: bag)
        districtButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayDistrictList()
            })
            .disposed(by: bag)
        addressTextField.rx.text.bind(to: viewModel.addressSubject).disposed(by: bag)
        locationPickerButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.showLocationPicker()
            })
            .disposed(by: bag)
        saveAddressButton.rx
            .tap
            .subscribe(onNext: {
                self.saveAddress()
            })
            .disposed(by: bag)
        viewModel.isFormValid.bind(to: continueButton.rx.isEnabled).disposed(by: bag)
        viewModel.isFormValid.map { $0 ? 1 : 0.4 }.bind(to: continueButton.rx.alpha).disposed(by: bag)

        continueButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.prepareAddressInfo()
            })
            .disposed(by: bag)
    }
    
    fileprivate func configureViews() {
        selectAddressView.layer.borderColor = UIColor.darkGray.cgColor
        locationPickerView.layer.borderColor = UIColor.darkGray.cgColor
        saveAddressView.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    fileprivate func configureObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name:UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name:UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    fileprivate func displayDocumentTypeList() {
        let dropDown = DropDown()
        dropDown.anchorView = documentTypeButton
        dropDown.dataSource = viewModel.documentTypeArray
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.documentTypeLabel.text = item
            self.viewModel.documentTypeSubject.accept(item)
        }
        dropDown.show()
    }
    
    fileprivate func showLocationPicker() {
//        let vc = LocationPickerViewController.instantiate(fromAppStoryboard: .Payment)
//        vc.modalPresentationStyle = .fullScreen
//        vc.delegate = self
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func initSpinners() {
        fetchStates()
    }
    
    fileprivate func fetchStates() {
        view.activityStarAnimating()
        viewModel
            .fetchStates()
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response,
                      let firstItem = response.first else { return }
                self.viewModel.statesArray.accept(response)
                self.stateLabel.text = firstItem.provincia
                self.viewModel.stateSubject.accept(firstItem.idProvincia)
                self.fetchCities(state: firstItem.idProvincia)
            })
            .disposed(by: bag)
    }
    
    fileprivate func fetchCities(state: String) {
        viewModel
            .fetchCities(state: state)
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response,
                      let firstItem = response.provincias.first,
                      let firstCounty = firstItem.cantones.first,
                      let firstDistrict = firstCounty.distritos.first else { return }
                self.viewModel.citiesArray.accept(firstItem.cantones)
                self.viewModel.districtArray.accept(firstCounty.distritos)
                self.countyLabel.text = firstCounty.canton
                self.viewModel.countySubject.accept(firstCounty.idCanton)
                self.districtLabel.text = firstDistrict.distrito
                self.viewModel.districtSubject.accept(firstDistrict.idDistrito)
                self.view.activityStopAnimating()
            })
            .disposed(by: bag)
    }
    
    fileprivate func displayStatesList() {
        let dropDown = DropDown()
        dropDown.anchorView = stateButton
        dropDown.dataSource = viewModel.statesArray.value.map{ $0.provincia }
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.stateLabel.text = item
            self.viewModel.stateSubject.accept(self.viewModel.statesArray.value[index].idProvincia)
            self.fetchCities(state: self.viewModel.statesArray.value[index].idProvincia)
        }
        dropDown.show()
    }
    
    fileprivate func displayCountyList() {
        let dropDown = DropDown()
        dropDown.anchorView = countyButton
        dropDown.dataSource = viewModel.citiesArray.value.map{ $0.canton }
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.countyLabel.text = item
            self.viewModel.countySubject.accept(self.viewModel.citiesArray.value[index].idCanton)
            self.fetchDistrictList(with: self.viewModel.citiesArray.value[index].idCanton)
        }
        dropDown.show()
    }
    
    fileprivate func displayDistrictList() {
        let dropDown = DropDown()
        dropDown.anchorView = districtButton
        dropDown.dataSource = viewModel.districtArray.value.map{ $0.distrito }
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.districtLabel.text = item
            self.viewModel.districtSubject.accept(self.viewModel.districtArray.value[index].idDistrito)
        }
        dropDown.show()
    }
    
    fileprivate func fetchDistrictList(with countyId: String) {
        guard let county = viewModel.citiesArray.value.first(where: { county in
            county.idCanton == countyId
        }), let district = county.distritos.first else { return }
        self.viewModel.districtArray.accept(county.distritos)
        self.viewModel.districtSubject.accept(district.idDistrito)
        self.districtLabel.text = district.distrito
    }
    
    fileprivate func prepareAddressInfo() {
        viewModel.prepareAddressInfoForPayment()
        showShippingMethodsPage()
    }
    
    fileprivate func showShippingMethodsPage() {
        let shippingMethodViewController = ShippingMethodViewController(
            viewModel: ShippingMethodViewModel(),
            state: viewModel.stateSubject.value,
            county: viewModel.countySubject.value,
            district: viewModel.districtSubject.value
        )
        shippingMethodViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(shippingMethodViewController, animated: true)
    }
    
    fileprivate func showAddressListPage() {
        let addressListViewController = AddressListViewController(
            viewModel: AddressListViewModel(),
            delegate: self
        )
        addressListViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(addressListViewController, animated: true)
    }
    
    fileprivate func saveAddress() {
        viewModel
            .saveAddress()
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self else { return }
                self.showAlert(alertText: "GolloApp", alertMessage: "Dirección guardada correctamente")
            })
            .disposed(by: bag)
    }
}

extension PaymentAddressViewController: AddressListDelegate {
    func didSelectAddress(address: UserAddress) {
        let stateSelected = viewModel.statesArray.value.first { state in
            state.idProvincia == address.idProvincia
        }
        viewModel.stateSubject.accept(stateSelected?.idProvincia ?? "")
        stateLabel.text = stateSelected?.provincia ?? ""
        let countySelected = viewModel.citiesArray.value.first { county in
            county.idCanton == address.idCanton
        }
        viewModel.countySubject.accept(countySelected?.idCanton ?? "")
        countyLabel.text = countySelected?.canton ?? ""
        viewModel.districtSubject.accept(address.idDistrito)
        districtLabel.text = address.distritoDesc
        addressTextField.text = address.direccionExacta
        postalCodeTextField.text = address.codigoPostal
    }
}
