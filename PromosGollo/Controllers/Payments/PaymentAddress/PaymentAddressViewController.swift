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
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var cityButton: UIButton!
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
        navigationItem.title = "PersonalInfoViewController_title".localized
        tabBarController?.navigationItem.hidesBackButton = false
        tabBarController?.navigationController?.navigationBar.tintColor = .white
        configureViews()
        configureObservers()
        configureRx()
        hideKeyboardWhenTappedAround()
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
        countryButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayCountryList()
            })
            .disposed(by: bag)
        stateButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayStatesList()
            })
            .disposed(by: bag)
        cityButton.rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.displayCitiesList()
            })
            .disposed(by: bag)
        addressTextField.rx.text.bind(to: viewModel.addressSubject).disposed(by: bag)
        postalCodeTextField.rx.text.bind(to: viewModel.postalCodeSubject).disposed(by: bag)
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
//                self.saveAddress()
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
        
//        viewModel.paymentAddressSubject
//            .asObservable()
//            .subscribe(onNext: {[weak self] address in
//                guard let self = self,
//                      let _ = address else { return }
//                self.viewModel.setPaymentAddressToManager()
//                self.showShippingMethodsPage()
//            })
//            .disposed(by: bag)
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
//        guard let country = viewModel.countryArray.first else { return }
//        fetchStates(with: country.code)
    }
    
    fileprivate func fetchStates(with country: String) {
//        view.activityStarAnimating()
//        viewModel.fetchStates(for: country)
//            .asObservable()
//            .subscribe(onNext: {[weak self] response in
//                guard let self = self,
//                      let firstItem = response.first else { return }
//                self.stateLabel.text = firstItem.name
//                self.viewModel.stateSubject.accept(firstItem.code)
//                self.fetchCities(with: country, state: firstItem.code)
//            })
//            .disposed(by: bag)
    }
    
    fileprivate func fetchCities(with country: String, state: String) {
//        viewModel.fetchCities(with: country, state: state)
//            .asObservable()
//            .subscribe(onNext: {[weak self] response in
//                guard let self = self,
//                      let firstItem = response.first else { return }
//                self.cityLabel.text = firstItem.name
//                self.viewModel.citySubject.accept(firstItem.code)
//                self.view.activityStopAnimating()
//            })
//            .disposed(by: bag)
    }
    
    fileprivate func displayCountryList() {
//        let dropDown = DropDown()
//        dropDown.anchorView = countryButton
//        dropDown.dataSource = viewModel.countryArray.map{ $0.name }
//        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
//            guard let self = self else { return }
//            self.countryLabel.text = item
//            self.viewModel.countrySubject.accept(self.viewModel.countryArray[index].code)
//            self.fetchStates(with: self.viewModel.countryArray[index].code)
//        }
//        dropDown.show()
    }
    
    fileprivate func displayStatesList() {
//        let dropDown = DropDown()
//        dropDown.anchorView = stateButton
//        dropDown.dataSource = viewModel.statesArray.value.map{ $0.name }
//        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
//            guard let self = self else { return }
//            self.stateLabel.text = item
//            self.viewModel.stateSubject.accept(self.viewModel.statesArray.value[index].code)
//            self.fetchCities(with: self.viewModel.countrySubject.value ?? "", state: self.viewModel.statesArray.value[index].code)
//        }
//        dropDown.show()
    }
    
    fileprivate func displayCitiesList() {
//        let dropDown = DropDown()
//        dropDown.anchorView = cityButton
//        dropDown.dataSource = viewModel.citiesArray.value.map{ $0.name }
//        dropDown.selectionAction = {[weak self] (index: Int, item: String) in
//            guard let self = self else { return }
//            self.cityLabel.text = item
//            self.viewModel.citySubject.accept(self.viewModel.citiesArray.value[index].code)
//        }
//        dropDown.show()
    }
    
    fileprivate func prepareAddressInfo() {
//        viewModel.prepareAddressInfoForPayment()
    }
    
    fileprivate func showShippingMethodsPage() {
//        let vc = ShippingMethodViewController.instantiate(fromAppStoryboard: .Payment)
//        vc.modalPresentationStyle = .fullScreen
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func showAddressListPage() {
//        let vc = AddressViewController.instantiate(fromAppStoryboard: .Payment)
//        vc.modalPresentationStyle = .fullScreen
//        vc.delegate = self
//        navigationController?.pushViewController(vc, animated: true)
    }
    
//    fileprivate func setAddressFromList(with data: AddressListResponse) {
//        countryLabel.text = data.country
//        viewModel.countrySubject.accept(data.countryCode)
//        stateLabel.text = data.state
//        viewModel.stateSubject.accept(data.stateCode)
//        cityLabel.text = data.city
//        viewModel.citySubject.accept(data.cityCode)
//        addressTextField.text = data.address
//        viewModel.addressSubject.accept(data.address)
//        postalCodeTextField.text = data.postalCode
//        viewModel.postalCodeSubject.accept(data.postalCode)
//        viewModel.latitudeSubject.accept(data.latitude)
//        viewModel.longitudeSubject.accept(data.longitude)
//    }
    
//    fileprivate func saveAddress() {
//        if viewModel.userManager.isUserLoggedIn() {
//            if viewModel.isValidAddress() {
//                viewModel.saveAddress()
//                    .asObservable()
//                    .subscribe(onNext: { success in
//                        if success {
//                            log.debug("Done")
//                            let banner = NotificationBanner(title: "Shoppi", subtitle: "PersonalInfoViewController_address_saved".localized, style: .success)
//                            banner.show()
//                        }
//                    })
//                    .disposed(by: bag)
//            } else {
//                log.debug("Addres incomplete")
//                let banner = NotificationBanner(title: "Shoppi", subtitle: "PersonalInfoViewController_address_incomplete".localized, style: .warning)
//                banner.show()
//            }
//        } else {
//            let banner = NotificationBanner(title: "Shoppi", subtitle: "PersonalInfoViewController_login_to_save_address".localized, style: .warning)
//            banner.show()
//        }
//    }
}
