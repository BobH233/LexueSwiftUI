//
//  ExtraFunctionDescription.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/12/6.
//

import Foundation
import SwiftUI


struct ExtraFunctionDescription: Hashable {
    var notificationName: String            // 到时候要发送的通知名字
    var titleName: String                   // 显示在列表中的名字
    var imageName: String                   // 列表中显示的图标的systemName
    var enable: Bool = false                // 是否显示在设置界面中
    var color: Color                        // 背景颜色
    func toDescriptionStored() -> ExtraFunctionDescriptionStored {
        return ExtraFunctionDescriptionStored(notificationName: notificationName, enable: enable)
    }
}


struct ExtraFunctionDescriptionStored: Codable {
    var notificationName: String            // 到时候要发送的通知名字
    var enable: Bool = false                // 是否显示在设置界面中
    func toDescription() -> ExtraFunctionDescription? {
        for des in GlobalVariables.shared.extraFunctions {
            if des.notificationName == notificationName {
                return des
            }
        }
        return nil
    }
}

func encodeFuncDescriptionStoredArr<T: Encodable>(_ array: [T]) -> Data? {
    try? JSONEncoder().encode(array)
}

func decodeStructArray<T: Decodable>(from data: Data) -> [T] {
    return (try? JSONDecoder().decode([T].self, from: data)) ?? []
}
