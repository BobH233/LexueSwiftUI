//
//  AlertData.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/12/12.
//

import Foundation
import SwiftUI

struct AlertData: Identifiable {
    var id: UUID = UUID()
    var title: String = ""
    var actionsView: AnyView = AnyView(
        EmptyView()
    )
    var messageView: AnyView = AnyView(
        Text("这是一条信息")
    )
}


