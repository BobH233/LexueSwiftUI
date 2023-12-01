//
//  Feedback.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/14.
//

import SwiftUI
import MarkdownUI

func GetBetaURL() -> String? {
    guard let path = Bundle.main.path(forResource: "KeyInfo", ofType: "plist") else { return "" }
    let keys = NSDictionary(contentsOfFile: path)
    return keys?.value(forKey: "TestFlightUrl") as? String
}

let markdownFeedbackTipsForTestFlight = """
# 感谢您参与内部测试，您的反馈至关重要！

我们非常乐意倾听您对于“i乐学助手”的建议，也欢迎您提出功能上的需求。如果您在使用中遇到任何bug，或者对于功能的缺失感到失望，欢迎您联系我们。

您可通过TestFlight及时向开发者反馈出现的问题，劳烦您提供出现问题的详细位置、问题截图等信息方便我们更快速处理这些问题，我们会收集内测时产生的崩溃日志信息以供修复。

**欢迎您添加意见反馈QQ群：297983455**，提出您宝贵的意见，对“i乐学助手”有帮助的建议我们都会采纳并附上感谢！

您也可以向开发者发送邮件：[admin@bit-helper.cn](mailto:admin@bit-helper.cn)

"""


// Apple 不允许应用内有引导用户进行加qq群类似的操作
let markdownFeedbackTipsForCommonUser = """
# 您的反馈至关重要！

我们非常乐意倾听您对于“i乐学助手”的建议，也欢迎您提出功能上的需求。如果您在使用中遇到任何bug，或者对于功能的缺失感到失望，欢迎您联系我们。

欢迎您直接联系开发者[admin@bit-helper.cn](mailto:admin@bit-helper.cn)，提出您宝贵的意见，对“i乐学助手”有帮助的建议我们都会采纳并附上感谢！

# 欢迎参与内测

如果您希望尽早体验到“i乐学助手”的最新功能，且愿意牺牲部分的app稳定性，您可以加入以下TestFlight群组参与内测，并及时反馈最新的问题，以便我们能在正式版上线前修复这些问题

[点我参与内测](\(GetBetaURL() ?? ""))

"""

struct Feedback: View {
    var body: some View {
        Form {
            Section() {
                if GlobalVariables.shared.TEST_FLIGHT_BUILD {
                    Markdown(markdownFeedbackTipsForTestFlight)
                } else {
                    Markdown(markdownFeedbackTipsForCommonUser)
                }
            }
        }
        .navigationTitle("反馈意见")
    }
}

#Preview {
    Feedback()
}
