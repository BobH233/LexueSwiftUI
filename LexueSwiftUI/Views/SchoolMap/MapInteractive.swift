//
//  MapInteractive.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/11/6.
//

// 与网页地图进行js交互相关操作

import Foundation
import WebKit


class MapInteractive: NSObject, WKNavigationDelegate {
    
    let rediusOfIndicatorX: Float = 0.0004
    let rediusOfIndicatorY: Float = 0.0003
    
    var webView: WKWebView?
    var jsInited: Bool = false
    
    var jsWaitQueue: [String] = []
    
    func setWebView(webView: WKWebView) {
        self.webView = webView
        webView.navigationDelegate = self
    }
    
    func unsetWebView() {
        self.webView = nil
        jsInited = false
        jsWaitQueue = []
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 网页加载完成后的操作
        print("网页加载完成")
        initJsSide()
        while let firstElem = jsWaitQueue.first {
            print("执行 等待js: \(firstElem)")
            self.webView?.evaluateJavaScript(firstElem)
            jsWaitQueue.removeFirst()
        }
        jsInited = true
    }
    func initJsSide() {
        // 初始化js侧，需要新建 document.mapInstance.gps = {}
        // 同时初始化一些参数值
        webView?.evaluateJavaScript("document.mapInstance.gps = {};\n" +
                                    "document.mapInstance.gps.direction = 0;\n" +
                                    "document.mapInstance.gps.enableDisplayPosition = false;")
    }
    
    // 允许地图显示自己的坐标圆
    func enableDisplayPosition() {
        if jsInited {
            webView?.evaluateJavaScript("document.mapInstance.gps.enableDisplayPosition = true;")
        } else {
            jsWaitQueue.append("document.mapInstance.gps.enableDisplayPosition = true;")
        }
    }
    
    // 禁止地图显示自己的坐标圆
    func disableDisplayPosition() {
        if jsInited {
            webView?.evaluateJavaScript("document.mapInstance.gps.enableDisplayPosition = false;")
        } else {
            jsWaitQueue.append("document.mapInstance.gps.enableDisplayPosition = false;")
        }
    }
    
    // 设置坐标圆朝向
    func setGpsDirection(direction: Double) {
        if jsInited {
            webView?.evaluateJavaScript("document.mapInstance.gps.direction = \(direction);")
        }
    }
    
    // 设置圆的中心点
    func setIndicatorCenter(lng: Float, lat: Float) {
        // 分别得到上下限的真实gps地址，然后转换成gcj02坐标系
        let (lng_1, lat_1) = (lng - rediusOfIndicatorX / 2, lat - rediusOfIndicatorY / 2)
        let (lng_2, lat_2) = (lng + rediusOfIndicatorX / 2, lat + rediusOfIndicatorY / 2)
        let (lng_ori_gcj, lat_ori_gcj) = LocationManager.shared.WGS84_to_GCJ02(lng: lng, lat: lat)
        let (lng_1_gcj, lat_1_gcj) = LocationManager.shared.WGS84_to_GCJ02(lng: lng_1, lat: lat_1)
        let (lng_2_gcj, lat_2_gcj) = LocationManager.shared.WGS84_to_GCJ02(lng: lng_2, lat: lat_2)
        let jsCode =    "document.mapInstance.gps.bound = new AMap.Bounds([\(lng_1_gcj), \(lat_1_gcj)],[\(lng_2_gcj), \(lat_2_gcj)]);\n" +
                        "document.mapInstance.circleMarker.setCenter([\(lng_ori_gcj), \(lat_ori_gcj)]);\n"
        if jsInited {
            webView?.evaluateJavaScript(jsCode)
        } else {
            jsWaitQueue.append(jsCode)
        }
    }
    
    // 设置视角切换到当前用户的位置
    func setZoomFitCurrentLocation() {
        let jsCode = "document.mapInstance.map.setBounds(document.mapInstance.canvasLayer.getBounds());"
        if jsInited {
            webView?.evaluateJavaScript(jsCode)
        } else {
            jsWaitQueue.append(jsCode)
        }
    }
}
