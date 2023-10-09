//
//  WebViewWrapper.swift
//  iGuard-iOSApp
//
//  Created by Nurzhan Ababakirov on 1/8/23.
//

import SwiftUI
import WebKit

struct WebViewWrapper: View {
    @Binding var showWebView: Bool
    var urlString: String

    var body: some View {
        NavigationView {
            VStack {
                WebView(urlString: urlString)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showWebView = false
                            }
                        }
                    }
            }
        }
    }
}
