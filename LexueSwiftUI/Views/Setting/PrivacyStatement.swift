//
//  PrivacyStatement.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/28.
//

import SwiftUI

struct PrivacyStatement: View {
    var body: some View {
        Form {
            Section("您的以下信息被收集") {
                HStack {
                    Text("设备标识(umid)")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(UMCommonSwift.umidString())
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                }
            }
        }
        .navigationTitle("隐私声明")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    PrivacyStatement()
}
