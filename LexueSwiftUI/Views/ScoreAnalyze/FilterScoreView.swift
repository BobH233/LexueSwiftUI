//
//  FilterScoreView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/12.
//

import SwiftUI
import WrappingHStack

struct FilterOptionBool {
    var title: String = ""
    var choose: Bool = true
}


struct FilterScoreView: View {
    @Binding var couse_type_choices: [FilterOptionBool]
    @Binding var semester_type_choices: [FilterOptionBool]
    @Environment(\.colorScheme) var sysColorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ContentCardView(title0: "过滤课程类型", color0: .blue) {
                    WrappingHStack($couse_type_choices, id: \.self) { choice in
                        ZStack {
                            Rectangle()
                                .foregroundColor(choice.choose.wrappedValue ? .blue : .secondarySystemBackground)
                                .cornerRadius(10)
                                .shadow(color: .secondary, radius: 1)
                            Text(choice.title.wrappedValue)
                                .bold()
                                .foregroundColor(choice.choose.wrappedValue ? .white : (sysColorScheme == .light ? .black : .white))
                                .padding()
                        }
                        .padding(.top, 10)
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.1)) {
                                choice.choose.wrappedValue.toggle()
                            }
                        }
                        
                    }
                    .padding(10)
                }
                ContentCardView(title0: "过滤学期", color0: .blue) {
                    WrappingHStack($semester_type_choices, id: \.self) { choice in
                        ZStack {
                            Rectangle()
                                .foregroundColor(choice.choose.wrappedValue ? .blue : .secondarySystemBackground)
                                .cornerRadius(10)
                                .shadow(color: .secondary, radius: 1)
                            Text(choice.title.wrappedValue)
                                .bold()
                                .foregroundColor(choice.choose.wrappedValue ? .white : (sysColorScheme == .light ? .black : .white))
                                .padding()
                        }
                        .padding(.top, 10)
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.1)) {
                                choice.choose.wrappedValue.toggle()
                            }
                        }
                        
                    }
                    .padding(10)
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 30)
        }
    }
}

#Preview {
    FilterScoreView(couse_type_choices: .constant([
        .init(title: "专业课"),
        .init(title: "公选课课"),
        .init(title: "体育课"),
        .init(title: "公共基础课")
    ]), semester_type_choices: .constant([
        .init(title: "2022-2023-1"),
        .init(title: "2022-2023-2"),
        .init(title: "体育课"),
        .init(title: "公共基础课")
    ]))
}
