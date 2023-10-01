//
//  DDLListView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI

private struct TopCardView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.orange)
                .frame(height: 300)
                .cornerRadius(15)
                .shadow(radius: 5)
            VStack {
                VStack(spacing: 5) {
                    HStack {
                        Text("早上好，")
                            .font(.system(size: 35))
                            .bold()
                            .foregroundColor(.white)
                        Text(globalVar.cur_user_info.fullName)
                            .font(.system(size: 35))
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                    }
                    HStack {
                        Text("10月1日 星期日")
                            .font(.system(size: 25))
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .padding(.leading, 20)
                .padding(.top, 20)
                Spacer()
                VStack {
                    HStack(alignment: .bottom) {
                        Text("今日有")
                            .font(.system(size: 30))
                            .bold()
                            .foregroundColor(.white)
                        Text("5")
                            .font(.system(size: 35))
                            .bold()
                            .foregroundColor(.yellow)
                            .shadow(color: .gray, radius: 10)
                        Text("个ddl")
                            .font(.system(size: 30))
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                    }
                    HStack(alignment: .bottom) {
                        Text("本周有")
                            .font(.system(size: 30))
                            .bold()
                            .foregroundColor(.white)
                        Text("5")
                            .font(.system(size: 35))
                            .bold()
                            .foregroundColor(.yellow)
                            .shadow(color: .gray, radius: 10)
                        Text("个ddl")
                            .font(.system(size: 30))
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .padding(.leading, 20)
                .padding(.bottom, 20)
                
            }
        }
    }
}

private struct FunctionalButtonView: View {
    var backgroundCol: Color = .blue
    var iconSystemName: String = "plus.circle.fill"
    var title: String = "标题"
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(backgroundCol)
                .frame(height: 100)
                .cornerRadius(15)
                .shadow(radius: 5)
            VStack {
                HStack {
                    Image(systemName: iconSystemName)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.leading, 10)
                Spacer()
                HStack {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .bold()
                    Spacer()
                }
                .padding(.bottom, 10)
                .padding(.leading, 10)
            }
        }
        
    }
}

private struct EventListItemView: View {
    var title: String = "DDL名字"
    var description: String = "DDL描述性文本DDL描述性文本DDL描述性文本DDL描述性文本DDL描述性文本DDL描述性文本"
    var endtime: String = "DDL结束时间"
    var courseName: String = "课程名字"
    var backgroundCol: Color = .green
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(backgroundCol)
                .cornerRadius(15)
                .shadow(radius: 5)
            VStack {
                HStack {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.system(size: 30))
                        .bold()
                        .lineLimit(1)
                        .padding(.trailing, 20)
                    Spacer()
                }
                HStack {
                    Text(description)
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .bold()
                        .lineLimit(1)
                        .padding(.trailing, 20)
                    Spacer()
                }
                VStack(spacing: 3) {
                    HStack(spacing: 6) {
                        Image(systemName: "graduationcap.fill")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.white)
                        Text(courseName)
                            .foregroundColor(.white)
                            .bold()
                            .font(.system(size: 15))
                        Spacer()
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.white)
                        Text(endtime)
                            .foregroundColor(.white)
                            .bold()
                            .font(.system(size: 15))
                        Spacer()
                    }
                }
                .padding(.top, 40)
                .padding(.bottom, 10)
            }
            .padding(.top, 10)
            .padding(.leading, 10)
        }
    }
}

struct EventListView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    //  @Binding var tabSelection: Int
    var body: some View {
        NavigationView {
            ScrollView {
                TopCardView()
                .padding(.horizontal, 15)
                HStack(spacing: 10) {
                    FunctionalButtonView(backgroundCol: .blue, iconSystemName: "plus.circle.fill", title: "手动添加日程")
                    FunctionalButtonView(backgroundCol: .gray, iconSystemName: "gear", title: "设置规则")
                }
                .padding(.horizontal, 15)
                VStack {
                    EventListItemView()
                    EventListItemView()
                }
                .padding(.top, 20)
                .padding(.horizontal, 15)
            }
            .navigationTitle("最近事件")
        }
        
    }
}

#Preview {
    EventListView()
}
