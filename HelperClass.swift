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
        let range = NSRange(location: 0, length: text.utf16.count)
        
        // Check for ENS domains (.eth)
        let ensRegex = #"^[a-zA-Z0-9-]+\.eth$"#
        if let regex = try? NSRegularExpression(pattern: ensRegex) {
            let matches = regex.matches(in: text, options: [], range: range)
            if matches.count > 0 {
                return true
            }
        }
        
        // Check for multi-chain domains (old format: name.chain)
        let multiChainRegex = #"^[a-zA-Z0-9-]+\.(btc|sol|doge|xrp|ltc|ada|base|arbi|polygon|avax|bsc|op|zora|linea|scroll|mantle|celo|gnosis|fantom)$"#
        if let regex = try? NSRegularExpression(pattern: multiChainRegex) {
            let matches = regex.matches(in: text, options: [], range: range)
            if matches.count > 0 {
                return true
            }
        }
        
        // Check for text record domains (old format: name.textrecord)
        let textRecordRegex = #"^[a-zA-Z0-9-]+\.(x|url|github|name|bio|description|avatar|header)$"#
        if let regex = try? NSRegularExpression(pattern: textRecordRegex) {
            let matches = regex.matches(in: text, options: [], range: range)
            if matches.count > 0 {
                return true
            }
        }
        
        // Check for new format (name.eth:chain or name.eth:textrecord)
        let newFormatRegex = #"^[a-zA-Z0-9-]+\.eth:(btc|sol|doge|xrp|ltc|ada|base|arbi|polygon|avax|bsc|op|zora|linea|scroll|mantle|celo|gnosis|fantom|x|url|github|name|bio|description|avatar|header)$"#
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
