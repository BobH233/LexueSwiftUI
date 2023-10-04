//
//  AboutView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/4.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        Form {
            
            NavigationLink("开源包引用声明", destination: {
                PackageDeclarationView()
            })
        }
        .navigationTitle("关于")
    }
}

#Preview {
    AboutView()
}
