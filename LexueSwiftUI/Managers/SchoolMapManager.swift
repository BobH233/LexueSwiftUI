//
//  SchoolMapManager.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/27.
//
//  校园内导航的管理

import Foundation
import MapKit

class SchoolMapManager {
    static let shared = SchoolMapManager()
    
    // 描述校园内的一个地方
    struct SchoolLocationDescription: Codable {
        var shortName: String = ""
        var fullName: String = ""
        var latitude: Double = 0
        var longitude: Double = 0
        // 匹配关键词
        var matchKeywords: [String] = []
        // 匹配校区
        var matchRegion: String = ""
    }
    
    let default_school_locations: [SchoolLocationDescription] = [
        // 基础教学楼支持
        .init(shortName: "良乡理教楼", fullName: "良乡校区理科教学大楼", latitude: 39.730286, longitude: 116.170955, matchKeywords: ["理教楼"], matchRegion: "良乡校区"),
        .init(shortName: "良乡综教楼A", fullName: "良乡校区综合教学楼大楼A", latitude: 39.73324, longitude: 116.17036, matchKeywords: ["综教A"], matchRegion: "良乡校区"),
        .init(shortName: "良乡综教楼B", fullName: "良乡校区综合教学楼大楼B", latitude: 39.733231, longitude: 116.171344, matchKeywords: ["综教B"], matchRegion: "良乡校区"),
        .init(shortName: "良乡文萃楼A", fullName: "良乡校区文萃楼A", latitude: 39.732592, longitude: 116.174668, matchKeywords: ["文萃楼A"], matchRegion: "良乡校区"),
        .init(shortName: "良乡文萃楼B", fullName: "良乡校区文萃楼B", latitude: 39.732206, longitude: 116.174708, matchKeywords: ["文萃楼B"], matchRegion: "良乡校区"),
        .init(shortName: "良乡文萃楼C", fullName: "良乡校区文萃楼C", latitude: 39.731549, longitude: 116.174225, matchKeywords: ["文萃楼C"], matchRegion: "良乡校区"),
        .init(shortName: "良乡文萃楼D", fullName: "良乡校区文萃楼D", latitude: 39.731591, longitude: 116.173867, matchKeywords: ["文萃楼D"], matchRegion: "良乡校区"),
        .init(shortName: "良乡文萃楼E", fullName: "良乡校区文萃楼E", latitude: 39.731545, longitude: 116.173488, matchKeywords: ["文萃楼E"], matchRegion: "良乡校区"),
        .init(shortName: "良乡文萃楼F", fullName: "良乡校区文萃楼F", latitude: 39.732217, longitude: 116.173874, matchKeywords: ["文萃楼F"], matchRegion: "良乡校区"),
        .init(shortName: "良乡文萃楼G", fullName: "良乡校区文萃楼G", latitude: 39.731973, longitude: 116.173090, matchKeywords: ["文萃楼G"], matchRegion: "良乡校区"),
        .init(shortName: "良乡文萃楼H", fullName: "良乡校区文萃楼H", latitude: 39.733093, longitude: 116.173169, matchKeywords: ["文萃楼H"], matchRegion: "良乡校区"),
        .init(shortName: "良乡文萃楼I", fullName: "良乡校区文萃楼I", latitude: 39.733282, longitude: 116.173510, matchKeywords: ["文萃楼I"], matchRegion: "良乡校区"),
        .init(shortName: "良乡文萃楼J", fullName: "良乡校区文萃楼J", latitude: 39.733641, longitude: 116.173569, matchKeywords: ["文萃楼J"], matchRegion: "良乡校区"),
        .init(shortName: "良乡文萃楼K", fullName: "良乡校区文萃楼K", latitude: 39.733607, longitude: 116.173844, matchKeywords: ["文萃楼K"], matchRegion: "良乡校区"),
        .init(shortName: "良乡文萃楼L", fullName: "良乡校区文萃楼L", latitude: 39.733572, longitude: 116.174227, matchKeywords: ["文萃楼L"], matchRegion: "良乡校区"),
        .init(shortName: "良乡文萃楼M", fullName: "良乡校区文萃楼M", latitude: 39.732941, longitude: 116.174576, matchKeywords: ["文萃楼M"], matchRegion: "良乡校区"),
        // 体育课方面
        .init(shortName: "良乡体育馆", fullName: "良乡校区体育馆", latitude: 39.731844, longitude: 116.176544, matchKeywords: ["良乡体育馆", "游泳馆"], matchRegion: "良乡校区"),
        .init(shortName: "良乡南操场", fullName: "良乡校区南校区足球场", latitude: 39.729293, longitude: 116.169420, matchKeywords: ["南校区足球场", "田径场主席台"], matchRegion: "良乡校区"),
        .init(shortName: "良乡南篮球场", fullName: "良乡校区南校区篮球场", latitude: 39.728285, longitude: 116.168703, matchKeywords: ["南校区篮球场"], matchRegion: "良乡校区"),
        .init(shortName: "良乡南网球场", fullName: "良乡校区南校区网球场", latitude: 39.727715, longitude: 116.168760, matchKeywords: ["南校区网球场"], matchRegion: "良乡校区"),
        .init(shortName: "良乡南排球场", fullName: "良乡校区南校区排球场", latitude: 39.727433, longitude: 116.169478, matchKeywords: ["南校区排球场"], matchRegion: "良乡校区"),
        .init(shortName: "良乡疏桐园A", fullName: "良乡校区疏桐园A", latitude: 39.728745, longitude: 116.168117, matchKeywords: ["疏桐园A"], matchRegion: "良乡校区"),
        
    ]
    
    func UpdateSchoolLocations(newLocations: [SchoolLocationDescription]) {
        if let data = encodeFuncDescriptionStoredArr(newLocations) {
            UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.set(data, forKey: "stored.school_locations")
            print("保存设置成功！")
        }
    }
    
    func GetSchoolLocations() -> [SchoolLocationDescription] {
        if let stored_data = UserDefaults(suiteName: "group.cn.bobh.LexueSwiftUI")!.value(forKey: "stored.school_locations") as? Data {
            let tmp: [SchoolLocationDescription] = decodeStructArray(from: stored_data)
            return tmp
        } else {
            // 如果是第一次，那么返回默认信息
            return default_school_locations
        }
    }
    
    func UpdateMapInfo() async {
        let backendResult = await LexueHelperBackend.shared.GetMapLocations()
        if backendResult.count > 0 {
            UpdateSchoolLocations(newLocations: backendResult)
        }
    }
    
    func OpenMapAppWithLocation(latitude la: Double, longitude lon: Double, regionDistance: CLLocationDistance, name: String) {
        let latitude: CLLocationDegrees = la
        let longitude: CLLocationDegrees = lon
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options: [String: Any] = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: options)
    }
    
    func GenerateRecommandationSchoolLocation(courseLocationDes: String) -> [SchoolLocationDescription] {
        // 根据上课地点生成推荐的导航地点
        let allLocations = GetSchoolLocations()
        var ret: [SchoolLocationDescription] = []
        for location in allLocations {
            var match = false
            for keyword in location.matchKeywords {
                if courseLocationDes.contains(keyword) {
                    match = true
                    break
                }
            }
            if match {
                ret.append(location)
            }
        }
        return ret
    }
}
