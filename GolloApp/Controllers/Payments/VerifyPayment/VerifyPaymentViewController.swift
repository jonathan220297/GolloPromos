//
//  VerifyPaymentViewController.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 26/10/22.
//

import UIKit
import WebKit

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
    var redirectURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(webView)
        self.webView.uiDelegate = self
        guard let url = URL(string: "https://google.com") else { return }
        webView.load(URLRequest(url: url))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.webView.frame = self.view.bounds
    }

}

extension VerifyPaymentViewController: WKUIDelegate, WKNavigationDelegate {
    func webViewDidFinishLoad(_ webView: WKWebView) {
        if webView.isLoading { return }
        print("Finished loading page")
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        if let urlStr = navigationAction.request.url?.absoluteString {
            print("Current page ~ \(urlStr)")
        }
        decisionHandler(.allow)
    }
}
