//
//  ExtraFunctionSetting.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/12/6.
//

import SwiftUI

struct ExtraFunctionSetting: View {
    @State var enabled_functions: [ExtraFunctionDescription] = []
    @State var isEditMode: Bool = true
    func IsFunctionEnabled(notificationName: String) -> Bool {
        for enabled_function in enabled_functions {
            if enabled_function.notificationName == notificationName {
                return true
            }
        }
        return false
    }
    var body: some View {
        List {
            Section(header: Text("已启用"), footer: Text("更多功能正在开发适配中，敬请期待！")) {
                ForEach(enabled_functions, id: \.self) { enabled_function in
                    HStack {
                        if isEditMode {
                            Button(action: {
                                if let index = enabled_functions.firstIndex(where: { $0.notificationName == enabled_function.notificationName }) {
                                    withAnimation {
                                        enabled_functions.remove(at: index)
                                        VibrateOnce()
                                    }
                                    SettingStorage.shared.SetEnabledExtraFunctions(current: enabled_functions)
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
                        
                        Text(enabled_function.titleName)
                    }
                    
                }
                .onMove { (fromOffsets: IndexSet, toOffset: Int) in
                    print("fromOffset:\(fromOffsets) toOffset:\(toOffset)")
                    enabled_functions.move(fromOffsets: fromOffsets, toOffset: toOffset)
                    SettingStorage.shared.SetEnabledExtraFunctions(current: enabled_functions)
                    print(enabled_functions)
                }
                
            }
            
            Section("未启用") {
                ForEach(GlobalVariables.shared.extraFunctions, id: \.self) { all_function in
                    if !IsFunctionEnabled(notificationName: all_function.notificationName) {
                        HStack {
                            if isEditMode {
                                Button(action: {
                                    withAnimation {
                                        enabled_functions.append(all_function)
                                        VibrateOnce()
                                    }
                                    SettingStorage.shared.SetEnabledExtraFunctions(current: enabled_functions)
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
                            
                            Text(all_function.titleName)
                        }
                    }
                }
            }
        }
        .onAppear {
            enabled_functions = SettingStorage.shared.GetEnabledExtraFunctions()
        }
        .environment(\.editMode, isEditMode ? .constant(.active) : .constant(.inactive))
        .navigationTitle("编辑实用功能")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    ExtraFunctionSetting()
}
