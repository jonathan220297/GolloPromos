//
//  VerifyPaymentViewController.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 26/10/22.
//

import UIKit
import WebKit

protocol VerifyPaymentDelegate: AnyObject {
    func transactionValidation(with success: Bool, processId: String)
}

class VerifyPaymentViewController: UIViewController {

    let webView: WKWebView = {
        let prefs = WKWebpagePreferences()
        if #available(iOS 14.0, *) {
            prefs.allowsContentJavaScript = true
        }
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    var redirectURL: String = ""
    var processId: String = ""
    var closePage: Bool = false
    weak var delegate: VerifyPaymentDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Verificación de pago"

        self.view.addSubview(webView)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        guard let url = URL(string: redirectURL) else { return }
        webView.load(URLRequest(url: url))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.webView.frame = self.view.bounds
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
        if self.isMovingFromParent && !closePage {
            self.delegate?.transactionValidation(with: false, processId: self.processId)
        }
    }

}

extension VerifyPaymentViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if closePage {
            self.navigationController?.popViewController(animated: true, completion: {
                self.delegate?.transactionValidation(with: self.closePage, processId: self.processId)
            })
        }
        print("Finished loading page new")
      }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlStr = navigationAction.request.url?.absoluteString {
            closePage = urlStr.lowercased().starts(with: "https://servicios.grupogollo.com:9196/ClientesApi/Transacciones/RespuestaBAC".lowercased())
        }
        decisionHandler(.allow)
    }
}
