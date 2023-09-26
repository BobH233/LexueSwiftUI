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
    @StateObject var webViewStore = WebViewStore()
    var body: some View {
        ZStack {
            WebView(webView: webViewStore.webView)
            if webViewStore.webView.isLoading {
                ProgressView()
                    .controlSize(.large)
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
