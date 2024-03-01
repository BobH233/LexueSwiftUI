//
//  LexueWidgetBundle.swift
//  LexueWidget
//
//  Created by bobh on 2023/9/28.
//

import WidgetKit
import SwiftUI

@main
struct LexueWidgetBundle: WidgetBundle {
    var body: some Widget {
        LexueEventWidget()
        ScoreMonitorWidget()
        ScheduleWidget()
    }
}
