//
//  KeyboardView.swift
//  FusionENSKeyboard
//
//  Created by Franz Quarshie on 05/09/2025.
//

import SwiftUI

// Protocol for keyboard functionality
protocol KeyboardController {
    func insertText(_ text: String)
    func deleteBackward()
    func triggerENSResolution()
    func getENSSuggestions() -> [String]
}

// Simplified SwiftUI-based keyboard implementation
// Focuses on ENS functionality with minimal custom UI
struct KeyboardView: View {
    let controller: KeyboardController
    
    // Add an id to force view refresh when controller changes
    private var viewId: String {
        return "\(ObjectIdentifier(controller as AnyObject))"
    }
    
    init(controller: KeyboardController) {
        self.controller = controller
        print("🎨 SwiftUI KeyboardView: Initialized with controller: \(ObjectIdentifier(controller as AnyObject))")
    }
    
    var body: some View {
        let _ = print("🎨 SwiftUI KeyboardView: body computed for controller: \(ObjectIdentifier(controller as AnyObject))")
        
        VStack(spacing: 8) {
            // Dynamic ENS Suggestion bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Get suggestions from controller
                    ForEach(controller.getENSSuggestions(), id: \.self) { suggestion in
                        Text(suggestion)
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                            .onTapGesture {
                                controller.insertText(suggestion)
                            }
                    }
                    
                    // Always show .eth button
                    Text(".eth")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(6)
                        .onTapGesture {
                            controller.insertText(".eth")
                        }
                }
                .padding(.horizontal, 8)
            }
            
            // Simple message indicating ENS resolution capability
            Text("Select ENS names to resolve to addresses")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .id(viewId) // Force view refresh when controller changes
    }
}


