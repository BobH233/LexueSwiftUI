//
//  ContactDetaiView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/8.
//

import SwiftUI

struct ContactDetailView: View {
    var body: some View {
        Form {
            Text("hello!")
        }
        .navigationTitle("编辑联系人")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContactDetailView()
}
