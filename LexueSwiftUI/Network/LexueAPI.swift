//
//  LexueAPI.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/12.
//

import Foundation
import Alamofire
import SwiftSoup



// rewrite from https://github.com/BIT-BOBH/LexueAPI
class LexueAPI {
    static let shared = LexueAPI()
    
    let API_LEXUE_TICK = "https://sso.bit.edu.cn/cas/login?service=https://lexue.bit.edu.cn/login/index.php"
    let API_LEXUE_SECOND_AUTH = "https://lexue.bit.edu.cn/login/index.php"
    let API_LEXUE_INDEX = "https://lexue.bit.edu.cn/"
    let API_LEXUE_DETAIL_INFO = "https://lexue.bit.edu.cn/user/edit.php"
    let API_LEXUE_SERVICE_CALL = "https://lexue.bit.edu.cn/lib/ajax/service.php"
    let API_LEXUE_PROFILE = "https://lexue.bit.edu.cn/user/profile.php"
    let API_LEXUE_VIEW_COURSE = "https://lexue.bit.edu.cn/course/view.php"
    
    let headers = [
        "Referer": "https://sso.bit.edu.cn/cas/login",
        "Host": "sso.bit.edu.cn",
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
    
    enum LexueAPIError: Error {
        case unknowError
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
    
    struct EditProfileParam {
        var course: String = ""
        var id: String = ""
        var returnto: String = "profile"
        var mform_isexpanded_id_moodle_picture: String = ""
        var sesskey: String = ""
        var _qf__user_edit_form: String = ""
        var mform_isexpanded_id_moodle: String = ""
        var mform_isexpanded_id_moodle_additional_names: String = ""
        var mform_isexpanded_id_moodle_optional: String = ""
        var mform_isexpanded_id_category_1: String = ""
        var email: String = ""
        var maildisplay: String = ""
        var city: String = ""
        var country: String = ""
        var timezone: String = ""
        var theme: String = ""
        var description_editor_text_: String = ""
        var description_editor_format_: String = ""
        var description_editor_itemid_: String = ""
        var firstnamephonetic: String = ""
        var lastnamephonetic: String = ""
        var middlename: String = ""
        var alternatename: String = ""
        var institution: String = ""
        var department: String = ""
        var phone1: String = ""
        var phone2: String = ""
        var address: String = ""
        var profile_field_icq: String = ""
        var profile_field_skype: String = ""
        var profile_field_aim: String = ""
        var profile_field_yahoo: String = ""
        var profile_field_msn: String = ""
        var profile_field_url: String = ""
        var submitbutton: String = ""
    }
    
    struct CourseSectionAvtivity {
        var url: String?
        var access: String?
        var name: String?
        var contentwithoutlink: String?
        var contentafterlink: String?
    }
    
    struct CourseSectionInfo: Identifiable {
        var id = UUID()
        var name: String?
        var url: String?
        var summary: String?
        var summaryText: String?
        var sectionId: String?
        var current: Bool = false
        // 暂时没用，没加载
        var activities: [CourseSectionAvtivity] = [CourseSectionAvtivity]()
        // 文件、作业、帖子、编程练习、测验数目
        var file_cnt: Int?
        var assignment_cnt: Int?
        var forum_cnt: Int?
        var coding_cnt: Int?
        var test_cnt: Int?
        // 显示的完成进度
        var progress_finish: Int?
        var progress_total: Int?
    }
    
    struct CourseMemberInfo: Identifiable {
        var id = UUID()
        var role: String?
        var href: String?
        var name: String?
        var group: String?
    }
    
    struct EventInfo: Identifiable {
        var id: String = ""
        var name: String?
        var description: String?
        var descriptionformat: Int?
        var location: String?
        var component: String?
        var modulename: String?
        // 如果是作业，那么这个就是作业编号
        var instance: Int?
        var eventtype: String?
        // 实际上就是ddl到期时间
        var timestart: Date?
        var timeusermidnight: Date?
        var course: CourseShortInfo?
        // 操作指向的url，目前看到的只有添加作业的选项
        var action_url: String?
        // 作业的链接
        var url: String?
        // 这是作业开启提交的时间
        var mindaytimestamp: Date?
    }
    
    struct LexueNotification: Identifiable {
        var id: String = ""
        var useridfrom: String = ""
        var useridto: String = ""
        var subject: String?
        var shortenedsubject: String?
        var text: String?
        var fullmessage: String?
        var fullmessagehtml: String?
        var smallmessage: String?
        // 如果是作业，指向作业链接
        var contexturl: String?
        var contexturlname: String?
        var timecreated: Date?
        var timeread: Date?
        var read: Bool?
        var component: String?
        var eventtype: String?
        var customdata: String?
    }
    
    func GetPopupNotifications(_ lexueContext: LexueContext, sesskey: String, selfUserId: String, retry: Bool = true) async -> Result<[LexueNotification], LexueAPIError> {
        let serviceRet = await UniversalServiceCall(lexueContext, sesskey: sesskey, methodName: "message_popup_get_popup_notifications", args: [
            "limit": 20,
            "offset": 0,
            "useridto": selfUserId,
        ])
        if let data = serviceRet["data"] as? [String: Any], let notifications = data["notifications"] as? [[String: Any]] {
            var ret = [LexueNotification]()
            for notification in notifications {
                var curNotification = LexueNotification()
                curNotification.id = String((notification["id"] as? Int) ?? -1)
                curNotification.useridfrom = String((notification["useridfrom"] as? Int) ?? -1)
                curNotification.useridto = String((notification["useridto"] as? Int) ?? -1)
                curNotification.subject = notification["subject"] as? String
                curNotification.shortenedsubject = notification["shortenedsubject"] as? String
                curNotification.text = notification["text"] as? String
                curNotification.fullmessage = notification["fullmessage"] as? String
                curNotification.fullmessagehtml = notification["fullmessagehtml"] as? String
                curNotification.smallmessage = notification["smallmessage"] as? String
                curNotification.contexturl = notification["contexturl"] as? String
                curNotification.contexturlname = notification["contexturlname"] as? String
                if let timecreated = notification["timecreated"] as? Int {
                    curNotification.timecreated = Date(timeIntervalSince1970: TimeInterval(timecreated))
                }
                if let timeread = notification["timeread"] as? Int {
                    curNotification.timeread = Date(timeIntervalSince1970: TimeInterval(timeread))
                }
                curNotification.read = notification["read"] as? Bool
                curNotification.component = notification["component"] as? String
                curNotification.eventtype = notification["eventtype"] as? String
                curNotification.customdata = notification["customdata"] as? String
                ret.append(curNotification)
            }
            return .success(ret)
        } else {
            if retry {
                let result = await GetSessKey(GlobalVariables.shared.cur_lexue_context)
                switch result {
                case .success(let (sesskey, new_context)):
                    DispatchQueue.main.async {
                        GlobalVariables.shared.cur_lexue_sessKey = sesskey
                    }
                    return await GetPopupNotifications(new_context == nil ? lexueContext : new_context!, sesskey: sesskey, selfUserId: selfUserId, retry: false)
                case .failure(_):
                    return .failure(.unknowError)
                }
            } else {
                return .failure(.unknowError)
            }
        }
    }
    
    func ParseCourseMembersHtml(_ html: String) -> [CourseMemberInfo] {
        var ret = [CourseMemberInfo]()
        do {
            let doc = try SwiftSoup.parse(html)
            let tbody = try doc.select("tbody")
            let memberElems = try tbody.select("tr")
            for member in memberElems {
                var curMember = CourseMemberInfo()
                var cnt = 0
                let aElem = try member.select("a")
                if aElem.count > 0 {
                    curMember.href = try aElem.attr("href")
                    curMember.name = try aElem.text().trimmingCharacters(in: .whitespacesAndNewlines)
                    if !(curMember.name ?? "").isEmpty {
                        curMember.name = curMember.name?.replacingOccurrences(of: " ", with: "")
                        cnt += 1
                    }
                }
                let tdElements = try member.select("td")
                if tdElements.count >= 2 {
                    curMember.role = try tdElements[0].text().trimmingCharacters(in: .whitespacesAndNewlines)
                    curMember.group = try tdElements[1].text().trimmingCharacters(in: .whitespacesAndNewlines)
                    if !(curMember.group ?? "").isEmpty || !(curMember.role ?? "").isEmpty {
                        cnt += 1
                    }
                }
                if cnt > 0 {
                    ret.append(curMember)
                }
            }
        } catch {
            print(error.localizedDescription)
            print("解析课程参与人发生错误")
        }
        return ret
    }
    
    // 优化请求次数
    func GetEventsByMonth(_ lexueContext: LexueContext, sesskey: String, year: String, month: String, retry: Bool = true) async throws -> Result<[EventInfo], LexueAPIError> {
        print("fetching \(year).\(month) events")
        let serviceRet = await UniversalServiceCall(lexueContext, sesskey: sesskey, methodName: "core_calendar_get_calendar_monthly_view", args: [
            "courseid": 1,
            "day": 1,
            "month": month,
            "year": year
        ])
        var ret = [EventInfo]()
        try Task.checkCancellation()
        if let data = serviceRet["data"] as? [String: Any], let weeks = data["weeks"] as? [[String: Any]] {
            for week in weeks {
                if let days = week["days"] as? [[String: Any]] {
                    for day in days {
                        if let events = day["events"] as? [[String: Any]] {
                            for event in events {
                                var curEvent = EventInfo()
                                curEvent.id = String((event["id"] as? Int) ?? -1)
                                curEvent.name = event["name"] as? String
                                curEvent.description = event["description"] as? String
                                curEvent.descriptionformat = event["descriptionformat"] as? Int
                                curEvent.location = event["location"] as? String
                                curEvent.component = event["component"] as? String
                                curEvent.modulename = event["modulename"] as? String
                                curEvent.instance = event["instance"] as? Int
                                curEvent.eventtype = event["eventtype"] as? String
                                if let timestart = event["timestart"] as? Int {
                                    curEvent.timestart = Date(timeIntervalSince1970: TimeInterval(timestart))
                                }
                                if let timeusermidnight = event["timeusermidnight"] as? Int {
                                    curEvent.timeusermidnight = Date(timeIntervalSince1970: TimeInterval(timeusermidnight))
                                }
                                if let course = event["course"] as? [String: Any] {
                                    curEvent.course = ParseCourseObject(course: course)
                                }
                                if let action = event["action"] as? [String: Any], let action_url = action["url"] as? String {
                                    curEvent.action_url = action_url
                                }
                                curEvent.url = event["url"] as? String
                                if let mindaytimestamp = event["mindaytimestamp"] as? Int {
                                    curEvent.mindaytimestamp = Date(timeIntervalSince1970: TimeInterval(mindaytimestamp))
                                }
                                ret.append(curEvent)
                            }
                        }
                    }
                }
            }
            return .success(ret)
        } else {
            if retry {
                let result = await GetSessKey(GlobalVariables.shared.cur_lexue_context)
                switch result {
                case .success(let (sesskey, new_context)):
                    DispatchQueue.main.async {
                        GlobalVariables.shared.cur_lexue_sessKey = sesskey
                    }
                    return try await GetEventsByMonth(new_context == nil ? lexueContext : new_context!, sesskey: sesskey, year: year, month: month, retry: false)
                case .failure(_):
                    return .failure(.unknowError)
                }
            } else {
                return .failure(.unknowError)
            }
        }
    }
    
    func GetEventsByDay(_ lexueContext: LexueContext, sesskey: String, year: String, month: String, day: String, retry: Bool = true) async throws -> Result<[EventInfo], LexueAPIError> {
        // print("fetching \(year).\(month).\(day) events")
        let serviceRet = await UniversalServiceCall(lexueContext, sesskey: sesskey, methodName: "core_calendar_get_calendar_day_view", args: [
            "courseid": 1,
            "day": day,
            "month": month,
            "year": year
        ])
        try Task.checkCancellation()
        if let data = serviceRet["data"] as? [String: Any], let events = data["events"] as? [[String: Any]] {
            var ret = [EventInfo]()
            for event in events {
                var curEvent = EventInfo()
                curEvent.id = String((event["id"] as? Int) ?? -1)
                curEvent.name = event["name"] as? String
                curEvent.description = event["description"] as? String
                curEvent.descriptionformat = event["descriptionformat"] as? Int
                curEvent.location = event["location"] as? String
                curEvent.component = event["component"] as? String
                curEvent.modulename = event["modulename"] as? String
                curEvent.instance = event["instance"] as? Int
                curEvent.eventtype = event["eventtype"] as? String
                if let timestart = event["timestart"] as? Int {
                    curEvent.timestart = Date(timeIntervalSince1970: TimeInterval(timestart))
                }
                if let timeusermidnight = event["timeusermidnight"] as? Int {
                    curEvent.timeusermidnight = Date(timeIntervalSince1970: TimeInterval(timeusermidnight))
                }
                if let course = event["course"] as? [String: Any] {
                    curEvent.course = ParseCourseObject(course: course)
                }
                if let action = event["action"] as? [String: Any], let action_url = action["url"] as? String {
                    curEvent.action_url = action_url
                }
                curEvent.url = event["url"] as? String
                if let mindaytimestamp = event["mindaytimestamp"] as? Int {
                    curEvent.mindaytimestamp = Date(timeIntervalSince1970: TimeInterval(mindaytimestamp))
                }
                ret.append(curEvent)
            }
            return .success(ret)
        } else {
            if retry {
                let result = await GetSessKey(GlobalVariables.shared.cur_lexue_context)
                switch result {
                case .success(let (sesskey, new_context)):
                    DispatchQueue.main.async {
                        GlobalVariables.shared.cur_lexue_sessKey = sesskey
                    }
                    return try await GetEventsByDay(new_context == nil ? lexueContext : new_context!, sesskey: sesskey, year: year, month: month, day: day, retry: false)
                case .failure(_):
                    return .failure(.unknowError)
                }
            } else {
                return .failure(.unknowError)
            }
        }
    }
    
    func GetCourseMembersInfo(_ lexueContext: LexueContext, sesskey: String, courseId: String, retry: Bool = true) async -> Result<[CourseMemberInfo], LexueAPIError> {
        let serviceRet = await UniversalServiceCall(lexueContext, sesskey: sesskey, methodName: "core_table_get_dynamic_table_content", args: [
            "component": "core_user",
            "handler": "participants",
            "uniqueid": "user-index-participants-\(courseId)",
            "sortdata": [
                [
                    "sortby": "lastname",
                    "sortorder": 4
                ]
            ],
            "jointype": 2,
            "filters": [
                "courseid": [
                    "name": "courseid",
                    "jointype": 1,
                    "values": [
                        Int(courseId)
                    ]
                ]
            ],
            "firstinitial": "",
            "lastinitial": "",
            "pagenumber": "1",
            "pagesize": "5000",
            "hiddencolumns": [],
            "resetpreferences": false
        ])
        if let data = serviceRet["data"] as? [String: Any], let html = data["html"] as? String {
            return .success(ParseCourseMembersHtml(html))
        } else {
            if retry {
                let result = await GetSessKey(GlobalVariables.shared.cur_lexue_context)
                switch result {
                case .success(let (sesskey, new_context)):
                    DispatchQueue.main.async {
                        GlobalVariables.shared.cur_lexue_sessKey = sesskey
                    }
                    return await GetCourseMembersInfo(new_context == nil ? lexueContext : new_context!, sesskey: sesskey, courseId: courseId, retry: false)
                case .failure(_):
                    return .failure(.unknowError)
                }
            } else {
                return .failure(.unknowError)
            }
        }
    }
    
    func GetLexueHeaders(_ lexueContext: LexueContext) -> HTTPHeaders {
        var cur_headers = HTTPHeaders(headers1)
        cur_headers.add(name: "Cookie", value: "MoodleSession=\(lexueContext.MoodleSession);")
        return cur_headers
    }
    
    func ParseViewCourseHtml2Sections(_ html: String) -> [CourseSectionInfo] {
        var ret = [CourseSectionInfo]()
        do {
            let doc = try SwiftSoup.parse(html)
            let topics = try doc.select("li")
            for topic in topics.array() {
                guard let classValue = try? topic.attr("class") else { continue }
                if !classValue.contains("section") { continue }
                guard let sectionIdValue = try? topic.attr("data-sectionid") else { continue }
                // print("classValue: \(classValue)")
                var curSection = CourseSectionInfo()
                curSection.sectionId = sectionIdValue
                if classValue.contains("current") {
                    curSection.current = true
                }
                let contentElem = try topic.select(".content")
                let titleElem = try contentElem.select("h3")
                let titleAElem = try titleElem.select("a")
                
                curSection.name = try titleElem.text().trimmingCharacters(in: .whitespacesAndNewlines)
                if titleAElem.array().count > 0 {
                    curSection.url = try titleAElem.attr("href")
                }
                let summaryNode = try contentElem.select(".summary")
                if summaryNode.array().count > 0 {
                    curSection.summary = try summaryNode.html()
                }
                // 转换数量
                let spans = try topic.select("span.activity-count")
                for span in spans {
                    let span_text = try span.text()
                    var components = span_text.components(separatedBy: ":")
                    if components.count != 2 {
                        components = span_text.components(separatedBy: "：")
                    }
                    if components.count != 2 {
                        continue
                    }
                    let character_text = components[0]
                    let file_character_text = ["文件", "Files", "Файлы"]
                    let assignment_character_text = ["作业", "Assignment", "Задание"]
                    let forum_character_text = ["讨论区", "Forum", "Форум"]
                    let progress_character_text = ["进度", "Progress", "Прогресс"]
                    let coding_character_text = ["编程练习", "Programming Practice", "Programming Practice"]
                    let test_character_text = ["测验", "Quizzes", "Тесты"]
                    
                    if file_character_text.contains(character_text) {
                        curSection.file_cnt = Int(components[1].trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    if assignment_character_text.contains(character_text) {
                        curSection.assignment_cnt = Int(components[1].trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    if forum_character_text.contains(character_text) {
                        curSection.forum_cnt = Int(components[1].trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    if coding_character_text.contains(character_text) {
                        curSection.coding_cnt = Int(components[1].trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    if test_character_text.contains(character_text) {
                        curSection.test_cnt = Int(components[1].trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    if progress_character_text.contains(character_text) {
                        let components1 = components[1].trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "/")
                        if components1.count == 2 {
                            curSection.progress_finish = Int(components1[0].trimmingCharacters(in: .whitespacesAndNewlines))
                            curSection.progress_total = Int(components1[1].trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                    }
                }
                ret.append(curSection)
            }
        } catch {
            print(error.localizedDescription)
            print("解析课程详情发生错误")
        }
        return ret
    }
    
    func GetCourseSections(_ lexueContext: LexueContext, courseId: String, retry: Bool = true) async -> Result<[CourseSectionInfo], Error> {
        let response1 = await AF.requestWithoutCache("\(API_LEXUE_VIEW_COURSE)?id=\(courseId)", method: .get, headers: GetLexueHeaders(lexueContext)).serializingString().response
        switch response1.result {
        case .success(let html):
            return .success(ParseViewCourseHtml2Sections(html))
        case .failure(let error):
            if retry {
                let result = await GetSessKey(GlobalVariables.shared.cur_lexue_context)
                switch result {
                case .success(let (sesskey, new_context)):
                    DispatchQueue.main.async {
                        GlobalVariables.shared.cur_lexue_sessKey = sesskey
                    }
                    return await GetCourseSections(new_context == nil ? lexueContext : new_context!, courseId: courseId, retry: false)
                case .failure(let error):
                    return .failure(error)
                }
            } else {
                return .failure(error)
            }
        }
    }
    
    func ParseDetailUserInfo(_ html: String, _ ori: SelfUserInfo) -> SelfUserInfo {
        var ret = ori
        do {
            let document = try SwiftSoup.parse(html)
            let emailElement = try document.select("#id_email").first()
            ret.email = try emailElement?.attr("value").trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let id_idnumber = try document.select("#id_idnumber").first()
            ret.stuId = try id_idnumber?.attr("value").trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let id_phone1 = try document.select("#id_phone1").first()
            ret.phone = try id_phone1?.attr("value").trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return ret
        } catch {
            print("Error parsing HTML: \(error.localizedDescription)")
            return ret
        }
    }
    
    func UpdateProfile(_ lexueContext: LexueContext, newProfile: EditProfileParam) async -> Result<EditProfileParam, Error> {
        let param: [String: Any] = [
            "course": newProfile.course,
            "id": newProfile.id,
            "returnto": newProfile.returnto,
            "mform_isexpanded_id_moodle_picture": newProfile.mform_isexpanded_id_moodle_picture,
            "sesskey": newProfile.sesskey,
            "_qf__user_edit_form": newProfile._qf__user_edit_form,
            "mform_isexpanded_id_moodle": newProfile.mform_isexpanded_id_moodle,
            "mform_isexpanded_id_moodle_additional_names": newProfile.mform_isexpanded_id_moodle_additional_names,
            "mform_isexpanded_id_moodle_optional": newProfile.mform_isexpanded_id_moodle_optional,
            "mform_isexpanded_id_category_1": newProfile.mform_isexpanded_id_category_1,
            "email": newProfile.email,
            "maildisplay": newProfile.maildisplay,
            "city": newProfile.city,
            "country": newProfile.country,
            "timezone": newProfile.timezone,
            "theme": newProfile.theme,
            "description_editor[text]": newProfile.description_editor_text_,
            "description_editor[format]": newProfile.description_editor_format_,
            "description_editor[itemid]": newProfile.description_editor_itemid_,
            "firstnamephonetic": newProfile.firstnamephonetic,
            "lastnamephonetic": newProfile.lastnamephonetic,
            "middlename": newProfile.middlename,
            "alternatename": newProfile.alternatename,
            "institution": newProfile.institution,
            "department": newProfile.department,
            "phone1": newProfile.phone1,
            "phone2": newProfile.phone2,
            "address": newProfile.address,
            "profile_field_icq": newProfile.profile_field_icq,
            "profile_field_skype": newProfile.profile_field_skype,
            "profile_field_aim": newProfile.profile_field_aim,
            "profile_field_yahoo": newProfile.profile_field_yahoo,
            "profile_field_msn": newProfile.profile_field_msn,
            "profile_field_url": newProfile.profile_field_url,
            "submitbutton": newProfile.submitbutton
        ]
        print("moodle: \(lexueContext.MoodleSession)")
        print("sesskey: \(newProfile.sesskey)")
        let response1 = await AF.requestWithoutCache(API_LEXUE_DETAIL_INFO, method: .post, parameters: param, encoding: URLEncoding.default, headers: GetLexueHeaders(lexueContext))
            .validate(statusCode: 300..<500)
            .redirect(using: Redirector.doNotFollow)
            .serializingString().response
        switch response1.result {
        case .success(_):
            if response1.response?.statusCode == 303 {
                return .success(newProfile)
            } else {
                return .failure(LexueAPIError.unknowError)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func GetProfileHtmlFromHtml(_ html: String) -> String {
        do {
            let document = try SwiftSoup.parse(html)
            if let userProfileDiv = try document.select("div.userprofile").first() {
                if let description = try userProfileDiv.select("div.description").first() {
                    return try description.html()
                } else {
                    return ""
                }
            } else {
                return ""
            }
        } catch {
            return ""
        }
    }
    
    // 获取其他用户的Profile信息, 返回profile的html内容
    func GetUserProfile(_ lexueContext: LexueContext, userId: String, retry: Bool = true) async -> Result<String, Error> {
        let response1 = await AF.requestWithoutCache("\(API_LEXUE_PROFILE)?id=\(userId)", method: .get, headers: GetLexueHeaders(lexueContext)).serializingString().response
        switch response1.result {
        case .success(let html):
            return .success(GetProfileHtmlFromHtml(html))
        case .failure(let error):
            if retry {
                let result = await GetSessKey(GlobalVariables.shared.cur_lexue_context)
                switch result {
                case .success(let (sesskey, new_context)):
                    DispatchQueue.main.async {
                        GlobalVariables.shared.cur_lexue_sessKey = sesskey
                    }
                    return await GetUserProfile(new_context == nil ? lexueContext : new_context!, userId: userId, retry: false)
                case .failure(_):
                    return .failure(error)
                }
            } else {
                return .failure(error)
            }
        }
    }
    
    func GetEditProfileParam(_ lexueContext: LexueContext) async -> Result<EditProfileParam, Error> {
        let response1 = await AF.requestWithoutCache(API_LEXUE_DETAIL_INFO, method: .get, headers: GetLexueHeaders(lexueContext)).serializingString().response
        let parseInput: (Document, String) -> String = { (doc, name) in
            do {
                let input = try doc.select("input[name=\(name)]").first()
                if let input = input {
                    return try input.attr("value")
                } else {
                    print("未找到\(name)标签！")
                }
                return ""
            } catch {
                return ""
            }
        }
        let parseTextarea: (Document, String) -> String = { (doc, name) in
            do {
                let input = try doc.select("textarea[name=\(name)]").first()
                if let input = input {
                    return try input.text()
                } else {
                    print("未找到\(name) 编辑框！")
                }
                return ""
            } catch {
                return ""
            }
        }
        let parseSelector: (Document, String) -> String = { (doc, name) in
            do {
                let select = try doc.select("select[name=\(name)]").first()
                if let select = select, let selectedOption = try select.select("option[selected]").first() {
                    return try selectedOption.attr("value")
                } else {
                    print("未找到\(name)选择器！")
                }
                return ""
            } catch {
                return ""
            }
        }
        
        switch response1.result {
        case .success(let data):
            do {
                var ret = EditProfileParam()
                let document = try SwiftSoup.parse(data)
                ret.course = parseInput(document, "course")
                ret.id = parseInput(document, "id")
                ret.returnto = parseInput(document, "returnto")
                ret.mform_isexpanded_id_moodle_picture = parseInput(document, "mform_isexpanded_id_moodle_picture")
                ret.sesskey = parseInput(document, "sesskey")
                ret._qf__user_edit_form = parseInput(document, "_qf__user_edit_form")
                ret.mform_isexpanded_id_moodle = parseInput(document, "mform_isexpanded_id_moodle")
                ret.mform_isexpanded_id_moodle_additional_names = parseInput(document, "mform_isexpanded_id_moodle_additional_names")
                ret.mform_isexpanded_id_moodle_optional = parseInput(document, "mform_isexpanded_id_moodle_optional")
                ret.mform_isexpanded_id_category_1 = parseInput(document, "mform_isexpanded_id_category_1")
                ret.email = parseInput(document, "email")
                ret.maildisplay = parseSelector(document, "maildisplay")
                ret.city = parseInput(document, "city")
                ret.country = parseSelector(document, "country")
                ret.timezone = parseSelector(document, "timezone")
                ret.theme = parseSelector(document, "theme")
                ret.description_editor_text_ = parseTextarea(document, "description_editor[text]")
                ret.description_editor_format_ = parseInput(document, "description_editor[format]")
                ret.description_editor_itemid_ = parseInput(document, "description_editor[itemid]")
                ret.firstnamephonetic = parseInput(document, "firstnamephonetic")
                ret.lastnamephonetic = parseInput(document, "lastnamephonetic")
                ret.middlename = parseInput(document, "middlename")
                ret.alternatename = parseInput(document, "alternatename")
                ret.institution = parseInput(document, "institution")
                ret.department = parseInput(document, "department")
                ret.phone1 = parseInput(document, "phone1")
                ret.phone2 = parseInput(document, "phone2")
                ret.address = parseInput(document, "address")
                ret.profile_field_icq = parseInput(document, "profile_field_icq")
                ret.profile_field_skype = parseInput(document, "profile_field_skype")
                ret.profile_field_aim = parseInput(document, "profile_field_aim")
                ret.profile_field_yahoo = parseInput(document, "profile_field_yahoo")
                ret.profile_field_msn = parseInput(document, "profile_field_msn")
                ret.profile_field_url = parseInput(document, "profile_field_url")
                return .success(ret)
            } catch {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func ParseBasicUserInfo(_ html: String) -> SelfUserInfo {
        do {
            var ret = SelfUserInfo()
            let document = try SwiftSoup.parse(html)
            let fullNameElement = try document.select(".myprofileitem.fullname")
            ret.fullName = try fullNameElement.text().trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "")
            
            let firstAccessElement = try document.select(".myprofileitem.firstaccess").first()
            ret.firstAccessTime = try firstAccessElement?.text().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let instanceHeaderElement = try document.select("#instance-33495-header").first()
            let parentElement = instanceHeaderElement?.parent()
            let infoElements = try parentElement?.select(".info")
            ret.onlineUsers = try infoElements?.text().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let containerElement = try document.select("#nav-notification-popover-container").first()
            ret.userId = try containerElement?.attr("data-userid") ?? ""
            return ret
        } catch {
            print("Error parsing HTML: \(error.localizedDescription)")
            return SelfUserInfo()
        }
    }
    
    func ParseSessKey(_ html: String) -> String {
        if let sesskeyRange = html.range(of: "\"sesskey\":\"") {
            // 计算 sesskey 的起始位置
            let startIndex = sesskeyRange.upperBound
            
            // 找到 sesskey 结束位置的引号
            if let endIndex = html[startIndex...].firstIndex(of: "\"") {
                // 提取 sesskey 后面的字符串
                let sessKey = String(html[startIndex..<endIndex])
                return sessKey
            }
        }
        return ""
    }
    
    func GetSessKey(_ lexueContext: LexueContext, retry: Bool = true) async -> Result<(String, LexueContext?), Error> {
        let response = await AF.requestWithoutCache(API_LEXUE_INDEX, method: .get, headers: GetLexueHeaders(lexueContext))
            .validate(statusCode: 200...200)
            .redirect(using: Redirector.doNotFollow)
            .serializingString()
            .response
        switch response.result {
        case .success(let html):
            let ret = ParseSessKey(html)
            SettingStorage.shared.set_widget_shared_sesskey(ret)
            return .success((ret, nil))
        case .failure(let error):
            if retry {
                print("GetSessKey occured error, retrying...")
                let new_lexue_context = await withCheckedContinuation { continuation in
                    self.GetLexueContext(SettingStorage.shared.loginnedContext) { result in
                        switch result {
                        case .success(let context):
                            continuation.resume(returning: Result<LexueContext, LexueLoginError>.success(context))
                        case .failure(let error):
                            continuation.resume(returning: Result<LexueContext, LexueLoginError>.failure(error))
                        }
                    }
                }
                switch new_lexue_context {
                case .success(let new_context):
                    DispatchQueue.main.async {
                        GlobalVariables.shared.cur_lexue_context = new_context
                    }
                    let retryResult = await GetSessKey(new_context, retry: false)
                    switch retryResult {
                    case .success(let (newSesskey, _)):
                        SettingStorage.shared.set_widget_shared_sesskey(newSesskey)
                        return .success((newSesskey, new_context))
                    case .failure(let error):
                        return .failure(error)
                    }
                case .failure(let error):
                    return .failure(error)
                }
            } else {
                return .failure(error)
            }
        }
    }
    
    func GetSelfUserInfo(_ lexueContext: LexueContext) async -> Result<SelfUserInfo, Error> {
        let response = await AF.requestWithoutCache(API_LEXUE_INDEX, method: .get, headers: GetLexueHeaders(lexueContext)).serializingString().response
        switch response.result {
        case .success(let data):
            var ret = ParseBasicUserInfo(data)
            let response2 = await AF.requestWithoutCache(API_LEXUE_DETAIL_INFO, method: .get, headers: GetLexueHeaders(lexueContext)).serializingString().response
            switch response2.result {
            case .success(let data2):
                ret = ParseDetailUserInfo(data2, ret)
                print(ret)
                return .success(ret)
            case .failure(_):
                return .success(ret)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func GetLexueLoginTicket(_ loginnedContext: BITLogin.LoginSuccessContext, completion: @escaping (Result<String, LexueLoginError>) -> Void) {
        var cur_headers = HTTPHeaders(headers)
        cur_headers.add(name: "Cookie", value: "SOURCEID_TGC=\(loginnedContext.CASTGC)")
        AF.requestWithoutCache(API_LEXUE_TICK, method: .get, headers: cur_headers)
            .validate(statusCode: 300..<500)
            .redirect(using: Redirector.doNotFollow)
            .response { response in
                switch response.result {
                case .success( _):
                    if let ret_headers = response.response?.allHeaderFields as? [String: String], let login_url = ret_headers["Location"] {
                        completion(.success(login_url))
                    } else {
                        completion(.failure(LexueLoginError.noLocationHeader))
                    }
                case .failure(_):
                    print("GetLexueContext 失败")
                    completion(.failure(LexueLoginError.networkError))
                }
                
            }
    }
    
    func GetLexueContext(_ loginnedContext: BITLogin.LoginSuccessContext, completion: @escaping (Result<LexueContext, LexueLoginError>) -> Void) {
        var cur_headers = HTTPHeaders(headers)
        cur_headers.add(name: "Cookie", value: "SOURCEID_TGC=\(loginnedContext.CASTGC)")
        AF.requestWithoutCache(API_LEXUE_TICK, method: .get, headers: cur_headers)
            .validate(statusCode: 300..<500)
            .redirect(using: Redirector.doNotFollow)
            .response { response in
                switch response.result {
                case .success( _):
                    if let ret_headers = response.response?.allHeaderFields as? [String: String], let login_url = ret_headers["Location"] {
                        // print("login_url: \(login_url)")
                        AF.requestWithoutCache(login_url, method: .get)
                            .validate(statusCode: 300..<500)
                            .redirect(using: Redirector.doNotFollow)
                            .response { response1 in
                                switch response1.result {
                                case .success(_):
                                    if let ret_headers = response1.response?.allHeaderFields as? [String: String], let cookie = ret_headers["Set-Cookie"] {
                                        let firstMoodle = get_cookie_key(cookie, "MoodleSession")
                                        // print("firstMoodle: \(cookie)")
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
                                                        SettingStorage.shared.set_widget_shared_LexueContext(ret)
                                                        // print(ret)
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
    
    func ParseCourseObject(course: [String: Any]) -> CourseShortInfo {
        var cur = CourseShortInfo()
        cur.id = String((course["id"] as? Int) ?? 0)
        cur.fullname = course["fullname"] as? String
        cur.shortname = course["shortname"] as? String
        cur.idnumber = course["idnumber"] as? String
        cur.summary = course["summary"] as? String
        cur.summaryformat = course["summaryformat"] as? Int
        cur.startdate = course["startdate"] as? Int
        cur.enddate = course["enddate"] as? Int
        cur.visible = course["visible"] as? Bool
        cur.showactivitydates = course["showactivitydates"] as? Bool
        cur.showcompletionconditions = course["showcompletionconditions"] as? Bool
        cur.fullnamedisplay = course["fullnamedisplay"] as? String
        cur.viewurl = course["viewurl"] as? String
        cur.courseimage = course["courseimage"] as? String
        cur.progress = course["progress"] as? Int
        cur.hasprogress = course["hasprogress"] as? Bool
        cur.isfavourite = course["isfavourite"] as? Bool
        cur.hidden = course["hidden"] as? Bool
        cur.showshortname = course["showshortname"] as? Bool
        cur.coursecategory = course["coursecategory"] as? String
        return cur
    }
    
    func GetAllCourseList(_ lexueContext: LexueContext, sesskey: String, retry: Bool = true) async -> Result<[CourseShortInfo],LexueAPIError> {
        var ret = [CourseShortInfo]()
        let serviceRet = await UniversalServiceCall(lexueContext, sesskey: sesskey, methodName: "core_course_get_enrolled_courses_by_timeline_classification", args: [
            "offset": 0,
            "limit": 0,
            "classification": "all",
            "sort": "fullname",
            "customfieldname": "",
            "customfieldvalue": ""
        ])
        if let data = serviceRet["data"] as? [String: Any], let courses = data["courses"] as? [[String: Any]] {
            for course in courses {
                if let course = course as? [String: Any] {
                    var cur = CourseShortInfo()
                    if course["id"] as? Int == nil {
                        continue;
                    }
                    cur = ParseCourseObject(course: course)
                    ret.append(cur)
                }
            }
        } else {
            if retry {
                let result = await GetSessKey(GlobalVariables.shared.cur_lexue_context)
                switch result {
                case .success(let (sesskey, new_context)):
                    DispatchQueue.main.async {
                        GlobalVariables.shared.cur_lexue_sessKey = sesskey
                    }
                    return await GetAllCourseList(new_context == nil ? lexueContext : new_context!, sesskey: sesskey, retry: false)
                case .failure(_):
                    return .failure(.unknowError)
                }
            } else {
                return .failure(.unknowError)
            }
        }
        return .success(ret)
    }
    
    func UniversalServiceCall(_ lexueContext: LexueContext, sesskey: String, methodName: String, args: [String: Any]) async -> [String: Any] {
        let data: [[String: Any]] = [[
            "index": 0,
            "methodname": methodName,
            "args": args
        ]]
        do {
            // 将字典转换为 JSON 数据
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            
            // 将 JSON 数据转换为字符串
            if String(data: jsonData, encoding: .utf8) != nil {
                var request = URLRequest(url: URL(string: "\(API_LEXUE_SERVICE_CALL)?sesskey=\(sesskey)")!)
                request.cachePolicy = .reloadIgnoringCacheData
                request.httpMethod = HTTPMethod.post.rawValue
                request.headers = GetLexueHeaders(lexueContext)
                request.httpBody = jsonData
                // https://stackoverflow.com/questions/68694917/convert-alamofire-completion-handler-to-async-await-swift-5-5
                let ret = await withCheckedContinuation { continuation in
                    AF.request(request).response { res in
                        switch res.result {
                        case .success(let data):
                            if data == nil {
                                print("无法将响应数据转换为字典")
                                continuation.resume(returning: [String: Any]())
                                return
                            }
                            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]], json.count > 0 {
                                continuation.resume(returning: json[0])
                            } else {
                                print("无法将响应数据转换为字典")
                                continuation.resume(returning: [String: Any]())
                            }
                        case .failure(_):
                            print("请求servicecall 失败")
                            continuation.resume(returning: [String: Any]())
                        }
                    }
                }
                return ret
            } else {
                print("无法将 JSON 数据转换为字符串")
                return [String: Any]()
            }
        } catch {
            print("转换为 JSON 数据时发生错误: \(error)")
            return [String: Any]()
        }
    }
    
    
}
