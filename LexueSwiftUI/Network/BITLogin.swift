//
//  BITLogin.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/11.
//

import CommonCrypto
import Foundation
import CommonCrypto

class BITLogin {
    static let shared = BITLogin()
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
}


