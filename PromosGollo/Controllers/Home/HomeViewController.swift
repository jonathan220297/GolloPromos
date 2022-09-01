//
//  HomeViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import FirebaseAuth
import UIKit
import RxSwift
import Nuke
import ImageSlideshow

class HomeViewController: UIViewController {

    lazy var idealButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "defaultImage"), for: .normal)
        button.imageView?.layer.cornerRadius = 16
        button.imageView?.backgroundColor = .white
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.layer.borderWidth = 1.5
        button.imageView?.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(buttonImageViewProfileTapped), for: .touchUpInside)
        return button
    }()

    @IBOutlet weak var homeTableView: UITableView!

    lazy var viewModel: HomeViewModel = {
        return HomeViewModel()
    }()

    let disposeBag = DisposeBag()
    let userDefaults = UserDefaults.standard

    var sectionCellSize = 30.0
    var productCellSize = 30.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setupNavigationBar()
        configureViewModel()
        configureTableView()
        configureRx()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        fetchHomeConfiguration()
    }

    // MARK: - Observers
    @objc func buttonImageViewProfileTapped() {
        if let vc = AppStoryboard.Menu.initialViewController() {
            self.present(vc, animated: true, completion: nil)
        }
    }

    // MARK: - Functions
    fileprivate func configureViewModel() {
        viewModel.reloadTableViewData = {[weak self] in
            guard let self = self else { return }
            self.homeTableView.reloadData()
        }
    }

    fileprivate func configureRx() {
        viewModel.errorMessage
            .asObservable()
            .bind { (errorMessage) in
                if !errorMessage.isEmpty {
                    self.showAlert(alertText: "GolloApp", alertMessage: errorMessage)
                    self.viewModel.errorMessage.accept("")
                }
            }
            .disposed(by: disposeBag)
        
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
            .disposed(by: disposeBag)
    }

    fileprivate func configureTableView() {
        homeTableView.register(UINib(nibName: "SingUpTableViewCell", bundle: nil), forCellReuseIdentifier: "SingUpTableViewCell")
        homeTableView.register(UINib(nibName: "SliderTableViewCell", bundle: nil), forCellReuseIdentifier: "SliderTableViewCell")
        homeTableView.register(UINib(nibName: "SectionTableViewCell", bundle: nil), forCellReuseIdentifier: "SectionTableViewCell")
        homeTableView.allowsSelection = false
        viewModel.tableViewWidth = homeTableView.layer.frame.width
    }

    @IBAction func offersAction(_ sender: Any) {
        let vc = OffersTabBarViewController.instantiate(fromAppStoryboard: .Offers)
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func paymentAction(_ sender: Any) {
        if Variables.isRegisterUser {
            let vc = PaymentTabBarViewController.instantiate(fromAppStoryboard: .Payments)
            vc.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let signupWaringViewController = SignupWaringViewController(
                delegate: self
            )
            signupWaringViewController.modalPresentationStyle = .overCurrentContext
            signupWaringViewController.modalTransitionStyle = .crossDissolve
            present(signupWaringViewController, animated: true)
        }
    }

    @IBAction func serviceAction(_ sender: Any) {
        let vc = ServicesViewController.instantiate(fromAppStoryboard: .Services)
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }

    fileprivate func fetchHomeConfiguration() {
        view.activityStarAnimating()
        viewModel.getHomeConfiguration()
            .asObservable()
            .subscribe(onNext: {[weak self] response in
                guard let self = self,
                      let response = response else { return }
                DispatchQueue.main.async {
                    defer { self.view.activityStopAnimating() }
                    self.viewModel.configure(with: response)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sectionsArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel.sectionsArray[indexPath.row].signUp != nil {
            return 150
        } else if viewModel.sectionsArray[indexPath.row].isSection {
            return CGFloat(productCellSize)
        } else {
            return viewModel.sectionsArray[indexPath.row].banner?.uiHeight ?? CGFloat(0)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.sectionsArray[indexPath.row].signUp != nil {
            return getSignUpCell(tableView, cellForRowAt: indexPath)
        } else if viewModel.sectionsArray[indexPath.row].isSection {
            return getSectionCell(tableView, cellForRowAt: indexPath)
        } else {
            return getSliderCell(tableView, cellForRowAt: indexPath)
        }
    }
    
    func getSignUpCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingUpTableViewCell", for: indexPath) as! SingUpTableViewCell
        cell.delegate = self
        return cell
    }

    func getSliderCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        guard let banner = viewModel.sectionsArray[indexPath.row].banner else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTableViewCell", for: indexPath) as! SliderTableViewCell
        cell.setSliderContent(with: banner)
        return cell
    }

    func getSectionCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        guard let section = viewModel.sectionsArray[indexPath.row].section else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTableViewCell", for: indexPath) as! SectionTableViewCell
        cell.setSectionData(with: section, delegate: self)
        return cell
    }
}

extension HomeViewController: SectionDelegate {
    func sectionTableView(_ sectionTableViewCell: SectionTableViewCell, shouldReloadWith cellSize: Double) {
        sectionCellSize = cellSize
        homeTableView.beginUpdates()
        homeTableView.endUpdates()
    }

    func sectionTableView(_ sectionTableViewCell: SectionTableViewCell, shouldReloadProductCellWith cellSize: Double) {
        productCellSize = cellSize
        homeTableView.beginUpdates()
        homeTableView.endUpdates()
    }

    func sectionTableView(_ sectionTableViewCell: SectionTableViewCell, moveTo viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension HomeViewController: SignUpCellDelegate {
    func presentEditProfileController() {
        let vc = EditProfileViewController.instantiate(fromAppStoryboard: .Profile)
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: SignupWarningDelegate {
    func didTapSignupButton() {
        let editProfileViewController = EditProfileViewController.instantiate(fromAppStoryboard: .Profile)
        editProfileViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(editProfileViewController, animated: true)
    }
}
