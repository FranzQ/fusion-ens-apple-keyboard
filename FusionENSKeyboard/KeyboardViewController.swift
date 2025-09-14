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
    private var isNumbersLayout = false
    
    // Haptic feedback settings
    private let hapticFeedbackKey = "hapticFeedbackEnabled"
    private var isHapticFeedbackEnabled: Bool {
        get {
            return UserDefaults(suiteName: "group.com.fusionens.keyboard")?.bool(forKey: hapticFeedbackKey) ?? true
        }
    }
    
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Recreate keyboard when dark mode changes
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            print("Dark mode changed, recreating keyboard")
            // Remove existing keyboard view
            view.subviews.forEach { $0.removeFromSuperview() }
            isKeyboardViewSetup = false
            // Recreate with new theme
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
        
        // Support dark mode
        if traitCollection.userInterfaceStyle == .dark {
            containerView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Dark keyboard background
        } else {
            containerView.backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0) // Light keyboard background
        }
        
        let rows: [[String]]
        if isNumbersLayout {
            rows = [
                ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
                ["#+=", ".", ",", "?", "!", "'", "⌫"],
                ["ABC", ".eth", "space", "return"]
            ]
        } else {
            if isShiftPressed {
                rows = [
                    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
                    ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
                    ["⇧", "Z", "X", "C", "V", "B", "N", "M", "⌫"],
                    ["123", ".eth", "space", "return"]
                ]
            } else {
                rows = [
                    ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
                    ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
                    ["⇧", "z", "x", "c", "v", "b", "n", "m", "⌫"],
                    ["123", ".eth", "space", "return"]
                ]
            }
        }
        
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
                
                // Set different widths for different keys (iOS standard proportions)
                let keyWidth: CGFloat
                switch key {
                case "space":
                    keyWidth = 200  // Wider space bar
                case "⇧", "⌫", "#+=":
                    keyWidth = 60   // Wider shift, delete, and symbol keys
                case "123", "ABC":
                    keyWidth = 45   // Standard function key width
                case ".eth":
                    keyWidth = 60   // Wider .eth button for better visibility
                case "return":
                    keyWidth = 80   // Wider return key
                default:
                    keyWidth = 35   // Standard letter/number key width
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
        
        // Support dark mode for text color
        if traitCollection.userInterfaceStyle == .dark {
            button.setTitleColor(UIColor.white, for: .normal)
        } else {
            button.setTitleColor(UIColor.black, for: .normal)
        }
        
        // Enhanced iOS keyboard styling with dark mode support
        // Special styling for shift key when active
        if title == "⇧" && isShiftPressed {
            if traitCollection.userInterfaceStyle == .dark {
                button.backgroundColor = UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 1.0) // Blue when active in dark mode
                button.setTitleColor(UIColor.white, for: .normal)
            } else {
                button.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0) // Blue when active in light mode
                button.setTitleColor(UIColor.white, for: .normal)
            }
        } else {
            if traitCollection.userInterfaceStyle == .dark {
                button.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) // Dark button background
                button.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.3).cgColor
            } else {
                button.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // Light button background
                button.layer.borderColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.2).cgColor
            }
        }
        
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 0.3
        
        // Enhanced shadow like real iOS keyboard
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        button.layer.shadowOpacity = 0.15
        button.layer.shadowRadius = 1
        button.layer.masksToBounds = false
        
        // Add subtle gradient effect with dark mode support
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100) // Will be resized
        if traitCollection.userInterfaceStyle == .dark {
            gradientLayer.colors = [
                UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0).cgColor,
                UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0).cgColor
            ]
        } else {
            gradientLayer.colors = [
                UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor,
                UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).cgColor
            ]
        }
        gradientLayer.cornerRadius = 6
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add touch feedback
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        button.addAction(UIAction { _ in
            // Trigger haptic feedback for button press
            self.triggerHapticFeedback()
            self.handleKeyPress(title)
        }, for: .touchUpInside)
        
        return button
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        // Darken button on press like iOS keyboard with dark mode support
        UIView.animate(withDuration: 0.1) {
            if self.traitCollection.userInterfaceStyle == .dark {
                sender.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0) // Dark mode press
            } else {
                sender.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) // Light mode press
            }
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        // Return to normal color with dark mode support
        UIView.animate(withDuration: 0.1) {
            if self.traitCollection.userInterfaceStyle == .dark {
                sender.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) // Dark mode normal
            } else {
                sender.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // Light mode normal
            }
        }
    }
    
    private func handleKeyPress(_ key: String) {
        switch key {
        case "⌫":
            deleteBackward()
        case "space":
            insertText(" ")
        case "return":
            insertText("\n")
        case "123":
            // Switch to numbers layout
            switchToNumbersLayout()
            break
        case "ABC":
            // Switch back to letters layout
            switchToLettersLayout()
            break
        case "#+=":
            // Switch to symbols layout (placeholder for now)
            break
        case ".eth":
            insertText(".eth")
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
        // Recreate keyboard when shift state changes
        print("Shift state: \(isShiftPressed)")
        
        // Remove existing keyboard view
        view.subviews.forEach { $0.removeFromSuperview() }
        isKeyboardViewSetup = false
        // Recreate with new shift state
        setupKeyboardView()
        isKeyboardViewSetup = true
    }
    
    private func switchToNumbersLayout() {
        isNumbersLayout = true
        // Remove existing keyboard view
        view.subviews.forEach { $0.removeFromSuperview() }
        isKeyboardViewSetup = false
        // Recreate with numbers layout
        setupKeyboardView()
        isKeyboardViewSetup = true
    }
    
    private func switchToLettersLayout() {
        isNumbersLayout = false
        // Remove existing keyboard view
        view.subviews.forEach { $0.removeFromSuperview() }
        isKeyboardViewSetup = false
        // Recreate with letters layout
        setupKeyboardView()
        isKeyboardViewSetup = true
    }
    
    // MARK: - Haptic Feedback
    
    private func triggerHapticFeedback() {
        guard isHapticFeedbackEnabled else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func triggerSuccessHaptic() {
        guard isHapticFeedbackEnabled else { return }
        
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    private func triggerErrorHaptic() {
        guard isHapticFeedbackEnabled else { return }
        
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
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
            
            // Trigger haptic feedback when starting resolution
            triggerHapticFeedback()
            
            APICaller.shared.resolveENSName(name: selectedText) { mappedAddress in
                DispatchQueue.main.async {
                    if !mappedAddress.isEmpty {
                        print("ENS resolved to: \(mappedAddress)")
                        // Delete the original text and insert the resolved address
                        for _ in 0..<selectedText.count {
                            self.textDocumentProxy.deleteBackward()
                        }
                        self.textDocumentProxy.insertText(mappedAddress)
                        
                        // Trigger success haptic feedback
                        self.triggerSuccessHaptic()
                    } else {
                        print("ENS resolution failed for: \(selectedText)")
                        // Trigger error haptic feedback
                        self.triggerErrorHaptic()
                    }
                }
            }
        } else {
            print("Text format is not valid for ENS resolution: \(selectedText)")
            // Trigger error haptic feedback for invalid format
            triggerErrorHaptic()
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




