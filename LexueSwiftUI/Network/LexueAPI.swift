//
//  LexueAPI.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/12.
//

import Foundation
import Alamofire
import SwiftSoup




class LexueAPI {
    static let shared = LexueAPI()
    
    let API_LEXUE_TICK = "https://login.bit.edu.cn/authserver/login?service=https://lexue.bit.edu.cn/login/index.php"
    let API_LEXUE_SECOND_AUTH = "https://lexue.bit.edu.cn/login/index.php"
    let API_LEXUE_INDEX = "https://lexue.bit.edu.cn/"
    
    
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
    
    struct SelfUserInfo {
        var userId: String = ""
        var fullName: String = ""
        var firstAccessTime: String = ""
        var onlineUsers: String = ""
        var email: String = ""
        var stuId: String = ""
        var phone: String = ""
    }
    
    func GetSelfUserInfo(_ lexueContext: LexueContext) async -> Result<SelfUserInfo, Error> {
        var cur_headers = HTTPHeaders(headers1)
        cur_headers.add(name: "Cookie", value: "MoodleSession=\(lexueContext.MoodleSession);")
        print(cur_headers)
        var ret: SelfUserInfo = SelfUserInfo()
        let response = await AF.requestWithoutCache(API_LEXUE_INDEX, method: .get, headers: cur_headers).serializingString().response
        switch response.result {
        case .success(let data):
            print(data)
            return .success(ret)
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
                        print("login_url: \(login_url)")
                        AF.requestWithoutCache(login_url, method: .get)
                            .validate(statusCode: 300..<500)
                            .redirect(using: Redirector.doNotFollow)
                            .response { response1 in
                                switch response1.result {
                                case .success(_):
                                    if let ret_headers = response1.response?.allHeaderFields as? [String: String], let cookie = ret_headers["Set-Cookie"] {
                                        let firstMoodle = get_cookie_key(cookie, "MoodleSession")
                                        print("firstMoodle: \(cookie)")
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
}
