//
//  Feedback.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/14.
//

import SwiftUI
import MarkdownUI

let markdownFeedbackTips = """
# 您的反馈至关重要！

我们非常乐意倾听您对于“乐学助手”的建议，也欢迎您提出功能上的需求。如果您在使用中遇到任何bug，或者对于功能的缺失感到失望，欢迎您联系我们。

欢迎您添加意见反馈QQ群：297983455，提出您宝贵的意见，对“乐学助手”有帮助的建议我们都会采纳并附上感谢！

您也可以向开发者发送邮件：[bobh@zendee.cn](mailto:bobh@zendee.cn)

"""

struct Feedback: View {
    var body: some View {
        Form {
            Section() {
                Markdown(markdownFeedbackTips)
            }
        }
        .navigationTitle("反馈意见")
    }
}

#Preview {
    Feedback()
}
