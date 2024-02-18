//
//  Score_MediumView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/18.
//

import WidgetKit
import SwiftUI

struct ScoreItemView: View {
    @State var color: Color
    @State var courseName: String
    @State var description: String
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 4)
                .foregroundColor(color)
                .cornerRadius(2)
            VStack {
                HStack {
                    Text(courseName)
                        .bold()
                        .font(.system(size: 17))
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.top, 1)
                HStack {
                    Text(description)
                        .font(.system(size: 15))
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.bottom, 1)
            }
            Spacer()
        }
        .frame(maxHeight: 60)
        .background(color.opacity(0.1))
    }
}

struct Score_MediumView: View {
    var entry: ScoreDefaultEntry = ScoreDefaultEntry()
    @State var limited_scores: [ScoreDiffCache] = []
    var firstLineSize: CGFloat = 14
    var secondLineSize: CGFloat = 16
    var limitCount: Int = 2
    var body: some View {
        VStack(spacing: 2) {
            if entry.isLogin && entry.isEnableScoreMonitor {
                HStack {
                    Text("乐学助手")
                        .font(.system(size: firstLineSize))
                    Text("|")
                        .font(.system(size: firstLineSize))
                    Text("成绩监控")
                        .font(.system(size: firstLineSize))
                    Spacer()
                }
                HStack(alignment: .bottom) {
                    Text("未读")
                        .font(.system(size: secondLineSize))
                    Text("\(entry.unread_cnt)")
                        .bold()
                        .foregroundColor(.green)
                        .font(.system(size: secondLineSize))
                    Text("个")
                        .font(.system(size: secondLineSize))
                    Text("|")
                        .font(.system(size: secondLineSize))
                    Text("总计")
                        .font(.system(size: secondLineSize))
                    Text("\(entry.total_cnt)")
                        .bold()
                        .foregroundColor(.blue)
                        .font(.system(size: secondLineSize))
                    Text("个")
                        .font(.system(size: secondLineSize))
                    Spacer()
                }
                .padding(.bottom, 3)
                ForEach(limited_scores) { score in
                    ScoreItemView(color: score.read ? .gray : .green, courseName: score.courseName ?? "未知", description: "我:\(score.myScore ?? "-") 均:\(score.avgScore ?? "-") 专业:\(score.scoreInMajor ?? "-")")
                }
                Spacer()
            } else {
                Spacer()
                Image(systemName: "person")
                HStack {
                    Spacer()
                    if entry.isLogin {
                        Text("请启用\"成绩监控\"消息源")
                            .multilineTextAlignment(.center)
                    } else {
                        Text("请先登录乐学助手")
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            // 最多显示 2 个
            for i in 0 ..< min(entry.scores.count, limitCount) {
                limited_scores.append(entry.scores[i])
            }
        }
    }
}

struct Score_MediumView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 17.0, *) {
            Score_MediumView()
                .containerBackground(.fill.tertiary, for: .widget)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        } else {
            Score_MediumView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
        
    }
}
