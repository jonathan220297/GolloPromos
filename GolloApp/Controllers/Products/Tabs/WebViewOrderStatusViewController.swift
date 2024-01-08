//
//  WebViewOrderViewController.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 4/1/24.
//

import UIKit
import WebKit

class WebViewOrderStatusViewController: UIViewController {
    
    let webView: WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    @IBOutlet weak var containerView: UIView!
    
    let idJob: String?
    
    init(idJob: String? = nil) {
        self.idJob = idJob
        super.init(nibName: "WebViewOrderStatusViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Estado del pedido"
        configureViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func configureViews() {
        self.view.activityStartAnimatingFull()
        containerView.addSubview(webView)
        
        let stringURL = "https://xandar-lsw-v3.instaleap.io/?job=\(self.idJob ?? "")&token=hkv6MpWZw6DwIPfuTlq0k3qNSX2JQkOxmYnOsPrO&language=es-ES&hideHelpCenter=true&hideProducts=true&hidePaymentMethod=true&hideOrderDetail=true&hideComments=true&primaryColor=%23005da4&hideCancelOrder=true"
        
        guard let url = URL(string: stringURL) else {
            return
        }
        
        webView.load(URLRequest(url: url))
        webView.customUserAgent = "iPad/Chrome/SomethingRandom"
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.view.activityStopAnimatingFull()
        }
    }

}
