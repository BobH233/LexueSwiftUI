//
//  CourseScoreViewEditor.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/21.
//

import SwiftUI


let allCourseScoreViewModules: [CourseScoreViewModuleDescription] = [
    .init(moduleName: "startSem", moduleDisplayName: "开课学期", imageName: "microbe.fill", enable: true),
    .init(moduleName: "courseType", moduleDisplayName: "课程性质", imageName: "square.split.2x2.fill", enable: true),
    .init(moduleName: "myGrade", moduleDisplayName: "我的成绩", imageName: "star.fill", enable: true),
    .init(moduleName: "credit", moduleDisplayName: "学分", imageName: "graduationcap.fill", enable: true),
    .init(moduleName: "avgScore", moduleDisplayName: "平均分", imageName: "alternatingcurrent", enable: true),
    .init(moduleName: "maxScore", moduleDisplayName: "最高分", imageName: "flag.fill", enable: true),
    .init(moduleName: "changeMyAvg", moduleDisplayName: "对我平均分的影响", imageName: "figure.soccer", enable: true),
    .init(moduleName: "inAllStu", moduleDisplayName: "在所有同学中排名", imageName: "person.2", enable: true),
    .init(moduleName: "inMajorStu", moduleDisplayName: "在专业中排名", imageName: "person.line.dotted.person.fill", enable: true),
    .init(moduleName: "reexamTip", moduleDisplayName: "重考提示", imageName: "exclamationmark.triangle.fill", enable: true),
]

struct CourseScoreViewModuleDescription: Hashable {
    var moduleName: String                          // 模块名字
    var moduleDisplayName: String                   // 显示在列表中的名字
    var imageName: String                           // 列表中显示的图标的systemName
    var enable: Bool = false                        // 是否显示在设置界面中
    func toDescriptionStored() -> CourseScoreViewModuleDescriptionStored {
        return CourseScoreViewModuleDescriptionStored(moduleName: moduleName, enable: enable)
    }
}

struct CourseScoreViewModuleDescriptionStored: Codable {
    var moduleName: String                  // 到时候要发送的通知名字
    var enable: Bool = false                // 是否显示在设置界面中
    func toDescription() -> CourseScoreViewModuleDescription? {
        for des in allCourseScoreViewModules {
            if des.moduleName == moduleName {
                return des
            }
        }
        return nil
    }
}

struct CourseScoreViewEditor: View {
    @State var enabled_modules: [CourseScoreViewModuleDescription] = []
    @State var isEditMode: Bool = true
    
    func IsFunctionEnabled(moduleName: String) -> Bool {
        for enabled_function in enabled_modules {
            if enabled_function.moduleName == moduleName {
                return true
            }
        }
        return false
    }
    var body: some View {
        List {
            Section(header: Text("已启用")) {
                ForEach(enabled_modules, id: \.self) { enabled_function in
                    HStack {
                        if isEditMode {
                            Button(action: {
                                if let index = enabled_modules.firstIndex(where: { $0.moduleName == enabled_function.moduleName }) {
                                    withAnimation {
                                        enabled_modules.remove(at: index)
                                        VibrateOnce()
                                    }
                                    SettingStorage.shared.SetEnabledScoreViewModule(current: enabled_modules)
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Image(systemName: enabled_function.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                                    .padding(5)
                            )
                        
                        Text(enabled_function.moduleDisplayName)
                    }
                    
                }
                .onMove { (fromOffsets: IndexSet, toOffset: Int) in
                    print("fromOffset:\(fromOffsets) toOffset:\(toOffset)")
                    enabled_modules.move(fromOffsets: fromOffsets, toOffset: toOffset)
                    SettingStorage.shared.SetEnabledScoreViewModule(current: enabled_modules)
                    print(enabled_modules)
                }
                
            }
            
            Section("未启用") {
                ForEach(allCourseScoreViewModules, id: \.self) { all_function in
                    if !IsFunctionEnabled(moduleName: all_function.moduleName) {
                        HStack {
                            if isEditMode {
                                Button(action: {
                                    withAnimation {
                                        enabled_modules.append(all_function)
                                        VibrateOnce()
                                    }
                                    SettingStorage.shared.SetEnabledScoreViewModule(current: enabled_modules)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Image(systemName: all_function.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.white)
                                        .padding(5)
                                )
                            
                            Text(all_function.moduleDisplayName)
                        }
                    }
                }
            }
        }
        .onAppear {
            enabled_modules = SettingStorage.shared.GetEnabledScoreViewModule()
        }
        .environment(\.editMode, isEditMode ? .constant(.active) : .constant(.inactive))
        .navigationTitle("编辑成绩分析界面")
        .navigationBarTitleDisplayMode(.large)
    }
}

