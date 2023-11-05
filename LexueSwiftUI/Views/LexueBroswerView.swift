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
    let customActions: [(String, (WebViewStore)->Void)]
    @StateObject var webViewStore = WebViewStore()
    @State var forParentWebViewStore: Binding<WebViewStore>?
    @State private var isActionSheetPresented = false
    
    func GetButtons() -> [Alert.Button] {
        var ret: [Alert.Button] = [
            .default(Text("在浏览器打开")) {
                if let url = webViewStore.webView.url {
                    UIApplication.shared.open(url)
                }
            },
            .default(Text("复制当前链接")) {
                if let url = webViewStore.webView.url {
                    UIPasteboard.general.string = url.absoluteString
                }
            },
            .cancel()
        ]
        
        for (actionName, cb) in customActions {
            ret.insert(.default(Text(actionName)) {
                cb(webViewStore)
            }, at: 0)
        }
        return ret
    }
    
    var body: some View {
        ZStack {
            WebView(webView: webViewStore.webView)
            if webViewStore.webView.isLoading {
                ProgressView()
                    .controlSize(.large)
            }
            
        }
        .navigationBarItems(trailing:
                                Button(action: {
            self.isActionSheetPresented.toggle()
        }) {
            Image(systemName: "ellipsis")
        }
            .actionSheet(isPresented: $isActionSheetPresented) {
                ActionSheet(title: Text("选项"), buttons: GetButtons())
            }
        )
        .onChange(of: webViewStore.webView.isLoading) { newVal in
            if !newVal {
                // 执行js代码
                self.webViewStore.webView.evaluateJavaScript(execJs)
            }
        }
        .onFirstAppear {
            if #available(iOS 16.4, *) {
                if GlobalVariables.shared.DEBUG_BUILD { self.webViewStore.webView.isInspectable = true }
            }
            Task {
                let res = await LexueAPI.shared.GetSessKey(GlobalVariables.shared.cur_lexue_context)
                switch res {
                case .success(let (sesskey, newContext)):
                    let cookie = HTTPCookie(properties: [
                        .domain: "lexue.bit.edu.cn",
                        .path: "/",
                        .name: "MoodleSession",
                        .value: (newContext != nil) ? newContext!.MoodleSession : GlobalVariables.shared.cur_lexue_context.MoodleSession,
                        .secure: "TRUE",
                        .expires: NSDate(timeIntervalSinceNow: 31556926)
                    ])!
                    DispatchQueue.main.async {
                        // 添加lexue的cookie
                        self.webViewStore.webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
                        // 显示手机版
                        self.webViewStore.webView.configuration.defaultWebpagePreferences.preferredContentMode = .mobile
                        self.webViewStore.webView.load(URLRequest(url: URL(string: url)!))
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        self.webViewStore.webView.configuration.defaultWebpagePreferences.preferredContentMode = .mobile
                        self.webViewStore.webView.load(URLRequest(url: URL(string: url)!))
                    }
                }
            }
        }
        
    }
}

