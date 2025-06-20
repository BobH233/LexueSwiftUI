//
//  JXZXehall.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/15.
//

import Foundation
import Alamofire
import SwiftUI

// 教学中心电子大厅，用于查询考试安排相关
class JXZXehall {
    static let shared = JXZXehall()
    
    // 用手机版获取Cookie方便一些
    let JXZX_INDEX = "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/*default/index.do"
    let API_JXZX_TICK = "https://sso.bit.edu.cn/cas/login?service=https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/*default/index.do#/"
    let API_JXZX_APP_INDEX = "https://jxzxehallapp.bit.edu.cn/jwapp/sys/mobilepub/res/sentry/wdksapMobile.do"
    // post
    let API_JXZX_APP_CONFIG = "https://jxzxehallapp.bit.edu.cn/jwapp/sys/mobilepub/getAppConfig/wdksapMobile.do"
    
    // 查询当前学期的信息, get
    let API_JXZX_GET_CURRENT_SEMESTER = "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/modules/ksap/cxdqxnxq.do"
    // 查询所有过往学期信息, get
    let API_JXZX_GET_ALL_SEMESTERS = "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/modules/ksap/xnxqcx.do?*order=-DM"
    // 查询某学期的已排考试信息, post
    // 表单 XNXQDM=2023-2024-1&*order=-KSRQ
    let API_JXZX_GET_ARRANGED_EXAM = "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/modules/ksap/cxxsksap.do"
    // 查询某学期未安排考试信息, post
    // 表单 XNXQDM=2023-2024-1
    let API_JXZX_GET_UNSCHEDULED_EXAM = "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/modules/ksap/cxapzjwaprw.do"
    
    // 查询某学期的日期信息，用于查询第一天post
    // 表单 requestParamStr={"XNXQDM":"2023-2024-2","ZC":"1"}
    let API_JXZX_GET_SEMESTER_DATE = "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdkbby/wdkbByController/cxzkbrq.do"
    // 查询某学期的课程表安排，post
    // 表单 XNXQDM=2023-2024-2
    let API_JXZX_GET_SEMESTER_SCHEDULED_COURSE = "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdkbby/modules/xskcb/cxxszhxqkb.do"
    
