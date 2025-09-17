//
//  APICaller.swift
//  FusionENSUIKitKeyboard
//
//  Created by Franz Quarshie on 17/09/2025.
//

import Foundation
import Alamofire

class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
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
                // For ETH subdomains (.base.eth, .uni.eth, etc.), use ENS Ideas API only
                resolveWithENSIdeasAPI(name: name, completion: completion)
            } else if chain == "eth" {
                // For .eth domains, use Fusion API
                resolveWithFusionAPI(name: name, completion: completion)
            } else {
                // For multi-chain domains (.btc, .sol, .doge, etc.), use Fusion API first
                resolveWithFusionAPI(name: name) { address in
                    if !address.isEmpty {
                        completion(address)
                    } else {
                        // Fallback to ENS Ideas API
                        self.resolveWithENSIdeasAPI(name: name, completion: completion)
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
    
    private func resolveWithENSIdeasAPI(name: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(URLS.ensIdeasResolver(name: name))") else {
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
            
            // Handle ENS Ideas API response format
            if let address = json["address"] as? String {
                completion(address)
            } else if let address = json["result"] as? String {
                completion(address)
            } else if let address = json["data"] as? String {
                completion(address)
            } else {
                // Try to find any field that might contain the address
                let possibleAddressFields = ["address", "result", "data", "mappedAddress", "resolvedAddress"]
                var foundAddress: String?
                
                for field in possibleAddressFields {
                    if let value = json[field] as? String, !value.isEmpty {
                        foundAddress = value
                        break
                    }
                }
                
                completion(foundAddress ?? "")
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
            // Handle new format like vitalik.eth:btc
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