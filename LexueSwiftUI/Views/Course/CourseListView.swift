//
//  CourseListView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI

struct CourseCardView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    let cardHeight: CGFloat = 150
    let cardCornelRadius: CGFloat = 10
    let cardHorizontalPadding: CGFloat = 10
    
    @Binding var courseId: String
    @Binding var courseName: String?
    @Binding var courseCategory: String?
    @Binding var isFavorite: Bool
    @Binding var progress: Int?
    @Binding var summary: String?
    
    @State var isActive: Bool = false
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
                Text(courseName!)
                    .bold()
                    .font(.title)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.leading, 10)
                
                Text(courseCategory!)
                    .bold()
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.leading, 10)
                    .padding(.bottom, 5)
                ProgressView(value: Double(progress!) / 100.0)
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
                        withAnimation {
                            CourseManager.shared.FavoriteCourse(courseId: courseId, isFavorite: !isFavorite, context: managedObjContext)
                        }
                    }) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundColor(isFavorite ? .yellow : .white)
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
            NavigationLink(destination:
                            CourseDetailView(courseName: courseName!),
               isActive: self.$isActive) {
                 EmptyView()
            }.hidden()
        }
        .onTapGesture {
            isActive = true
        }
        .contextMenu(menuItems: {
            Text("课程名: \(courseName!)")
        })
        .shadow(radius: 5, x: 0, y: 2)
    }
}

private struct ListView: View {
    @Binding var courses: [CourseShortInfo]
    @Binding var isRefreshing: Bool
    @Environment(\.isSearching) private var isSearching
    @Binding var searchText: String
    
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
                ForEach($courses) { item in
                    if !isSearching || searchText.isEmpty || (item.fullname.wrappedValue!.contains(searchText)) {
                        CourseCardView(courseId: item.id, courseName: item.fullname, courseCategory: item.coursecategory, isFavorite: item.local_favorite, progress: item.progress, summary: item.summary)
//                            .contextMenu {
//                                Text("课程名: \(item.fullname.wrappedValue!)")
//                            }
                    }
                }
            }
        }
        .toolbar {
            refreshToolbar
        }
    }
}

struct CourseListView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    @ObservedObject var courseManager = CourseManager.shared
    @Binding var tabSelection: Int
    
    @State var isRefreshing: Bool = false
    @State var searchText: String = ""
    var body: some View {
        NavigationView {
            if globalVar.isLogin {
                VStack {
                    ListView(courses: $courseManager.CourseDisplayList, isRefreshing: $isRefreshing, searchText: $searchText)
                        .refreshable {
                            isRefreshing = true
                            await CoreLogicManager.shared.UpdateCourseList()
                            isRefreshing = false
                        }
                }
                .searchable(text: $searchText, prompt: "搜索课程")
                .navigationTitle("课程")
                .navigationBarTitleDisplayMode(.large)
            } else {
                UnloginView(tabSelection: $tabSelection)
            }
        }
    }
}
