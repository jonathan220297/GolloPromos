//
//  HomeTabViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 12/10/22.
//

import RxSwift
import UIKit
import FirebaseAuth
import FirebaseMessaging
import Nuke
import SafariServices

class HomeTabViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    // MARK: - Constants
    let viewModel: HomeViewModel
    let disposeBag = DisposeBag()
    let userDefaults = UserDefaults.standard
    
    // MARK: - Variables
    var imageDimensions: [IndexPath: CGSize] = [:]
    
    // MARK: - Lifecycle
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "HomeTabViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureViewModel()
        configureRx()
        configureTopic()
        configureObservers()
        fetchHomeConfiguration()
//        validateVersion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
        validateNotificationsFlow()
    }
    
    // MARK: - Observers
    @objc func handleMoreTap(_ sender: UIGestureRecognizer) {
    }
    
    @objc func notificationAction(notification: NSNotification) {
        validateNotificationsFlow()
    }
    
    // MARK: - Functions
    fileprivate func configureObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationAction),
            name: NSNotification.Name(rawValue: NOTIFICATION_NAME.NOTIFICATION_FLOW),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(navigateProduct),
            name: NSNotification.Name(rawValue: "showDynamicLinkProduct"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ReloadHomeData"), object: nil, queue: nil) { _ in
            if Variables.isRegisterUser {
                Messaging.messaging().token { token, error in
                    if let error = error {
                        print("Error fetching FCM registration token: \(error)")
                    } else if let token = token {
                        self.registerDevice(with: token)
                        self.fetchHomeConfiguration()
                    }
                }
            } else {
                self.fetchHomeConfiguration()
            }
        }
    }
    
    fileprivate func configureRx() {
        viewModel
            .errorExpiredToken
            .asObservable()
            .subscribe(onNext: {[weak self] value in
                guard let self = self,
                      let value = value else { return }
                if value {
                    self.view.activityStopAnimating()
                    self.viewModel.errorExpiredToken.accept(nil)
                    self.userDefaults.removeObject(forKey: "Information")
                    let _ = KeychainManager.delete(key: "token")
                    Variables.isRegisterUser = false
                    Variables.isLoginUser = false
                    Variables.isClientUser = false
                    Variables.userProfile = nil
                    UserManager.shared.userData = nil
                    self.showAlertWithActions(alertText: "Detectamos otra sesión activa", alertMessage: "La aplicación se reiniciará.") {
                        let firebaseAuth = Auth.auth()
                        do {
                            try firebaseAuth.signOut()
                            self.userDefaults.removeObject(forKey: "Information")
                            Variables.isRegisterUser = false
                            Variables.isLoginUser = false
                            Variables.isClientUser = false
                            Variables.userProfile = nil
                            UserManager.shared.userData = nil
                            Messaging.messaging().token { token, error in
                              if let error = error {
                                print("Error fetching FCM registration token: \(error)")
                              } else if let token = token {
                                self.registerDevice(with: token)
                              }
                            }
                        } catch let signOutError as NSError {
                            log.error("Error signing out: \(signOutError)")
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.updatedVersion
            .asObservable()
            .bind { (errorMessage) in
                if !errorMessage.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                        self?.showAlertWithActions(alertText: "Actualización", alertMessage: errorMessage) {
                            exit(0)
                        }
                    }
                    self.viewModel.updatedVersion.accept("")
                }
            }
            .disposed(by: disposeBag)
    }
    
    fileprivate func validateVersion() {
        Messaging.messaging().token { token, error in
          if let error = error {
              print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
              print("FCM registration token: \(token)")
              self.registerDevice(with: token)
          }
        }
    }

    fileprivate func configureViewModel() {
        viewModel.reloadTableViewData = { [weak self] in
            guard let self = self else { return }
            self.viewModel.sections.sort { section1, section2 in
                guard let position1 = section1.position,
                      let position2 = section2.position else { return false }
                return position1 < position2
            }
            self.homeCollectionView.reloadData()
        }
    }

    fileprivate func registerDevice(with token: String) {
        viewModel
            .registerDevice(with: token)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let self = self,
                      let data = data else { return }
                if let info = data.registro {
                    Variables.userProfile = info
                    do {
                        try self.userDefaults.setObject(info, forKey: "Information")
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                if let token = data.token {
                    let _ = self.viewModel.saveToken(with: token)
                }
                if let deviceID = data.idCliente {
                    self.userDefaults.set(deviceID, forKey: "deviceID")
                }
                Variables.isRegisterUser = data.estadoRegistro ?? false
                Variables.isLoginUser = data.estadoLogin ?? false
                Variables.isClientUser = data.estadoCliente ?? false
                self.fetchHomeConfiguration()
            })
            .disposed(by: disposeBag)
    }
    
    fileprivate func configureCollectionView() {
        homeCollectionView.register(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionViewCell")
        homeCollectionView.register(UINib(nibName: "SectionCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionCollectionViewCell")
        homeCollectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        homeCollectionView.register(
            UINib(
                nibName: "ProductFooterCollectionViewCell",
                bundle: nil
            ),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "ProductFooterCollectionViewCell"
        )
        homeCollectionView.register(
            UINib(
                nibName: "HorizontalSliderCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "HorizontalSliderCollectionViewCell"
        )
        homeCollectionView.register(
            UINib(
                nibName: "TopCategoriesCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "TopCategoriesCollectionViewCell"
        )
        homeCollectionView.register(
            UINib(
                nibName: "PreapprovedCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "PreapprovedCollectionViewCell"
        )
    }
    
    fileprivate func fetchHomeConfiguration() {
        view.activityStarAnimating()
        viewModel.configuration = nil
        viewModel.sections.removeAll()
        imageDimensions.removeAll()
        homeCollectionView.reloadData()
        viewModel
            .getHomeConfiguration()
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response else { return }
                DispatchQueue.main.async {
                    defer { self.view.activityStopAnimating() }
                    self.viewModel.configuration = response
                    self.viewModel.configureSections()
                    self.homeCollectionView.reloadData()
                    if let isPreapproved = response.preaprobado {
                        let preapprovedViewController = PreapprovedViewController(
                            description: "Estimado \(isPreapproved.nombreCliente ?? ""), tenés un crédito preaprobado de \(String(isPreapproved.monto ?? 0.0).currencyFormatting()) colones con vigencia del \(isPreapproved.fechaInicio ?? "") al \(isPreapproved.fechaFin ?? "")".withBoldText(
                                texts: [
                                    isPreapproved.nombreCliente ?? "",
                                    String(isPreapproved.monto ?? 0.0).currencyFormatting(),
                                    isPreapproved.fechaInicio ?? "",
                                    isPreapproved.fechaFin ?? ""
                                ],
                                regularFont: UIFont(name: "KohinoorBangla-Regular", size: 14),
                                boldFont: UIFont(name: "KohinoorBangla-Semibold", size: 14)
                            ),
                            image: isPreapproved.image
                        )
                        preapprovedViewController.modalPresentationStyle = .overCurrentContext
                        preapprovedViewController.modalTransitionStyle = .crossDissolve
                        self.present(preapprovedViewController, animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    fileprivate func configureTopic() {
        if Messaging.messaging().fcmToken != nil {
            Messaging.messaging().subscribe(toTopic: "gollo_app") { error in
                if error == nil {
                    print("Subscribed to topic")
                } else{
                    print("Not Subscribed to topic")
                }
            }
        }
    }
    
    fileprivate func validateNotificationsFlow() {
        if Variables.openPushNotificationFlow {
            if let userInfo = Variables.notificationFlowPayload, let notificationType = userInfo["type"] as? String {
                switch(notificationType) {
                case APP_NOTIFICATIONS.GENERAL.rawValue:
                    let vc = NotificationsViewController.instantiate(fromAppStoryboard: .Notifications)
                    vc.modalPresentationStyle = .fullScreen
                    vc.fromNotifications = false
                    self.navigationController?.pushViewController(vc, animated: true)
                case APP_NOTIFICATIONS.ORDER.rawValue:
                    let orderDetailTabViewController = OrderDetailTabViewController(
                        viewModel: OrderDetailTabViewModel(),
                        orderId: userInfo["idType"] as? String ?? "",
                        fromNotifications: false
                    )
                    orderDetailTabViewController.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(orderDetailTabViewController, animated: true)
                default:
                    print("None action.")
                }
            }
            Variables.openPushNotificationFlow = false
        }
    }
    
    @objc fileprivate func navigateProduct(_ notification: Notification) {
        if let productCode = notification.userInfo?["product"] as? String {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
                let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
                vc.skuProduct = productCode
                vc.modalPresentationStyle = .fullScreen
                self?.navigationController?.pushViewController(vc, animated: true)
            }
         }
    }
    
    func downloadImageAsync(from url: URL, completion: @escaping (UIImage?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            if let data = data, let image = UIImage(data: data) {
                completion(image, nil)
            } else {
                completion(nil, NSError(domain: "YourApp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error al convertir los datos en imagen"]))
            }
        }.resume()
    }
}

extension HomeTabViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.sections[section].banner != nil {
            return 1
        } else if !viewModel.sections[section].vertical {
            return 1
        } else if let products = viewModel.sections[section].product {
            return products.count
        } else if let isPreapproved = viewModel.sections[section].isPreapproved, isPreapproved {
            return 1
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionCollectionViewCell", for: indexPath) as! SectionCollectionViewCell
            
            header.indexPath = indexPath
            header.setSectionName(with: viewModel.sections[indexPath.section].name ?? "")
            header.delegate = self
            
            return header
        case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ProductFooterCollectionViewCell", for: indexPath) as! ProductFooterCollectionViewCell
            footer.delegate = self
            footer.indexPath = indexPath
            return footer
        default:
            fatalError("Unexpected element kind")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if viewModel.sections[section].banner != nil {
            return CGSize(width: collectionView.bounds.width, height: 0)
        } else if let products = viewModel.sections[section].product, !products.isEmpty {
            return CGSize(width: collectionView.bounds.width, height: 55)
        } else if let categories = viewModel.sections[section].categories, !categories.isEmpty {
            return CGSize(width: collectionView.bounds.width, height: 55)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if viewModel.sections[section].banner != nil {
            return CGSize(width: collectionView.bounds.width, height: 0)
        } else if !viewModel.sections[section].vertical {
            return CGSize(width: 0, height: 0)
        } else if let products = viewModel.sections[section].product, !products.isEmpty {
            return CGSize(width: collectionView.bounds.width, height: 50)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.sections[indexPath.section].banner != nil {
            return getBannerCell(collectionView, cellForItemAt: indexPath)
        } else if viewModel.sections[indexPath.section].product != nil {
            return viewModel.sections[indexPath.section].vertical ?
            getProductCell(collectionView, cellForItemAt: indexPath) :
            getHorizontalSliderCell(collectionView, cellForItemAt: indexPath)
        } else if viewModel.sections[indexPath.section].categories != nil {
            return getCategoriesCell(collectionView, cellForItemAt: indexPath)
        } else if viewModel.sections[indexPath.section].isPreapproved ?? false {
            return getPreapprovedCell(collectionView, cellForItemAt: indexPath)
        } else {
            return UICollectionViewCell()
        }
    }
    
    func getBannerCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as? BannerCollectionViewCell else { return UICollectionViewCell() }
        cell.setBanner(with: viewModel.sections[indexPath.section].banner)
        cell.delegate = self
        cell.dividerViewHeight.constant = 0
        cell.dividerView.isHidden = true
        if indexPath.section == 0 {
            cell.dividerViewHeight.constant = 0
            cell.dividerView.isHidden = true
        } else {
            cell.dividerViewHeight.constant = 0
            cell.dividerView.isHidden = false
        }
        if imageDimensions[indexPath] == nil {
            guard let imageURL = URL(string: viewModel.sections[indexPath.section].banner?.images?.first?.image?.replacingOccurrences(of: " ", with: "%20") ?? "") else {
                return cell
            }
            
            downloadImageAsync(from: imageURL) { [weak self] (image, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error al descargar la imagen: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    if let image = image {
                        let aspectRatio = image.size.width / image.size.height
                        let newHeight = collectionView.frame.size.width / aspectRatio
                        
                        // Almacena las dimensiones de la imagen descargada
                        self.imageDimensions[indexPath] = CGSize(width: collectionView.frame.size.width, height: newHeight)
                        
                        // Recarga la celda para aplicar el nuevo tamaño
                        collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        }
        
        return cell
    }
    
    func getProductCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as? ProductCollectionViewCell else { return UICollectionViewCell() }
        cell.setProductData(with: viewModel.sections[indexPath.section].product?[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func getHorizontalSliderCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "HorizontalSliderCollectionViewCell",
            for: indexPath
        ) as? HorizontalSliderCollectionViewCell else { return UICollectionViewCell() }
        cell.section = viewModel.sections[indexPath.section]
        cell.delegate = self
        cell.configureCollectionView()
        return cell
    }
    
    func getCategoriesCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TopCategoriesCollectionViewCell",
            for: indexPath
        ) as? TopCategoriesCollectionViewCell else { return UICollectionViewCell() }
        cell.section = viewModel.sections[indexPath.section]
        cell.delegate = self
        cell.configureCollectionView()
        return cell
    }
    
    func getPreapprovedCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PreapprovedCollectionViewCell",
            for: indexPath
        ) as? PreapprovedCollectionViewCell else { return UICollectionViewCell() }
        cell.configureData(with: viewModel.sections[indexPath.section].preapprovedDescription)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if viewModel.sections[indexPath.section].banner != nil {
            if let dimensions = imageDimensions[indexPath] {
                return CGSize(
                    width: dimensions.width + CGFloat(viewModel.sections[indexPath.section].banner?.borderWidth ?? 0),
                    height: dimensions.height + CGFloat(viewModel.sections[indexPath.section].banner?.borderWidth ?? 0)
                )
            } else {
                return CGSize(width: collectionView.frame.size.width, height: 200)
            }
        } else if viewModel.sections[indexPath.section].isPreapproved ?? false {
            return CGSize(width: collectionView.frame.size.width, height: 100)
        } else {
            if viewModel.sections[indexPath.section].vertical {
                let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
                let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
                let size: CGFloat = (collectionView.frame.size.width - space) / 2.0
                return CGSize(width: size, height: 280)
            } else {
                print(String(indexPath.section) + " - " + String(indexPath.row))
                return CGSize(width: collectionView.frame.size.width, height: 280)
            }
        }
    }
}

extension HomeTabViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let isPreapproved = viewModel.sections[indexPath.section].isPreapproved, isPreapproved {
            let preapprovedViewController = PreapprovedViewController(
                description: viewModel.sections[indexPath.section].preapprovedDescription,
                image: viewModel.sections[indexPath.section].preapprovedImage
            )
            preapprovedViewController.modalPresentationStyle = .overCurrentContext
            preapprovedViewController.modalTransitionStyle = .crossDissolve
            self.present(preapprovedViewController, animated: true)
        } else {
            let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
            vc.offer = viewModel.sections[indexPath.section].product?[indexPath.row]
            vc.skuProduct = viewModel.sections[indexPath.section].product?[indexPath.row].productCode
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension HomeTabViewController: HomeSectionDelegate {
    func moreButtonTapped(at indexPath: IndexPath) {
        let offersFilteredListViewController = OffersFilteredListViewController(
            viewModel: OffersFilteredListViewModel(),
            category: viewModel.sections[indexPath.section].link,
            taxonomy: viewModel.sections[indexPath.section].tax ?? -1
        )
        offersFilteredListViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(offersFilteredListViewController, animated: true)
    }
}

extension HomeTabViewController: ProductCellDelegate {
    func productCell(_ productCollectionViewCell: ProductCollectionViewCell, willMoveToDetilWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.skuProduct = data.productCode
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeTabViewController: OffersCellDelegate {
    func offerssCell(_ offersTableViewCell: OffersTableViewCell, shouldMoveToDetailWith data: Product) {
        let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
        vc.offer = data
        vc.skuProduct = data.productCode
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeTabViewController: BannerCellDelegate {
    func bannerCell(_ bannerCollectionViewCell: BannerCollectionViewCell, willMoveToDetilWith data: Banner, position: Int) {
        if let bannerImages = data.images {
            let item = bannerImages[position]
            if item.linkType == 1 {
                if let category = item.linkValue, !category.isEmpty, let taxonomy = item.taxonomia {
                    let offersFilteredListViewController = OffersFilteredListViewController(
                        viewModel: OffersFilteredListViewModel(),
                        category: Int(category),
                        taxonomy: taxonomy
                    )
                    offersFilteredListViewController.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(offersFilteredListViewController, animated: true)
                }
            } else if item.linkType == 2, let sku = item.linkValue {
                let vc = OfferDetailViewController.instantiate(fromAppStoryboard: .Offers)
                vc.modalPresentationStyle = .fullScreen
                vc.skuProduct = sku
                navigationController?.pushViewController(vc, animated: true)
            } else if item.linkType == 3 {
                if let value = item.linkValue, value.starts(with: "https"), let url = URL(string: value) {
                    let config = SFSafariViewController.Configuration()
                    config.entersReaderIfAvailable = true

                    let vc = SFSafariViewController(url: url, configuration: config)
                    present(vc, animated: true)
                }
            }
        }
    }
}

extension HomeTabViewController: ProductFooterDelegate {
    func seeMoreTapped(indexPath: IndexPath) {
        let offersFilteredListViewController = OffersFilteredListViewController(
            viewModel: OffersFilteredListViewModel(),
            category: viewModel.sections[indexPath.section].link,
            taxonomy: viewModel.sections[indexPath.section].tax ?? -1
        )
        offersFilteredListViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(offersFilteredListViewController, animated: true)
    }
}

extension HomeTabViewController: HorizontalSliderDelegate {
    func didTapProduct(with controller: OfferDetailViewController) {
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapSeeMore(with controller: OffersFilteredListViewController) {
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension HomeTabViewController: TopCategoriesDelegate {
    func didTapSeeMore(with controller: CategoriesViewController) {
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapCategory(with controller: OffersFilteredListViewController) {
        navigationController?.pushViewController(controller, animated: true)
    }
}
