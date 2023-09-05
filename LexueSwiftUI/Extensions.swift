//
//  Extensions.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/5.
//

import Foundation
import SwiftUI


struct OnFirstAppearModifier: ViewModifier {
    let perform:() -> Void
    @State private var firstTime: Bool = true
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if firstTime {
                    firstTime = false
                    self.perform()
                }
            }
    }
}


extension View {
    func onFirstAppear( perform: @escaping () -> Void ) -> some View {
        return self.modifier(OnFirstAppearModifier(perform: perform))
    }
}
