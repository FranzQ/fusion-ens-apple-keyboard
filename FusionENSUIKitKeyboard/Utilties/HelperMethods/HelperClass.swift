//
//  HelperClass.swift
//  FusionENSUIKitKeyboard
//
//  Created by Franz Quarshie on 17/09/2025.
//

import Foundation

class HelperClass {
    
    static func checkFormat(_ text: String) -> Bool {
        // Simple ENS domain format check
        // This is a basic implementation - you can enhance it as needed
        let ensPattern = "^[a-z0-9-]+\\.eth$"
        let regex = try? NSRegularExpression(pattern: ensPattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: text.utf16.count)
        return regex?.firstMatch(in: text, options: [], range: range) != nil
    }
    
    static func isValidENS(_ text: String) -> Bool {
        return checkFormat(text)
    }
}