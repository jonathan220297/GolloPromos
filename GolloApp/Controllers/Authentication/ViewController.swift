//
//  ViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import UIKit
import FirebaseAuth
import FirebaseMessaging
import RxSwift

class ViewController: UIViewController {
    @IBOutlet weak var continueButton: LocalizableButton!
    
    var viewLoader = UIView()

    lazy var viewModel: SplashViewModel = {
        return SplashViewModel()
    }()

    let userDefaults = UserDefaults.standard
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.verifyUserLogged() {
            let userDefaults = UserDefaults.standard
            do {
                let myInfo = try userDefaults.getObject(forKey: "Information", castTo: UserInfo.self)
                print(myInfo)
                Variables.userProfile = myInfo
                Variables.isRegisterUser = true
                Variables.isClientUser = true
                Variables.isLoginUser = true
            } catch {
                print(error.localizedDescription)
            }
            if let vc = AppStoryboard.Home.initialViewController() {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        } else {
            if viewModel.verifyTermsConditionsState() {
                if let vc = AppStoryboard.Home.initialViewController() {
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }
        }
        Messaging.messaging().token { token, error in
          if let error = error {
              print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
              print("FCM registration token: \(token)")
              self.registerDevice(with: token)
              self.registerDeviceToken(with: token)
          }
        }
    }

    // MARK: - Actions
    @IBAction func buttonContiueTapped(_ sender: UIButton) {
        let vc = TermsConditionsViewController.instantiate(fromAppStoryboard: .Main)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    // MARK: - Functions
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
            })
            .disposed(by: bag)
    }

    fileprivate func registerDeviceToken(with token: String) {
        viewModel
            .registerDeviceToken(with: token)
            .asObservable()
            .subscribe(onNext: {[weak self] data in
                guard let _ = self else { return }
                print("Token saved")
            })
            .disposed(by: bag)
    }

    fileprivate func configureRx() {
        continueButton
            .rx
            .tap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                let vc = TermsConditionsViewController.instantiate(fromAppStoryboard: .Main)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            })
            .disposed(by: bag)
    }
}

