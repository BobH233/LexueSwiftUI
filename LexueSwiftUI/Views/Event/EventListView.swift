//
//  DDLListView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI

struct EventListView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    //  @Binding var tabSelection: Int
    var body: some View {
        NavigationView {
            ScrollView {
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
                .padding(.horizontal, 15)
            }
            .navigationTitle("最近事件")
        }
        
    }
}

#Preview {
    EventListView()
}
