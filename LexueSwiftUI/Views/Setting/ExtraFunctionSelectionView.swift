//
//  ExtraFunctionSelectionView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/12/1.
//

import SwiftUI

// 设置界面里，由于功能多了会很冗杂，所以用一个可以横向滑动的视图承载现在，以及未来的所有拓展功能如：“查成绩”、“查考试安排”、“校园地图等”

let extraFunctionSelectedNotification = Notification.Name("extraFunctionSelectedNotification")

struct ExtraFunctionDescription: Hashable {
    var notificationName: String            // 到时候要发送的通知名字
    var titleName: String                   // 显示在列表中的名字
    var imageName: String                   // 列表中显示的图标的systemName
    var color: Color                        // 背景颜色
}
struct ExtraFunctionSelectionView: View {
    @State var functions: [ExtraFunctionDescription] = [
        .init(notificationName: "queryScore", titleName: "成绩查询", imageName: "graduationcap.fill", color: .blue),
        .init(notificationName: "examArrange", titleName: "考试安排", imageName: "calendar", color: .blue),
        .init(notificationName: "schoolMap", titleName: "校园导航", imageName: "map.fill", color: .blue),
        .init(notificationName: "editFunctions", titleName: "编辑", imageName: "ellipsis", color: .gray),
    ]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(functions, id: \.self) { function in
                    VStack {
                        ZStack {
                            Circle()
                                .foregroundColor(function.color)
                                .frame(height: 50)
                            Image(systemName: function.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20)
                                .foregroundColor(.white)
                        }
                        HStack {
                            Spacer()
                            Text(function.titleName)
                                .bold()
                            Spacer()
                        }
                        .padding(.vertical, 5)
                    }
                    .onTapGesture {
                        VibrateOnce()
                        NotificationCenter.default.post(name: extraFunctionSelectedNotification, object: function.notificationName)
                    }
                    .padding(.horizontal, 5)
                }
                
            }
        }
    }
}

#Preview {
    ExtraFunctionSelectionView()
}
