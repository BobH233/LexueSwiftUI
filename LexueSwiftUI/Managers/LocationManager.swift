//
//  LocationManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/11/5.
//

// GPS 定位服务的相关管理

import Foundation
import CoreLocation


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private var locationManager = CLLocationManager()
    
    var updatingPosition: Bool = false
    
    @Published var compassHeading: CLLocationDirection?
    
    @Published var currentLocation: CLLocation?
    
    public static let locationAuthUpdated = Notification.Name("locationAuthUpdated")
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        updatingPosition = false
    }
    
    func RequestPermission() -> Bool {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            return true
        }
        return false
    }
    func GetLocationAuthStatus() -> CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        NotificationCenter.default.post(name: LocationManager.locationAuthUpdated, object: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.magneticHeading >= 0 {
            compassHeading = newHeading.magneticHeading
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            currentLocation = newLocation
        }
    }
    
    private func Is_Outof_China(lng: Float, lat: Float) -> Bool {
        var lat = +lat;
        var lng = +lng;
        return !(lng > 73.66 && lng < 135.05 && lat > 3.86 && lat < 53.55);
    }
    
    private func transformlat(_ lng: Float, _ lat: Float) -> Float {
        let lat = lat
        let lng = lng
        let PI = Float.pi

        var ret = -100.0 + 2.0 * lng + 3.0 * lat + 0.2 * lat * lat + 0.1 * lng * lat + 0.2 * sqrt(abs(lng))
        ret += (20.0 * sin(6.0 * lng * PI) + 20.0 * sin(2.0 * lng * PI)) * 2.0 / 3.0
        ret += (20.0 * sin(lat * PI) + 40.0 * sin(lat / 3.0 * PI)) * 2.0 / 3.0
        ret += (160.0 * sin(lat / 12.0 * PI) + 320 * sin(lat * PI / 30.0)) * 2.0 / 3.0
        
        return ret
    }
    private func transformlng(_ lng: Float, _ lat: Float) -> Float {
        let lat = lat
        let lng = lng
        let PI = Float.pi

        var ret = 300.0 + lng + 2.0 * lat + 0.1 * lng * lng + 0.1 * lng * lat + 0.1 * sqrt(abs(lng))
        ret += (20.0 * sin(6.0 * lng * PI) + 20.0 * sin(2.0 * lng * PI)) * 2.0 / 3.0
        ret += (20.0 * sin(lng * PI) + 40.0 * sin(lng / 3.0 * PI)) * 2.0 / 3.0
        ret += (150.0 * sin(lng / 12.0 * PI) + 300.0 * sin(lng / 30.0 * PI)) * 2.0 / 3.0

        return ret
    }
    
    // ret: (mglng, mglat)
    func WGS84_to_GCJ02(lng: Float, lat: Float) -> (Float, Float) {
        var lat = +lat;
        var lng = +lng;
        let PI = Float.pi
        let a = Float(6378245.0);
        let ee = Float(0.00669342162296594323);
        if Is_Outof_China(lng: lng, lat: lat) {
            return (lng, lat)
        }
        var dlat = transformlat(lng - 105.0, lat - 35.0)
        var dlng = transformlng(lng - 105.0, lat - 35.0)
        let radlat = lat / 180.0 * PI
        var magic = sin(radlat)
        magic = 1 - ee * magic * magic
        let sqrtmagic = sqrt(magic)
        dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * PI)
        dlng = (dlng * 180.0) / (a / sqrtmagic * cos(radlat) * PI)
        let mglat = lat + dlat
        let mglng = lng + dlng
        
        return (mglng, mglat)
    }
    
    // 开始更新位置
    func startUpdate() {
        if updatingPosition {
            return
        }
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        updatingPosition = true
    }
    
    // 停止更新位置
    func stopUpdate() {
        if !updatingPosition {
            return
        }
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        updatingPosition = false
    }
    
}
