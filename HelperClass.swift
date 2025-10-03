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
        
        // Check for ENS domains (.eth) - now supports subdomains like jessie.base.eth and emoji characters
        let ensRegex = #"^[\p{L}\p{N}\p{M}\p{S}\p{P}\p{Z}.-]+\.eth$"#
        if let regex = try? NSRegularExpression(pattern: ensRegex) {
            let matches = regex.matches(in: text, options: [], range: range)
            if matches.count > 0 {
                return true
            }
        }
        
        // Check for multi-chain domains (old format: name.chain) - now supports subdomains and emoji characters
        let multiChainRegex = #"^[\p{L}\p{N}\p{M}\p{S}\p{P}\p{Z}.-]+\.(btc|sol|doge|xrp|ltc|ada|base|arbi|polygon|avax|bsc|op|zora|linea|scroll|mantle|celo|gnosis|fantom)$"#
        if let regex = try? NSRegularExpression(pattern: multiChainRegex) {
            let matches = regex.matches(in: text, options: [], range: range)
            if matches.count > 0 {
                return true
            }
        }
        
        // Check for text record domains (old format: name.textrecord) - now supports subdomains and emoji characters
        let textRecordRegex = #"^[\p{L}\p{N}\p{M}\p{S}\p{P}\p{Z}.-]+\.(x|url|github|name|bio|description|avatar|header)$"#
        if let regex = try? NSRegularExpression(pattern: textRecordRegex) {
            let matches = regex.matches(in: text, options: [], range: range)
            if matches.count > 0 {
                return true
            }
        }
        
        // Check for new format (name.eth:chain or name.eth:textrecord) - now supports subdomains and emoji characters
        let newFormatRegex = #"^[\p{L}\p{N}\p{M}\p{S}\p{P}\p{Z}.-]+\.eth:(btc|sol|doge|xrp|ltc|ada|base|arbi|polygon|avax|bsc|op|zora|linea|scroll|mantle|celo|gnosis|fantom|x|url|github|name|bio|description|avatar|header)$"#
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
    
    // MARK: - Browser Default Action Support
    
    /// Gets the user's default browser action for ENS resolution
    /// - Returns: The default browser action
    public static func getDefaultBrowserAction() -> BrowserAction {
        let defaults = UserDefaults(suiteName: "group.com.fusionens.keyboard")
        let rawValue = defaults?.string(forKey: "defaultBrowserAction") ?? "etherscan"
        return BrowserAction(rawValue: rawValue) ?? .etherscan
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
    
    /// Converts a text record type and value to a URL
    /// - Parameters:
    ///   - recordType: The type of text record (e.g., "url", "github", "x")
    ///   - value: The value of the text record
    /// - Returns: A URL string, or nil if conversion fails
    public static func convertTextRecordToURL(recordType: String, value: String) -> String? {
        switch recordType.lowercased() {
        case "url":
            return value.hasPrefix("http") ? value : "https://\(value)"
        case "github":
            return "https://github.com/\(value)"
        case "x", "twitter":
            return "https://x.com/\(value)"
        case "name", "bio", "description", "avatar", "header":
            return nil // These don't convert to URLs
        default:
            return nil
        }
    }
}

// MARK: - Browser Action Enum

public enum BrowserAction: String, CaseIterable {
    case etherscan = "etherscan"
    case url = "url"
    case github = "github"
    case x = "x"
    
    public var displayName: String {
        switch self {
        case .etherscan:
            return "Etherscan"
        case .url:
            return "Website"
        case .github:
            return "GitHub"
        case .x:
            return "X (Twitter)"
        }
    }
}
