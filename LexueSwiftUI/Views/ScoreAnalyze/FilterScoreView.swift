//
//  FilterScoreView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/12.
//

import SwiftUI

struct FilterOptionBool {
    var title: String = ""
    var choose: Bool = true
}

struct FilterScoreView: View {
    @Binding var couse_type_choices: [FilterOptionBool]
    @Binding var semester_type_choices: [FilterOptionBool]
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ContentCardView(title0: "过滤课程类型", color0: .blue) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach($couse_type_choices, id: \.title) { choice in
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(choice.choose.wrappedValue ? .blue : .secondarySystemBackground)
                                        .cornerRadius(10)
                                    Text(choice.title.wrappedValue)
                                        .bold()
                                        .foregroundColor(choice.choose.wrappedValue ? .white : .black)
                                        .padding()
                                }
                                .onTapGesture {
                                    withAnimation {
                                        choice.choose.wrappedValue.toggle()
                                    }
                                }
                                
                            }
                        }
                        .padding(.leading, 10)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                ContentCardView(title0: "过滤学期", color0: .blue) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach($semester_type_choices, id: \.title) { choice in
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(choice.choose.wrappedValue ? .blue : .secondarySystemBackground)
                                        .cornerRadius(10)
                                    Text(choice.title.wrappedValue)
                                        .bold()
                                        .foregroundColor(choice.choose.wrappedValue ? .white : .black)
                                        .padding()
                                }
                                .onTapGesture {
                                    withAnimation {
                                        choice.choose.wrappedValue.toggle()
                                    }
                                }
                                
                            }
                        }
                        .padding(.leading, 10)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
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
