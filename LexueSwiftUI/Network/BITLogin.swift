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

// rewrite from https://github.com/BIT-BOBH/BITLogin-Node
class BITLogin {
    static let shared = BITLogin()
    var cookies: String = ""
    
    // 因为为了能够获取到lexue的session，所以必须导航到lexue上
    let API_INDEX = "https://login.bit.edu.cn/authserver/login?service=https%3A%2F%2Flexue.bit.edu.cn%2Flogin%2Findex.php"
    let headers = [
        "Referer": "https://login.bit.edu.cn/authserver/login",
        "Host": "login.bit.edu.cn",
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
    
    func init_login_param(completion: @escaping (Result<LoginContext, Error>) -> Void ) {
        AF.request(API_INDEX, method: .get, headers: HTTPHeaders(headers))
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    if let htmlString = String(data: data, encoding: .utf8), let headers = response.response?.allHeaderFields as? [String: String]  {
                        if !headers.keys.contains("Set-Cookie") {
                            completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                            return
                        }
                        var ret = LoginContext()
                        ret.cookies = headers["Set-Cookie"]!.replacingOccurrences(of: "HttpOnly", with: "")
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
}


