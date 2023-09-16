//
//  LexueAPI.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/12.
//

import Foundation
import Alamofire
import SwiftSoup



// rewrite from https://github.com/BIT-BOBH/LexueAPI
class LexueAPI {
    static let shared = LexueAPI()
    
    let API_LEXUE_TICK = "https://login.bit.edu.cn/authserver/login?service=https://lexue.bit.edu.cn/login/index.php"
    let API_LEXUE_SECOND_AUTH = "https://lexue.bit.edu.cn/login/index.php"
    let API_LEXUE_INDEX = "https://lexue.bit.edu.cn/"
    let API_LEXUE_DETAIL_INFO = "https://lexue.bit.edu.cn/user/edit.php"
    let API_LEXUE_SERVICE_CALL = "https://lexue.bit.edu.cn/lib/ajax/service.php"
    
    let headers = [
        "Referer": "https://login.bit.edu.cn/authserver/login",
        "Host": "login.bit.edu.cn",
        "Accept-Language": "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:103.0) Gecko/20100101 Firefox/103.0"
    ]
    
    let headers1 = [
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
        "Connection": "keep-alive",
        "Host": "lexue.bit.edu.cn",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.76",
    ]
    
    struct LexueContext {
        var MoodleSession: String = ""
    }
    
    enum LexueLoginError: Error {
        case networkError
        case noLocationHeader
    }
    
    enum LexueAPIError: Error {
        case unknowError
    }
    
    struct SelfUserInfo {
        var userId: String = ""
        var fullName: String = ""
        var firstAccessTime: String = ""
        var onlineUsers: String = ""
        var email: String = ""
        var stuId: String = ""
        var phone: String = ""
    }
    
    func GetLexueHeaders(_ lexueContext: LexueContext) -> HTTPHeaders {
        var cur_headers = HTTPHeaders(headers1)
        cur_headers.add(name: "Cookie", value: "MoodleSession=\(lexueContext.MoodleSession);")
        return cur_headers
    }
    
    func ParseDetailUserInfo(_ html: String, _ ori: SelfUserInfo) -> SelfUserInfo {
        var ret = ori
        do {
            let document = try SwiftSoup.parse(html)
            let emailElement = try document.select("#id_email").first()
            ret.email = try emailElement?.attr("value").trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let id_idnumber = try document.select("#id_idnumber").first()
            ret.stuId = try id_idnumber?.attr("value").trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let id_phone1 = try document.select("#id_phone1").first()
            ret.phone = try id_phone1?.attr("value").trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return ret
        } catch {
            print("Error parsing HTML: \(error.localizedDescription)")
            return ret
        }
    }
    
