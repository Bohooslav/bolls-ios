//
//  ContentView.swift
//  Bolls
//
//  Created by Богуслав Павлишинець on 16.08.2020.
//  Copyright © 2020 Bohuslav Pavlyshynets. All rights reserved.
//

import SwiftUI
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    var popupWebView: WKWebView?
    
    override func loadView() {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences = preferences
        webConfiguration.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.uiDelegate = self
        self.webView.navigationDelegate = self
        
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(displayP3Red: 4.0, green: 6.0, blue: 12.0, alpha: 1.0)
        self.webView!.isOpaque = false
        self.webView!.backgroundColor = UIColor.clear
        self.webView!.scrollView.backgroundColor = UIColor.clear
        
        loadBolls()
    }

    func loadBolls() {
        // For production
        let myURL = URL(string:"https://bolls.life")

        // For local debug
//        let myURL = URL(string:"http://192.168.122.1:8000/")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard
            let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
        }
        
        let stringUrl = url.absoluteString
        
        if (!(navigationAction.targetFrame?.isMainFrame ?? false)) {
            if stringUrl.contains("accounts.youtube.com/accounts/CheckConnection") {
                let webConfiguration = WKWebViewConfiguration()
                webConfiguration.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
                popupWebView = WKWebView(frame: view.bounds, configuration: webConfiguration)
                popupWebView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                popupWebView!.isHidden = true
                popupWebView!.navigationDelegate = self
                popupWebView!.uiDelegate = self
                view.addSubview(popupWebView!)
                decisionHandler(.cancel)
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }

        if (stringUrl.contains("mailto:")) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let url = Bundle.main.url(forResource: "err", withExtension: "html", subdirectory: "")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let url = Bundle.main.url(forResource: "err", withExtension: "html", subdirectory: "")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct ContentView: UIViewControllerRepresentable{
    func makeUIViewController(context _: Context) -> ViewController {
        return ViewController()
    }

    func updateUIViewController(_: ViewController, context _: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
