//
//  APICaller.swift
//  FusionENSKeyboard
//
//  Created by Franz Quarshie on 05/09/2025.
//

import Foundation
import Alamofire

class APICaller {
    static let shared = APICaller()
    
    func resolveENSName(name: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "\(URLS.fusionNameResolver(name: name))") else { return }

        AF.request(url).response { response in
            guard let data = response.data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            else {
                print("Failed to parse JSON response")
                completion("") // Return empty string if the response cannot be parsed
                return
            }
            
            print("API Response: \(json)")
            
            // Handle Fusion ENS API response format
            // The API returns: {"success": true, "data": {"name": "ses.eth", "address": "0x1234...", "network": "mainnet"}}
            if let success = json["success"] as? Bool, success {
                if let data = json["data"] as? [String: Any],
                   let address = data["address"] as? String {
                    print("Resolved address: \(address)")
                    completion(address)
                    return
                }
            }
            
            // Fallback: try direct address field (for backward compatibility)
            if let address = json["address"] as? String {
                completion(address)
            } else if let address = json["result"] as? String {
                completion(address)
            } else {
                print("No address found in response")
                completion("")
            }
        }
    }
    
    // Keep the old method name for backward compatibility
    func resolveFusionENSName(name: String, completion: @escaping (String) -> Void) {
        resolveENSName(name: name, completion: completion)
    }
}
