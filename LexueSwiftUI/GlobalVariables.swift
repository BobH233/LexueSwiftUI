//
//  GlobalVariables.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import Foundation
import SwiftUI

class GlobalVariables {
    static let shared = GlobalVariables()
    @Published var isLogin = true
    
    var debugMode = true

    private init() {
        
    }
}
