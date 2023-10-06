//
//  HaoBIT.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/6.
//

import Foundation
import Alamofire



class HaoBIT {
    static let shared = HaoBIT()
    
    let headers = [
        "Referer": "https://haobit.top/",
        "Host": "haobit.top",
        "Accept-Language": "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:103.0) Gecko/20100101 Firefox/103.0 LexueHelper/114514"
    ]
    
    let HAOBIT_FETCH_NOTICE = "https://haobit.top/dev/site/notices.json"
    struct Notice {
        var link: String?
        var title: String?
        var date: Date?
        var source: String?
        // 用于判断两个Notice是否是同一个，检测刷新用
        func get_descriptor() -> String {
            return "\(link ?? "")_\(title ?? "")_\(source ?? "")".sha256
        }
    }
    func GetNotices() async -> [Notice] {
        var ret = [Notice]()
        let response = await AF.requestWithoutCache(HAOBIT_FETCH_NOTICE, method: .get, headers: HTTPHeaders(headers)).serializingString().response
        switch response.result {
        case .success(let jsonData):
            if let data = jsonData.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                for notice in json {
                    var currentNotice = Notice()
                    currentNotice.link = notice["link"] as? String
                    currentNotice.title = notice["title"] as? String
                    currentNotice.source = notice["source"] as? String
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    if let dateString = notice["date"] as? String, let date = dateFormatter.date(from: dateString) {
                        currentNotice.date = date
                    }
                    ret.append(currentNotice)
                }
            }
        case .failure(_):
            print("获取HAOBIT Notices 失败")
        }
        return ret
    }
}
