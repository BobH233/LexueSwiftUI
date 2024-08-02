//
//  Webvpn.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/9.
//

import Foundation
import Alamofire

/**
        提供校内外同时访问webvpn的能力
        用户无论在何处都可以随时通过webvpn访问内网服务
        登录过程是无感的
        换 BIT101 查成绩了
 */
class Webvpn {
    static let shared = Webvpn()
    
    let API_WEBVPN_TICK = "https://login.bit.edu.cn/authserver/login?service=https://webvpn.bit.edu.cn/login?cas_login=true"
    
    // 一个直接的反向代理，解决校内无法访问webvpn的问题...
    // 之前尝试过直接用 webvpn 解析出来的ip进行访问，但是有ssl验证问题死活解决不了，没办法...
    // TODO: 记得修改用户协议告知用户
    let WEBVPN_INDEX = "https://lexue.zendee.cn/"
    
    let BIT101_WEBVPN_INIT = "https://bit101.flwfdd.xyz/user/webvpn_verify_init"
    let BIT101_WEBVPN_VERIFY = "https://bit101.flwfdd.xyz/user/webvpn_verify"
    let BIT101_QUERY_SCORE = "https://bit101.flwfdd.xyz/score?detail=true"
    let BIT101_COURSE_HISTORY = "https://bit101.flwfdd.xyz/courses/histories"
    // ?search=100063122&order=new&page=0
    let BIT101_COURSE_SEARCH = "https://bit101.flwfdd.xyz/courses"
    // ?obj=course5932&order=default&page=0
    let BIT101_COURSE_COMMENTS = "https://bit101.flwfdd.xyz/reaction/comments"
    
    let WEBVPN_ORIGIN_DOMAIN = "webvpn.bit.edu.cn"
    let PROXY_WEBVPN_DOMAIN = "lexue.zendee.cn"
    
    struct WebvpnContext {
        var wengine_vpn_ticketwebvpn_bit_edu_cn: String = ""
    }
    
    enum WebvpnError: Error {
        case NetworkError
        case UnknowError
        case CannotGetTicket
        case NeedCaptcha
        case JsonConvertError
    }
    
    struct ScoreInfo: Identifiable, Hashable {
        var id: String {
            return courseId + index
        }
        var hash: String {
            // 用于统计成绩是否发生变化的hash值
            return "\(semester)_\(courseId)_\(courseName)_\(credit)_\(study_hours)_\(course_type)_\(my_score)_\(exam_type)_hash".sha256
        }
        
        // 序号
        var index: String = ""
        // 开课学期
        var semester: String = ""
        // 课程编号
        var courseId: String = ""
        // 课程名称
        var courseName: String = ""
        // 学分
        var credit: String = ""
        // 总学时
        var study_hours: String = ""
        // 课程性质
        var course_type: String = ""
        // 本人成绩
        var my_score: String = ""
        // 专业排名
        var my_grade_in_major: String = ""
        // 班级排名
        var my_grade_in_class: String = ""
        // 全部排名
        var my_grade_in_all: String = ""
        // 班级人数
        var class_study_count: String = ""
        // 学习人数
        var all_study_count: String = ""
        // 专业人数
        var major_study_count: String = ""
        // 平均分
        var avg_score: String = ""
        // 最高分
        var max_score: String = ""
        // 考试性质: 补考/正常考试/重考
        var exam_type: String = ""
        // 是否不计入成绩统计, 用于补考后覆盖
        var ignored_course: Bool = false
        // 是否是未读的新成绩, 用于高亮显示
        var is_unread_new_score: Bool = false
        // 成绩标识, 如果是缓考会在这里显示
        var score_tag: String = ""
        
        
        static func SemesterInt(semesterStr: String) -> Int {
            let segments = semesterStr.split(separator: "-")
            if segments.count != 3 {
                return 0
            }
            let first: Int = Int(segments[0]) ?? 0
            let second: Int = Int(segments[1]) ?? 0
            let third: Int = Int(segments[2]) ?? 0
            return first * 100000 + second * 10 + third
        }
    }
    
