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
        print("HaobitGetNotice")
        var ret = [Notice]()
        
        let retJson = await withCheckedContinuation { continuation in
            AF.requestWithoutCache(HAOBIT_FETCH_NOTICE, method: .get, headers: HTTPHeaders(headers)).response { res in
                switch res.result {
                case .success(let data):
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] {
                        continuation.resume(returning: json)
                    } else {
                        print("无法将响应数据转换为字典")
                        continuation.resume(returning: [[String: Any]]())
                    }
                case .failure(_):
                    print("请求HAOBIT 失败")
                    continuation.resume(returning: [[String: Any]]())
                }
            }
        }
        for notice in retJson {
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
        return ret
    }
}
