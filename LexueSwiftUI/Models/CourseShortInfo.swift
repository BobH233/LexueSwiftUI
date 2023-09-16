//
//  CourseShortInfo.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/4.
//

import Foundation
import CoreData

struct CourseShortInfo: Codable, Identifiable {
    var id: String = ""
    var fullname: String?
    var shortname: String?
    var idnumber: String?
    var summary: String?
    var summaryformat: Int?
    var startdate: Int?
    var enddate: Int?
    var visible: Bool?
    var showactivitydates: Bool?
    var showcompletionconditions: Bool?
    var fullnamedisplay: String?
    var viewurl: String?
    var courseimage: String?
    var progress: Int?
    var hasprogress: Bool?
    var isfavourite: Bool?
    var hidden: Bool?
    var showshortname: Bool?
    var coursecategory: String?
    var local_favorite: Bool = false
    
}

