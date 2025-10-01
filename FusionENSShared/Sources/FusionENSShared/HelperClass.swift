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
    
    /// Checks if the given ENS name is an L2 subdomain
    /// - Parameter ensName: The ENS name to check
    /// - Returns: True if it's an L2 subdomain (.base.eth, .polygon.eth, .arbitrum.eth, .optimism.eth)
    public static func isL2Subdomain(_ ensName: String) -> Bool {
        let l2Suffixes = [".base.eth", ".polygon.eth", ".arbitrum.eth", ".optimism.eth"]
        return l2Suffixes.contains { ensName.hasSuffix($0) }
    }
    
    /// Gets the L2 network type from an ENS subdomain
    /// - Parameter ensName: The ENS name to check
    /// - Returns: The L2 network type, or nil if not an L2 subdomain
    public static func getL2NetworkType(_ ensName: String) -> L2NetworkType? {
        if ensName.hasSuffix(".base.eth") {
            return .base
        } else if ensName.hasSuffix(".polygon.eth") {
            return .polygon
        } else if ensName.hasSuffix(".arbitrum.eth") {
            return .arbitrum
        } else if ensName.hasSuffix(".optimism.eth") {
            return .optimism
        }
        return nil
    }
    
    /// Resolves an L2 subdomain to its explorer URL using the resolved address
    /// - Parameters:
    ///   - ensName: The L2 subdomain (e.g., "jessie.base.eth", "alice.polygon.eth")
    ///   - resolvedAddress: The resolved Ethereum address
    /// - Returns: The explorer URL for the address
    public static func resolveL2SubdomainToExplorer(_ ensName: String, resolvedAddress: String) -> String {
        guard let networkType = getL2NetworkType(ensName) else {
            return "https://etherscan.io/address/\(resolvedAddress)" // Fallback to Etherscan
        }
        
        switch networkType {
        case .base:
            return "https://basescan.org/address/\(resolvedAddress)"
        case .polygon:
            return "https://polygonscan.com/address/\(resolvedAddress)"
        case .arbitrum:
            return "https://arbiscan.io/address/\(resolvedAddress)"
        case .optimism:
            return "https://optimistic.etherscan.io/address/\(resolvedAddress)"
        }
    }
    
    /// L2 Network types supported for subdomain detection
    public enum L2NetworkType: String, CaseIterable {
        case base = "base"
        case polygon = "polygon"
        case arbitrum = "arbitrum"
        case optimism = "optimism"
        
        public var displayName: String {
            switch self {
            case .base:
                return "Base"
            case .polygon:
                return "Polygon"
            case .arbitrum:
                return "Arbitrum"
            case .optimism:
                return "Optimism"
            }
        }
        
        public var explorerName: String {
            switch self {
            case .base:
                return "BaseScan"
            case .polygon:
                return "PolygonScan"
            case .arbitrum:
                return "Arbiscan"
            case .optimism:
                return "Optimistic Etherscan"
            }
        }
    }
    
    // MARK: - Default Browser Action Management
    
    /// Default browser action types
    public enum DefaultBrowserAction: String, CaseIterable {
        case url = "url"
        case github = "github"
        case x = "x"
        case etherscan = "etherscan"
        
        public var displayName: String {
            switch self {
            case .url:
                return "Open Website"
            case .github:
                return "Open GitHub"
            case .x:
                return "Open X/Twitter"
            case .etherscan:
                return "Open Etherscan"
            }
        }
    }
    
    /// Get the user's default browser action setting
    /// - Returns: The default browser action, defaults to .url
    public static func getDefaultBrowserAction() -> DefaultBrowserAction {
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        if let savedAction = userDefaults.string(forKey: "defaultBrowserAction"),
           let action = DefaultBrowserAction(rawValue: savedAction) {
            return action
        }
        return .url // Default to URL
    }
    
    /// Set the user's default browser action setting
    /// - Parameter action: The default browser action to set
    public static func setDefaultBrowserAction(_ action: DefaultBrowserAction) {
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        userDefaults.set(action.rawValue, forKey: "defaultBrowserAction")
        userDefaults.synchronize()
    }
    
    /// Gets whether L2 chain detection is enabled
    /// - Returns: True if L2 chain detection is enabled
    public static func isL2ChainDetectionEnabled() -> Bool {
        let defaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        return defaults.bool(forKey: "l2ChainDetectionEnabled")
    }
    
    /// Sets whether L2 chain detection is enabled
    /// - Parameter enabled: Whether to enable L2 chain detection
    public static func setL2ChainDetectionEnabled(_ enabled: Bool) {
        let defaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        defaults.set(enabled, forKey: "l2ChainDetectionEnabled")
        defaults.synchronize()
    }
    
    /// Convert text record value to appropriate URL based on record type
    /// - Parameters:
    ///   - recordType: The type of text record (x, url, github, etc.)
    ///   - value: The value of the text record
    /// - Returns: The appropriate URL for the record type and value
    public static func convertTextRecordToURL(recordType: String, value: String) -> String {
        switch recordType {
        case "x":
            // Twitter/X handle
            if value.hasPrefix("@") {
                return "https://x.com/\(String(value.dropFirst()))"
            } else {
                return "https://x.com/\(value)"
            }
        case "url":
            // Direct URL
            if value.hasPrefix("http://") || value.hasPrefix("https://") {
                return value
            } else {
                return "https://\(value)"
            }
        case "github":
            // GitHub profile
            if value.hasPrefix("@") {
                return "https://github.com/\(String(value.dropFirst()))"
            } else {
                return "https://github.com/\(value)"
            }
        case "name":
            // Name - could be a search or profile
            return "https://google.com/search?q=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value)"
        case "bio", "description":
            // Bio - could be a search
            return "https://google.com/search?q=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value)"
        default:
            // Default to search
            return "https://google.com/search?q=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value)"
        }
    }
}
