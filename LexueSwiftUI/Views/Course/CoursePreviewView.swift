//
//  CoursePreviewView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/25.
//

import SwiftUI

@available(iOS 15, *)
struct HTMLText: View {
    var html = "<b>This is</b> <i>rich</i> <u>HTML</u> <span style=\"color: red;\">text</span>."
    var body: some View {
        if let nsAttributedString = try? NSAttributedString(data: Data(html.data(using: String.Encoding.unicode)!), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil),
           let attributedString = try? AttributedString(nsAttributedString, including: \.uiKit) {
            Text(attributedString)
        } else {
            Text(html)
        }
    }
}

struct CoursePreviewView: View {
    var courseName: String = "test啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    var summary: String = "<b>This is啊啊啊？？</b> <i>rich</i> <u>HTML</u> <span style=\"color: red;\">text</span>."
    var body: some View {
        VStack{
            Group{
                Text(courseName)
                    .foregroundColor(.blue)
                    .bold()
                    .lineLimit(100)
                    .font(.system(size: 30))
                    .lineLimit(nil)
                Divider()
                HTMLText(html: summary)
            }
            .padding()
        }
        .frame(height: 500)
    }
}

#Preview {
    CoursePreviewView()
}
