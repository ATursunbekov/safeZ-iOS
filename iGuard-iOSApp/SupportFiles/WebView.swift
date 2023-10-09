//
//  WebView.swift
//  iGuard-iOSApp
//
//  Created by Nurzhan Ababakirov on 1/8/23.
//

import SwiftUI
import WebKit

struct WebView: UIViewControllerRepresentable {
    var urlString: String

    func makeUIViewController(context: Context) -> WKViewController {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        return WKViewController(webView: webView)
    }

    func updateUIViewController(_ uiViewController: WKViewController, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiViewController.webView.load(request)
        }
    }
}
