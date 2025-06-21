//
//  BITLogin.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/11.
//
import Foundation
import Alamofire
import SwiftSoup
import CommonCrypto
import CryptoSwift




// rewrite from https://github.com/BIT-BOBH/BITLogin-Node
class BITLogin {
    static let shared = BITLogin()
    var cookies: String = ""
    
    let API_INDEX = "https://sso.bit.edu.cn/cas/login"
    let API_CAPTCHA_GET = "https://sso.bit.edu.cn/cas/getCaptcha.htl"
    let API_CAPTCHA_CHECK = "https://sso.bit.edu.cn/cas/checkNeedCaptcha.htl"
    
    let headers = [
        "Referer": "https://sso.bit.edu.cn/cas/login",
        "Host": "sso.bit.edu.cn",
        "Accept-Language": "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:103.0) Gecko/20100101 Firefox/103.0"
    ]
    
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
        case cryptoError
    }
    
    func aesECBEncrypt(data: Data, key: Data) -> Data? {
        let keyLength = key.count
        guard [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256].contains(keyLength) else {
            return nil
        }

        var encryptedBytes = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
        var encryptedLength = 0

        let status = key.withUnsafeBytes { keyBytes in
            data.withUnsafeBytes { dataBytes in
                CCCrypt(
                    CCOperation(kCCEncrypt),
                    CCAlgorithm(kCCAlgorithmAES),
                    CCOptions(kCCOptionPKCS7Padding | kCCOptionECBMode),
                    keyBytes.baseAddress, keyLength,
                    nil, // IV for ECB is nil
                    dataBytes.baseAddress, data.count,
                    &encryptedBytes, encryptedBytes.count,
                    &encryptedLength
                )
            }
        }

        if status == kCCSuccess {
            return Data(bytes: encryptedBytes, count: encryptedLength)
        } else {
            return nil
        }
    }

    @available(*, deprecated, message: "This is the old encryption method for login.bit.edu.cn. Use encryptPasswordNew for sso.bit.edu.cn")
    func encryptPassword(pwd0: String, key: String) -> String {
        guard let keyData = Data(base64Encoded: key) else {
            return ""
        }
        let data: [UInt8] = Array(pwd0.utf8)
        let iv: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        do {
            let encrypted = try AES(key: keyData.bytes, blockMode: CBC(iv: iv), padding: .pkcs7).encrypt(data)
            return Data(encrypted).base64EncodedString()
        } catch {
            return ""
        }
    }

    func encryptPasswordNew(password: String, loginCrypto: String) -> String? {
        guard let keyData = Data(base64Encoded: loginCrypto) else {
            return nil
        }
        guard let passwordData = password.data(using: .utf8) else {
            return nil
        }

        if let encryptedData = aesECBEncrypt(data: passwordData, key: keyData) {
            return encryptedData.base64EncodedString()
        }
        
        return nil
    }
    
    func get_html_encSalt(_ html: String) -> String {
        do {
            let document = try SwiftSoup.parse(html)
            if let inputElement = try document.select("#login-croypto").first() {
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
    
    func get_html_execution(_ html: String) -> String {
        do {
            let document = try SwiftSoup.parse(html)
            if let inputElement = try document.select("#login-page-flowkey").first() {
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

    
    private func get_session_cookie(_ cookie: String) -> String {
        if let range = cookie.range(of: "SESSION=") {
            let substring = cookie[range.upperBound...]
            if let semicolonIndex = substring.firstIndex(of: ";") {
                return "SESSION=" + String(substring[..<semicolonIndex])
            } else {
                return "SESSION=" + String(substring)
            }
        }
        return ""
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
                        ret.cookies = self.get_session_cookie(ret_headers["Set-Cookie"]!.replacingOccurrences(of: "HttpOnly", with: ""))
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
        
        guard let encryptedPassword = encryptPasswordNew(password: password, loginCrypto: context.encryptSalt) else {
            completion(.failure(.cryptoError))
            return
        }
        
        guard let captchaPayload = encryptPasswordNew(password: "{}", loginCrypto: context.encryptSalt) else {
            completion(.failure(.cryptoError))
            return
        }

        let param: [String: Any] = [
            "username": username,
            "password": encryptedPassword,
            "execution": context.execution,
            "croypto": context.encryptSalt,
            "captcha_payload": captchaPayload,
            "type": "UsernamePassword",
            "geolocation": "",
            "captcha_code": captcha,
            "_eventId": "submit"
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
                            let allCookies = respHeader?["Set-Cookie"] ?? ""
                            var loginned_context = LoginSuccessContext()
                            loginned_context.CASTGC = get_cookie_key(allCookies, "SOURCEID_TGC")
                            loginned_context.happyVoyagePersonal = get_cookie_key(allCookies, "happyVoyagePersonal")
                            completion(.success(loginned_context))
                        } else {
                            // 登录失败
                            if let data = response.data, let htmlString = String(data: data, encoding: .utf8) {
                                let reason_cn = self.get_html_errorTip(htmlString)
                                print("reason: \(reason_cn)")
                                if reason_cn.contains("账号或密码错误") || reason_cn.contains("用户名或密码错误") {
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


