//
//  InfoMergingDataProvider.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/6.
//

import Foundation


/**
        校内消息聚合，主要是一些教务部的通知等等
        希望由HaoBIT提供数据源
 */
class InfoMergingDataProvider: DataProvider {
    
    struct MessageSource {
        var shortName: String
        var fullName: String
        var optionName: String
    }
    
    var enabled: Bool = true
    
    var allowMessage: Bool = true
    
    var allowNotification: Bool = true
    
    var msgRequestList: [PushMessageRequest] = []
    
    var customOptions: [ProviderCustomOption] = []
    
    var messageSources: [MessageSource]
    
    // shortName -> messageSource
    var messageSourceMap = [String: MessageSource]()
    
    init() {
        messageSources = [
            .init(shortName: "睿信", fullName: "睿信书院", optionName: "option_0"),
            .init(shortName: "求是", fullName: "求是书院", optionName: "option_1"),
            .init(shortName: "精工", fullName: "精工书院", optionName: "option_2"),
            .init(shortName: "明德", fullName: "明德书院", optionName: "option_3"),
            .init(shortName: "经管", fullName: "经管书院", optionName: "option_4"),
            .init(shortName: "知艺", fullName: "知艺书院", optionName: "option_5"),
            .init(shortName: "特立", fullName: "特立书院", optionName: "option_6"),
            .init(shortName: "北京书院", fullName: "北京书院", optionName: "option_7"),
            .init(shortName: "留学生", fullName: "留学生中心", optionName: "option_8"),
            .init(shortName: "马克思", fullName: "马克思主义学院", optionName: "option_9"),
            .init(shortName: "研究生", fullName: "研究生院", optionName: "option_10"),
            .init(shortName: "通用", fullName: "主站最新通知", optionName: "option_11"),
            .init(shortName: "教务处", fullName: "教务处", optionName: "option_12"),
            .init(shortName: "教务部", fullName: "教务部", optionName: "option_13"),
            .init(shortName: "教学中心", fullName: "教学运行与考务中心", optionName: "option_14"),
            .init(shortName: "学工部等", fullName: "学生工作部、武装部或心理健康教育与咨询中心", optionName: "option_15"),
            .init(shortName: "计算机", fullName: "计算机学院", optionName: "option_16"),
            .init(shortName: "学生事务", fullName: "学生事务中心", optionName: "option_17"),
            .init(shortName: "创新创业", fullName: "学生创新创业实践中心", optionName: "option_18"),
            .init(shortName: "资助公示", fullName: "学生事务中心校内公示", optionName: "option_19"),
            .init(shortName: "大创", fullName: "大学生创新创业训练计划管理系统", optionName: "option_20"),
            .init(shortName: "第二课堂", fullName: "第二课堂", optionName: "option_21"),
            .init(shortName: "光电", fullName: "光电学院", optionName: "option_22"),
            .init(shortName: "网信", fullName: "网络信息技术中心", optionName: "option_23"),
            .init(shortName: "数学实验", fullName: "数学实验中心", optionName: "option_24"),
            .init(shortName: "党政部", fullName: "党委或行政办公室", optionName: "option_25"),
            .init(shortName: "人事", fullName: "党委教师工作部、人力资源部", optionName: "option_26"),
            .init(shortName: "公开数据", fullName: "公开数据", optionName: "option_27"),
            .init(shortName: "公开通知", fullName: "公开通知", optionName: "option_28"),
            .init(shortName: "校医院", fullName: "医院和社区卫生服务中心", optionName: "option_29"),
            .init(shortName: "图书馆", fullName: "图书馆", optionName: "option_30"),
            .init(shortName: "图书馆讲座", fullName: "图书馆讲座", optionName: "option_31"),
            .init(shortName: "延河", fullName: "延河课堂更新日志", optionName: "option_32"),
            .init(shortName: "国际交流", fullName: "国际交流", optionName: "option_33"),
            .init(shortName: "新生", fullName: "迎新动态", optionName: "option_34"),
            .init(shortName: "信电", fullName: "信息与电子学院", optionName: "option_35"),
            .init(shortName: "网安", fullName: "网络空间安全学院", optionName: "option_36"),
            .init(shortName: "集电", fullName: "集成电路与电子学院", optionName: "option_37"),
            .init(shortName: "机车", fullName: "机械与车辆学院", optionName: "option_38"),
            .init(shortName: "数学", fullName: "数学与统计学院", optionName: "option_39"),
            .init(shortName: "物理", fullName: "物理学院", optionName: "option_40"),
            .init(shortName: "机电", fullName: "机电学院", optionName: "option_41"),
            .init(shortName: "生命", fullName: "生命学院", optionName: "option_42"),
            .init(shortName: "宇航", fullName: "宇航学院", optionName: "option_43"),
            .init(shortName: "医学", fullName: "医学技术学院", optionName: "option_44"),
            .init(shortName: "自动化", fullName: "自动化学院", optionName: "option_45"),
            .init(shortName: "人文", fullName: "人文与社会科学学院", optionName: "option_46"),
            .init(shortName: "人文素质", fullName: "人文素质教研部", optionName: "option_47")
        ]
        for messageSource in messageSources {
            messageSourceMap[messageSource.shortName] = messageSource
        }
    }
    
    func get_default_enabled() -> Bool {
        return true
    }
    
    func get_default_allowMessage() -> Bool {
        return true
    }
    
    func get_default_allowNotification() -> Bool {
        return true
    }
    
    func get_custom_option_item(_ optionName: String) -> ProviderCustomOption? {
        for option in customOptions {
            if option.optionName == optionName {
                return option
            }
        }
        return nil
    }
    
    func get_custom_options() -> [ProviderCustomOption] {
        var ret = [ProviderCustomOption]()
        for messageSource in messageSources {
            ret.append(.init(optionName: messageSource.optionName, displayName: messageSource.fullName, optionType: .bool, optionValueBool: false))
        }
        return ret
    }
    
    func get_priority() -> TaskPriority {
        return .low
    }
    
    var providerIdForEach: String {
        return "provider.info_merging"
    }
    
    func info() -> DataProviderInfo {
        return DataProviderInfo(providerId: "provider.info_merging", providerName: "消息聚合服务", description: "聚合教务处、各学院等发布的消息，并发送通知", author: "HaoBIT\nYDX-2147483647/bulletin-issues-transferred", author_url: "https://haobit.top/dev/site/")
    }
    
    func refresh(param: [String : Any]) async {
        return
    }
    
    
}