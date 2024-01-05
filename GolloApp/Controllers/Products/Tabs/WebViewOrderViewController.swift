//
//  WebViewOrderViewController.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 4/1/24.
//

import UIKit
import WebKit

class WebViewOrderViewController: UIViewController {
    
    let webView: WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    let idJob: String?
    
    init(idJob: String? = nil) {
        self.idJob = idJob
        super.init(nibName: "WebViewOrderViewController", bundle: nil)
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
    
    private func configureViews() {
        view.addSubview(webView)
        
        let stringURL = "https://xandar-lsw-v3.instaleap.io/?job=\(self.idJob ?? "")&token=hkv6MpWZw6DwIPfuTlq0k3qNSX2JQkOxmYnOsPrO&language=es-ES&hideHelpCenter=true&hideProducts=true&hidePaymentMethod=true&hideOrderDetail=true&hideComments=true&primaryColor=%23005da4&hideOrderId=true&hideCancelOrder=true"
        
        guard let url = URL(string: stringURL) else {
            return
        }
        
        webView.load(URLRequest(url: url))
        webView.customUserAgent = "iPad/Chrome/SomethingRandom"
    }

}
