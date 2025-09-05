//
//  FusionENSAutoCompleteProvider.swift
//  FusionENSKeyboard
//
//  Created by Franz Quarshie on 05/09/2025.
//

import Foundation

class FusionENSAutoCompleteProvider {
    
    init() {
        // Initialize autocomplete provider
    }
    
    func getSuggestions(for text: String, completion: @escaping ([String]) -> Void) {
        var suggestions: [String] = []
        
        guard text.count > 0 else { 
            completion(suggestions)
            return 
        }
        
        // Check if it's an ENS format
        if HelperClass.checkFormat(text) {
            // Get ENS suggestions
            APICaller.shared.resolveENSName(name: text) { mappedAddress in
                if !mappedAddress.isEmpty {
                    suggestions.append(mappedAddress)
                }
                completion(suggestions)
            }
        } else {
            // Return basic suggestions
            suggestions.append(text)
            completion(suggestions)
        }
    }
}
