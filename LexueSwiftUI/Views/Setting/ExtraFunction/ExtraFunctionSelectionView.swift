//
//  ExtraFunctionSelectionView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/12/1.
//

import SwiftUI

// 设置界面里，由于功能多了会很冗杂，所以用一个可以横向滑动的视图承载现在，以及未来的所有拓展功能如：“查成绩”、“查考试安排”、“校园地图等”

let extraFunctionSelectedNotification = Notification.Name("extraFunctionSelectedNotification")


struct ExtraFunctionSelectionView: View {
    @State var functions: [ExtraFunctionDescription] = []
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
                            Text(function.titleName)
                                .bold()
                        }
                        .padding(.top, 10)
                    }
                    .frame(width: 70)
                    .padding(.horizontal, 10)
                    .onTapGesture {
                        VibrateOnce()
                        NotificationCenter.default.post(name: extraFunctionSelectedNotification, object: function.notificationName)
                    }
                    
                }
                
            }
        }
        .onAppear {
            functions = SettingStorage.shared.GetEnabledExtraFunctions()
            functions.append(
                .init(notificationName: "editFunctions", titleName: "编辑", imageName: "ellipsis", enable: true, color: .gray))
        }
    }
}

#Preview {
    ExtraFunctionSelectionView()
}
