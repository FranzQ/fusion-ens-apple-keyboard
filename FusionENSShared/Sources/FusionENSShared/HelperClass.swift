//
//  HelperClass.swift
//  FusionENSShared
//
//  Created by Franz Quarshie on 17/09/2025.
//

import Foundation

public class HelperClass {
    
    /// Validates if the given text matches ENS domain format
    /// - Parameter text: The text to validate
    /// - Returns: True if the text is a valid ENS domain format
    public static func checkFormat(_ text: String) -> Bool {
        // Check for ENS domains (.eth) - now supports subdomains like jessie.base.eth
        let ensRegex = #"^[a-zA-Z0-9.-]+\.eth$"#
        let range = NSRange(location: 0, length: text.utf16.count)
        
        if let regex = try? NSRegularExpression(pattern: ensRegex) {
            let matches = regex.matches(in: text, options: [], range: range)
            if matches.count > 0 {
                return true
            }
        }
        
        // Also check for multi-chain domains (.btc, .sol, .doge, etc.) - now supports subdomains
        let multiChainRegex = #"^[a-zA-Z0-9.-]+\.(btc|sol|doge|x|url|github|bio)$"#
        
        if let regex = try? NSRegularExpression(pattern: multiChainRegex) {
            let matches = regex.matches(in: text, options: [], range: range)
            if matches.count > 0 {
                return true
            }
        }
        
        // Check for new format like vitalik.eth:btc - now supports subdomains
        let newFormatRegex = #"^[a-zA-Z0-9.-]+\.eth:[a-zA-Z0-9-]+$"#
        
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
    public static func isValidENS(_ text: String) -> Bool {
        return checkFormat(text)
    }
}
