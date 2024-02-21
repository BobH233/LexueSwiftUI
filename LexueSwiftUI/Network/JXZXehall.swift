//
//  JXZXehall.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/15.
//

import Foundation
import Alamofire

// 教学中心电子大厅，用于查询考试安排相关
class JXZXehall {
    static let shared = JXZXehall()
    
    // 用手机版获取Cookie方便一些
    let JXZX_INDEX = "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/*default/index.do"
    let API_JXZX_TICK = "https://login.bit.edu.cn/authserver/login?service=https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/*default/index.do#/"
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
    let API_JXZX_GET_UNSCHEDULED_EXAM = "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdksapMobile/modules/ksap/cxwapdksrw.do"
    
    // 查询某学期的课程表安排，post
    // 表单 XNXQDM=2023-2024-2
    let API_JXZX_GET_SEMESTER_COURSE = "https://jxzxehallapp.bit.edu.cn/jwapp/sys/wdkbby/modules/xskcb/cxxszhxqkb.do"
    
    let bit_login_header = [
        "Referer": "https://login.bit.edu.cn/authserver/login",
        "Host": "login.bit.edu.cn",
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
    struct ScheduleCourseInfo {
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
        if let datas = retJson["datas"] as? [String: Any], let cxwapdksrw = datas["cxwapdksrw"] as? [String: Any], let rows = cxwapdksrw["rows"] as? [[String: Any]], rows.count > 0 {
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
    
    private func GetTicketLoginUrl(loginnedContext: BITLogin.LoginSuccessContext) async -> String {
        var cur_headers = HTTPHeaders(bit_login_header)
        cur_headers.add(name: "Cookie", value: "CASTGC=\(loginnedContext.CASTGC)")
        return await withCheckedContinuation { continuation in
            AF.requestWithoutCache(API_JXZX_TICK, method: .get, headers: cur_headers)
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
    
    func GetJXZXContext(loginnedContext: BITLogin.LoginSuccessContext) async -> Result<JXZXContext, JXZXError> {
        let ticketLoginUrl = await GetTicketLoginUrl(loginnedContext: loginnedContext)
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
}
