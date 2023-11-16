//
//  PaymentAddressViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 22/9/22.
//

import DropDown
import RxSwift
import UIKit
import FirebaseAuth

class PaymentAddressViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var firstNameBottomView: UIView!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var lastNameBottomView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailBottomView: UIView!
    @IBOutlet weak var documentTypeLabel: UILabel!
    @IBOutlet weak var documentTypeButton: UIButton!
    @IBOutlet weak var documentBottomView: UIView!
    @IBOutlet weak var identificationNumberTextField: UITextField!
    @IBOutlet weak var identificationBottomView: UIView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var phoneNumberBottomView: UIView!
    @IBOutlet weak var selectAddressView: UIView!
    @IBOutlet weak var selectAddressButton: UIButton!
    @IBOutlet weak var localizationAddressView: UIView!
    @IBOutlet weak var localizationAddressButton: UIButton!
    @IBOutlet weak var locationPickerView: UIView!
    @IBOutlet weak var locationPickerButton: UIButton!
    @IBOutlet weak var currentLocationView: UIView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var countyLabel: UILabel!
    @IBOutlet weak var countyButton: UIButton!
    @IBOutlet weak var countyBottomView: UIView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var stateBottomView: UIView!
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var districtButton: UIButton!
    @IBOutlet weak var districtBottomView: UIView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var addressBottomView: UIView!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var preApprovedView: UIView!
    @IBOutlet weak var preApprovedSwitch: UISwitch!
    @IBOutlet weak var creditCardView: UIView!
    @IBOutlet weak var creditCardSwitch: UISwitch!
    @IBOutlet weak var saveAddressView: UIView!
    @IBOutlet weak var saveAddressButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    // MARK: - Constants
    var viewModel: PaymentAddressViewModel
    let bag = DisposeBag()
    let userDefaults = UserDefaults.standard
    var firstLoad = true
    
    init(viewModel: PaymentAddressViewModel) {
        self.viewModel = viewModel
        self.viewModel.processDocTypes()
        super.init(nibName: "PaymentAddressViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Datos de envío"
        tabBarController?.navigationItem.hidesBackButton = false
        tabBarController?.navigationController?.navigationBar.tintColor = .white
        
        configureViews()
        configureObservers()
        configureRx()
        configureErrors()
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
            self.documentTypeLabel.text = document.name
            self.viewModel.documentTypeSubject.accept(document.code)
        }
        identificationNumberTextField.text = Variables.userProfile?.numeroIdentificacion
        viewModel.identificationNumberSubject.accept(Variables.userProfile?.numeroIdentificacion)
    }
    
    fileprivate func configureRx() {
        firstNameTextField.rx.text.bind(to: viewModel.firstNameSubject).disposed(by: bag)
        lastNameTextField.rx.text.bind(to: viewModel.lastNameSubject).disposed(by: bag)
        emailTextField.rx.text.bind(to: viewModel.emailSubject).disposed(by: bag)
        phoneNumberTextField.rx.text.bind(to: viewModel.phoneNumberSubject).disposed(by: bag)
        addressTextField.rx.text.bind(to: viewModel.addressSubject).disposed(by: bag)
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
        localizationAddressButton
            .rx
            .tap
            .subscribe(onNext: {
                let geolozalizationViewController = GeolozalizationViewController(
                    delegate: self
                )
                geolozalizationViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(geolozalizationViewController, animated: true)
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
        
        preApprovedSwitch
            .rx
            .isOn
            .subscribe(onNext: {[weak self] value in
                guard let self = self else { return }
                self.viewModel.preApprovedSubject.accept(value)
            })
            .disposed(by: bag)
        
        creditCardSwitch
            .rx
            .isOn
            .subscribe(onNext: {[weak self] value in
                guard let self = self else { return }
                self.viewModel.creditCardSubject.accept(value)
            })
            .disposed(by: bag)
        
        saveAddressButton.rx
            .tap
            .subscribe(onNext: {
                self.saveAddress()
            })
            .disposed(by: bag)
        viewModel.isFormValid.map { $0 ? 1 : 0.4 }.bind(to: continueButton.rx.alpha).disposed(by: bag)
        
        continueButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                if self.viewModel.validateInputs() {
                    self.prepareAddressInfo()
                }
            })
            .disposed(by: bag)
    }
    
    fileprivate func configureErrors() {
        viewModel.nameError.asObservable().subscribe(onNext: {[weak self] value in
            guard let self = self else { return }
            if value {
                self.firstNameBottomView.backgroundColor = .red
            } else {
                self.firstNameBottomView.backgroundColor = .secondaryLabel
            }
        }).disposed(by: bag)
        viewModel.lastNameError.asObservable().subscribe(onNext: {[weak self] value in
            guard let self = self else { return }
            if value {
                self.lastNameBottomView.backgroundColor = .red
            } else {
                self.lastNameBottomView.backgroundColor = .secondaryLabel
            }
        }).disposed(by: bag)
        viewModel.emailError.asObservable().subscribe(onNext: {[weak self] value in
            guard let self = self else { return }
            if value {
                self.emailBottomView.backgroundColor = .red
            } else {
                self.emailBottomView.backgroundColor = .secondaryLabel
            }
        }).disposed(by: bag)
        viewModel.phoneNumberError.asObservable().subscribe(onNext: {[weak self] value in
            guard let self = self else { return }
            if value {
                self.phoneNumberBottomView.backgroundColor = .red
            } else {
                self.phoneNumberBottomView.backgroundColor = .secondaryLabel
            }
        }).disposed(by: bag)
        viewModel.documentTypeError.asObservable().subscribe(onNext: {[weak self] value in
            guard let self = self else { return }
            if value {
                self.documentBottomView.backgroundColor = .red
            } else {
                self.documentBottomView.backgroundColor = .secondaryLabel
            }
        }).disposed(by: bag)
        viewModel.identificationNumberError.asObservable().subscribe(onNext: {[weak self] value in
            guard let self = self else { return }
            if value {
                self.identificationBottomView.backgroundColor = .red
            } else {
                self.identificationBottomView.backgroundColor = .secondaryLabel
            }
        }).disposed(by: bag)
        viewModel.stateError.asObservable().subscribe(onNext: {[weak self] value in
            guard let self = self else { return }
            if value {
                self.stateBottomView.backgroundColor = .red
            } else {
                self.stateBottomView.backgroundColor = .secondaryLabel
            }
        }).disposed(by: bag)
        viewModel.countyError.asObservable().subscribe(onNext: {[weak self] value in
            guard let self = self else { return }
            if value {
                self.countyBottomView.backgroundColor = .red
            } else {
                self.countyBottomView.backgroundColor = .secondaryLabel
            }
        }).disposed(by: bag)
        viewModel.districtError.asObservable().subscribe(onNext: {[weak self] value in
            guard let self = self else { return }
            if value {
                self.districtBottomView.backgroundColor = .red
            } else {
                self.districtBottomView.backgroundColor = .secondaryLabel
            }
        }).disposed(by: bag)
        viewModel.addressError.asObservable().subscribe(onNext: {[weak self] value in
            guard let self = self else { return }
            if value {
                self.addressBottomView.backgroundColor = .red
            } else {
                self.addressBottomView.backgroundColor = .secondaryLabel
            }
        }).disposed(by: bag)
        
        viewModel
            .errorExpiredToken
            .asObservable()
            .subscribe(onNext: {[weak self] value in
                guard let self = self,
                      let value = value else { return }
                if value {
                    let _ = KeychainManager.delete(key: "token")
                    let firebaseAuth = Auth.auth()
                    do {
                        try firebaseAuth.signOut()
                        let story = UIStoryboard(name: "Main", bundle:nil)
                        let vc = story.instantiateViewController(withIdentifier: "navVC") as! UINavigationController
                        UIApplication.shared.windows.first?.rootViewController = vc
                        UIApplication.shared.windows.first?.makeKeyAndVisible()
                        self.userDefaults.removeObject(forKey: "Information")
                    } catch _ as NSError {
            //            log.error("Error signing out: \(signOutError)")
                    }
                    self.viewModel.errorExpiredToken.accept(nil)
                }
            })
            .disposed(by: bag)
    }
    
    fileprivate func configureViews() {
        selectAddressView.layer.borderColor = UIColor.darkGray.cgColor
        localizationAddressView.layer.borderColor = UIColor.darkGray.cgColor
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
        dropDown.dataSource = viewModel.documentTypeArray.map { $0.name }
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.documentTypeLabel.text = item
            self.viewModel.documentTypeSubject.accept(self.viewModel.documentTypeArray[index].code)
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
        fetchClient()
        fetchStates()
    }
    
    fileprivate func fetchClient() {
        if let info = Variables.userProfile {
            viewModel
                .fetchUserData(id: info.numeroIdentificacion ?? "", type: info.tipoIdentificacion ?? "")
                .asObservable()
                .subscribe(onNext: {[weak self] data in
                    guard let self = self,
                          let data = data else { return }
                    if let profile = data.perfil, let _ = profile.numeroIdentificacion, let _ = profile.numeroIdentificacion {
                        Variables.profile = profile
                        if profile.indPreaprobado == 1 {
                            self.preApprovedView.isHidden = false
                        } else {
                            self.preApprovedView.isHidden = true
                        }
                        
                        if profile.indPreaprobado != 1 && profile.indEmma != 1 {
                            self.creditCardView.isHidden = false
                        } else {
                            self.creditCardView.isHidden = true
                        }
                    }
                })
                .disposed(by: bag)
        }
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
                self.view.activityStopAnimating()
                self.viewModel.statesArray.accept(response)
                self.stateLabel.text = ""
                self.viewModel.stateSubject.accept(nil)
                
                do {
                    let previousSelectedProvince = try self.userDefaults.getObject(forKey: "Province", castTo: State?.self)
                    var id = firstItem.idProvincia
                    if let selectedProvince = previousSelectedProvince {
                        id = selectedProvince.idProvincia
                    }
                    self.fetchCities(state: id) {[weak self] response in
                        guard let self = self else { return }
                        self.processCities(with: response)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            })
            .disposed(by: bag)
    }
    
    fileprivate func fetchCities(state: String, completion: @escaping(_ result: Provincias?) -> Void) {
        viewModel
            .fetchCities(state: state)
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard self != nil else { return }
                completion(response)
            })
            .disposed(by: bag)
    }
    
    fileprivate func processCities(with response : Provincias?) {
        guard let response = response,
              let firstItem = response.provincias.first,
              let firstCounty = firstItem.cantones.first,
              let firstDistrict = firstCounty.distritos.first else { return }
        self.viewModel.citiesArray.accept(firstItem.cantones)
        self.viewModel.districtArray.accept(firstCounty.distritos)
        self.countyLabel.text = ""
        self.viewModel.countySubject.accept(nil)
        self.districtLabel.text = ""
        self.viewModel.districtSubject.accept(nil)
        //        self.countyLabel.text = firstCounty.canton
        //        self.viewModel.countySubject.accept(firstCounty)
        //        self.districtLabel.text = firstDistrict.distrito
        //        self.viewModel.districtSubject.accept(firstDistrict)
        self.view.activityStopAnimating()
        
        if firstLoad {
            do {
                let previousSelectedProvince = try self.userDefaults.getObject(forKey: "Province", castTo: State?.self)
                let previousSelectedCounty = try self.userDefaults.getObject(forKey: "County", castTo: County?.self)
                let previousSelectedDistrict = try self.userDefaults.getObject(forKey: "District", castTo: District?.self)
                let previousSelectedAddress = self.userDefaults.object(forKey: "Address") as? String
                
                if let state = previousSelectedProvince,
                   let county = previousSelectedCounty,
                   let district = previousSelectedDistrict,
                   let address = previousSelectedAddress {
                    firstLoad = false
                    self.stateLabel.text = state.provincia
                    self.viewModel.stateSubject.accept(state)
                    
                    self.countyLabel.text = county.canton
                    self.viewModel.countySubject.accept(county)
                    self.fetchDistrictList(with: county.idCanton)
                    
                    self.districtLabel.text = district.distrito
                    self.viewModel.districtSubject.accept(district)
                    
                    self.addressTextField.text = address
                    self.viewModel.addressSubject.accept(address)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    fileprivate func displayStatesList() {
        let dropDown = DropDown()
        dropDown.anchorView = stateButton
        dropDown.dataSource = viewModel.statesArray.value.map{ $0.provincia }
        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.stateLabel.text = item
            self.viewModel.stateError.accept(false)
            self.viewModel.stateSubject.accept(self.viewModel.statesArray.value[index])
            self.fetchCities(state: self.viewModel.statesArray.value[index].idProvincia) {[weak self] response in
                guard let self = self else { return }
                self.processCities(with: response)
            }
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
            self.viewModel.countyError.accept(false)
            self.viewModel.countySubject.accept(self.viewModel.citiesArray.value[index])
            self.viewModel.districtSubject.accept(nil)
            self.districtLabel.text = ""
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
            self.viewModel.districtError.accept(false)
            self.viewModel.districtSubject.accept(self.viewModel.districtArray.value[index])
        }
        dropDown.show()
    }
    
    fileprivate func fetchDistrictList(with countyId: String) {
        guard let county = viewModel.citiesArray.value.first(where: { county in
            county.idCanton == countyId
        }), let district = county.distritos.first else { return }
        self.viewModel.districtArray.accept(county.distritos)
        //        self.viewModel.districtSubject.accept(district)
        //        self.districtLabel.text = district.distrito
    }
    
    fileprivate func prepareAddressInfo() {
        viewModel.prepareAddressInfoForPayment()
        showShippingMethodsPage()
    }
    
    fileprivate func showShippingMethodsPage() {
        do {
            self.userDefaults.removeObject(forKey: "Province")
            self.userDefaults.removeObject(forKey: "County")
            self.userDefaults.removeObject(forKey: "District")
            self.userDefaults.set(nil, forKey: "Address")
            
            try self.userDefaults.setObject(viewModel.stateSubject.value, forKey: "Province")
            try self.userDefaults.setObject(viewModel.countySubject.value, forKey: "County")
            try self.userDefaults.setObject(viewModel.districtSubject.value, forKey: "District")
            self.userDefaults.set(viewModel.addressSubject.value, forKey: "Address")
        } catch {
            print(error.localizedDescription)
        }
        let shippingMethodViewController = ShippingMethodViewController(
            viewModel: ShippingMethodViewModel(),
            state: viewModel.stateSubject.value?.idProvincia,
            county: viewModel.countySubject.value?.idCanton,
            district: viewModel.districtSubject.value?.idDistrito
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
        view.activityStartAnimatingFull()
        let stateSelected = viewModel.statesArray.value.first { state in
            state.idProvincia == address.idProvincia
        }
        viewModel.stateSubject.accept(stateSelected)
        stateLabel.text = stateSelected?.provincia
        fetchCities(state: stateSelected?.idProvincia ?? "") {[weak self] response in
            guard let self = self, let cities = response?.provincias.first?.cantones else { return }
            self.view.activityStopAnimatingFull()
            self.viewModel.citiesArray.accept(cities)
            let countySelected = self.viewModel.citiesArray.value.first { county in
                county.idCanton == address.idCanton
            }
            self.viewModel.countySubject.accept(countySelected)
            self.countyLabel.text = countySelected?.canton
            self.fetchDistrictList(with: countySelected?.idCanton ?? "")
            let districtSelected = self.viewModel.districtArray.value.first { district in
                district.idDistrito == address.idDistrito
            }
            self.viewModel.districtSubject.accept(districtSelected)
            self.districtLabel.text = districtSelected?.distrito
            self.addressTextField.text = address.direccionExacta
            self.viewModel.addressSubject.accept(address.direccionExacta)
            self.postalCodeTextField.text = address.codigoPostal
        }
    }
}

extension PaymentAddressViewController: GeolozalizationCoordinateDelegate {
    func addingCoordinates(with coordinateX: Double, coordinateY: Double) {
        viewModel.latitudeSubject.accept(coordinateX)
        viewModel.longitudeSubject.accept(coordinateY)
        currentLocationLabel.text = "\(coordinateX), \(coordinateY)"
        currentLocationView.isHidden = false
    }
}
