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
}

struct KeyboardView: View {
    
    let controller: KeyboardController
    
    var body: some View {
        VStack(spacing: 8) {
            // Top row
            HStack(spacing: 4) {
                ForEach(["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"], id: \.self) { key in
                    KeyboardButton(title: key) {
                        controller.insertText(key)
                    }
                }
            }
            
            // Middle row
            HStack(spacing: 4) {
                ForEach(["A", "S", "D", "F", "G", "H", "J", "K", "L"], id: \.self) { key in
                    KeyboardButton(title: key) {
                        controller.insertText(key)
                    }
                }
            }
            
            // Bottom row
            HStack(spacing: 4) {
                ForEach(["Z", "X", "C", "V", "B", "N", "M"], id: \.self) { key in
                    KeyboardButton(title: key) {
                        controller.insertText(key)
                    }
                }
                
                KeyboardButton(title: "⌫") {
                    controller.deleteBackward()
                }
            }
            
            // Function row
            HStack(spacing: 4) {
                KeyboardButton(title: "123") {
                    // Switch to numbers
                }
                
                KeyboardButton(title: "Space", isWide: true) {
                    controller.insertText(" ")
                }
                
                KeyboardButton(title: "Return") {
                    controller.insertText("\n")
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
    }
}

struct KeyboardButton: View {
    let title: String
    let action: () -> Void
    let isWide: Bool
    
    init(title: String, isWide: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isWide = isWide
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: isWide ? .infinity : 32, minHeight: 44)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 1)
        }
    }
}


