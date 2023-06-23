//
//  ChatbotViewController.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 23/6/23.
//

import UIKit
import RxSwift

class ChatbotViewController: UIViewController {
    
    @IBOutlet weak var continueChatButton: UIButton!
    @IBOutlet weak var cancelChatButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    init() {
        super.init(nibName: "ChatbotViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRx()
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

    func configureRx() {
        continueChatButton
            .rx
            .tap
            .subscribe(onNext: {
                let phoneNumber =  "+50683046556"
                let appURL = URL(string: "https://api.whatsapp.com/send?phone=\(phoneNumber)")
                if let appURL = appURL, UIApplication.shared.canOpenURL(appURL) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                    }
                    else {
                        UIApplication.shared.openURL(appURL)
                    }
                } else {
                    self.showAlert(alertText: "GolloApp", alertMessage: "Para contactar a Gollo Chatbot necesita WhatsApp instalado a su dispositivo.")
                }
            })
            .disposed(by: disposeBag)
        
        cancelChatButton
            .rx
            .tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }

}
