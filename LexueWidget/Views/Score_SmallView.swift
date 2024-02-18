//
//  Score_SmallView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/18.
//

import WidgetKit
import SwiftUI

struct Score_SmallView: View {
    var entry: ScoreDefaultEntry = ScoreDefaultEntry()
    func GetFontSize() -> CGFloat {
        if entry.size.height <= 148 {
            return 15
        } else if entry.size.height <= 158 {
            return 17
        } else {
            return 20
        }
    }
    func GetVSpacing() -> CGFloat {
        if entry.size.height <= 148 {
            return 5
        } else if entry.size.height <= 158 {
            return 7
        } else {
            return 10
        }
    }
    var body: some View {
        VStack(spacing: GetVSpacing()) {
            if entry.isLogin && entry.isEnableScoreMonitor {
                
                HStack {
                    Text("乐学助手")
                        .font(.system(size: GetFontSize()))
                    Spacer()
                }
                HStack {
                    Text("成绩监控")
                        .font(.system(size: GetFontSize()))
                        .bold()
                    Spacer()
                }
                HStack(alignment: .bottom) {
                    Rectangle()
                        .frame(width: 4)
                        .foregroundColor(.green)
                        .cornerRadius(2)
                    Text("未读")
                    Text("\(entry.unread_cnt)")
                        .font(.system(size: 25))
                        .bold()
                        .foregroundColor(.green)
                    Text("门")
                    Spacer()
                }
                HStack(alignment: .bottom) {
                    Rectangle()
                        .frame(width: 4)
                        .foregroundColor(.blue)
                        .cornerRadius(2)
                    Text("总计")
                    Text("\(entry.total_cnt)")
                        .font(.system(size: 25))
                        .bold()
                        .foregroundColor(.blue)
                    Text("门")
                    Spacer()
                }
                .padding(.bottom, 5)
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
    }
}

struct Score_SmallView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 17.0, *) {
            Score_SmallView(entry: ScoreDefaultEntry(isLogin: true))
                .containerBackground(.fill.tertiary, for: .widget)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        } else {
            Score_SmallView(entry: ScoreDefaultEntry(isLogin: true))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
        
    }
}
