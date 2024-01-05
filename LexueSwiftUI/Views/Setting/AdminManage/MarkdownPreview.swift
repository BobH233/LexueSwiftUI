//
//  MarkdownPreview.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/1/5.
//

import SwiftUI

struct MarkdownPreview: View {
    @Binding var makrdownContent: String
    @Binding var isPinned: Bool
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                NotificationCard(image_name: isPinned ? "pin.fill" : "paperplane.fill", title: isPinned ? "置顶公告" : "公告", timeStr: GetDateDescriptionText(sendDate: Date.now), markdownContent: makrdownContent)
            }
            .frame(maxWidth: 500)
            .padding()
        }
    }
}

//
//#Preview {
//    MarkdownPreview()
//}
