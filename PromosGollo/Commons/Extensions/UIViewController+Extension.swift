//
//  UIViewController+Extension.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 30/8/21.
//

import SideMenu
import UIKit

/// Enum to list each storyboard.
enum AppStoryboard: String {

    // List all the storyboards here.
    // swiftlint:disable identifier_name
    case Main
    case Home
    case Menu
    case Profile
    case Notifications
    case Payments
    case Offers
    case Services
    // swiftlint:enable identifier_name

    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }

    /// Gets the instance of a view controller with a given type
    ///
    /// - Parameters:
    ///   - viewControllerClass: The Type for the view controller
    /// - Returns: The view controller instance
    func viewController<T: UIViewController>(viewControllerClass: T.Type,
                                             function: String = #function,
                                             line: Int = #line,
                                             file: String = #file) -> T {

        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID

        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            let viewController = "ViewController with identifier \(storyboardID)"
            let storyboard = "\(self.rawValue) Storyboard.\n"
            let file = "File : \(file) \n"
            let line = "Line Number : \(line) \n"
            let function = "Function : \(function)"
            fatalError("\(viewController), not found in \(storyboard)\(file)\(line)\(function)")
        }
        return scene
    }

    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}

// MARK: - Extending UIViewController
extension UIViewController {

    // Not using static as it wont be possible to override if one wants to provide custom storyboardID
    class var storyboardID: String {
        // This implementation assumes the same name for class name and storyboard identifier.
        // Reflection could be used to get the right invoking class name
        return "\(self)"
    }

    /// Instantiates a UIViewControl from a Storyboard
    ///
    /// - Parameter appStoryboard: the storyboard where the view is
    /// - Returns: the UIViewController
    static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)
    }

    func viewContainingController() -> UIViewController? {
        var nextResponder: UIResponder? = self
        repeat {
            nextResponder = nextResponder?.next
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
        } while nextResponder != nil

        return nil
    }

    func topMostViewController() -> UIViewController {

        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }

        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }

        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }

        return self
    }

    func setUpNavigationBarMenu() {
        let notificationImage = UIImage(named: "ic_notification")
        let btn = Badge(with: notificationImage)
        btn.setBadge(with: 0)
        let rigthButton = btn
        let searchImage = UIImage(named: "ic_search")
        let rightButton2 = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItems = [rigthButton, rightButton2]

//        btn.tapAction = {
//            DispatchQueue.main.async {
//                let vc = NotificationsViewController.instantiate(fromAppStoryboard: .Notifications)
//                vc.modalPresentationStyle = .fullScreen
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
    }

//    @objc func search() {
//        let vc = SearchViewController.instantiate(fromAppStoryboard: .Search)
//        vc.modalPresentationStyle = .fullScreen
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return UIApplication
            .shared
            .windows
            .filter { $0.isKeyWindow }
            .first?
            .rootViewController?
            .topMostViewController()
    }
}

extension UIViewController {
    func showAlert(alertText : String, alertMessage : String) {
        let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Extension_simple_alert_ok_button".localized, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func showAlertWithActions(alertText : String, alertMessage : String, action: @escaping () -> Void) {
        let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Extension_simple_alert_ok_button".localized, style: UIAlertAction.Style.default) { _ in
            action()
        })
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension UIViewController {
    @objc func menuButtonTapped() {
        if let vc = AppStoryboard.Menu.initialViewController() {
            self.present(vc, animated: true)
        }
    }
    
    @objc func carButtonTapped() {
        let carTab = CarTabViewController(
            viewModel: CarTabViewModel()
        )
        carTab.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(carTab, animated: true)
    }

    @objc func searchButtonTapped() {
        let searchOffersViewController = SearchOffersViewController(
            viewModel: SearchOffersViewModel()
        )
        searchOffersViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(searchOffersViewController, animated: true)
    }

    @objc func backViewButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func configureNavBar() {
        let menuButton = UIBarButtonItem(image: UIImage(named: "ic_menu"), style: .plain, target: self, action: #selector(menuButtonTapped))
        menuButton.tintColor = .white
        let carButton = UIBarButtonItem(image: UIImage(named: "ic_cart"), style: .plain, target: self, action: #selector(carButtonTapped))
        carButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = menuButton
        self.navigationItem.rightBarButtonItem = carButton
        
        let searchView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width * 0.65, height: 25))
        searchView.backgroundColor = .white
        searchView.layer.cornerRadius = 5.0
        let searchImageView = UIImageView(frame: CGRect(x: 8, y: 4, width: 15, height: 15))
        searchImageView.image = UIImage(systemName: "magnifyingglass")
        searchView.addSubview(searchImageView)
        searchImageView.tintColor = .gray
        let searchLabel = UILabel(frame: CGRect(x: 28, y: 2, width: self.view.frame.size.width * 0.4, height: 21))
        searchLabel.font = UIFont.systemFont(ofSize: 13)
        searchLabel.textColor = .gray
        searchLabel.text = "Buscar en Gollo"
        searchView.addSubview(searchLabel)

        let tap = UITapGestureRecognizer(target: self, action: #selector(searchButtonTapped))

        searchView.addGestureRecognizer(tap)
        searchView.isUserInteractionEnabled = true

        self.navigationItem.titleView = searchView
    }

    func configureAlternativeNavBar() {
        let menuButton = UIBarButtonItem(image: UIImage(named: "ic_back_arrow"), style: .plain, target: self, action: #selector(backViewButtonTapped))
        menuButton.tintColor = .white
        let carButton = UIBarButtonItem(image: UIImage(named: "ic_cart"), style: .plain, target: self, action: #selector(carButtonTapped))
        carButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = menuButton
        self.navigationItem.rightBarButtonItem = carButton

        let searchView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width * 0.65, height: 25))
        searchView.backgroundColor = .white
        searchView.layer.cornerRadius = 5.0
        let searchImageView = UIImageView(frame: CGRect(x: 8, y: 4, width: 15, height: 15))
        searchImageView.image = UIImage(systemName: "magnifyingglass")
        searchView.addSubview(searchImageView)
        searchImageView.tintColor = .gray
        let searchLabel = UILabel(frame: CGRect(x: 28, y: 2, width: self.view.frame.size.width * 0.4, height: 21))
        searchLabel.font = UIFont.systemFont(ofSize: 13)
        searchLabel.textColor = .gray
        searchLabel.text = "Buscar en Gollo"
        searchView.addSubview(searchLabel)

        let tap = UITapGestureRecognizer(target: self, action: #selector(searchButtonTapped))

        searchView.addGestureRecognizer(tap)
        searchView.isUserInteractionEnabled = true

        self.navigationItem.titleView = searchView
    }
}
