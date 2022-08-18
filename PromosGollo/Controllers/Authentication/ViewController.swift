//
//  ViewController.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 27/8/21.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    var viewLoader = UIView()

    lazy var viewModel: SplashViewModel = {
        return SplashViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewLoader = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        view.addSubview(viewLoader)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.verifyUserLogged() && !viewModel.sessionExpired() {
            if let vc = AppStoryboard.Home.initialViewController() {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        } else {
            if viewModel.verifyTermsConditionsState() {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "navVC") as! UINavigationController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            } else {
                viewLoader.isHidden = true
                viewLoader.removeFromSuperview()
            }
        }
    }

    // MARK: - Actions
    @IBAction func buttonContiueTapped(_ sender: UIButton) {
        let vc = TermsConditionsViewController.instantiate(fromAppStoryboard: .Main)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

}

