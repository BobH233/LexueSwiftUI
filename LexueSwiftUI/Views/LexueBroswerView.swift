//
//  LexueBroswerView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/26.
//

import SwiftUI
import WebView


struct LexueBroswerView: View {
    var url: String = "https://lexue.bit.edu.cn/"
    var execJs: String = ""
    @StateObject var webViewStore = WebViewStore()
    var body: some View {
        ZStack {
            WebView(webView: webViewStore.webView)
            if webViewStore.webView.isLoading {
                ProgressView()
                    .controlSize(.large)
            }
            
        }
        .onChange(of: webViewStore.webView.isLoading) { newVal in
            if !newVal {
                // 执行js代码
                self.webViewStore.webView.evaluateJavaScript(execJs)
            }
        }
        .onAppear {
            let cookie = HTTPCookie(properties: [
                .domain: "lexue.bit.edu.cn",
                .path: "/",
                .name: "MoodleSession",
                .value: GlobalVariables.shared.cur_lexue_context.MoodleSession,
                .secure: "TRUE",
                .expires: NSDate(timeIntervalSinceNow: 31556926)
            ])!
            if #available(iOS 16.4, *) {
                if GlobalVariables.shared.debugMode { self.webViewStore.webView.isInspectable = true }
            }
            // 添加lexue的cookie
            self.webViewStore.webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            // 显示手机版
            self.webViewStore.webView.configuration.defaultWebpagePreferences.preferredContentMode = .mobile
            self.webViewStore.webView.load(URLRequest(url: URL(string: url)!))
        }
        
    }
}

#Preview {
    LexueBroswerView()
}
