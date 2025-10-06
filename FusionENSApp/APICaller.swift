//
//  APICaller.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 17/09/2025.
//

import Foundation
import Alamofire

/// A shared API client for resolving ENS (Ethereum Name Service) names to addresses
/// Supports multiple chains and text records through Fusion API and ENSData API
class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    /// Resolves an ENS name to its corresponding address
    /// - Parameters:
    ///   - name: The ENS name to resolve (e.g., "vitalik.eth", "onshow.eth:btc")
    ///   - completion: Completion handler that returns the resolved address or empty string if not found
    func resolveENSName(name: String, completion: @escaping (String) -> Void) {
        let chain = detectChain(name)
        
        // Check if this is a text record (like .x, .url, .github) that should be resolved from .eth
        let isTextRecord = ["x", "url", "github", "name", "bio"].contains { name.hasSuffix(".\($0)") }
        
        if isTextRecord {
            // Use Fusion API for text records (.x, .url, .github, etc.)
            resolveWithFusionAPI(name: name, completion: completion)
        } else {
            // Check if this is an ETH subdomain (.base.eth, .uni.eth, etc.)
            let isEthSubdomain = name.hasSuffix(".eth") && name.contains(".")
            if isEthSubdomain {
                // For ETH subdomains (.base.eth, .uni.eth, etc.), use ENSData API
                resolveWithENSDataAPI(name: name) { address in
                    completion(address)
                }
            } else {
                // Use Fusion API for all other ENS names (including regular .eth)
                resolveWithFusionAPI(name: name) { address in
                    if !address.isEmpty {
                        completion(address)
                    } else {
                        // Fallback to ENSData API
                        self.resolveWithENSDataAPI(name: name, completion: completion)
                    }
                }
            }
        }
    }
    
    private func resolveWithFusionAPI(name: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(URLS.fusionNameResolver(name: name))") else {
            completion("")
            return
        }
        
        AF.request(url).response { response in
            guard let data = response.data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            else {
                completion("")
                return
            }
            
            // Handle Fusion API response format
            if let success = json["success"] as? Bool, success {
                if let data = json["data"] as? [String: Any],
                   let address = data["address"] as? String {
                    completion(address)
                } else {
                    completion("")
                }
            } else {
                completion("")
            }
        }
    }
    
    
    private func resolveWithENSDataAPI(name: String, completion: @escaping (String) -> Void) {
        let urlString = "\(URLS.ensDataResolver(name: name))"
        guard let url = URL(string: urlString) else {
            completion("")
            return
        }
        
        // Add timeout configuration
        let session = AF.session
        session.configuration.timeoutIntervalForRequest = 3.0
        session.configuration.timeoutIntervalForResource = 5.0
        
        AF.request(url).response { response in
            guard let data = response.data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            else {
                completion("")
                return
            }
            
            // Handle ENSData API response format
            if let address = json["address"] as? String, !address.isEmpty {
                completion(address)
            } else {
                completion("")
            }
        }
    }
    
    private func detectChain(_ name: String) -> String {
        if name.hasSuffix(".eth") {
            return "eth"
        } else if name.hasSuffix(".btc") {
            return "btc"
        } else if name.hasSuffix(".sol") {
            return "sol"
        } else if name.hasSuffix(".doge") {
            return "doge"
        } else if name.hasSuffix(".x") {
            return "x"
        } else if name.hasSuffix(".url") {
            return "url"
        } else if name.hasSuffix(".github") {
            return "github"
        } else if name.hasSuffix(".bio") {
            return "bio"
        } else if name.contains(":") {
            // Handle new format like onshow.eth:btc
            let parts = name.components(separatedBy: ":")
            if parts.count == 2 {
                return parts[1]
            }
        }
        return "eth" // Default to eth
    }
    
    // Keep the old method name for backward compatibility
    func resolveFusionENSName(name: String, completion: @escaping (String) -> Void) {
        resolveENSName(name: name, completion: completion)
    }
}
