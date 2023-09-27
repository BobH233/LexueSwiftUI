//
//  Extensions.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/5.
//

import Foundation
import SwiftUI
import CommonCrypto
import Alamofire
import UIKit
import UserNotifications

// reference: https://stackoverflow.com/questions/43663622/is-a-date-in-same-week-month-year-of-another-date-in-swift
extension Date {

    func isEqual(to date: Date, toGranularity component: Calendar.Component) -> Bool {
        // 每个周星期一为开始周
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        return calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    var isInThisYear:  Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date() }
    var isInThePast:   Bool { self < Date() }
}

struct OnFirstAppearModifier: ViewModifier {
    let perform:() -> Void
    @State private var firstTime: Bool = true
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if firstTime {
                    firstTime = false
                    self.perform()
                }
            }
    }
}


extension View {
    func onFirstAppear( perform: @escaping () -> Void ) -> some View {
        return self.modifier(OnFirstAppearModifier(perform: perform))
    }
}

// reference https://www.jianshu.com/p/2437451484e9

internal extension Int {
    subscript(digitIndex: Int) -> Int {
        var decimalBase = 1
            for _ in 1...digitIndex {
                decimalBase *= 10
            }
        return (self / decimalBase) % 10
    }
}

internal extension UInt {
    subscript(digitIndex: Int) -> UInt {
        var decimalBase:UInt = 1
            for _ in 1...digitIndex {
                decimalBase *= 10
            }
            return (self / decimalBase) % 10
    }
}

internal extension UInt8 {
    subscript(digitIndex: Int) -> UInt8 {
        var decimalBase:UInt8 = 1
            for _ in 1...digitIndex {
                decimalBase *= 10
            }
            return (self / decimalBase) % 10
    }
}
internal extension Data {
    func hexadecimalString() -> String {
        let string = NSMutableString(capacity: count * 2)
        var byte: UInt8 = 0
        for i in 0 ..< count {
            copyBytes(to: &byte, from: i..<index(after: i))
            string.appendFormat("%02x", byte)
        }
        
        return string as String
    }
    var hexString : String {
        return self.hexadecimalString()
    }
    var base64String:String {
        return self.base64EncodedString(options: NSData.Base64EncodingOptions())
    }
    func arrayOfBytes() -> [UInt8] {
        let count = self.count / MemoryLayout<UInt8>.size
        var bytesArray = [UInt8](repeating: 0, count: count)
        (self as NSData).getBytes(&bytesArray, length:count * MemoryLayout<UInt8>.size)
        return bytesArray
    }
}
internal extension String {
    /// Array of UInt8
    var arrayOfBytes:[UInt8] {
        let data = self.data(using: String.Encoding.utf8)!
        return data.arrayOfBytes()
    }
    var bytes:UnsafeRawPointer{
        let data = self.data(using: String.Encoding.utf8)!
        return (data as NSData).bytes
    }
    func dataFromHexadecimalString() -> Data? {
        let trimmedString = self.trimmingCharacters(in: CharacterSet(charactersIn: "<> ")).replacingOccurrences(of: " ", with: "")
        
        guard let regex = try? NSRegularExpression(pattern: "^[0-9a-f]*$", options: NSRegularExpression.Options.caseInsensitive) else{
            return nil
        }
        let trimmedStringLength = trimmedString.lengthOfBytes(using: String.Encoding.utf8)
        let found = regex.firstMatch(in: trimmedString, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, trimmedStringLength))
        if found == nil || found?.range.location == NSNotFound || trimmedStringLength % 2 != 0 {
            return nil
        }
      
        var data = Data(capacity: trimmedStringLength / 2)
        
        for index in trimmedString.indices {
            let next_index = trimmedString.index(after: index)
            let byteString = String(trimmedString[index ..< next_index]) //trimmedString.substring(with: )
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            data.append(num)
        }
        return data
    }
}


