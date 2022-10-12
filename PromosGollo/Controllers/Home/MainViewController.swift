//
//  MainViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 8/10/22.
//

import FirebaseAuth
import UIKit
import RxSwift

class MainViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!

    // MARK: - Constants
    let viewModel: HomeViewModel
    let disposeBag = DisposeBag()
    let userDefaults = UserDefaults.standard

    var sectionCellSize = 30.0
    var productCellSize = 30.0

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "MainViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewModel()
        configureTableView()
        configureRx()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        configureNavBar()
        fetchHomeConfiguration()
    }

    // MARK: - Functions
    fileprivate func configureViewModel() {
        viewModel.reloadTableViewData = {[weak self] in
            guard let self = self else { return }
            self.mainTableView.reloadData()
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
        mainTableView.register(UINib(nibName: "SingUpTableViewCell", bundle: nil), forCellReuseIdentifier: "SingUpTableViewCell")
        mainTableView.register(UINib(nibName: "SliderTableViewCell", bundle: nil), forCellReuseIdentifier: "SliderTableViewCell")
        mainTableView.register(UINib(nibName: "SectionTableViewCell", bundle: nil), forCellReuseIdentifier: "SectionTableViewCell")
        mainTableView.allowsSelection = false
        viewModel.tableViewWidth = mainTableView.layer.frame.width
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

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
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

extension MainViewController: SectionDelegate {
    func sectionTableView(_ sectionTableViewCell: SectionTableViewCell, shouldReloadWith cellSize: Double) {
        sectionCellSize = cellSize
        mainTableView.beginUpdates()
        mainTableView.endUpdates()
    }

    func sectionTableView(_ sectionTableViewCell: SectionTableViewCell, shouldReloadProductCellWith cellSize: Double) {
        productCellSize = cellSize
        mainTableView.beginUpdates()
        mainTableView.endUpdates()
    }

    func sectionTableView(_ sectionTableViewCell: SectionTableViewCell, moveTo viewController: UIViewController) {
        viewController.hidesBottomBarWhenPushed = false
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension MainViewController: SignUpCellDelegate {
    func presentEditProfileController() {
        let vc = EditProfileViewController.instantiate(fromAppStoryboard: .Profile)
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}