    func ParseBasicUserInfo(_ html: String) -> SelfUserInfo {
        do {
            var ret = SelfUserInfo()
            let document = try SwiftSoup.parse(html)
            let fullNameElement = try document.select(".myprofileitem.fullname")
            ret.fullName = try fullNameElement.text().trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "")
            
            let firstAccessElement = try document.select(".myprofileitem.firstaccess").first()
            ret.firstAccessTime = try firstAccessElement?.text().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let instanceHeaderElement = try document.select("#instance-33495-header").first()
            let parentElement = instanceHeaderElement?.parent()
            let infoElements = try parentElement?.select(".info")
            ret.onlineUsers = try infoElements?.text().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let containerElement = try document.select("#nav-notification-popover-container").first()
            ret.userId = try containerElement?.attr("data-userid") ?? ""
            return ret
        } catch {
            print("Error parsing HTML: \(error.localizedDescription)")
            return SelfUserInfo()
        }
    }
    
    func ParseSessKey(_ html: String) -> String {
        if let sesskeyRange = html.range(of: "\"sesskey\":\"") {
            // 计算 sesskey 的起始位置
            let startIndex = sesskeyRange.upperBound
            
            // 找到 sesskey 结束位置的引号
            if let endIndex = html[startIndex...].firstIndex(of: "\"") {
                // 提取 sesskey 后面的字符串
                let sessKey = String(html[startIndex..<endIndex])
                return sessKey
            }
        }
        return ""
    }
    
    func GetSessKey(_ lexueContext: LexueContext) async -> Result<String, Error> {
        let response = await AF.requestWithoutCache(API_LEXUE_INDEX, method: .get, headers: GetLexueHeaders(lexueContext)).serializingString().response
        switch response.result {
        case .success(let html):
            let ret = ParseSessKey(html)
            return .success(ret)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func GetSelfUserInfo(_ lexueContext: LexueContext) async -> Result<SelfUserInfo, Error> {
        let response = await AF.requestWithoutCache(API_LEXUE_INDEX, method: .get, headers: GetLexueHeaders(lexueContext)).serializingString().response
        switch response.result {
        case .success(let data):
            var ret = ParseBasicUserInfo(data)
            let response2 = await AF.requestWithoutCache(API_LEXUE_DETAIL_INFO, method: .get, headers: GetLexueHeaders(lexueContext)).serializingString().response
            switch response2.result {
            case .success(let data2):
                ret = ParseDetailUserInfo(data2, ret)
                print(ret)
                return .success(ret)
            case .failure(_):
                return .success(ret)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func GetLexueContext(_ loginnedContext: BITLogin.LoginSuccessContext, completion: @escaping (Result<LexueContext, LexueLoginError>) -> Void) {
        var cur_headers = HTTPHeaders(headers)
        cur_headers.add(name: "Cookie", value: "CASTGC=\(loginnedContext.CASTGC)")
        AF.requestWithoutCache(API_LEXUE_TICK, method: .get, headers: cur_headers)
            .validate(statusCode: 300..<500)
            .redirect(using: Redirector.doNotFollow)
            .response { response in
                switch response.result {
                case .success( _):
                    if let ret_headers = response.response?.allHeaderFields as? [String: String], let login_url = ret_headers["Location"] {
                        AF.requestWithoutCache(login_url, method: .get)
                            .validate(statusCode: 300..<500)
                            .redirect(using: Redirector.doNotFollow)
                            .response { response1 in
                                switch response1.result {
                                case .success(_):
                                    if let ret_headers = response1.response?.allHeaderFields as? [String: String], let cookie = ret_headers["Set-Cookie"] {
                                        let firstMoodle = get_cookie_key(cookie, "MoodleSession")
                                        // print("firstMoodle: \(cookie)")
                                        var secondHeaders = HTTPHeaders(self.headers1)
                                        secondHeaders.add(name: "Cookie", value: "MoodleSession=\(firstMoodle);")
                                        AF.requestWithoutCache(self.API_LEXUE_SECOND_AUTH, method: .get, headers: secondHeaders)
                                            .validate(statusCode: 300..<500)
                                            .redirect(using: Redirector.doNotFollow)
                                            .response { response2 in
                                                switch response2.result {
                                                case .success(_):
                                                    if let ret_headers = response2.response?.allHeaderFields as? [String: String], let cookie = ret_headers["Set-Cookie"]{
                                                        var ret = LexueContext()
                                                        ret.MoodleSession = get_cookie_key(cookie, "MoodleSession")
                                                        print(ret)
                                                        completion(.success(ret))
                                                    } else {
                                                        print("登录lexue 失败")
                                                        completion(.failure(LexueLoginError.networkError))
                                                    }
                                                case .failure(_):
                                                    print("登录lexue 失败")
                                                    completion(.failure(LexueLoginError.networkError))
                                                }
                                            }
                                    } else {
                                        print("登录lexue 失败")
                                        completion(.failure(LexueLoginError.networkError))
                                    }
                                case .failure(_):
                                    print("登录lexue 失败")
                                    completion(.failure(LexueLoginError.networkError))
                                }
                            }
                    } else {
                        completion(.failure(LexueLoginError.noLocationHeader))
                    }
                case .failure(_):
                    print("GetLexueContext 失败")
                    completion(.failure(LexueLoginError.networkError))
                }
                
            }
    }
    
    func GetAllCourseList(_ lexueContext: LexueContext, sesskey: String) async -> Result<[CourseShortInfo],LexueAPIError> {
        var ret = [CourseShortInfo]()
        let serviceRet = await UniversalServiceCall(lexueContext, sesskey: sesskey, methodName: "core_course_get_enrolled_courses_by_timeline_classification", args: [
            "offset": 0,
            "limit": 0,
            "classification": "all",
            "sort": "fullname",
            "customfieldname": "",
            "customfieldvalue": ""
        ])
        if let data = serviceRet["data"] as? [String: Any], let courses = data["courses"] as? [[String: Any]] {
            for course in courses {
                if let course = course as? [String: Any] {
                    var cur = CourseShortInfo()
                    if let id = course["id"] as? Int {
                        cur.id = String(id)
                    } else {
                        continue
                    }
                    cur.fullname = course["fullname"] as? String
                    cur.shortname = course["shortname"] as? String
                    cur.idnumber = course["idnumber"] as? String
                    cur.summary = course["summary"] as? String
                    cur.summaryformat = course["summaryformat"] as? Int
                    cur.startdate = course["startdate"] as? Int
                    cur.enddate = course["enddate"] as? Int
                    cur.visible = course["visible"] as? Bool
                    cur.showactivitydates = course["showactivitydates"] as? Bool
                    cur.showcompletionconditions = course["showcompletionconditions"] as? Bool
                    cur.fullnamedisplay = course["fullnamedisplay"] as? String
                    cur.viewurl = course["viewurl"] as? String
                    cur.courseimage = course["courseimage"] as? String
                    cur.progress = course["progress"] as? Int
                    cur.hasprogress = course["hasprogress"] as? Bool
                    cur.isfavourite = course["isfavourite"] as? Bool
                    cur.hidden = course["hidden"] as? Bool
                    cur.showshortname = course["showshortname"] as? Bool
                    cur.coursecategory = course["coursecategory"] as? String
                    ret.append(cur)
                }
            }
        } else {
            return .failure(.unknowError)
        }
        return .success(ret)
    }
    
    func UniversalServiceCall(_ lexueContext: LexueContext, sesskey: String, methodName: String, args: [String: Any]) async -> [String: Any] {
        let data: [[String: Any]] = [[
            "index": 0,
            "methodname": methodName,
            "args": args
        ]]
        do {
            // 将字典转换为 JSON 数据
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            
            // 将 JSON 数据转换为字符串
            if String(data: jsonData, encoding: .utf8) != nil {
                var request = URLRequest(url: URL(string: "\(API_LEXUE_SERVICE_CALL)?sesskey=\(sesskey)")!)
                request.cachePolicy = .reloadIgnoringCacheData
                request.httpMethod = HTTPMethod.post.rawValue
                request.headers = GetLexueHeaders(lexueContext)
                request.httpBody = jsonData
                // https://stackoverflow.com/questions/68694917/convert-alamofire-completion-handler-to-async-await-swift-5-5
                let ret = await withCheckedContinuation { continuation in
                    AF.request(request).response { res in
                        switch res.result {
                        case .success(let data):
                            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]], json.count > 0 {
                                continuation.resume(returning: json[0])
                            } else {
                                print("无法将响应数据转换为字典")
                                continuation.resume(returning: [String: Any]())
                            }
                        case .failure(_):
                            print("请求servicecall 失败")
                            continuation.resume(returning: [String: Any]())
                        }
                    }
                }
                return ret
            } else {
                print("无法将 JSON 数据转换为字符串")
                return [String: Any]()
            }
        } catch {
            print("转换为 JSON 数据时发生错误: \(error)")
            return [String: Any]()
        }
    }
    
    
}
