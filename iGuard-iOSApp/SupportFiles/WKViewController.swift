//
//  WKViewController.swift
//  iGuard-iOSApp
//
//  Created by Nurzhan Ababakirov on 1/8/23.
//

import Foundation
import UIKit
import WebKit

class WKViewController: UIViewController {
    var webView: WKWebView

    init(webView: WKWebView) {
        self.webView = webView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = webView
    }
}
