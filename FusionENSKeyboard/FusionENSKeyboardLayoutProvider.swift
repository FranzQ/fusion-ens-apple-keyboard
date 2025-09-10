//
//  FusionENSKeyboardLayoutProvider.swift
//  FusionENSKeyboard
//
//  Created by Franz Quarshie on 05/09/2025.
//

import Foundation
import UIKit

class FusionENSKeyboardLayoutProvider {
    
    // Basic keyboard layout settings
    var rowHeight: CGFloat = 50.0
    var buttonSpacing: CGFloat = 5.0
    var buttonCornerRadius: CGFloat = 8.0
    
    init() {
        // Initialize with default values
    }
    
    func getKeyboardLayout() -> [[String]] {
        // Return iOS-standard QWERTY layout
        return [
            ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
            ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
            ["⇧", "Z", "X", "C", "V", "B", "N", "M", "⌫"],
            ["123", "🌐", "Space", "Return"]
        ]
    }
}

