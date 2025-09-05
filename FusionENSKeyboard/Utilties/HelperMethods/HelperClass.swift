//
//  HelperClass.swift
//  FusionENSKeyboard
//
//  Created by Franz Quarshie on 05/09/2025.
//

import Foundation

class HelperClass{
    
    static func checkFormat(_ text: String) -> Bool {
        // Check for ENS domains (.eth)
        let ensRegex = #"^[a-zA-Z0-9-]+\.eth$"#
        let range = NSRange(location: 0, length: text.utf16.count)
        
        if let regex = try? NSRegularExpression(pattern: ensRegex) {
            let matches = regex.matches(in: text, options: [], range: range)
            if matches.count > 0 {
                return true
            }
        }
        
        // Also check for the original fusion format (btc, eth, web, twitter)
        let formatRegex = #"^(\w+)\.(\w+)$"#
        let tickerRegex = #"^(btc|eth|web|twitter)$"#
        
        if let regex = try? NSRegularExpression(pattern: formatRegex) {
            let matches = regex.matches(in: text, options: [], range: range)
            
            if matches.count > 0 {
                let secondStringRange = matches[0].range(at: 2)
                let secondString = (text as NSString).substring(with: secondStringRange)
                
                if let tickerMatch = try? NSRegularExpression(pattern: tickerRegex) {
                    let tickerMatches = tickerMatch.matches(in: secondString, options: [], range: NSRange(location: 0, length: secondString.utf16.count))
                    
                    return tickerMatches.count > 0
                }
            }
        }
        
        return false
    }
}
