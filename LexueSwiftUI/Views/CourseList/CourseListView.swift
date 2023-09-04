//
//  CourseListView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI

struct CourseCardView: View {
    let cardHeight: CGFloat = 150
    let cardCornelRadius: CGFloat = 10
    let cardHorizontalPadding: CGFloat = 10
    
    @State var courseName = "课程名称"
    @State var courseCategory = "学院名称"
    @State var progress = 66
    var body: some View {
        ZStack {
            Image("default_course_bg")
                .resizable()
                .blur(radius: 2)
                .cornerRadius(cardCornelRadius)
                .padding(.horizontal, cardHorizontalPadding)
                .frame(height: cardHeight)
            
            Color.clear
                .background(.ultraThinMaterial)
                .cornerRadius(cardCornelRadius)
                .padding(.horizontal, cardHorizontalPadding)
                .frame(height: cardHeight)
                .opacity(0.8)
                
            
            VStack(alignment: .leading, spacing: 2) {
                Spacer()
                Text(courseName)
                    .bold()
                    .font(.title)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                    .padding(.leading, 10)
                
                Text(courseCategory)
                    .bold()
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                    .padding(.leading, 10)
                    .padding(.bottom, 5)
                ProgressView(value: Double(progress) / 100.0)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                    .accentColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .frame(height: cardHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, cardHorizontalPadding)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        
                    }) {
                        Image(systemName: "star")
                            .foregroundColor(.white)
                            .font(.system(size: 24).weight(.regular))
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .padding(.trailing, 10)
                    .padding(.top, 10)
                }
                Spacer()
            }
            .frame(height: cardHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, cardHorizontalPadding)
        }
    }
}

private struct ListView: View {
    @Binding var courses: [CourseShortInfo]
    @Binding var isRefreshing: Bool
    
    @Environment(\.refresh) private var refreshAction
    @ViewBuilder
    var refreshToolbar: some View {
        if let doRefresh = refreshAction {
            if isRefreshing {
                ProgressView()
            } else {
                Button(action: {
                    Task{
                        await doRefresh()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 20){
                    ForEach(courses) { item in
                        CourseCardView(courseName: item.shortname!, courseCategory: item.coursecategory!, progress: item.progress!)
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .toolbar {
                refreshToolbar
            }
        }
    }
}

struct CourseListView: View {
    @State private var courseList = GlobalVariables.shared.courseList
    @State var isRefreshing: Bool = false
    var body: some View {
        NavigationView {
            VStack {
                ListView(courses: $courseList, isRefreshing: $isRefreshing)
                    .refreshable {
                        print("refresh")
                    }
            }
            .navigationTitle("课程")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView()
    }
}
