//
//  HelperClass.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 17/09/2025.
//

import Foundation

class HelperClass {
    
    /// Validates if the given text matches ENS domain format
    /// - Parameter text: The text to validate
    /// - Returns: True if the text is a valid ENS domain format
    static func checkFormat(_ text: String) -> Bool {
        // Check for ENS domains (.eth) - now supports subdomains like jessie.base.eth and emoji characters
        let ensRegex = #"^[\p{L}\p{N}\p{M}\p{S}\p{P}\p{Z}.-]+\.eth$"#
        let range = NSRange(location: 0, length: text.utf16.count)
        
        if let regex = try? NSRegularExpression(pattern: ensRegex) {
            let matches = regex.matches(in: text, options: [], range: range)
            if matches.count > 0 {
                return true
            }
        }
        
        // Also check for multi-chain domains (.btc, .sol, .doge, etc.) - now supports subdomains and emoji characters
        let multiChainRegex = #"^[\p{L}\p{N}\p{M}\p{S}\p{P}\p{Z}.-]+\.(btc|sol|doge|x|url|github|bio)$"#
        
        if let regex = try? NSRegularExpression(pattern: multiChainRegex) {
            let matches = regex.matches(in: text, options: [], range: range)
            if matches.count > 0 {
                return true
            }
        }
        
        // Check for new format like onshow.eth:btc - now supports subdomains and emoji characters
        let newFormatRegex = #"^[\p{L}\p{N}\p{M}\p{S}\p{P}\p{Z}.-]+\.eth:[\p{L}\p{N}\p{M}\p{S}\p{P}\p{Z}-]+$"#
        
        if let regex = try? NSRegularExpression(pattern: newFormatRegex) {
            let matches = regex.matches(in: text, options: [], range: range)
            if matches.count > 0 {
                return true
            }
        }
        
        return false
    }
    
    /// Alias for checkFormat for better readability
    /// - Parameter text: The text to validate
    /// - Returns: True if the text is a valid ENS domain format
    static func isValidENS(_ text: String) -> Bool {
        return checkFormat(text)
    }
}
