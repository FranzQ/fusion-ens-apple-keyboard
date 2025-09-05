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
                completion("") // Return empty string if the response cannot be parsed
                return
            }
            
            // Handle ENS Ideas API response format
            // The API returns the address directly or in a different structure
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
    
    // Keep the old method name for backward compatibility
    func resolveFusionENSName(name: String, completion: @escaping (String) -> Void) {
        resolveENSName(name: name, completion: completion)
    }
}
