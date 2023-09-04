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
        }
    }
}

struct CourseListView: View {
    var body: some View {
        NavigationView {
            Text("CourseListView")
                .navigationTitle("CourseListView")
        }
    }
}

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseCardView()
    }
}