    func DiffScoreInfoAndUpdate(curScoreInfo: [ScoreInfo]) async -> [ScoreInfo] {
        // 如果数据库都是空的，那么就把所有hash都加进去，但是是已读状态
        // 如果数据库不是空的，那么就只加数据库里面没有的hash，并且是未读状态
        let curDate = Date.now
        var newScoreInfo: [ScoreInfo] = []
        await DataController.shared.container.performBackgroundTask { (bgContext) in
            let isEmptyDB = DataController.shared.isScoreDiffCacheEmpty(context: bgContext)
            if isEmptyDB {
                for score in curScoreInfo {
                    DataController.shared.addScoreDiffCache(context: bgContext, read: true, id: score.index, scoreHash: score.hash, scoreInMajor: score.my_grade_in_major, myScore: score.my_score, last_update: curDate, courseName: score.courseName, avgScore: score.avg_score)
                }
            } else {
                for score in curScoreInfo {
                    if !DataController.shared.isScoreDiffCacheExist(context: bgContext, scoreHash: score.hash) {
                        newScoreInfo.append(score)
                        DataController.shared.addScoreDiffCache(context: bgContext, read: false, id: score.index, scoreHash: score.hash, scoreInMajor: score.my_grade_in_major, myScore: score.my_score, last_update: curDate, courseName: score.courseName, avgScore: score.avg_score)
                    }
                }
            }
            DataController.shared.save(context: bgContext)
        }
        return newScoreInfo
    }
    