internal extension Data {
    // MARK: cbc
    fileprivate func aesCBC(_ operation:CCOperation,key:String, iv:String? = nil) -> Data? {
        guard [16,24,32].contains(key.lengthOfBytes(using: String.Encoding.utf8)) else {
            return nil
        }
        let input_bytes = self.arrayOfBytes()
        let key_bytes = key.bytes
        var encrypt_length = Swift.max(input_bytes.count * 2, 16)
        var encrypt_bytes = [UInt8](repeating: 0,
                                    count: encrypt_length)
        
        let iv_bytes = (iv != nil) ? iv?.bytes : nil
        let status = CCCrypt(UInt32(operation),
                             UInt32(kCCAlgorithmAES128),
                             UInt32(kCCOptionPKCS7Padding),
                             key_bytes,
                             key.lengthOfBytes(using: String.Encoding.utf8),
                             iv_bytes,
                             input_bytes,
                             input_bytes.count,
                             &encrypt_bytes,
                             encrypt_bytes.count,
                             &encrypt_length)
        if status == Int32(kCCSuccess) {
            return Data(bytes: UnsafePointer<UInt8>(encrypt_bytes), count: encrypt_length)
        }
        return nil
    }
    
   fileprivate func aesCBCEncrypt(_ key:String,iv:String? = nil) -> Data? {
        return aesCBC(UInt32(kCCEncrypt), key: key, iv: iv)
    }
    
   fileprivate func aesCBCDecrypt(_ key:String,iv:String? = nil)->Data?{
        return aesCBC(UInt32(kCCDecrypt), key: key, iv: iv)
    }
}


internal extension String {
    // MARK: cbc
    func aesCBCEncrypt(_ key:String, iv:String? = nil) -> Data? {
        let data = self.data(using: String.Encoding.utf8)
        return data?.aesCBCEncrypt(key, iv: iv)
    }
    
    func aesCBCDecryptFromHex(_ key:String,iv:String? = nil) ->String?{
        let data = self.dataFromHexadecimalString()
        guard let raw_data = data?.aesCBCDecrypt(key, iv: iv) else{
            return nil
        }
        return String(data: raw_data, encoding: String.Encoding.utf8)
    }
    
    func aesCBCDecryptFromBase64(_ key:String, iv:String? = nil) ->String? {
        let data = Data(base64Encoded: self, options: NSData.Base64DecodingOptions())
        guard let raw_data = data?.aesCBCDecrypt(key, iv: iv) else{
            return nil
        }
        return String(data: raw_data, encoding: String.Encoding.utf8)
    }
}

// https://stackoverflow.com/questions/32199494/how-to-disable-caching-in-alamofire
extension Alamofire.Session{
    @discardableResult
    open func requestWithoutCache(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)// also you can add URLRequest.CachePolicy here as parameter
        -> DataRequest
    {
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: headers)
            urlRequest.cachePolicy = .reloadIgnoringCacheData // <<== Cache disabled
            // 不要让这个请求存储cookie，不然之后很麻烦
            urlRequest.httpShouldHandleCookies = false
            let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
            return request(encodedURLRequest)
        } catch {
            // TODO: find a better way to handle error
            print(error)
            return request(URLRequest(url: URL(string: "http://example.com/wrong_request")!))
        }
    }
}


func get_cookie_key(_ cookie: String, _ keyValue: String) -> String {
    if let range = cookie.range(of: "\(keyValue)=") {
        let routeSubstring = cookie[range.upperBound...]
        let semicolonIndex = routeSubstring.firstIndex(of: ";") ?? routeSubstring.endIndex
        let keyValue = String(routeSubstring[..<semicolonIndex])
        return keyValue
    } else {
        return ""
    }
}


extension UNNotificationAttachment {

    static func create(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier+".png"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            let imageData = UIImage.pngData(image)
            try imageData()?.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("error creating UIImage attachments: " + error.localizedDescription)
        }
        return nil
    }
}
