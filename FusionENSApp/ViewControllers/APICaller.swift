//
//  APICaller.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 05/09/2025.
//

import Foundation
import Alamofire

class APICaller {
    static let shared = APICaller()
    
    // Network configuration
    private let session: Session
    private var activeRequests: [String: DataRequest] = [:]
    
    // Offline cache for ENS resolutions
    private let offlineCache = UserDefaults(suiteName: "group.com.fusionens.keyboard")
    private let cacheKey = "ensOfflineCache"
    private let maxCacheSize = 100 // Maximum number of cached resolutions
    
    private init() {
        // Configure session with proper timeouts and security
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0 // 10 second timeout
        configuration.timeoutIntervalForResource = 15.0 // 15 second total timeout
        configuration.waitsForConnectivity = true
        
        // Create session with custom configuration
        self.session = Session(configuration: configuration)
    }
    
    func resolveENSName(name: String, completion: @escaping (String) -> Void) {
        // Cancel any existing request for this name
        cancelRequest(for: name)
        
        // Check offline cache first
        if let cachedAddress = getCachedResolution(for: name) {
            print("📱 APICaller: Using cached resolution for \(name): \(cachedAddress)")
            completion(cachedAddress)
            return
        }
        
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
    
    // Cancel specific request
    func cancelRequest(for name: String) {
        activeRequests[name]?.cancel()
        activeRequests.removeValue(forKey: name)
    }
    
    // Cancel all active requests
    func cancelAllRequests() {
        for (_, request) in activeRequests {
            request.cancel()
        }
        activeRequests.removeAll()
    }
    
    private func resolveWithFusionAPI(name: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(URLS.fusionNameResolver(name: name))") else {
            print("❌ APICaller: Invalid URL for Fusion API: \(name)")
            completion("")
            return
        }
        
        let request = session.request(url)
        activeRequests[name] = request
        
        request.response { [weak self] response in
            // Remove from active requests
            self?.activeRequests.removeValue(forKey: name)
            
            // Handle network errors
            if let error = response.error {
                print("❌ APICaller: Fusion API error for \(name): \(error.localizedDescription)")
                completion("")
                return
            }
            
            guard let data = response.data else {
                print("❌ APICaller: No data received from Fusion API for \(name)")
                completion("")
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    print("❌ APICaller: Invalid JSON from Fusion API for \(name)")
                    completion("")
                    return
                }
                
                // Handle Fusion API response format
                if let success = json["success"] as? Bool, success {
                    if let data = json["data"] as? [String: Any],
                       let address = data["address"] as? String, !address.isEmpty {
                        print("✅ APICaller: Successfully resolved \(name) to \(address)")
                        // Cache the successful resolution
                        self.cacheResolution(name: name, address: address)
                        completion(address)
                    } else {
                        print("❌ APICaller: No address in Fusion API response for \(name)")
                        completion("")
                    }
                } else {
                    print("❌ APICaller: Fusion API returned success=false for \(name)")
                    completion("")
                }
            } catch {
                print("❌ APICaller: JSON parsing error for \(name): \(error.localizedDescription)")
                completion("")
            }
        }
    }
    
    private func resolveWithENSIdeasAPI(name: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(URLS.ensIdeasResolver(name: name))") else {
            print("❌ APICaller: Invalid URL for ENS Ideas API: \(name)")
            completion("")
            return
        }
        
        let request = session.request(url)
        activeRequests[name] = request
        
        request.response { [weak self] response in
            // Remove from active requests
            self?.activeRequests.removeValue(forKey: name)
            
            // Handle network errors
            if let error = response.error {
                print("❌ APICaller: ENS Ideas API error for \(name): \(error.localizedDescription)")
                completion("")
                return
            }
            
            guard let data = response.data else {
                print("❌ APICaller: No data received from ENS Ideas API for \(name)")
                completion("")
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    print("❌ APICaller: Invalid JSON from ENS Ideas API for \(name)")
                    completion("")
                    return
                }
                
                // Handle ENS Ideas API response format
                if let address = json["address"] as? String, !address.isEmpty {
                    print("✅ APICaller: Successfully resolved \(name) to \(address) via ENS Ideas")
                    // Cache the successful resolution
                    self.cacheResolution(name: name, address: address)
                    completion(address)
                } else if let address = json["result"] as? String, !address.isEmpty {
                    print("✅ APICaller: Successfully resolved \(name) to \(address) via ENS Ideas (result)")
                    // Cache the successful resolution
                    self.cacheResolution(name: name, address: address)
                    completion(address)
                } else if let address = json["data"] as? String, !address.isEmpty {
                    print("✅ APICaller: Successfully resolved \(name) to \(address) via ENS Ideas (data)")
                    // Cache the successful resolution
                    self.cacheResolution(name: name, address: address)
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
                    
                    if let address = foundAddress {
                        print("✅ APICaller: Successfully resolved \(name) to \(address) via ENS Ideas (fallback)")
                        // Cache the successful resolution
                        self.cacheResolution(name: name, address: address)
                        completion(address)
                    } else {
                        print("❌ APICaller: No address found in ENS Ideas API response for \(name)")
                        completion("")
                    }
                }
            } catch {
                print("❌ APICaller: JSON parsing error for \(name): \(error.localizedDescription)")
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
    
    // MARK: - Offline Cache Management
    
    private func getCachedResolution(for name: String) -> String? {
        guard let cacheData = offlineCache?.data(forKey: cacheKey),
              let cache = try? JSONDecoder().decode([String: String].self, from: cacheData) else {
            return nil
        }
        return cache[name]
    }
    
    private func cacheResolution(name: String, address: String) {
        guard !address.isEmpty else { return }
        
        var cache: [String: String] = [:]
        if let cacheData = offlineCache?.data(forKey: cacheKey),
           let existingCache = try? JSONDecoder().decode([String: String].self, from: cacheData) {
            cache = existingCache
        }
        
        // Add new resolution
        cache[name] = address
        
        // Limit cache size by removing oldest entries
        if cache.count > maxCacheSize {
            let keysToRemove = Array(cache.keys.prefix(cache.count - maxCacheSize))
            keysToRemove.forEach { cache.removeValue(forKey: $0) }
        }
        
        // Save to UserDefaults
        if let cacheData = try? JSONEncoder().encode(cache) {
            offlineCache?.set(cacheData, forKey: cacheKey)
            offlineCache?.synchronize()
        }
    }
    
    func clearOfflineCache() {
        offlineCache?.removeObject(forKey: cacheKey)
        offlineCache?.synchronize()
    }
}

struct URLS {
    static let FUSION_BASEURL = "https://api.fusionens.com/"
    static let ENSIDEAS_BASEURL = "https://api.ensideas.com/"
    static let fusionResolve = FUSION_BASEURL + "resolve/"
    static let ensIdeasResolve = ENSIDEAS_BASEURL + "ens/resolve/"
    
    static func fusionNameResolver(name: String) -> String {
        return fusionResolve + name
    }
    
    static func ensIdeasResolver(name: String) -> String {
        return ensIdeasResolve + name
    }
    
    static func ensNameResolver(name: String) -> String {
        return fusionResolve + name
    }
    
    static func unsNameResolver(name: String) -> String {
        return fusionResolve + name
    }
}
