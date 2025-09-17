//
//  KeyboardType.swift
//  FusionENSKeyboard
//
//  Created by Franz Quarshie on 12/09/2025.
//

import Foundation

enum KeyboardType: String, CaseIterable {
    case uikit = "UIKit"
    case swiftui = "SwiftUI"
    
    var displayName: String {
        switch self {
        case .uikit:
            return "UIKit (Default)"
        case .swiftui:
            return "SwiftUI (Modern)"
        }
    }
}
