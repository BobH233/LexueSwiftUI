//
//  PackageDeclarationView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/4.
//

import SwiftUI

private struct PackageUsingDeclarationInfo: Hashable {
    var packageName: String = ""
    var packageDescription: String = ""
    var license: String = ""
    var URL: URL?
    var ourPurpose: String = ""
}

private var packages: [PackageUsingDeclarationInfo] = [
    PackageUsingDeclarationInfo(packageName: "Alamofire", packageDescription: "Elegant HTTP Networking in Swift", license: "MIT license", URL: URL(string: "https://github.com/Alamofire/Alamofire"), ourPurpose: "用于进行网络请求"),
    PackageUsingDeclarationInfo(packageName: "CloudKitSyncMonitor", packageDescription: "Monitor current state of NSPersistentCloudKitContainer sync", license: "MIT license", URL: URL(string: "https://github.com/ggruen/CloudKitSyncMonitor"), ourPurpose: "用于监控并显示iCloud同步状态"),
    PackageUsingDeclarationInfo(packageName: "CryptoSwift", packageDescription: "Crypto related functions and helpers for Swift", license: "Permissive license", URL: URL(string: "https://github.com/krzyzanowskim/CryptoSwift"), ourPurpose: "用于进行加密操作"),
    PackageUsingDeclarationInfo(packageName: "swift-markdown-ui", packageDescription: "Display and customize Markdown text in SwiftUI", license: "MIT license", URL: URL(string: "https://github.com/gonzalezreal/swift-markdown-ui"), ourPurpose: "用于app内显示markdown格式的文本"),
    PackageUsingDeclarationInfo(packageName: "SwiftSideways", packageDescription: "A multi-platform SwiftUI component for the horizontal scrolling of tabular data in compact areas", license: "Apache-2.0 license", URL: URL(string: "https://github.com/openalloc/SwiftSideways"), ourPurpose: "用于程序内表格的左右拖动效果"),
    PackageUsingDeclarationInfo(packageName: "SwiftSoup", packageDescription: "Pure Swift HTML Parser, with best of DOM, CSS, and jquery (Supports Linux, iOS, Mac, tvOS, watchOS)", license: "MIT license", URL: URL(string: "https://github.com/scinfu/SwiftSoup"), ourPurpose: "用于进行网页内容的解析，提供乐学API相关服务"),
    PackageUsingDeclarationInfo(packageName: "SwiftTabler", packageDescription: "A multi-platform SwiftUI component for tabular data", license: "Apache-2.0 license", URL: URL(string: "https://github.com/openalloc/SwiftTabler"), ourPurpose: "用于程序内显示表格"),
    PackageUsingDeclarationInfo(packageName: "SwiftUICharts", packageDescription: "A charts / plotting library for SwiftUI", license: "MIT license", URL: URL(string: "https://github.com/willdale/SwiftUICharts"), ourPurpose: "用于显示app内分析图表"),
    PackageUsingDeclarationInfo(packageName: "SwiftUIImageViewer", packageDescription: "An image viewer built using SwiftUI.", license: "MIT license", URL: URL(string: "https://github.com/Jake-Short/swiftui-image-viewer/"), ourPurpose: "用于查看消息中的图片，预览用户的头像"),
    PackageUsingDeclarationInfo(packageName: "SwiftUIKit", packageDescription: "SwiftUIKit contains additional functionality for SwiftUI.", license: "MIT license", URL: URL(string: "https://github.com/danielsaidi/SwiftUIKit"), ourPurpose: "用于组件功能的拓展"),
    PackageUsingDeclarationInfo(packageName: "WebView", packageDescription: "A SwiftUI component View that contains a WKWebView ", license: "Unlicense license", URL: URL(string: "https://github.com/kylehickinson/SwiftUI-WebView"), ourPurpose: "用于构建内置浏览器功能"),
    PackageUsingDeclarationInfo(packageName: "WrappingHStack", packageDescription: "A SwiftUI HStack with the ability to wrap contained elements", license: "MIT license", URL: URL(string: "https://github.com/dkk/WrappingHStack"), ourPurpose: "用于自动换行的水平布局"),
]

struct PackageDeclarationView: View {
    var body: some View {
        Form {
            Section {
                ForEach(packages, id: \.self) { package in
                    NavigationLink(package.packageName, destination: {
                        Form {
                            HStack {
                                Text("包名")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(package.packageName)
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Text("描述")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(package.packageDescription)
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Text("开源协议")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(package.license)
                                    .foregroundColor(.secondary)
                            }
                            if let url = package.URL {
                                HStack {
                                    Text("网址")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Link(url.absoluteString, destination: url)
                                }
                            }
                            HStack {
                                Text("用途")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(package.ourPurpose)
                                    .foregroundColor(.secondary)
                            }
                        }
                    })
                }
            } header: {
                Text("乐学助手引用了下面的一些开源包，感谢这些开源作者的贡献")
            }
        }
        .navigationTitle("开源包引用声明")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    PackageDeclarationView()
}
