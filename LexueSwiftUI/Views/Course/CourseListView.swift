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
    
    // TODO: remove this when release
    @State var debug_use_lazy_v_stack: Bool
    
    @State var courseName = "课程名称"
    @State var courseCategory = "学院名称"
    @State var progress = 66
    var body: some View {
        ZStack {
            Image("default_course_bg")
                .resizable()
                .blur(radius: 5, opaque: true)
                .cornerRadius(cardCornelRadius)
                .padding(.horizontal, cardHorizontalPadding)
                .frame(height: cardHeight)
            Color.white
                .cornerRadius(cardCornelRadius)
                .padding(.horizontal, cardHorizontalPadding)
                .frame(height: cardHeight)
                .opacity(0.1)
            
            VStack(alignment: .leading, spacing: 2) {
                Spacer()
                Text(courseName)
                    .bold()
                    .font(.title)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.leading, 10)
                
                Text(courseCategory)
                    .bold()
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.leading, 10)
                    .padding(.bottom, 5)
                ProgressView(value: Double(progress) / 100.0)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                    .accentColor(.white)
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
        .shadow(radius: 5, x: 0, y: 2)
    }
}

private struct ListView: View {
    @Binding var courses: [CourseShortInfo]
    @Binding var isRefreshing: Bool
    
    // TODO: remove this when release
    @State var debug_use_lazy_v_stack: Bool
    
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
        ScrollView(.vertical) {
            LazyVStack(spacing: 20){
                ForEach(courses) { item in
                    CourseCardView(debug_use_lazy_v_stack: debug_use_lazy_v_stack, courseName: item.fullname!, courseCategory: item.coursecategory!, progress: item.progress!)
                }
            }
        }
        .toolbar {
            refreshToolbar
        }
    }
}

struct CourseListView: View {
    @State private var courseList = GlobalVariables.shared.courseList
    @State var isRefreshing: Bool = false
    @State var searchText: String = ""
    @State var debug_use_lazy_v_stack: Bool = true
    func testRefresh() async {
        Task {
            isRefreshing = true
            Thread.sleep(forTimeInterval: 1.5)
            withAnimation {
                isRefreshing = false
            }
        }
    }
    var body: some View {
        NavigationView {
            VStack {
                ListView(courses: $courseList, isRefreshing: $isRefreshing, debug_use_lazy_v_stack: debug_use_lazy_v_stack)
                    .refreshable {
                        print("refresh")
                        await testRefresh()
                    }
            }
            .searchable(text: $searchText, prompt: "搜索课程")
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
