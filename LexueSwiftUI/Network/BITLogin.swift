//
//  BITLogin.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/11.
//
import Foundation
import Alamofire
import SwiftSoup

struct LoginContext {
    var cookies: String = ""
    var execution: String = ""
    var encryptSalt: String = ""
}

struct LoginSuccessContext {
    var happyVoyagePersonal: String = ""
    var CASTGC: String = ""
    
}

enum LoginError: Error {
    case networkError
    case wrongPassword
    case wrongCaptcha
    case stopAccount
    case unknowError
}



// rewrite from https://github.com/BIT-BOBH/BITLogin-Node
class BITLogin {
    static let shared = BITLogin()
    var cookies: String = ""
    
    let API_INDEX = "https://login.bit.edu.cn/authserver/login"
    let API_CAPTCHA_GET = "https://login.bit.edu.cn/authserver/getCaptcha.htl"
    let API_CAPTCHA_CHECK = "https://login.bit.edu.cn/authserver/checkNeedCaptcha.htl"
    
    let headers = [
        "Referer": "https://login.bit.edu.cn/authserver/login",
        "Host": "login.bit.edu.cn",
        "Accept-Language": "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:103.0) Gecko/20100101 Firefox/103.0"
    ]
    
    func encryptAES(data: String, aesKey: String) -> String? {
        if aesKey.isEmpty {
            return data
        }
        let processedPasswd = randomString(len: 64) + data
        let key0 = aesKey
        let iv0 = randomString(len: 16)
        if let result = processedPasswd.aesCBCEncrypt(key0, iv: iv0) {
            return result.base64EncodedString(options: NSData.Base64EncodingOptions())
        } else {
            return nil
        }
    }

    func encryptPassword(pwd0: String, key: String) -> String {
        if let encryptedPassword = encryptAES(data: pwd0, aesKey: key) {
            return encryptedPassword
        }
        return pwd0
    }

    func randomString(len: Int) -> String {
        var retStr = ""
        for _ in 0..<len {
            // TODO: 添加真正的随机字符串保证安全性，现在调试方便
            retStr.append("A")
        }
        return retStr
    }
    
    func get_html_encSalt(_ html: String) -> String {
        do {
            let document = try SwiftSoup.parse(html)
            if let inputElement = try document.select("#pwdEncryptSalt").first() {
                // 获取输入元素的 name 属性值
                let nameAttribute = try inputElement.attr("value")
                return nameAttribute
            }
            return ""
        } catch {
            print("Error parsing HTML: \(error.localizedDescription)")
            return ""
        }
    }
    
    func get_html_execution(_ html: String) -> String {
        do {
            let document = try SwiftSoup.parse(html)
            if let inputElement = try document.select("#execution").first() {
                // 获取输入元素的 name 属性值
                let nameAttribute = try inputElement.attr("value")
                return nameAttribute
            }
            return ""
        } catch {
            print("Error parsing HTML: \(error.localizedDescription)")
            return ""
        }
    }
    
    func get_html_errorTip(_ html: String) -> String {
        do {
            let document = try SwiftSoup.parse(html)
            if let inputElement = try document.select("#showErrorTip").first() {
                // 获取输入元素的 name 属性值
                let nameAttribute = try inputElement.text()
                return nameAttribute
            }
            return ""
        } catch {
            print("Error parsing HTML: \(error.localizedDescription)")
            return ""
        }
    }
    private func get_cookie_key(_ cookie: String, _ keyValue: String) -> String {
        if let range = cookie.range(of: "\(keyValue)=") {
            let routeSubstring = cookie[range.upperBound...]
            let semicolonIndex = routeSubstring.firstIndex(of: ";") ?? routeSubstring.endIndex
            let keyValue = String(routeSubstring[..<semicolonIndex])
            return keyValue
        } else {
            return ""
        }
    }
    
    private func get_pour_cookie(_ cookie: String) -> String {
        let routeValue = get_cookie_key(cookie, "route")
        let JSESSIONIDValue = get_cookie_key(cookie, "JSESSIONID")
        return "route=\(routeValue); JSESSIONID=\(JSESSIONIDValue);"
    }
    