    let bit_login_header = [
        "Referer": "https://sso.bit.edu.cn/cas/login",
        "Host": "sso.bit.edu.cn",
        "Accept-Language": "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:103.0) Gecko/20100101 Firefox/103.0"
    ]
    let jxzx_header = [
        "Host": "jxzxehallapp.bit.edu.cn",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:103.0) Gecko/20100101 Firefox/103.0"
    ]
    
    struct JXZXContext {
        var GS_SESSIONID: String = ""
        var _WEU: String = ""
    }
    
    struct SemesterInfo {
        // 形如 2023-2024-1
        var semesterId: String = ""
        // 形如 2023-2024学年 1学期
        var semesterDescription: String = ""
    }
    
    // 未安排的考试信息
    struct UnscheduledExamInfo {
        // 课程名 KCM
        var courseName: String = ""
        // 课程号 KCH
        var courseId: String = ""
        // 老师名字 ZJJSXM
        var teacherName: String = ""
        // 考试类型 KHFSDM_DISPLAY  考查 考试之类的
        var examType: String = ""
    }
    
    // 考试信息
    struct ExamInfo {
        // 考试地点 JASMC
        var examLocation: String = ""
        // 考试时间 KSSJMS
        var examTime: String = ""
        // 考试类型 KSMC, 分散考试/考试周集中考试 等
        var examType: String = ""
        // 座位号 ZWH
        var seatIndex: String = ""
        // 课程名称 KCM
        var courseName: String = ""
        // 老师名称 ZJJSXM
        var teacherName: String = ""
        // 课程号 KCH
        var courseId: String = ""
        // 考试日期凌晨 KSRQ 格式 2023-06-20 00:00:00 用于判断考试是否已完成
        var examTimeMidnight: String = ""
        
        func GetExamStartDate() -> Date {
            let components = examTime.components(separatedBy: "-")
            if components.count == 4 {
                let datePart = "\(components[0])-\(components[1])-\(components[2])"
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                if let date = dateFormatter.date(from: datePart) {
                    return date
                } else {
                    return GetMidNightDate()
                }
            } else {
                return GetMidNightDate()
            }
        }
        
        func GetExamEndDate() -> Date {
            let components = examTime.components(separatedBy: "-")
            if components.count == 4 {
                let datePart = "\(components[0])-\(components[1])-\(components[2])"
                let onlyDayDate = datePart.components(separatedBy: " ")[0]
                let onlyEndTimeDate = components[3].components(separatedBy: "(")[0]
                let endTimeFull = "\(onlyDayDate) \(onlyEndTimeDate)"
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                if let date = dateFormatter.date(from: endTimeFull) {
                    return date
                } else {
                    return GetMidNightDate()
                }
            } else {
                return GetMidNightDate()
            }
        }
        
        func GetMidNightDate() -> Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let date = dateFormatter.date(from: examTimeMidnight) {
                return date
            } else {
                return .now
            }
        }
        
        // 判断考试是否是已完成的考试
        func IsFinished() -> Bool {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            if let date = dateFormatter.date(from: examTimeMidnight) {
//                if let oneDayLater = Calendar.current.date(byAdding: .day, value: 1, to: date) {
//                    return oneDayLater < Date.now
//                } else {
//                    return false
//                }
//            } else {
//                return false
//            }
            // 更新使用考试完成的时间逻辑
            return GetExamEndDate() < Date.now
        }
    }
    
    // 课程表上课程的信息
    struct ScheduleCourseInfo: Identifiable {
        var id = UUID()
        // KKDWDM_DISPLAY: 开课学院
        var KKDWDM_DISPLAY: String = ""
        // KCM: 课程名
        var CourseName: String = ""
        // SKJS: 授课老师名字
        var TeacherName: String = ""
        // SKZC: 课程所在的周数, 01串
        var ExistWeek: String = ""
        // JASMC: 上课的教室位置
        var ClassroomLocation: String = ""
        // YPSJDD: 上课的时间地点总字符串(e.g. "1-8周 星期三 6-7节 综教B302,1-8周 星期五 6-7节 综教B302")
        var ClassroomLocationTimeDes: String = ""
        // SKXQ: 上课星期，整数，1~7
        var DayOfWeek: Int = 1
        // KSJC: 开始节次，整数
        var StartSectionId: Int = 0
        // JSJC: 结束节次，整数
        var EndSectionId: Int = 0
        // XXXQMC: 校区
        var SchoolRegion: String = ""
        // KCH: 课程号
        var CourseId: String = ""
        // XF: 学分，整数
        var CourseCredit: Int = 0
        // KCXZDM_DISPLAY: 课程性质，选修，必修
        var CourseType: String = ""
        
        // 本地自定义属性，颜色
        var CourseBgColor: Color = .blue
        // 本地存储属性，开学时间
        var SemesterStartDate: Date = .now
        // 导入时间
        var ImportDate: Date = .now
        
        func GetSectionLength() -> Int {
            if EndSectionId >= StartSectionId {
                return EndSectionId - StartSectionId + 1
            }
            return 0
        }
        
        
        func GetDayOfWeekText() -> String {
            let text_arr = ["一","二","三","四","五","六","日"]
            if DayOfWeek >= 1 && DayOfWeek <= 7 {
                return text_arr[DayOfWeek-1]
            }
            return ""
        }
        
        func GetFullLocationText() -> String {
            return "\(SchoolRegion)\(ClassroomLocation)"
        }
        
    }
    
    enum JXZXError: Error {
        case NetworkError
        case UnknowError
        case CannotGetTicket
        case JsonConvertError
    }
    
    
    func GetUnscheduledExam(context: JXZXContext, semesterId: String) async -> Result<[UnscheduledExamInfo], JXZXError> {
        var cur_headers = HTTPHeaders(jxzx_header)
        cur_headers.add(name: "Referer", value: "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/*default/index.do")
        cur_headers.add(name: "Cookie", value: "GS_SESSIONID=\(context.GS_SESSIONID); _WEU=\(context._WEU)")
        let submitForm = [
            "XNXQDM": semesterId
        ]
        let retJson = await withCheckedContinuation { continuation in
            AF.requestWithoutCache(API_JXZX_GET_UNSCHEDULED_EXAM, method: .post, parameters: submitForm, encoding: URLEncoding.default, headers: cur_headers)
                .response { result in
                    switch result.result {
                    case .success(let data):
                        if data == nil {
                            print("无法将响应数据转换为字典")
                            continuation.resume(returning: [String: Any]())
                            return
                        }
                        if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            continuation.resume(returning: json)
                        } else {
                            print("无法将响应数据转换为字典")
                            continuation.resume(returning: [String: Any]())
                        }
                    case .failure(_):
                        print("请求 GetUnscheduledExam 失败")
                        continuation.resume(returning: [String: Any]())
                    }
                }
        }
        if let datas = retJson["datas"] as? [String: Any], let cxwapdksrw = datas["cxapzjwaprw"] as? [String: Any], let rows = cxwapdksrw["rows"] as? [[String: Any]], rows.count > 0 {
            var ret: [UnscheduledExamInfo] = []
            for row in rows {
                var currentRow = UnscheduledExamInfo()
                if let KHFSDM_DISPLAY = row["KHFSDM_DISPLAY"] as? String {
                    currentRow.examType = KHFSDM_DISPLAY
                }
                if let ZJJSXM = row["ZJJSXM"] as? String {
                    currentRow.teacherName = ZJJSXM
                }
                if let KCH = row["KCH"] as? String {
                    currentRow.courseId = KCH
                }
                if let KCM = row["KCM"] as? String {
                    currentRow.courseName = KCM
                }
                ret.append(currentRow)
            }
            return .success(ret)
        } else {
            return .failure(.JsonConvertError)
        }
    }
    
    func GetArrangedExam(context: JXZXContext, semesterId: String) async -> Result<[ExamInfo], JXZXError> {
        var cur_headers = HTTPHeaders(jxzx_header)
        cur_headers.add(name: "Referer", value: "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/*default/index.do")
        cur_headers.add(name: "Cookie", value: "GS_SESSIONID=\(context.GS_SESSIONID); _WEU=\(context._WEU)")
        let submitForm = [
            "XNXQDM": semesterId,
            "*order": "-KSRQ"
        ]
        let retJson = await withCheckedContinuation { continuation in
            AF.requestWithoutCache(API_JXZX_GET_ARRANGED_EXAM, method: .post, parameters: submitForm, encoding: URLEncoding.default, headers: cur_headers)
                .response { result in
                    switch result.result {
                    case .success(let data):
                        if data == nil {
                            print("无法将响应数据转换为字典")
                            continuation.resume(returning: [String: Any]())
                            return
                        }
                        if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            continuation.resume(returning: json)
                        } else {
                            print("无法将响应数据转换为字典")
                            continuation.resume(returning: [String: Any]())
                        }
                    case .failure(_):
                        print("请求 GetArrangedExam 失败")
                        continuation.resume(returning: [String: Any]())
                    }
                }
        }
        if let datas = retJson["datas"] as? [String: Any], let cxxsksap = datas["cxxsksap"] as? [String: Any], let rows = cxxsksap["rows"] as? [[String: Any]], rows.count > 0 {
            var ret: [ExamInfo] = []
            for row in rows {
                var currentRow = ExamInfo()
                if let JASMC = row["JASMC"] as? String {
                    currentRow.examLocation = JASMC
                }
                if let KSSJMS = row["KSSJMS"] as? String {
                    currentRow.examTime = KSSJMS
                }
                if let KSMC = row["KSMC"] as? String {
                    currentRow.examType = KSMC
                }
                if let ZWH = row["ZWH"] as? String {
                    currentRow.seatIndex = ZWH
                }
                if let KCM = row["KCM"] as? String {
                    currentRow.courseName = KCM
                }
                if let ZJJSXM = row["ZJJSXM"] as? String {
                    currentRow.teacherName = ZJJSXM
                }
                if let KCH = row["KCH"] as? String {
                    currentRow.courseId = KCH
                }
                if let KSRQ = row["KSRQ"] as? String {
                    currentRow.examTimeMidnight = KSRQ
                }
                ret.append(currentRow)
            }
            return .success(ret)
        } else {
            return .failure(.JsonConvertError)
        }
    }
    
    func GetAllSemesterInfo(context: JXZXContext) async -> Result<[SemesterInfo], JXZXError> {
        var cur_headers = HTTPHeaders(jxzx_header)
        cur_headers.add(name: "Referer", value: "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/*default/index.do")
        cur_headers.add(name: "Cookie", value: "GS_SESSIONID=\(context.GS_SESSIONID); _WEU=\(context._WEU)")
        let retJson = await withCheckedContinuation { continuation in
            AF.requestWithoutCache(API_JXZX_GET_ALL_SEMESTERS, method: .get, headers: cur_headers).response { res in
                switch res.result {
                case .success(let data):
                    if data == nil {
                        print("无法将响应数据转换为字典")
                        continuation.resume(returning: [String: Any]())
                        return
                    }
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        continuation.resume(returning: json)
                    } else {
                        print("无法将响应数据转换为字典")
                        continuation.resume(returning: [String: Any]())
                    }
                case .failure(_):
                    print("GetAllSemesterInfo 失败")
                    continuation.resume(returning: [String: Any]())
                }
            }
        }
        if let datas = retJson["datas"] as? [String: Any], let xnxqcx = datas["xnxqcx"] as? [String: Any], let rows = xnxqcx["rows"] as? [[String: Any]], rows.count > 0 {
            var ret: [SemesterInfo] = []
            for row in rows {
                var currentRow = SemesterInfo()
                if let DM = row["DM"] as? String {
                    currentRow.semesterId = DM
                }
                if let MC = row["MC"] as? String {
                    currentRow.semesterDescription = MC
                }
                ret.append(currentRow)
            }
            return .success(ret)
        } else {
            return .failure(.JsonConvertError)
        }
    }
    
    func GetCurrentSemesterInfo(context: JXZXContext) async -> Result<SemesterInfo, JXZXError> {
        var cur_headers = HTTPHeaders(jxzx_header)
        cur_headers.add(name: "Referer", value: "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/*default/index.do")
        cur_headers.add(name: "Cookie", value: "GS_SESSIONID=\(context.GS_SESSIONID); _WEU=\(context._WEU)")
        let retJson = await withCheckedContinuation { continuation in
            AF.requestWithoutCache(API_JXZX_GET_CURRENT_SEMESTER, method: .get, headers: cur_headers).response { res in
                switch res.result {
                case .success(let data):
                    if data == nil {
                        print("无法将响应数据转换为字典")
                        continuation.resume(returning: [String: Any]())
                        return
                    }
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        continuation.resume(returning: json)
                    } else {
                        print("无法将响应数据转换为字典")
                        continuation.resume(returning: [String: Any]())
                    }
                case .failure(_):
                    print("GetCurrentSemesterInfo 失败")
                    continuation.resume(returning: [String: Any]())
                }
            }
        }
        if let datas = retJson["datas"] as? [String: Any], let cxdqxnxq = datas["cxdqxnxq"] as? [String: Any], let rows = cxdqxnxq["rows"] as? [[String: Any]], rows.count > 0 {
            var ret = SemesterInfo()
            if let semesterId = rows[0]["DM"] as? String {
                ret.semesterId = semesterId
            }
            if let semesterDescription = rows[0]["MC"] as? String {
                ret.semesterDescription = semesterDescription
            }
            return .success(ret)
        } else {
            return .failure(.JsonConvertError)
        }
    }
    
    func GetUrlRetHead(url: String, header: HTTPHeaders = HTTPHeaders()) async -> [String: String] {
        print("getheader: ", url)
        return await withCheckedContinuation { continuation in
            AF.requestWithoutCache(url, method: .get, headers: header)
                .redirect(using: Redirector.doNotFollow)
                .response { response in
                    if let ret_headers = response.response?.allHeaderFields as? [String: String] {
                        continuation.resume(returning: ret_headers)
                    } else {
                        continuation.resume(returning: [:])
                    }
                }
        }
    }
    
    private func GetTicketLoginUrl(targetTicketUrl: String, loginnedContext: BITLogin.LoginSuccessContext) async -> String {
        var cur_headers = HTTPHeaders(bit_login_header)
        // 新的身份认证使用 SOURCEID_TGC 替代 CASTGC
        cur_headers.add(name: "Cookie", value: "SOURCEID_TGC=\(loginnedContext.CASTGC)")
        return await withCheckedContinuation { continuation in
            AF.requestWithoutCache(targetTicketUrl, method: .get, headers: cur_headers)
                .validate(statusCode: 300..<500)
                .redirect(using: Redirector.doNotFollow)
                .response { response in
                    switch response.result {
                    case .success(_):
                        if let ret_headers = response.response?.allHeaderFields as? [String: String], let login_url = ret_headers["Location"] {
                            continuation.resume(returning: login_url)
                        } else {
                            continuation.resume(returning: "")
                        }
                    case .failure(_):
                        continuation.resume(returning: "")
                    }
                }
        }
    }
    
    private func GetRealWEU(fakeWEU: String, GS_SESSIONID: String, origin: Bool, url: String, method: HTTPMethod) async -> String {
        var cur_headers = HTTPHeaders(jxzx_header)
        cur_headers.add(name: "Cookie", value: "GS_SESSIONID=\(GS_SESSIONID); _WEU=\(fakeWEU);")
        cur_headers.add(name: "Referer", value: "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/*default/index.do")
        if origin {
            cur_headers.add(name: "Origin", value: "https://jxzxehallapp.bit.edu.cn")
        }
        return await withCheckedContinuation { continuation in
            AF.requestWithoutCache(url, method: method, headers: cur_headers)
                .redirect(using: Redirector.doNotFollow)
                .response { response in
                    switch response.result {
                    case .success(_):
                        if let ret_headers = response.response?.allHeaderFields as? [String: String] {
                            if let cookie = ret_headers["Set-Cookie"] {
                                continuation.resume(returning: get_cookie_key(cookie, "_WEU"))
                            } else {
                                continuation.resume(returning: "")
                            }
                        } else {
                            continuation.resume(returning: "")
                        }
                    case .failure(let error):
                        print(error)
                        continuation.resume(returning: "")
                    }
                }
        }
    }
    
    func genCookieStr(cookieList: [String: String]) -> String {
        var ret = ""
        for (key, value) in cookieList {
            ret += "\(key)=\(value);"
        }
        return ret
    }
    
    private func UpdateCookieWithHeader(localCookie: [String: String], SetCookieStr: String) -> [String: String] {
        // 复制当前的 Cookie 字典以进行修改
        var updatedCookie = localCookie
        
        // 分割 Cookie 字符串来提取 Cookie 名称和值
        let components = SetCookieStr.components(separatedBy: ";").first // 只关注第一部分，忽略如 path, Httponly 等修饰符
        if let cookieComponent = components {
            // 进一步分割来获取具体的 Cookie 名称和值
            let keyValueArray = cookieComponent.components(separatedBy: "=")
            if keyValueArray.count == 2 { // 确保有名称和值
                let key = keyValueArray[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let value = keyValueArray[1].trimmingCharacters(in: .whitespacesAndNewlines)
                // 更新或添加 Cookie
                updatedCookie[key] = value
            }
        }
        
        return updatedCookie
    }
    
    // 获取 wdkbby 相关的 cookie
    func GetJXZXwdkbbyContext(loginnedContext: BITLogin.LoginSuccessContext) async -> Result<JXZXContext, JXZXError> {
        let ticketLoginUrl = await GetTicketLoginUrl(targetTicketUrl: "https://sso.bit.edu.cn/cas/login?service=https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdkbby/*default/index.do", loginnedContext: loginnedContext)
        if ticketLoginUrl.isEmpty {
            return .failure(.CannotGetTicket)
        }
        let first_cookie = await withCheckedContinuation { continuation in
            AF.requestWithoutCache(ticketLoginUrl, method: .get)
                .validate(statusCode: 300..<500)
                .redirect(using: Redirector.doNotFollow)
                .response { response1 in
                    switch response1.result {
                    case .success(_):
                        if let ret_headers = response1.response?.allHeaderFields as? [String: String], let cookie = ret_headers["Set-Cookie"] {
                            continuation.resume(returning: cookie)
                        } else {
                            continuation.resume(returning: "")
                        }
                    case .failure(_):
                        continuation.resume(returning: "")
                    }
                }
        }
//        print("firstCookie:", first_cookie)
        if first_cookie.isEmpty {
            return .failure(.CannotGetTicket)
        }
        var retContext = JXZXContext()
        retContext.GS_SESSIONID = get_cookie_key(first_cookie, "GS_SESSIONID")
        var second_cookie = await withCheckedContinuation { continuation in
            var cur_headers = HTTPHeaders(jxzx_header)
            cur_headers.add(name: "Cookie", value: "GS_SESSIONID=\(retContext.GS_SESSIONID)")
            AF.requestWithoutCache("https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdkbby/*default/index.do", method: .get, headers: cur_headers)
                .redirect(using: Redirector.doNotFollow)
                .response { response1 in
                    switch response1.result {
                    case .success(_):
                        if let ret_headers = response1.response?.allHeaderFields as? [String: String], let cookie = ret_headers["Set-Cookie"] {
                            continuation.resume(returning: cookie)
                        } else {
                            continuation.resume(returning: "")
                        }
                    case .failure(let error):
                        print(error     )
                        continuation.resume(returning: "")
                    }
                }
        }
        if second_cookie.isEmpty {
            return .failure(.CannotGetTicket)
        }
        if let range = second_cookie.range(of: "_WEU=") {
            second_cookie.replaceSubrange(range, with: "")
        }
        var tmpWEU = get_cookie_key(second_cookie, "_WEU")
//        print("GS_SESSIONID", retContext.GS_SESSIONID, "tmpWEU", tmpWEU)
        retContext._WEU = await GetRealWEU(fakeWEU: tmpWEU, GS_SESSIONID: retContext.GS_SESSIONID, origin: false, url: "https://jxzxehallapp.bit.edu.cn/jwapp/sys/funauthapp/api/getAppConfig/wdkbby-5959167891382285.do?v=09859374943354992", method: .get)
//        print(retContext)
        return .success(retContext)
    }
    
    // 获取 wdksapMobile 相关的 cookie
    func GetJXZXMobileContext(loginnedContext: BITLogin.LoginSuccessContext) async -> Result<JXZXContext, JXZXError> {
        let ticketLoginUrl = await GetTicketLoginUrl(targetTicketUrl: API_JXZX_TICK, loginnedContext: loginnedContext)
        if ticketLoginUrl.isEmpty {
            return .failure(.CannotGetTicket)
        }
        let first_cookie = await withCheckedContinuation { continuation in
            AF.requestWithoutCache(ticketLoginUrl, method: .get)
                .validate(statusCode: 300..<500)
                .redirect(using: Redirector.doNotFollow)
                .response { response1 in
                    switch response1.result {
                    case .success(_):
                        if let ret_headers = response1.response?.allHeaderFields as? [String: String], let cookie = ret_headers["Set-Cookie"] {
                            continuation.resume(returning: cookie)
                        } else {
                            continuation.resume(returning: "")
                        }
                    case .failure(_):
                        continuation.resume(returning: "")
                    }
                }
        }
        
        if first_cookie.isEmpty {
            return .failure(.CannotGetTicket)
        }
        var retContext = JXZXContext()
        retContext.GS_SESSIONID = get_cookie_key(first_cookie, "GS_SESSIONID")
        var second_cookie = await withCheckedContinuation { continuation in
            var cur_headers = HTTPHeaders(jxzx_header)
            cur_headers.add(name: "Cookie", value: "GS_SESSIONID=\(retContext.GS_SESSIONID)")
            AF.requestWithoutCache(JXZX_INDEX, method: .get, headers: cur_headers)
                .redirect(using: Redirector.doNotFollow)
                .response { response1 in
                    switch response1.result {
                    case .success(_):
                        if let ret_headers = response1.response?.allHeaderFields as? [String: String], let cookie = ret_headers["Set-Cookie"] {
                            continuation.resume(returning: cookie)
                        } else {
                            continuation.resume(returning: "")
                        }
                    case .failure(let error):
                        print(error     )
                        continuation.resume(returning: "")
                    }
                }
        }
        if second_cookie.isEmpty {
            return .failure(.CannotGetTicket)
        }
        // 只截取第二个_WEU
        if let range = second_cookie.range(of: "_WEU=") {
            second_cookie.replaceSubrange(range, with: "")
        }
        var tmpWEU = get_cookie_key(second_cookie, "_WEU")
        retContext._WEU = await GetRealWEU(fakeWEU: tmpWEU, GS_SESSIONID: retContext.GS_SESSIONID, origin: false, url: API_JXZX_APP_INDEX, method: .get)
        retContext._WEU = await GetRealWEU(fakeWEU: retContext._WEU, GS_SESSIONID: retContext.GS_SESSIONID, origin: true, url: API_JXZX_APP_CONFIG, method: .post)
        return .success(retContext)
    }
    
    // 返回 比如 2024-02-26
    func GetSemesterStartDate(context: JXZXContext, semesterId: String) async -> Result<String, JXZXError> {
        var cur_headers = HTTPHeaders(jxzx_header)
        cur_headers.add(name: "Referer", value: "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/*default/index.do")
        cur_headers.add(name: "Cookie", value: "GS_SESSIONID=\(context.GS_SESSIONID); _WEU=\(context._WEU)")
        let submitForm = [
            "requestParamStr": "{\"XNXQDM\":\"\(semesterId)\",\"ZC\":\"1\"}"
        ]
        let retJson = await withCheckedContinuation { continuation in
            AF.requestWithoutCache(API_JXZX_GET_SEMESTER_DATE, method: .post, parameters: submitForm, encoding: URLEncoding.default, headers: cur_headers)
                .response { result in
                    switch result.result {
                    case .success(let data):
                        if data == nil {
                            print("无法将响应数据转换为字典")
                            continuation.resume(returning: [String: Any]())
                            return
                        }
                        if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            continuation.resume(returning: json)
                        } else {
                            print("无法将响应数据转换为字典")
                            continuation.resume(returning: [String: Any]())
                        }
                    case .failure(_):
                        print("请求 GetSemesterStartDate 失败")
                        continuation.resume(returning: [String: Any]())
                    }
                }
        }
        if let data = retJson["data"] as? [[String: Any]] {
            for record in data {
                guard let XQ = record["XQ"] as? Int else {
                    continue
                }
                guard let RQ = record["RQ"] as? String else {
                    continue
                }
                if XQ == 1 {
                    return .success(RQ)
                }
            }
        }
        return .failure(.JsonConvertError)
    }
    
    func GetSemesterScheduleCourses(context: JXZXContext, semesterId: String) async -> Result<[ScheduleCourseInfo], JXZXError> {
        var cur_headers = HTTPHeaders(jxzx_header)
        cur_headers.add(name: "Referer", value: "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/*default/index.do")
        cur_headers.add(name: "Cookie", value: "GS_SESSIONID=\(context.GS_SESSIONID); _WEU=\(context._WEU)")
        let submitForm = [
            "XNXQDM": semesterId
        ]
        let retJson = await withCheckedContinuation { continuation in
            AF.requestWithoutCache(API_JXZX_GET_SEMESTER_SCHEDULED_COURSE, method: .post, parameters: submitForm, encoding: URLEncoding.default, headers: cur_headers)
                .response { result in
                    switch result.result {
                    case .success(let data):
                        if data == nil {
                            print("无法将响应数据转换为字典")
                            continuation.resume(returning: [String: Any]())
                            return
                        }
                        if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            continuation.resume(returning: json)
                        } else {
                            print("无法将响应数据转换为字典")
                            continuation.resume(returning: [String: Any]())
                        }
                    case .failure(_):
                        print("请求 GetSemesterScheduleCourses 失败")
                        continuation.resume(returning: [String: Any]())
                    }
                }
        }
        if let datas = retJson["datas"] as? [String: Any], let cxxszhxqkb = datas["cxxszhxqkb"] as? [String: Any], let rows = cxxszhxqkb["rows"] as? [[String: Any]], rows.count > 0 {
            var ret: [ScheduleCourseInfo] = []
            for row in rows {
                var currentRow = ScheduleCourseInfo()
                if let KKDWDM_DISPLAY = row["KKDWDM_DISPLAY"] as? String {
                    currentRow.KKDWDM_DISPLAY = KKDWDM_DISPLAY
                }
                if let CourseName = row["KCM"] as? String {
                    currentRow.CourseName = CourseName
                }
                if let TeacherName = row["SKJS"] as? String {
                    currentRow.TeacherName = TeacherName
                }
                if let ExistWeek = row["SKZC"] as? String {
                    currentRow.ExistWeek = ExistWeek
                }
                if let ClassroomLocation = row["JASMC"] as? String {
                    currentRow.ClassroomLocation = ClassroomLocation
                }
                if let ClassroomLocationTimeDes = row["YPSJDD"] as? String {
                    currentRow.ClassroomLocationTimeDes = ClassroomLocationTimeDes
                }
                if let DayOfWeek = row["SKXQ"] as? Int {
                    currentRow.DayOfWeek = DayOfWeek
                }
                if let StartSectionId = row["KSJC"] as? Int {
                    currentRow.StartSectionId = StartSectionId
                }
                if let EndSectionId = row["JSJC"] as? Int {
                    currentRow.EndSectionId = EndSectionId
                }
                if let SchoolRegion = row["XXXQMC"] as? String {
                    currentRow.SchoolRegion = SchoolRegion
                }
                if let CourseId = row["KCH"] as? String {
                    currentRow.CourseId = CourseId
                }
                if let CourseCredit = row["XF"] as? Int {
                    currentRow.CourseCredit = CourseCredit
                }
                if let CourseType = row["KCXZDM_DISPLAY"] as? String {
                    currentRow.CourseType = CourseType
                }
                ret.append(currentRow)
            }
            ret = ret.sorted { course1, course2 in
                return course1.CourseId > course2.CourseId
            }
            return .success(ret)
        } else {
            return .failure(.JsonConvertError)
        }
    }
}
