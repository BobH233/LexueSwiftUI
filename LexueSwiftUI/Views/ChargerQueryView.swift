//
//  ChargerQueryView.swift
//  LexueSwiftUI
//
//  Created by 何秋洋 on 2025/10/13.
//

import SwiftUI
import WebView

struct ChargerQueryView: View {
    @StateObject private var webViewStore = WebViewStore()
    private let url = URL(string: "https://chongdian.bit-helper.cn/")!

    var body: some View {
        ZStack {
            WebView(webView: webViewStore.webView)
                .onAppear {
                    webViewStore.webView.configuration.defaultWebpagePreferences.preferredContentMode = .mobile
                    webViewStore.webView.load(URLRequest(url: url))
                }

            if webViewStore.webView.isLoading {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .navigationTitle("全校充电桩查询")
        .navigationBarTitleDisplayMode(.inline)
    }
}
