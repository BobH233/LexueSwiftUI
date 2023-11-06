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


struct SchoolMapView: View {
    
    @Environment(\.dismiss) var dismiss
    
    // TODO: 改成真正的服务链接
    let mapServiceUrl = "http://192.168.8.143:5500/ver1.html"
    
    @State var isLocationAvailable: Bool = false
    @ObservedObject var locationManager = LocationManager.shared
    @StateObject var webViewStore = WebViewStore()
    @State var mapInteractive: MapInteractive = MapInteractive()
    var body: some View {
        ScrollView{
            ZStack {
                WebView(webView: webViewStore.webView)
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
            }
            .frame(
                width: UIScreen.main.bounds.width ,
                height: UIScreen.main.bounds.height
            )
        }
        .onChange(of: locationManager.compassHeading) { newVal in
            if let newVal = newVal {
                mapInteractive.setGpsDirection(direction: newVal)
            }
        }
        .onChange(of: locationManager.currentLocation) { newVal in
            if let NewVal = newVal {
                print(NewVal.coordinate.longitude)
                print(NewVal.coordinate.latitude)
                mapInteractive.setIndicatorCenter(lng: Float(NewVal.coordinate.longitude), lat: Float(NewVal.coordinate.latitude))
            }
        }
        .navigationBarHidden(true)
        .statusBarHidden()
        .ignoresSafeArea(.all, edges: [.top])
        .onFirstAppear {
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
