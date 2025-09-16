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
    private var suggestionOverlay: UIView?
    private var suggestionBar: UIScrollView?
    private var suggestionButtons: [UIButton] = []
    private var lastTypedWord: String = ""
    
    // ENS suggestions data - expanded list for contextual matching
    private let popularENSDomains = [
        "vitalik.eth", "ethereum.eth", "uniswap.eth", "aave.eth", "compound.eth",
        "opensea.eth", "ens.eth", "dapp.eth", "defi.eth", "nft.eth",
        "web3.eth", "dao.eth", "metaverse.eth", "crypto.eth", "blockchain.eth",
        "bitcoin.eth", "coinbase.eth", "binance.eth", "chainlink.eth", "maker.eth",
        "curve.eth", "sushi.eth", "yearn.eth", "balancer.eth", "synthetix.eth",
        "polygon.eth", "arbitrum.eth", "optimism.eth", "base.eth", "avalanche.eth",
        "solana.eth", "cardano.eth", "polkadot.eth", "cosmos.eth", "near.eth",
        "algorand.eth", "tezos.eth", "stellar.eth", "ripple.eth", "litecoin.eth",
        "dogecoin.eth", "shiba.eth", "pepe.eth", "meme.eth", "token.eth"
    ]
    
    // Haptic feedback settings
    private let hapticFeedbackKey = "hapticFeedbackEnabled"
    private var isHapticFeedbackEnabled: Bool {
        get {
            // Try app group first, fallback to standard UserDefaults
            let appGroupDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard")
            let standardDefaults = UserDefaults.standard
            
            let isEnabled: Bool
            if let appGroupValue = appGroupDefaults?.object(forKey: hapticFeedbackKey) {
                isEnabled = appGroupDefaults?.bool(forKey: hapticFeedbackKey) ?? true
                print("Haptic feedback setting from app group: \(isEnabled)")
            } else {
                isEnabled = standardDefaults.bool(forKey: hapticFeedbackKey)
                print("Haptic feedback setting from standard UserDefaults: \(isEnabled)")
            }
            
            return isEnabled
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Fusion ENS Keyboard loaded")
        
        // Test haptic feedback on load
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("Testing haptic feedback...")
            self.testHapticFeedback()
        }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Hide suggestion when keyboard disappears
        hideENSSuggestion()
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
        
        // iPhone keyboard background - light gray
        containerView.backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0)
        
        let rows: [[String]]
        if isNumbersLayout {
            rows = [
                ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
                ["#+=", ".", ",", "?", "!", "'", "⌫"],
                ["ABC", "space", "return"]
            ]
        } else {
            if isShiftPressed {
                rows = [
                    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
                    ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
                    ["⇧", "Z", "X", "C", "V", "B", "N", "M", "⌫"],
                    ["123", "🌐", "space", "return"]
                ]
            } else {
                rows = [
                    ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
                    ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
                    ["⇧", "z", "x", "c", "v", "b", "n", "m", "⌫"],
                    ["123", "🌐", "space", "return"]
                ]
            }
        }
        
        var previousRow: UIView?
        
        for (rowIndex, row) in rows.enumerated() {
            let rowView = UIView()
            containerView.addSubview(rowView)
            
            rowView.translatesAutoresizingMaskIntoConstraints = false
            
            // Center align the second row (index 1), left align others
            if rowIndex == 1 {
                // Second row should be center-aligned
                NSLayoutConstraint.activate([
                    rowView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    rowView.heightAnchor.constraint(equalToConstant: 45)
                ])
            } else {
                // Other rows should be full width
                NSLayoutConstraint.activate([
                    rowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                    rowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                    rowView.heightAnchor.constraint(equalToConstant: 45)
                ])
            }
            
            if let previousRow = previousRow {
                rowView.topAnchor.constraint(equalTo: previousRow.bottomAnchor, constant: 8).isActive = true
            } else {
                // First row should be below the suggestion bar
                rowView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 48).isActive = true
            }
            
            if rowIndex == rows.count - 1 {
                rowView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6).isActive = true
            }
            
            // For the second row, create a container to center the buttons
            if rowIndex == 1 {
                let buttonContainer = UIView()
                buttonContainer.isUserInteractionEnabled = true  // Enable touch events
                rowView.addSubview(buttonContainer)
                buttonContainer.translatesAutoresizingMaskIntoConstraints = false
                
                // Center the button container
                NSLayoutConstraint.activate([
                    buttonContainer.centerXAnchor.constraint(equalTo: rowView.centerXAnchor),
                    buttonContainer.topAnchor.constraint(equalTo: rowView.topAnchor),
                    buttonContainer.bottomAnchor.constraint(equalTo: rowView.bottomAnchor)
                ])
                
                var previousButton: UIButton?
                
                for key in row {
                    let button = createKeyboardButton(title: key)
                    buttonContainer.addSubview(button)
                    
                    button.translatesAutoresizingMaskIntoConstraints = false
                    
                    // Set different widths for different keys (iPhone keyboard proportions)
                    let keyWidth: CGFloat = 36  // Standard letter key width for second row
                    
                    NSLayoutConstraint.activate([
                        button.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
                        button.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
                        button.widthAnchor.constraint(equalToConstant: keyWidth)
                    ])
                    
                    if let previousButton = previousButton {
                        button.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor, constant: 6).isActive = true
                    } else {
                        button.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor).isActive = true
                    }
                    
                    // Pin the last key to trailing edge to define container width
                    if key == row.last {
                        button.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor).isActive = true
                    }
                    
                    previousButton = button
                }
            } else {
                // For other rows, use the original logic
                var previousButton: UIButton?
                
                for key in row {
                    let button = createKeyboardButton(title: key)
                    rowView.addSubview(button)
                    
                    button.translatesAutoresizingMaskIntoConstraints = false
                    
                    // Set different widths for different keys (iPhone keyboard proportions)
                    let keyWidth: CGFloat
                    switch key {
                    case "space":
                        keyWidth = 200  // Wide space bar like iPhone
                    case "⇧", "⌫", "#+=":
                        keyWidth = 60   // Shift and delete keys
                    case "123", "ABC":
                        keyWidth = 55   // Number/symbol toggle key
                    case "🌐":
                        keyWidth = 50   // Globe key
                    case "return":
                        keyWidth = 75   // Return key
                    default:
                        keyWidth = 36   // Standard letter/number key width
                    }
                    
                    NSLayoutConstraint.activate([
                        button.topAnchor.constraint(equalTo: rowView.topAnchor),
                        button.bottomAnchor.constraint(equalTo: rowView.bottomAnchor),
                        button.widthAnchor.constraint(equalToConstant: keyWidth)
                    ])
                    
                    if let previousButton = previousButton {
                        button.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor, constant: 6).isActive = true
                    } else {
                        button.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 6).isActive = true
                    }
                    
                    // Pin the last key to trailing edge to define row width
                    if key == row.last {
                        button.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -6).isActive = true
                    }
                    
                    previousButton = button
                }
            }
            
            previousRow = rowView
        }
        
        // Add suggestion bar above keyboard
        addSuggestionBar(to: containerView)
        
        return containerView
    }
    
    private func addSuggestionBar(to containerView: UIView) {
        // Create suggestion bar
        let suggestionBar = UIScrollView()
        suggestionBar.backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0) // Match keyboard background
        suggestionBar.showsHorizontalScrollIndicator = false
        suggestionBar.translatesAutoresizingMaskIntoConstraints = false
        suggestionBar.isHidden = true // Initially hidden, will show when there are suggestions
        
        containerView.addSubview(suggestionBar)
        
        // Position suggestion bar at the top
        NSLayoutConstraint.activate([
            suggestionBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            suggestionBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            suggestionBar.topAnchor.constraint(equalTo: containerView.topAnchor),
            suggestionBar.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        self.suggestionBar = suggestionBar
    }
    
    private func createSuggestionButton(text: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.clear // No background
        button.layer.cornerRadius = 0
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.clear.cgColor
        
        // Add proper padding like Apple keyboard
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        // Add touch feedback
        button.addTarget(self, action: #selector(suggestionButtonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(suggestionButtonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        button.addAction(UIAction { _ in
            self.triggerHapticFeedback()
            self.insertText(text)
        }, for: .touchUpInside)
        
        return button
    }
    
    @objc private func suggestionButtonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 0.6
        }
    }
    
    @objc private func suggestionButtonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.alpha = 1.0
        }
    }
    
    private func createKeyboardButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        
        // Use PNG image for globe icon, text for everything else
        if title == "🌐" {
            if let globeImage = UIImage(named: "globe-icon") {
                button.setImage(globeImage, for: .normal)
                button.imageView?.contentMode = .scaleAspectFit
                button.tintColor = UIColor.black
            } else {
                button.setTitle(title, for: .normal)
            }
        } else {
            button.setTitle(title, for: .normal)
        }
        
        // Use smaller font for bottom row keys
        let fontSize: CGFloat
        if title == "123" || title == "ABC" || title == "🌐" || title == "space" || title == "return" {
            fontSize = 16  // Smaller font for bottom row
        } else {
            fontSize = 22  // Standard font for other keys
        }
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        
        // iPhone keyboard styling
        if title == "return" {
            // Blue return key
            button.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
            button.setTitleColor(UIColor.white, for: .normal)
        } else if title == "⇧" || title == "⌫" || title == "123" || title == "🌐" || title == "ABC" || title == "#+=" {
            // Gray function keys
            button.backgroundColor = UIColor(red: 0.68, green: 0.68, blue: 0.70, alpha: 1.0)
            button.setTitleColor(UIColor.black, for: .normal)
        } else {
            // White letter/number keys
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor.black, for: .normal)
        }
        
        // iPhone keyboard corner radius
        button.layer.cornerRadius = 5
        
        // iPhone keyboard shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 0
        button.layer.masksToBounds = false
        
        // Add touch feedback
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        // Add long press gesture for space bar to trigger ENS resolution
        if title == "space" {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(spaceBarLongPress(_:)))
            longPressGesture.minimumPressDuration = 0.5
            button.addGestureRecognizer(longPressGesture)
        }
        
        button.addAction(UIAction { _ in
            self.triggerHapticFeedback()
            self.handleKeyPress(title)
        }, for: .touchUpInside)
        
        return button
    }
    
    private func createENSSuggestionOverlay(for domain: String) -> UIView {
        let overlay = UIView()
        overlay.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 0.95)
        overlay.layer.cornerRadius = 8
        overlay.layer.shadowColor = UIColor.black.cgColor
        overlay.layer.shadowOffset = CGSize(width: 0, height: 2)
        overlay.layer.shadowOpacity = 0.1
        overlay.layer.shadowRadius = 4
        
        // Safari icon
        let safariIcon = UILabel()
        safariIcon.text = "🌐"
        safariIcon.font = UIFont.systemFont(ofSize: 20)
        safariIcon.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(safariIcon)
        
        // Main text
        let mainLabel = UILabel()
        mainLabel.text = "\(domain) on ENS"
        mainLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        mainLabel.textColor = UIColor.black
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(mainLabel)
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "app.ens.domains"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = UIColor.gray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(subtitleLabel)
        
        // Open button
        let openButton = UIButton(type: .system)
        openButton.setTitle("Open", for: .normal)
        openButton.setTitleColor(UIColor.systemBlue, for: .normal)
        openButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        openButton.translatesAutoresizingMaskIntoConstraints = false
        openButton.addAction(UIAction { _ in
            self.openENSInBrowser(domain: domain)
        }, for: .touchUpInside)
        overlay.addSubview(openButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            overlay.heightAnchor.constraint(equalToConstant: 60),
            
            safariIcon.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 12),
            safariIcon.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            
            mainLabel.leadingAnchor.constraint(equalTo: safariIcon.trailingAnchor, constant: 12),
            mainLabel.topAnchor.constraint(equalTo: overlay.topAnchor, constant: 12),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: mainLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 2),
            
            openButton.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -12),
            openButton.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])
        
        return overlay
    }
    
    private func showENSSuggestion(for domain: String) {
        // Remove existing suggestion if any
        hideENSSuggestion()
        
        let suggestion = createENSSuggestionOverlay(for: domain)
        view.addSubview(suggestion)
        
        suggestion.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            suggestion.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            suggestion.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            suggestion.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -8)
        ])
        
        suggestionOverlay = suggestion
        
        // Animate in
        suggestion.alpha = 0
        suggestion.transform = CGAffineTransform(translationX: 0, y: -20)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            suggestion.alpha = 1
            suggestion.transform = .identity
        })
        
        // Auto-hide after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.hideENSSuggestion()
        }
    }
    
    private func hideENSSuggestion() {
        guard let suggestion = suggestionOverlay else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            suggestion.alpha = 0
            suggestion.transform = CGAffineTransform(translationX: 0, y: -20)
        }) { _ in
            suggestion.removeFromSuperview()
            self.suggestionOverlay = nil
        }
    }
    
    private func openENSInBrowser(domain: String) {
        let urlString = "https://app.ens.domains/name/\(domain)"
        if let url = URL(string: urlString) {
            // Use extension context to open URL (extension-compatible)
            let context = NSExtensionContext()
            context.open(url, completionHandler: nil)
        }
        hideENSSuggestion()
    }
    
    @objc private func spaceBarLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            print("Space bar long press - triggering ENS resolution")
            triggerHapticFeedback()
            triggerENSResolution()
        }
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        // iPhone keyboard press effect - darken the button
        UIView.animate(withDuration: 0.1) {
            if sender.backgroundColor == UIColor.white {
                sender.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) // White key press
            } else if sender.backgroundColor == UIColor(red: 0.68, green: 0.68, blue: 0.70, alpha: 1.0) {
                sender.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0) // Gray key press
            } else if sender.backgroundColor == UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) {
                sender.backgroundColor = UIColor(red: 0.0, green: 0.3, blue: 0.8, alpha: 1.0) // Blue key press
            }
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        // Return to normal iPhone keyboard colors
        UIView.animate(withDuration: 0.1) {
            if let title = sender.title(for: .normal) {
                if title == "return" {
                    sender.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // Blue return
                } else if title == "⇧" || title == "⌫" || title == "123" || title == "🌐" || title == "ABC" || title == "#+=" {
                    sender.backgroundColor = UIColor(red: 0.68, green: 0.68, blue: 0.70, alpha: 1.0) // Gray function keys
                } else {
                    sender.backgroundColor = UIColor.white // White letter/number keys
                }
            } else if sender.image(for: .normal) != nil {
                // Handle image button (globe icon)
                sender.backgroundColor = UIColor(red: 0.68, green: 0.68, blue: 0.70, alpha: 1.0) // Gray function key
            }
        }
    }
    
    private func handleKeyPress(_ key: String) {
        switch key {
        case "⌫":
            deleteBackward()
            // Update last typed word when deleting
            if !lastTypedWord.isEmpty {
                lastTypedWord = String(lastTypedWord.dropLast())
                // Update suggestions after deleting
                if !lastTypedWord.isEmpty {
                    updateSuggestionsForWord(lastTypedWord)
                } else {
                    updateSuggestionBar(with: [])
                }
            }
        case "space":
            insertText(" ")
            // Clear last typed word when space is pressed
            lastTypedWord = ""
            // Hide suggestions when space is pressed
            updateSuggestionBar(with: [])
        case "return":
            insertText("\n")
            // Clear last typed word when return is pressed
            lastTypedWord = ""
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
        case "🌐":
            // Globe key - insert .eth at cursor position
            insertText(".eth")
            lastTypedWord += ".eth"
        case ".":
            insertText(".")
            lastTypedWord += "."
        case "⇧":
            isShiftPressed.toggle()
            // Update keyboard appearance to show shift state
            updateKeyboardAppearance()
        default:
            let textToInsert = isShiftPressed ? key.uppercased() : key.lowercased()
            insertText(textToInsert)
            lastTypedWord += textToInsert
            
            // Update suggestions after typing
            updateSuggestionsForWord(lastTypedWord)
            
            // Auto-release shift after typing
            if isShiftPressed {
                isShiftPressed = false
                updateKeyboardAppearance()
            }
        }
    }
    
    private func triggerENSResolution() {
        print("Triggering ENS resolution...")
        
        // First try to get selected text
        if let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty {
            print("Manual ENS resolution for selected text: \(selectedText)")
            if HelperClass.checkFormat(selectedText) {
                handleSelectedText(selectedText)
                return
            } else {
                print("Selected text is not a valid ENS domain format")
                triggerErrorHaptic()
                return
            }
        }
        
        // Try the last typed word
        if !lastTypedWord.isEmpty {
            print("Manual ENS resolution for last typed word: \(lastTypedWord)")
            if HelperClass.checkFormat(lastTypedWord) {
                handleSelectedText(lastTypedWord)
                return
            } else {
                print("Last typed word is not a valid ENS domain format")
                triggerErrorHaptic()
                return
            }
        }
        
        // Try to get current word from text document proxy
        if let currentWord = textDocumentProxy.currentWord, !currentWord.isEmpty {
            print("Manual ENS resolution for current word: \(currentWord)")
            if HelperClass.checkFormat(currentWord) {
                handleSelectedText(currentWord)
                return
            } else {
                print("Current word is not a valid ENS domain format")
                triggerErrorHaptic()
                return
            }
        }
        
        print("No text available for ENS resolution")
        triggerErrorHaptic()
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
    
    // MARK: - Contextual Suggestions
    
    private func getContextualSuggestions(for input: String) -> [String] {
        guard !input.isEmpty else { return [] }
        
        let lowercaseInput = input.lowercased()
        var suggestions: [String] = []
        
        // Find domains that start with the input
        for domain in popularENSDomains {
            let domainName = String(domain.dropLast(4)) // Remove ".eth"
            if domainName.lowercased().hasPrefix(lowercaseInput) {
                suggestions.append(domain)
            }
        }
        
        // If no exact prefix matches, find domains that contain the input
        if suggestions.isEmpty {
            for domain in popularENSDomains {
                let domainName = String(domain.dropLast(4)) // Remove ".eth"
                if domainName.lowercased().contains(lowercaseInput) {
                    suggestions.append(domain)
                }
            }
        }
        
        // Limit to top 5 suggestions to avoid clutter
        return Array(suggestions.prefix(5))
    }
    
    private func updateSuggestionBar(with suggestions: [String]) {
        // Clear existing suggestion buttons
        suggestionButtons.forEach { $0.removeFromSuperview() }
        suggestionButtons.removeAll()
        
        guard !suggestions.isEmpty else {
            // Hide suggestion bar if no suggestions
            suggestionBar?.isHidden = true
            return
        }
        
        // Show suggestion bar
        suggestionBar?.isHidden = false
        
        // Create new suggestion buttons
        var previousButton: UIButton?
        
        for suggestion in suggestions {
            let button = createSuggestionButton(text: suggestion)
            suggestionBar?.addSubview(button)
            suggestionButtons.append(button)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: suggestionBar!.topAnchor, constant: 8),
                button.bottomAnchor.constraint(equalTo: suggestionBar!.bottomAnchor, constant: -8),
                button.heightAnchor.constraint(equalToConstant: 24)
            ])
            
            if let previousButton = previousButton {
                button.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor, constant: 4).isActive = true
            } else {
                button.leadingAnchor.constraint(equalTo: suggestionBar!.leadingAnchor, constant: 12).isActive = true
            }
            
            if suggestion == suggestions.last {
                button.trailingAnchor.constraint(equalTo: suggestionBar!.trailingAnchor, constant: -12).isActive = true
            }
            
            previousButton = button
        }
    }
    
    // MARK: - Haptic Feedback
    
    private func testHapticFeedback() {
        print("Testing haptic feedback capabilities...")
        
        // Test basic haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
        
        // Test after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.prepare()
            notificationFeedback.notificationOccurred(.success)
        }
    }
    
    private func triggerHapticFeedback() {
        guard isHapticFeedbackEnabled else { 
            print("Haptic feedback disabled")
            return 
        }
        
        print("Triggering haptic feedback")
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare() // Prepare the generator for better performance
        impactFeedback.impactOccurred()
    }
    
    private func triggerSuccessHaptic() {
        guard isHapticFeedbackEnabled else { 
            print("Success haptic feedback disabled")
            return 
        }
        
        print("Triggering success haptic feedback")
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare() // Prepare the generator for better performance
        notificationFeedback.notificationOccurred(.success)
    }
    
    private func triggerErrorHaptic() {
        guard isHapticFeedbackEnabled else { 
            print("Error haptic feedback disabled")
            return 
        }
        
        print("Triggering error haptic feedback")
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare() // Prepare the generator for better performance
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
        print("textDidChange called")
        
        // Check if there's selected text first
        if let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty {
            print("Selected text: \(selectedText)")
            // Only resolve if it's an ENS domain
            if HelperClass.checkFormat(selectedText) {
                handleSelectedText(selectedText)
            }
        }
        // Check current word for suggestions
        else if let currentWord = textDocumentProxy.currentWord, !currentWord.isEmpty {
            print("Current word from textDocumentProxy: \(currentWord)")
            updateSuggestionsForWord(currentWord)
        }
        // Fallback to last typed word if textDocumentProxy doesn't work
        else if !lastTypedWord.isEmpty {
            print("Using last typed word: \(lastTypedWord)")
            updateSuggestionsForWord(lastTypedWord)
        } else {
            print("No current word available")
            // Hide suggestions if no current word
            hideENSSuggestion()
            updateSuggestionBar(with: [])
        }
    }
    
    private func updateSuggestionsForWord(_ word: String) {
        // Update last typed word to match current word
        lastTypedWord = word
        
        // Show contextual suggestions based on current word
        let suggestions = getContextualSuggestions(for: word)
        print("Found \(suggestions.count) suggestions for '\(word)': \(suggestions)")
        updateSuggestionBar(with: suggestions)
        
        // Check if it looks like an ENS domain
        if HelperClass.checkFormat(word) {
            // Show suggestion to open in browser
            showENSSuggestion(for: word)
        } else {
            // Hide ENS suggestion overlay if not an ENS domain
            hideENSSuggestion()
        }
    }
}




