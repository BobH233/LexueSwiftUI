//
//  Score_LargeView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2024/2/18.
//

import WidgetKit
import SwiftUI

struct Score_LargeView: View {
    var entry: ScoreDefaultEntry = ScoreDefaultEntry()
    @State var limited_event: [ScoreDiffCache] = []
    let firstLineSize: CGFloat = 14
    let secondLineSize: CGFloat = 16
    var body: some View {
        Score_MediumView(entry: entry, firstLineSize: 16, secondLineSize: 18, limitCount: 6)
    }
}


struct Score_LargeView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 17.0, *) {
            Score_LargeView()
                .containerBackground(.fill.tertiary, for: .widget)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        } else {
            Score_LargeView()
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
        
    }
}