    func init_login_param(completion: @escaping (Result<LoginContext, Error>) -> Void ) {
        AF.requestWithoutCache(API_INDEX, method: .get, headers: HTTPHeaders(headers))
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    if let htmlString = String(data: data, encoding: .utf8), let ret_headers = response.response?.allHeaderFields as? [String: String]  {
                        if !ret_headers.keys.contains("Set-Cookie") {
                            completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                            return
                        }
                        var ret = LoginContext()
                        ret.cookies = self.get_pour_cookie(ret_headers["Set-Cookie"]!.replacingOccurrences(of: "HttpOnly", with: ""))
                        ret.execution = self.get_html_execution(htmlString)
                        ret.encryptSalt = self.get_html_encSalt(htmlString)
                        completion(.success(ret))
                    } else {
                        completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func get_captcha_data( context: LoginContext, completion: @escaping (Result<Data, Error>) -> Void) {
        var cur_headers = HTTPHeaders(headers)
        cur_headers.add(name: "Cookie", value: context.cookies)
        AF.requestWithoutCache(API_CAPTCHA_GET, method: .get, headers: cur_headers)
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    print("获取验证码图片数据失败 \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    func check_need_captcha(context: LoginContext, username: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        struct ResponseData: Codable {
            let isNeed: Bool
        }
        var cur_headers = HTTPHeaders(headers)
        cur_headers.add(name: "Cookie", value: context.cookies)
        let api_url = API_CAPTCHA_CHECK + "?username=\(username)&_=\(Date().timeIntervalSince1970)"
        AF.requestWithoutCache(api_url, method: .get, headers: cur_headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: ResponseData.self) { response in
                switch response.result {
                case .success(let responseData):
                    completion(.success(responseData.isNeed))
                case .failure(let error):
                    print("获取是否需要验证码失败：\(error)")
                    completion(.failure(error))
                }
            }
    }
    
    func do_login(context: LoginContext, username: String, password: String, captcha: String = "", completion: @escaping (Result<LoginSuccessContext, LoginError>) -> Void) {
        var cur_headers = HTTPHeaders(headers)
        cur_headers.add(name: "Cookie", value: context.cookies)
        let encryptedPassword = encryptPassword(pwd0: password, key: context.encryptSalt)
        let param: [String: Any] = [
            "username": username,
            "password": encryptedPassword,
            "captcha": captcha,
            "rememberMe": "true",
            "_eventId": "submit",
            "cllt": "userNameLogin",
            "dllt": "generalLogin",
            "lt": "",
            "execution": context.execution
        ]
        AF.requestWithoutCache(API_INDEX, method: .post, parameters: param, encoding: URLEncoding.default, headers: cur_headers)
            .validate(statusCode: 300..<500)
            .redirect(using: Redirector.doNotFollow)
            .response { response in
                switch response.result {
                case .success( _):
                    if let respCode = response.response?.statusCode {
                        if respCode == 302 {
                            // 登录成功
                            let respHeader = response.response?.allHeaderFields as? [String: String]
                            let Cookie = respHeader?["Set-Cookie"] ?? ""
                            var loginned_context = LoginSuccessContext()
                            loginned_context.CASTGC = self.get_cookie_key(Cookie, "CASTGC")
                            loginned_context.happyVoyagePersonal = self.get_cookie_key(Cookie, "happyVoyagePersonal")
                            completion(.success(loginned_context))
                        } else {
                            // 登录失败
                            if let data = response.data, let htmlString = String(data: data, encoding: .utf8) {
                                let reason_cn = self.get_html_errorTip(htmlString)
                                print("reason: \(reason_cn)")
                                if reason_cn.contains("账号或密码错误") {
                                    completion(.failure(.wrongPassword))
                                } else if reason_cn.contains("验证码错误") {
                                    completion(.failure(.wrongCaptcha))
                                } else if reason_cn.contains("该帐号已被冻结") {
                                    completion(.failure(.stopAccount))
                                }
                                else {
                                    completion(.failure(.unknowError))
                                }
                            } else {
                                completion(.failure(.unknowError))
                            }
                        }
                    } else {
                        completion(.failure(.networkError))
                    }
                case .failure( _):
                    completion(.failure(.networkError))
                }
            }
    }
}


