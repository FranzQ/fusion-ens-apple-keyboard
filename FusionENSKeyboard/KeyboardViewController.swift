//
//  KeyboardViewController.swift
//  FusionENSKeyboard
//
//  Created by Franz Quarshie on 05/09/2025.
//

import UIKit
import KeyboardKit
import SwiftUI

class KeyboardViewController: KeyboardInputViewController, KeyboardController {
    
    var previousCurrentWord: String?
    private var isKeyboardViewSetup = false
    private var isShiftPressed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Fusion ENS Keyboard loaded")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Fusion ENS Keyboard appeared")
        
        // Setup keyboard view only once
        if !isKeyboardViewSetup {
            setupKeyboardView()
            isKeyboardViewSetup = true
        }
    }
    
    private func setupKeyboardView() {
        // Create a simple UIKit-based keyboard
        let keyboardView = createSimpleKeyboard()
        view.addSubview(keyboardView)
        
        // Set up constraints
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createSimpleKeyboard() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0) // iOS keyboard gray
        
        let rows = [
            ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
            ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
            ["⇧", "Z", "X", "C", "V", "B", "N", "M", "⌫"],
            ["123", "Space", ".", "Return"]
        ]
        
        var previousRow: UIView?
        
        for (rowIndex, row) in rows.enumerated() {
            let rowView = UIView()
            containerView.addSubview(rowView)
            
            rowView.translatesAutoresizingMaskIntoConstraints = false
                            NSLayoutConstraint.activate([
                    rowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6),
                    rowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -6),
                    rowView.heightAnchor.constraint(equalToConstant: 45)
                ])
            
            if let previousRow = previousRow {
                rowView.topAnchor.constraint(equalTo: previousRow.bottomAnchor, constant: 6).isActive = true
            } else {
                rowView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6).isActive = true
            }
            
            if rowIndex == rows.count - 1 {
                rowView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6).isActive = true
            }
            
            var previousButton: UIButton?
            
            for key in row {
                let button = createKeyboardButton(title: key)
                rowView.addSubview(button)
                
                button.translatesAutoresizingMaskIntoConstraints = false
                
                // Set different widths for different keys
                let keyWidth: CGFloat
                switch key {
                case "Space":
                    keyWidth = 150
                case "⇧", "⌫", "123", "Return", ".":
                    keyWidth = 50
                default:
                    keyWidth = 32
                }
                
                NSLayoutConstraint.activate([
                    button.topAnchor.constraint(equalTo: rowView.topAnchor),
                    button.bottomAnchor.constraint(equalTo: rowView.bottomAnchor),
                    button.widthAnchor.constraint(equalToConstant: keyWidth)
                ])
                
                if let previousButton = previousButton {
                    button.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor, constant: 3).isActive = true
                } else {
                    button.leadingAnchor.constraint(equalTo: rowView.leadingAnchor).isActive = true
                }
                
                if key == row.last {
                    button.trailingAnchor.constraint(equalTo: rowView.trailingAnchor).isActive = true
                }
                
                previousButton = button
            }
            
            previousRow = rowView
        }
        
        return containerView
    }
    
    private func createKeyboardButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        button.setTitleColor(UIColor.black, for: .normal)
        
        // Standard iOS keyboard styling
        button.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.3).cgColor
        
        // Add subtle shadow like iOS keyboard
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 0
        button.layer.masksToBounds = false
        
        // Add touch feedback
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        button.addAction(UIAction { _ in
            self.handleKeyPress(title)
        }, for: .touchUpInside)
        
        return button
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        // Darken button on press like iOS keyboard
        UIView.animate(withDuration: 0.1) {
            sender.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        // Return to normal color
        UIView.animate(withDuration: 0.1) {
            sender.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    private func handleKeyPress(_ key: String) {
        switch key {
        case "⌫":
            deleteBackward()
        case "Space":
            insertText(" ")
        case "Return":
            insertText("\n")
        case "123":
            // Switch to numbers (placeholder)
            break
        case ".":
            insertText(".")
        case "⇧":
            isShiftPressed.toggle()
            // Update keyboard appearance to show shift state
            updateKeyboardAppearance()
        default:
            let textToInsert = isShiftPressed ? key.uppercased() : key.lowercased()
            insertText(textToInsert)
            // Auto-release shift after typing
            if isShiftPressed {
                isShiftPressed = false
                updateKeyboardAppearance()
            }
        }
    }
    
    private func triggerENSResolution() {
        // Try to get selected text first
        if let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty {
            print("Manual ENS resolution for selected text: \(selectedText)")
            handleSelectedText(selectedText)
        }
        // Otherwise try current word
        else if let currentWord = textDocumentProxy.currentWord, !currentWord.isEmpty {
            print("Manual ENS resolution for current word: \(currentWord)")
            handleSelectedText(currentWord)
        }
        else {
            print("No text selected or current word available for ENS resolution")
        }
    }
    
    private func updateKeyboardAppearance() {
        // Update shift key appearance based on state
        // This is a simplified version - in a real implementation you'd update the button colors
        print("Shift state: \(isShiftPressed)")
    }
    
    // MARK: - KeyboardController Protocol
    
    override func insertText(_ text: String) {
        textDocumentProxy.insertText(text)
    }
    
    override func deleteBackward() {
        textDocumentProxy.deleteBackward()
    }
    

    
    override var autocompleteText: String? {
        // Get the current word for autocomplete
        if let currentWord = textDocumentProxy.currentWord, !currentWord.isEmpty {
            return currentWord
        }
        
        return nil
    }
    
    func handleSelectedText(_ selectedText: String) {
        print("Attempting ENS resolution for: \(selectedText)")
        
        if(HelperClass.checkFormat(selectedText)) {
            print("Text format is valid for ENS resolution")
            
            APICaller.shared.resolveENSName(name: selectedText) { mappedAddress in
                DispatchQueue.main.async {
                    if !mappedAddress.isEmpty {
                        print("ENS resolved to: \(mappedAddress)")
                        // Delete the original text and insert the resolved address
                        for _ in 0..<selectedText.count {
                            self.textDocumentProxy.deleteBackward()
                        }
                        self.textDocumentProxy.insertText(mappedAddress)
                    } else {
                        print("ENS resolution failed for: \(selectedText)")
                    }
                }
            }
        } else {
            print("Text format is not valid for ENS resolution: \(selectedText)")
        }
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        
        // Check if there's selected text first
        if let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty {
            print("Selected text: \(selectedText)")
            handleSelectedText(selectedText)
        }
        // Otherwise check current word
        else if let currentWord = textDocumentProxy.currentWord, !currentWord.isEmpty {
            print("Current word: \(currentWord)")
            // Only handle if it looks like an ENS domain
            if HelperClass.checkFormat(currentWord) {
                handleSelectedText(currentWord)
            }
        }
    }
}




