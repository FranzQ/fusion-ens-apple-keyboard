//
//  FusionENSAutoCompleteProvider.swift
//  FusionENSKeyboard
//
//  Created by Franz Quarshie on 05/09/2025.
//

import Foundation

class FusionENSAutoCompleteProvider {
    
    // API base URL - same as Chrome extension
    private let API_BASE_URL = "https://api.fusionens.com"
    
    // Multi-chain regex - same as Chrome extension, now supports emoji characters
    private let multiChainRegex = try! NSRegularExpression(pattern: "^[\\p{L}\\p{N}\\p{M}\\p{S}\\p{P}\\p{Z}][\\p{L}\\p{N}\\p{M}\\p{S}\\p{P}\\p{Z}-]{0,61}[\\p{L}\\p{N}\\p{M}\\p{S}\\p{P}\\p{Z}](\\.[\\p{L}\\p{N}\\p{M}\\p{S}\\p{P}\\p{Z}][\\p{L}\\p{N}\\p{M}\\p{S}\\p{P}\\p{Z}-]{0,61}[\\p{L}\\p{N}\\p{M}\\p{S}\\p{P}\\p{Z}])*(\\.[\\p{L}\\p{N}\\p{M}\\p{S}\\p{P}\\p{Z}]+)?(:[\\p{L}\\p{N}\\p{M}\\p{S}\\p{P}\\p{Z}]+)?$")
    
    // Supported text record types
    private let textRecordTypes = ["x", "url", "github", "name", "bio", "description", "avatar", "header"]
    
    // Supported multi-chain TLDs
    private let multiChainTLDs = ["btc", "sol", "doge", "xrp", "ltc", "ada", "base", "arbi", "polygon", "avax", "bsc", "op", "zora", "linea", "scroll", "mantle", "celo", "gnosis", "fantom"]
    
    init() {
        // Initialize autocomplete provider
    }
    
    func getSuggestions(for text: String, completion: @escaping ([String]) -> Void) {
        var suggestions: [String] = []
        
        guard text.count > 0 else { 
            completion(suggestions)
            return 
        }
        
        // Check if it's a valid multi-chain format
        if isValidMultiChainFormat(text) {
            // Resolve using the same API as Chrome extension
            resolveMultiChain(domainName: text, network: "mainnet") { resolvedAddress in
                if let address = resolvedAddress, !address.isEmpty {
                    suggestions.append(address)
                }
                completion(suggestions)
            }
        } else {
            // Return basic suggestions
            suggestions.append(text)
            completion(suggestions)
        }
    }
    
    // MARK: - Multi-chain Resolution (same logic as Chrome extension)
    
    private func isValidMultiChainFormat(_ text: String) -> Bool {
        let range = NSRange(location: 0, length: text.utf16.count)
        return multiChainRegex.firstMatch(in: text, options: [], range: range) != nil
    }
    
    private func detectChain(_ domainName: String) -> String? {
        // Check for new format (name.eth:chain)
        if let colonIndex = domainName.lastIndex(of: ":") {
            let targetChain = String(domainName[domainName.index(after: colonIndex)...])
            return targetChain
        }
        
        // Handle old format (name.chain)
        let components = domainName.components(separatedBy: ".")
        guard let tld = components.last else { return nil }
        
        if textRecordTypes.contains(tld) || multiChainTLDs.contains(tld) {
            return tld
        }
        
        return tld == "eth" ? "eth" : nil
    }
    
    private func convertToNewFormat(_ domainName: String) -> String {
        // Check for new format (name.eth:chain)
        if domainName.contains(":") {
            return domainName // Already in new format
        }
        
        // Convert old format to new format
        let components = domainName.components(separatedBy: ".")
        guard let tld = components.last else { return domainName }
        
        if textRecordTypes.contains(tld) || multiChainTLDs.contains(tld) {
            let nameWithoutTLD = components.dropLast().joined(separator: ".")
            return "\(nameWithoutTLD).eth:\(tld)"
        }
        
        return domainName
    }
    
    private func resolveMultiChain(domainName: String, network: String, completion: @escaping (String?) -> Void) {
        guard detectChain(domainName) != nil else {
            completion(nil)
            return
        }
        
        // Convert to new format for server requests
        let serverDomainName = convertToNewFormat(domainName)
        
        // Create URL with same parameters as Chrome extension
        let urlString = "\(API_BASE_URL)/resolve/\(serverDomainName)?network=\(network)&source=ios-keyboard"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 5.0 // 5 second timeout like Chrome extension
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    completion(nil)
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let success = json["success"] as? Bool,
                      success == true,
                      let dataDict = json["data"] as? [String: Any],
                      let address = dataDict["address"] as? String,
                      !address.isEmpty else {
                    completion(nil)
                    return
                }
                
                completion(address)
            }
        }.resume()
    }
}
