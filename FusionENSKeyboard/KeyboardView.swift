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

// SwiftUI-based keyboard implementation - alternative to the UIKit version
// This provides a modern, simplified keyboard interface that users can choose in settings
struct KeyboardView: View {
    @State private var isShiftPressed = false
    @State private var isNumbersLayout = false
    @State private var isSecondarySymbolsLayout = false
    
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
            // Suggestion bar
            HStack {
                Text("vitalik.eth")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .onTapGesture {
                        controller.insertText("vitalik.eth")
                    }
                
                Spacer()
                
                Text(".eth")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .onTapGesture {
                        controller.insertText(".eth")
                    }
            }
            .padding(.horizontal, 8)
            
            // Keyboard rows
            VStack(spacing: 8) {
                if isNumbersLayout {
                    if isSecondarySymbolsLayout {
                        // Secondary symbols layout
                        VStack(spacing: 8) {
                            HStack(spacing: 4) {
                                ForEach(["[", "]", "{", "}", "#", "%", "^", "*", "+", "="], id: \.self) { key in
                                    KeyboardButton(title: key) {
                                        controller.insertText(key)
                                    }
                                }
                            }
                            
                            HStack(spacing: 4) {
                                ForEach(["-", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"], id: \.self) { key in
                                    KeyboardButton(title: key) {
                                        controller.insertText(key)
                                    }
                                }
                            }
                            
                            HStack(spacing: 4) {
                                KeyboardButton(title: "123") {
                                    isSecondarySymbolsLayout = false
                                }
                                
                                ForEach([".", ",", "?", "!", "'"], id: \.self) { key in
                                    KeyboardButton(title: key) {
                                        controller.insertText(key)
                                    }
                                }
                                
                                KeyboardButton(title: "⌫") {
                                    controller.deleteBackward()
                                }
                            }
                            
                            HStack(spacing: 4) {
                                KeyboardButton(title: "ABC") {
                                    isNumbersLayout = false
                                    isSecondarySymbolsLayout = false
                                }
                                
                                KeyboardButton(title: "🙂") {
                                    controller.insertText("🙂")
                                }
                                
                                KeyboardButton(title: "Space", isWide: true) {
                                    controller.insertText(" ")
                                }
                                
                                KeyboardButton(title: "Return") {
                                    controller.insertText("\n")
                                }
                            }
                        }
                    } else {
                        // Numbers layout
                        VStack(spacing: 8) {
                            HStack(spacing: 4) {
                                ForEach(["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"], id: \.self) { key in
                                    KeyboardButton(title: key) {
                                        controller.insertText(key)
                                    }
                                }
                            }
                            
                            HStack(spacing: 4) {
                                ForEach(["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""], id: \.self) { key in
                                    KeyboardButton(title: key) {
                                        controller.insertText(key)
                                    }
                                }
                            }
                            
                            HStack(spacing: 4) {
                                KeyboardButton(title: "#+=") {
                                    isSecondarySymbolsLayout = true
                                }
                                
                                ForEach([".", ",", "?", "!", "'"], id: \.self) { key in
                                    KeyboardButton(title: key) {
                                        controller.insertText(key)
                                    }
                                }
                                
                                KeyboardButton(title: "⌫") {
                                    controller.deleteBackward()
                                }
                            }
                            
                            HStack(spacing: 4) {
                                KeyboardButton(title: "ABC") {
                                    isNumbersLayout = false
                                    isSecondarySymbolsLayout = false
                                }
                                
                                KeyboardButton(title: "Space", isWide: true) {
                                    controller.insertText(" ")
                                }
                                
                                KeyboardButton(title: "Return") {
                                    controller.insertText("\n")
                                }
                            }
                        }
                    }
                } else {
                    // Letters layout
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            ForEach(isShiftPressed ? ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"] : ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"], id: \.self) { key in
                                KeyboardButton(title: key) {
                                    controller.insertText(key)
                                }
                            }
                        }
                        
                        HStack(spacing: 4) {
                            ForEach(isShiftPressed ? ["A", "S", "D", "F", "G", "H", "J", "K", "L"] : ["a", "s", "d", "f", "g", "h", "j", "k", "l"], id: \.self) { key in
                                KeyboardButton(title: key) {
                                    controller.insertText(key)
                                }
                            }
                        }
                        
                        HStack(spacing: 4) {
                            KeyboardButton(title: "⇧") {
                                isShiftPressed.toggle()
                            }
                            
                            ForEach(isShiftPressed ? ["Z", "X", "C", "V", "B", "N", "M"] : ["z", "x", "c", "v", "b", "n", "m"], id: \.self) { key in
                                KeyboardButton(title: key) {
                                    controller.insertText(key)
                                }
                            }
                            
                            KeyboardButton(title: "⌫") {
                                controller.deleteBackward()
                            }
                        }
                        
                        HStack(spacing: 4) {
                            KeyboardButton(title: "123") {
                                isNumbersLayout = true
                                isSecondarySymbolsLayout = false
                            }
                            
                            KeyboardButton(title: "🌐") {
                                controller.insertText(".eth")
                            }
                            
                            KeyboardButton(title: "Space", isWide: true) {
                                controller.insertText(" ")
                            }
                            
                            KeyboardButton(title: "Return") {
                                controller.insertText("\n")
                            }
                        }
                    }
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .id(viewId) // Force view refresh when controller changes
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


