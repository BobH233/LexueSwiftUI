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
import SwiftSoup
import AudioToolbox
import CoreData

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


// https://blog.eidinger.info/from-hex-to-color-and-back-in-swiftui
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}


func GetHtmlText(_ html: String) -> String {
    do {
        let document = try SwiftSoup.parse(html)
        let text = try document.text()
        return text
    } catch {
        print("解析HTML出错：\(error)")
        return ""
    }
}

func GetFullDisplayTime(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy年M月d日 HH:mm"
    return dateFormatter.string(from: date)
}

// https://gist.github.com/swhitty/9be89dfe97dbb55c6ef0f916273bbb97
extension Task where Failure == Error {
    
    // Start a new Task with a timeout. If the timeout expires before the operation is
    // completed then the task is cancelled and an error is thrown.
    init(priority: TaskPriority? = nil, timeout: TimeInterval, operation: @escaping @Sendable () async throws -> Success) {
        self = Task(priority: priority) {
            try await withThrowingTaskGroup(of: Success.self) { group -> Success in
                group.addTask(operation: operation)
                group.addTask {
                    try await _Concurrency.Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                    throw TimeoutError()
                }
                guard let success = try await group.next() else {
                    throw _Concurrency.CancellationError()
                }
                group.cancelAll()
                return success
            }
        }
    }
}

private struct TimeoutError: LocalizedError {
    var errorDescription: String? = "Task timed out before completion"
}


// https://www.youtube.com/watch?v=FV_3kiRF90g&ab_channel=FlowritesCode
public extension URL {
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("无法创建 \(appGroup) 的URL")
        }
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}


func GetDateDescriptionText(sendDate: Date) -> String {
    let today = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "zh-CN")
    if sendDate.isInSameDay(as: today) {
        dateFormatter.dateFormat = "今天 HH:mm"
        return dateFormatter.string(from: sendDate)
    } else if Calendar.current.isDateInYesterday(sendDate) {
        dateFormatter.dateFormat = "昨天 HH:mm"
        return dateFormatter.string(from: sendDate)
    } else if Calendar.current.isDateInTomorrow(sendDate) {
        dateFormatter.dateFormat = "明天 HH:mm"
        return dateFormatter.string(from: sendDate)
    } else if sendDate.isInSameWeek(as: today) {
        dateFormatter.dateFormat = "EEEE HH:mm"
        return dateFormatter.string(from: sendDate)
    } else if sendDate.isInSameYear(as: today) {
        dateFormatter.dateFormat = "MM-dd HH:mm"
        return dateFormatter.string(from: sendDate)
    } else {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: sendDate)
    }
}

func GetDatePeriodDescriptionText(starttime: Date, endtime: Date) -> String {
    if starttime.isInSameDay(as: endtime) {
        // 如果是同一天，后面部分不必带上是哪一天
        let begin_text = GetDateDescriptionText(sendDate: starttime)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh-CN")
        dateFormatter.dateFormat = "HH:mm"
        return begin_text + " ~ " + dateFormatter.string(from: endtime)
    } else {
        return GetDateDescriptionText(sendDate: starttime) + " ~ " + GetDateDescriptionText(sendDate: endtime)
    }
}


extension String {
    var sha256: String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
}


func VibrateOnce() {
    AudioServicesPlaySystemSound(1519)
}

func VibrateTwice() {
    AudioServicesPlaySystemSound(1102)
}


// https://www.williamkurniawan.com/blog/take-a-screenshot-in-swiftui
extension View {
    func snapshot(origin: CGPoint = .zero, size: CGSize = .zero) -> UIImage {
        autoreleasepool {
            let controller = UIHostingController(rootView: self)
            let view = controller.view
            
            let targetSize = size == .zero ? controller.view.intrinsicContentSize : size
            view?.backgroundColor = .clear
            view?.bounds = CGRect(origin: origin, size: targetSize)
            
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            
            return renderer.image { _ in
                view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            }
        }
    }
}

extension String {
    func GuardNotEmpty() -> String {
        if self.isEmpty {
            return "无"
        } else {
            return self
        }
    }
}



extension NSPersistentContainer {
    func backgroundContext() -> NSManagedObjectContext {
        let context = newBackgroundContext()
        context.transactionAuthor = "LexueSwiftUI"
        return context
    }
}




// 底部多级的抽屉sheet

@available(iOS 15.0, *)
@available(iOSApplicationExtension, unavailable)
extension View {
    @ViewBuilder
    func bottomSheet15<Content: View> (
        isPresented: Binding<Bool>,
        dragIndicator: Visibility = .visible,
        sheetCornerRadius: CGFloat?,
        largestUndimmedIdentifier: UISheetPresentationController.Detent.Identifier = .large,
        isTransparentBG: Bool = false,
        interactiveDisabled: Bool = true,
        @ViewBuilder content: @escaping () -> Content,
        onDismiss: @escaping () -> ()
    ) -> some View {
        self
            .sheet(isPresented: isPresented) {
                onDismiss()
            } content: {
                content()
                    .interactiveDismissDisabled(interactiveDisabled)
                    .onAppear {
                        guard let windows = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                            return
                        }
                        if let controller = windows.windows.first?.rootViewController?.presentedViewController, let sheet = controller.presentationController as? UISheetPresentationController {
                            sheet.detents = [
                                .medium(),
                                .large()
                            ]
                            if isTransparentBG {
                                controller.view.backgroundColor = .clear
                            }
                            sheet.prefersGrabberVisible = true
                            controller.presentingViewController?.view.tintAdjustmentMode = .normal
                            sheet.largestUndimmedDetentIdentifier = largestUndimmedIdentifier
                            sheet.preferredCornerRadius = sheetCornerRadius
                        } else {
                            print("NO CONTROLLER")
                        }
                    }
            }
    }
}

@available(iOS 16.0, *)
@available(iOSApplicationExtension, unavailable)
extension View {
    @ViewBuilder
    func bottomSheet<Content: View> (
        presentationDetents: Set<PresentationDetent>,
        isPresented: Binding<Bool>,
        dragIndicator: Visibility = .visible,
        sheetCornerRadius: CGFloat?,
        largestUndimmedIdentifier: UISheetPresentationController.Detent.Identifier = .large,
        isTransparentBG: Bool = false,
        interactiveDisabled: Bool = true,
        @ViewBuilder content: @escaping () -> Content,
        onDismiss: @escaping () -> ()
    ) -> some View {
        self
            .sheet(isPresented: isPresented) {
                onDismiss()
            } content: {
                content()
                    .presentationDetents(presentationDetents)
                    .presentationDragIndicator(dragIndicator)
                    .interactiveDismissDisabled(interactiveDisabled)
                    .onAppear {
                        guard let windows = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                            return
                        }
                        if let controller = windows.windows.first?.rootViewController?.presentedViewController, let sheet = controller.presentationController as? UISheetPresentationController {
                            if isTransparentBG {
                                controller.view.backgroundColor = .clear
                            }
                            controller.presentingViewController?.view.tintAdjustmentMode = .normal
                            sheet.largestUndimmedDetentIdentifier = largestUndimmedIdentifier
                            sheet.preferredCornerRadius = sheetCornerRadius
                        } else {
                            print("NO CONTROLLER")
                        }
                    }
            }
    }
}

extension String {
    func DashIfEmpty() -> String {
        if self.isEmpty {
            return "-"
        } else {
            return self
        }
    }
}
