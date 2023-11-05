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
