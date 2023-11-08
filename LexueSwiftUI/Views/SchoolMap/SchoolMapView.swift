//
//  SchoolMapView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/11/5.
//

import SwiftUI
import CoreLocation
import WebView
import WebKit
import SwiftUIKit



@available(iOS 16.0, *)
private struct SheetView16: View {
    @State var selectedDetents: PresentationDetent = .height(70)
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                TextField("搜索校园地点", text: .constant(""))
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.ultraThickMaterial)
                    }
            }
            .padding()
        }
        .background(content: {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        })
        .presentationDetents([.medium, .large, .height(70)], largestUndimmed: .large, selection: $selectedDetents)
        .interactiveDismissDisabled(true)
    }
}


//
//extension View {
//    
//    @ViewBuilder
//    func bottomSheetIfAvailable<Content: View>(presented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
//        if #available(iOS 16.0, *) {
//            self.bottomSheet(presentationDetents: [.medium, .large, .height(70)], isPresented: .constant(true), sheetCornerRadius: 20, isTransparentBG: true) {
//                content()
//            } onDismiss: {
//                
//            }
//        } else {
//            self.bottomSheet15(isPresented: presented, sheetCornerRadius: 20, isTransparentBG: true, interactiveDisabled: false) {
//                content()
//            } onDismiss: {
//                
//            }
//        }
//    }
//}

struct SchoolMapView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var sheetShow = true
    // TODO: 改成真正的服务链接
    let mapServiceUrl = "https://mapapi.bit-helper.cn/ver1.html"
    
    @State var isLocationAvailable: Bool = false
    @ObservedObject var locationManager = LocationManager.shared
    @StateObject var webViewStore = WebViewStore()
    @State var mapInteractive: MapInteractive = MapInteractive()
    var body: some View {
        ZStack {
            ScrollView {
                WebView(webView: webViewStore.webView)
                .frame(
                    width: UIScreen.main.bounds.width ,
                    height: UIScreen.main.bounds.height
                )
            }
            HStack {
                VStack {
                    // 关闭地图
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                        .padding(20)
                        .onTapGesture {
                            VibrateOnce()
                            dismiss()
                            mapInteractive.unsetWebView()
                        }
                    Spacer()
                }
                Spacer()
            }
            
            HStack {
                Spacer()
                VStack(spacing: 15) {
                    Spacer()
                    // 对于ios16以下的系统，需要按钮来显示sheet
                    if #unavailable(iOS 16.0){
                        Image(systemName: "line.3.horizontal.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            .padding(.horizontal, 20)
                            .onTapGesture {
                                VibrateOnce()
                                sheetShow.toggle()
                            }
                    }
                    if isLocationAvailable {
                        // 定位到当前位置
                        Image(systemName: "location.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .onTapGesture {
                                VibrateOnce()
                                mapInteractive.setZoomFitCurrentLocation()
                            }
                    }
                }
            }
        }
        .sheet(isPresented: $sheetShow) {
            if #available(iOS 16.0, *) {
                SheetView16()
            }
        }
        .onChange(of: locationManager.compassHeading) { newVal in
            if let newVal = newVal {
                mapInteractive.setGpsDirection(direction: newVal)
            }
        }
        .onChange(of: locationManager.currentLocation) { newVal in
            if let NewVal = newVal {
                mapInteractive.setIndicatorCenter(lng: Float(NewVal.coordinate.longitude), lat: Float(NewVal.coordinate.latitude))
            }
        }
        .navigationBarHidden(true)
        .statusBarHidden()
        .ignoresSafeArea(.all, edges: [.top])
        .onFirstAppear {
            sheetShow = true
            if #available(iOS 16.4, *) {
                if GlobalVariables.shared.DEBUG_BUILD {
                    self.webViewStore.webView.isInspectable = true
                }
            }
            mapInteractive.setWebView(webView: webViewStore.webView)
            // 高德地图太坑了...必须加这一行才能正常工作，不知道是不是故意不让app用网页服务的
            self.webViewStore.webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36 Edg/119.0.0.0"
            
            self.webViewStore.webView.load(URLRequest(url: URL(string: mapServiceUrl)!))
            let _ = LocationManager.shared.RequestPermission()
            let status = LocationManager.shared.GetLocationAuthStatus()
            print(status)
            if status == .denied || status == .restricted {
                isLocationAvailable = false
                GlobalVariables.shared.alertTitle = "校园地图定位无法正常工作"
                GlobalVariables.shared.alertContent = "因为您未授权app使用您的位置，因此校园地图的定位功能无法正常工作，但您依然可以使用校园地图的其他功能。"
                GlobalVariables.shared.showAlert = true
            } else {
                isLocationAvailable = true
            }
            LocationManager.shared.startUpdate()
            if isLocationAvailable {
                mapInteractive.enableDisplayPosition()
            } else {
                mapInteractive.disableDisplayPosition()
            }
        }
        .onDisappear() {
            LocationManager.shared.stopUpdate()
        }
        .onReceive(NotificationCenter.default.publisher(for: LocationManager.locationAuthUpdated)) { auth in
            let status = auth.object as? CLAuthorizationStatus
            if status == nil {
                return
            }
            if status == .notDetermined {
                return
            }
            if status == .denied || status == .restricted {
                DispatchQueue.main.async {
                    isLocationAvailable = false
                    GlobalVariables.shared.alertTitle = "校园地图定位无法正常工作"
                    GlobalVariables.shared.alertContent = "因为您未授权app使用您的位置，因此校园地图的定位功能无法正常工作，但您依然可以使用校园地图的其他功能。"
                    GlobalVariables.shared.showAlert = true
                }
            } else {
                DispatchQueue.main.async {
                    isLocationAvailable = true
                }
            }
        }
    }
}

#Preview {
    SchoolMapView()
}