    func QueryScoreInfo(webvpn_context: WebvpnContext, auto_diff_score: Bool = true) async -> Result<[ScoreInfo], WebvpnError> {
        let header = [
            "Webvpn-Cookie": "wengine_vpn_ticketwebvpn_bit_edu_cn=\(webvpn_context.wengine_vpn_ticketwebvpn_bit_edu_cn); Path=/; Domain=webvpn.bit.edu.cn; HttpOnly",
            "User-Agent": "LexueHelper"
        ]
        var request = URLRequest(url: URL(string: BIT101_QUERY_SCORE)!)
        request.cachePolicy = .reloadIgnoringCacheData
        request.httpMethod = HTTPMethod.get.rawValue
        request.headers = HTTPHeaders(header)
        let ret = await withCheckedContinuation { continuation in
            AF.request(request).response { res in
                switch res.result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(_):
                    print("请求 bit101 失败")
                    continuation.resume(returning: nil)
                }
            }
        }
        if ret == nil {
            return .failure(.NetworkError)
        }
        var ret_scores = [ScoreInfo]()
        if let json = try? JSONSerialization.jsonObject(with: ret!, options: []) as? [String: Any], let data = json["data"] as? [[String]], data.count >= 1 {
            var attriMap = [String: Int]()
            for i in 0 ..< data[0].count {
                attriMap[data[0][i]] = i
            }
            // 确保每一个想要的属性都存在了
            let wantedAttri = ["开课学期", "课程名称", "课程编号", "成绩", "学分", "总学时", "课程性质", "本人成绩在专业中占", "本人成绩在班级中占", "本人成绩在所有学生中占", "班级人数", "学习人数", "专业人数", "平均分", "最高分", "序号", "考试性质", "成绩标识"]
            for attri in wantedAttri {
                if attriMap[attri] == nil {
                    // 没有返回全部需要的属性
                    return .failure(.NetworkError)
                }
            }
            for i in 1 ..< data.count {
                var currentCourse = ScoreInfo()
                currentCourse.index = data[i][attriMap["序号"]!]
                currentCourse.semester = data[i][attriMap["开课学期"]!]
                currentCourse.courseId = data[i][attriMap["课程编号"]!]
                currentCourse.courseName = data[i][attriMap["课程名称"]!]
                currentCourse.credit = data[i][attriMap["学分"]!]
                currentCourse.study_hours = data[i][attriMap["总学时"]!]
                currentCourse.course_type = data[i][attriMap["课程性质"]!]
                currentCourse.my_score = data[i][attriMap["成绩"]!]
                currentCourse.my_grade_in_major = data[i][attriMap["本人成绩在专业中占"]!]
                currentCourse.my_grade_in_class = data[i][attriMap["本人成绩在班级中占"]!]
                currentCourse.my_grade_in_all = data[i][attriMap["本人成绩在所有学生中占"]!]
                currentCourse.class_study_count = data[i][attriMap["班级人数"]!]
                currentCourse.all_study_count = data[i][attriMap["学习人数"]!]
                currentCourse.major_study_count = data[i][attriMap["专业人数"]!]
                currentCourse.avg_score = data[i][attriMap["平均分"]!]
                currentCourse.max_score = data[i][attriMap["最高分"]!]
                currentCourse.exam_type = data[i][attriMap["考试性质"]!]
                currentCourse.score_tag = data[i][attriMap["成绩标识"]!]
                ret_scores.append(currentCourse)
            }
            if auto_diff_score {
                await DiffScoreInfoAndUpdate(curScoreInfo: ret_scores)
            }
            return .success(ret_scores)
        } else {
            return .failure(.JsonConvertError)
        }
    }
    
    struct CourseHistoryScoreInfo {
        var term: String = ""
        var avg_score: Double = 0
        var max_score: Double = 0
        var student_num: Int = 0
    }
    
    func QueryCourseHistoryScoreInfo(courseId: String) async -> [CourseHistoryScoreInfo] {
        let header = [
            "User-Agent": "LexueHelper"
        ]
        var request = URLRequest(url: URL(string: "\(BIT101_COURSE_HISTORY)/\(courseId)")!)
        request.cachePolicy = .reloadIgnoringCacheData
        request.httpMethod = HTTPMethod.get.rawValue
        request.headers = HTTPHeaders(header)
        let ret = await withCheckedContinuation { continuation in
            AF.request(request).response { res in
                switch res.result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(_):
                    print("请求 bit101 失败")
                    continuation.resume(returning: nil)
                }
            }
        }
        if ret == nil {
            return []
        }
        var ret_scores = [CourseHistoryScoreInfo]()
        if let json = try? JSONSerialization.jsonObject(with: ret!, options: []) as? [[String: Any]] {
            for record in json {
                var current = CourseHistoryScoreInfo()
                guard let term = record["term"] as? String, let avg = record["avg_score"] as? Double, let maxv = record["max_score"] as? Double, let stu_num = record["student_num"] as? Int else {
                    continue
                }
                current.avg_score = avg
                current.max_score = maxv
                current.student_num = stu_num
                current.term = term
                ret_scores.append(current)
            }
        }
        return ret_scores
    }
    
    struct CourseSearchResult {
        // BIT101的id号
        var id: Int = 0
        // 课程编号
        var number: String = ""
        // 老师名字
        var teacherName: String = ""
        // 评价人数
        var comment_num: Int = 0
    }
    
    struct CourseComment {
        var comment_id: Int = 0
        var update_time: Date = .now
        var comment_text: String = ""
        var for_course_teacher: String = ""
        var rate: Int = 0
    }
    
    func GetCourseComments(courseId: String) async -> [CourseComment] {
        let header = [
            "User-Agent": "LexueHelper"
        ]
        var request = URLRequest(url: URL(string: "\(BIT101_COURSE_SEARCH)?search=\(courseId)&order=new&page=0")!)
        request.cachePolicy = .reloadIgnoringCacheData
        request.httpMethod = HTTPMethod.get.rawValue
        request.headers = HTTPHeaders(header)
        let ret = await withCheckedContinuation { continuation in
            AF.request(request).response { res in
                switch res.result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(_):
                    print("请求 bit101 失败")
                    continuation.resume(returning: nil)
                }
            }
        }
        if ret == nil {
            return []
        }
        var courses = [CourseSearchResult]()
        if let json = try? JSONSerialization.jsonObject(with: ret!, options: []) as? [[String: Any]] {
            for record in json {
                var current = CourseSearchResult()
                guard let id = record["id"] as? Int, let number = record["number"] as? String, let teachers_name = record["teachers_name"] as? String, let comment_num = record["comment_num"] as? Int else {
                    continue
                }
                if number != courseId {
                    continue
                }
                if comment_num == 0 {
                    continue
                }
                current.id = id
                current.number = number
                current.teacherName = teachers_name
                current.comment_num = comment_num
                courses.append(current)
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        var comments = [CourseComment]()
        for course in courses {
            var request = URLRequest(url: URL(string: "\(BIT101_COURSE_COMMENTS)?obj=course\(course.id)&order=default&page=0")!)
            request.cachePolicy = .reloadIgnoringCacheData
            request.httpMethod = HTTPMethod.get.rawValue
            request.headers = HTTPHeaders(header)
            let ret = await withCheckedContinuation { continuation in
                AF.request(request).response { res in
                    switch res.result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure(_):
                        print("请求 bit101 失败")
                        continuation.resume(returning: nil)
                    }
                }
            }
            if ret == nil {
                continue
            }
            if let json = try? JSONSerialization.jsonObject(with: ret!, options: []) as? [[String: Any]] {
                for record in json {
                    var current = CourseComment()
                    guard let update_time = record["create_time"] as? String, let text = record["text"] as? String, let rate = record["rate"] as? Int, let id = record["id"] as? Int else {
                        continue
                    }
                    current.comment_id = id
                    current.comment_text = text
                    current.for_course_teacher = course.teacherName
                    current.rate = rate
                    if let format_date = dateFormatter.date(from: update_time) {
                        current.update_time = format_date
                    } else if let format_date = dateFormatter2.date(from: update_time) {
                        current.update_time = format_date
                    } else {
                        print("无法转换")
                    }
                    comments.append(current)
                }
            }
        }
        return comments
    }
    
    func GetWebvpnContext(username: String, password: String) async -> Result<WebvpnContext, WebvpnError> {
        var ret_context = WebvpnContext()
        var init_param = [
            "sid": username
        ]
        let header_with_json_type = [
            "Content-Type": "application/json"
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: init_param, options: [])
            if String(data: jsonData, encoding: .utf8) != nil {
                var request = URLRequest(url: URL(string: BIT101_WEBVPN_INIT)!)
                request.headers = HTTPHeaders(header_with_json_type)
                request.cachePolicy = .reloadIgnoringCacheData
                request.httpMethod = HTTPMethod.post.rawValue
                request.httpBody = jsonData
                let ret = await withCheckedContinuation { continuation in
                    AF.request(request).response { res in
                        switch res.result {
                        case .success(let data):
                            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                                continuation.resume(returning: json)
                            } else {
                                print("无法将响应数据转换为字典")
                                continuation.resume(returning: [String: Any]())
                            }
                        case .failure(_):
                            print("请求 bit101_init 失败")
                            continuation.resume(returning: [String: Any]())
                        }
                    }
                }
                guard let cookie = ret["cookie"] as? String else {
                    return .failure(.NetworkError)
                }
                guard let captcha = ret["captcha"] as? String else {
                    return .failure(.NetworkError)
                }
                guard let salt = ret["salt"] as? String else {
                    return .failure(.NetworkError)
                }
                guard let execution = ret["execution"] as? String else {
                    return .failure(.NetworkError)
                }
                if captcha != "" {
                    return .failure(.NeedCaptcha)
                }
                let encryptedPassword = BITLogin.shared.encryptPassword(pwd0: password, key: salt)
                let param2 = [
                    "sid": username,
                    "password": encryptedPassword,
                    "execution": execution,
                    "cookie": cookie
                ]
                let jsonData2 = try JSONSerialization.data(withJSONObject: param2, options: [])
                guard let t = String(data: jsonData2, encoding: .utf8) else {
                    return .failure(.JsonConvertError)
                }
                var request2 = URLRequest(url: URL(string: BIT101_WEBVPN_VERIFY)!)
                request2.headers = HTTPHeaders(header_with_json_type)
                request2.cachePolicy = .reloadIgnoringCacheData
                request2.httpMethod = HTTPMethod.post.rawValue
                request2.httpBody = jsonData2
                let status_code = await withCheckedContinuation { continuation in
                    AF.request(request2).response { res in
                        switch res.result {
                        case .success(let data):
                            if let data_str = String(data: data!, encoding: .utf8) {
                                print(data_str)
                            }
                            continuation.resume(returning: res.response?.statusCode ?? -1)
                        case .failure(_):
                            print("请求 bit101_verify 失败")
                            continuation.resume(returning: -1)
                        }
                    }
                }
                print("status_code: \(status_code)")
                if status_code != 200 {
                    return .failure(.UnknowError)
                }
                ret_context.wengine_vpn_ticketwebvpn_bit_edu_cn = get_cookie_key(cookie, "wengine_vpn_ticketwebvpn_bit_edu_cn")
                return .success(ret_context)
            } else {
                return .failure(.JsonConvertError)
            }
        } catch {
            return .failure(.UnknowError)
        }
    }
    
    
    
}
