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
    private var isCapsLock = false
    private var isNumbersLayout = false
    private var isSecondarySymbolsLayout = false
    private var suggestionOverlay: UIView?
    private var suggestionBar: UIScrollView?
    private var suggestionButtons: [UIButton] = []
    private var lastTypedWord: String = ""
    private var lastShiftPressTime: TimeInterval = 0
    private var lastSpacePressTime: TimeInterval = 0
    
    // Default ENS suggestions
    private let defaultENSSuggestions = ["linea.eth", "base.eth", "vitalik.eth"]
    
    // Track most typed ENS names
    private var ensUsageCount: [String: Int] = [:]
    private var mostTypedENS: [String] = []
    
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
            // Default to enabled to avoid I/O operations
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardView()
        isKeyboardViewSetup = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Ensure keyboard is set up
        if !isKeyboardViewSetup {
            setupKeyboardView()
            isKeyboardViewSetup = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // No operations to avoid I/O issues
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // No operations to avoid I/O issues
    }
    
    private func setupKeyboardView() {
        // Clear any existing views
        view.subviews.forEach { $0.removeFromSuperview() }
        
        // Create the actual keyboard view
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
        
        // iPhone keyboard background - adapts to dark/light mode
        if traitCollection.userInterfaceStyle == .dark {
            containerView.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Dark mode
        } else {
            containerView.backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0) // Light mode
        }
        
        let rows: [[String]]
        if isNumbersLayout {
            if isSecondarySymbolsLayout {
                rows = [
                    ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
                    ["-", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"],
                    ["123", ".", ",", "?", "!", "'", "⌫"],
                    ["ABC", "🙂", "space", "return"]
                ]
            } else {
                rows = [
                    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                    ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
                    ["#+=", ".", ",", "?", "!", "'", "⌫"],
                    ["ABC", "space", "return"]
                ]
            }
        } else {
            if isShiftPressed || isCapsLock {
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
            NSLayoutConstraint.activate([
                rowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                rowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                rowView.heightAnchor.constraint(equalToConstant: 45)
            ])
            
            if let previousRow = previousRow {
                rowView.topAnchor.constraint(equalTo: previousRow.bottomAnchor, constant: 12).isActive = true
            } else {
                // First row should be below the suggestion bar
                rowView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 48).isActive = true
            }
            
            if rowIndex == rows.count - 1 {
                rowView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6).isActive = true
            }
            
            // Create buttons for all rows
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
                case "🌐", "🙂":
                    keyWidth = 50   // Globe key and emoji key
                case "return", "search":
                    keyWidth = 75   // Return/Search key
                default:
                    // For the second row (symbols row), use smaller width to fit 10 keys
                    if rowIndex == 1 {
                        // ASDF row - wider width for A, S, D, F, G, H, J, K, but keep L key smaller
                        if key == "L" || key == "l" {
                            keyWidth = 33   // Keep L key smaller
                        } else {
                            keyWidth = 35   // Wider width for other ASDF row keys
                        }
                    } else {
                        keyWidth = 36   // Standard letter/number key width
                    }
                }
                
                NSLayoutConstraint.activate([
                    button.topAnchor.constraint(equalTo: rowView.topAnchor),
                    button.bottomAnchor.constraint(equalTo: rowView.bottomAnchor),
                    button.widthAnchor.constraint(equalToConstant: keyWidth)
                ])
                
                if let previousButton = previousButton {
                    button.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor, constant: 6).isActive = true
                } else {
                    // For the second row, add extra leading margin to center it
                    if rowIndex == 1 {
                        button.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 24).isActive = true
                    } else {
                        button.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 6).isActive = true
                    }
                }
                
                // Pin the last key to trailing edge to define row width (except for second row)
                if key == row.last && rowIndex != 1 {
                    button.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -6).isActive = true
                } else if key == row.last && rowIndex == 1 {
                    // For second row, add trailing margin to match leading margin
                    button.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -24).isActive = true
                }
                
                previousButton = button
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
        // Match keyboard background - adapts to dark/light mode
        if traitCollection.userInterfaceStyle == .dark {
            suggestionBar.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Dark mode
        } else {
            suggestionBar.backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0) // Light mode
        }
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
        
        // Adapt text color to dark/light mode
        if traitCollection.userInterfaceStyle == .dark {
            button.setTitleColor(UIColor.white, for: .normal)
        } else {
            button.setTitleColor(UIColor.black, for: .normal)
        }
        
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
            self.insertSuggestion(text)
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
        
        // Use text for all buttons to avoid image loading issues
        button.setTitle(title, for: .normal)
        
        // Use smaller font for bottom row keys
        let fontSize: CGFloat
        if title == "123" || title == "ABC" || title == "🌐" || title == "space" || title == "return" {
            fontSize = 16  // Smaller font for bottom row
        } else {
            fontSize = 22  // Standard font for other keys
        }
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        
        // iPhone keyboard styling - adapts to dark/light mode
        if title == "return" {
            // Blue return key
            button.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
            button.setTitleColor(UIColor.white, for: .normal)
        } else if title == "⇧" || title == "⌫" || title == "123" || title == "🌐" || title == "ABC" || title == "#+=" || title == "🙂" || title == "search" {
            // Function keys - adapt to dark/light mode
            if traitCollection.userInterfaceStyle == .dark {
                button.backgroundColor = UIColor(red: 0.27, green: 0.27, blue: 0.30, alpha: 1.0) // Dark mode gray
                button.setTitleColor(UIColor.white, for: .normal)
            } else {
                button.backgroundColor = UIColor(red: 0.68, green: 0.68, blue: 0.70, alpha: 1.0) // Light mode gray
                button.setTitleColor(UIColor.black, for: .normal)
            }
            
            // Special styling for caps lock
            if title == "⇧" && isCapsLock {
                button.backgroundColor = UIColor.systemBlue
                button.setTitleColor(UIColor.white, for: .normal)
            }
        } else {
            // Letter/number keys - adapt to dark/light mode
            if traitCollection.userInterfaceStyle == .dark {
                button.backgroundColor = UIColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1.0) // Dark mode
                button.setTitleColor(UIColor.white, for: .normal)
            } else {
                button.backgroundColor = UIColor.white // Light mode
                button.setTitleColor(UIColor.black, for: .normal)
            }
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
        // iPhone keyboard press effect - darken the button (adapts to dark/light mode)
        UIView.animate(withDuration: 0.1) {
            if sender.backgroundColor == UIColor.white {
                sender.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) // Light mode white key press
            } else if sender.backgroundColor == UIColor(red: 0.68, green: 0.68, blue: 0.70, alpha: 1.0) {
                sender.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0) // Light mode gray key press
            } else if sender.backgroundColor == UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) {
                sender.backgroundColor = UIColor(red: 0.0, green: 0.3, blue: 0.8, alpha: 1.0) // Blue key press
            } else if sender.backgroundColor == UIColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1.0) {
                sender.backgroundColor = UIColor(red: 0.35, green: 0.35, blue: 0.37, alpha: 1.0) // Dark mode key press
            } else if sender.backgroundColor == UIColor(red: 0.27, green: 0.27, blue: 0.30, alpha: 1.0) {
                sender.backgroundColor = UIColor(red: 0.42, green: 0.42, blue: 0.45, alpha: 1.0) // Dark mode function key press
            }
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        // Return to normal iPhone keyboard colors (adapts to dark/light mode)
        UIView.animate(withDuration: 0.1) {
            if let title = sender.title(for: .normal) {
                if title == "return" {
                    sender.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // Blue return
                } else if title == "⇧" || title == "⌫" || title == "123" || title == "🌐" || title == "ABC" || title == "#+=" || title == "🙂" || title == "search" {
                    // Function keys - adapt to dark/light mode
                    if title == "⇧" && self.isCapsLock {
                        sender.backgroundColor = UIColor.systemBlue // Caps lock is blue
                    } else if self.traitCollection.userInterfaceStyle == .dark {
                        sender.backgroundColor = UIColor(red: 0.27, green: 0.27, blue: 0.30, alpha: 1.0) // Dark mode gray
                    } else {
                        sender.backgroundColor = UIColor(red: 0.68, green: 0.68, blue: 0.70, alpha: 1.0) // Light mode gray
                    }
                } else {
                    // Letter/number keys - adapt to dark/light mode
                    if self.traitCollection.userInterfaceStyle == .dark {
                        sender.backgroundColor = UIColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1.0) // Dark mode
                    } else {
                        sender.backgroundColor = UIColor.white // Light mode
                    }
                }
            } else if sender.image(for: .normal) != nil {
                // Handle image button (globe icon) - adapt to dark/light mode
                if self.traitCollection.userInterfaceStyle == .dark {
                    sender.backgroundColor = UIColor(red: 0.27, green: 0.27, blue: 0.30, alpha: 1.0) // Dark mode gray
                } else {
                    sender.backgroundColor = UIColor(red: 0.68, green: 0.68, blue: 0.70, alpha: 1.0) // Light mode gray
                }
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
            handleSpaceKeyPress()
        case "return", "search":
            insertText("\n")
            // Clear last typed word when return is pressed
            lastTypedWord = ""
        case "123":
            // Switch to numbers layout (or back to primary numbers if in secondary symbols)
            switchToNumbersLayout()
            break
        case "ABC":
            // Switch back to letters layout
            switchToLettersLayout()
            break
        case "#+=":
            // Switch to secondary symbols layout
            switchToSecondarySymbolsLayout()
            break
        case "🌐":
            // Globe key - insert .eth at cursor position
            insertText(".eth")
            lastTypedWord += ".eth"
        case "🙂":
            // Emoji key - insert smiley face
            insertText("🙂")
            lastTypedWord += "🙂"
        case ".":
            insertText(".")
            lastTypedWord += "."
        case "⇧":
            handleShiftKeyPress()
        default:
            let shouldCapitalize = (isShiftPressed || isCapsLock) || shouldAutoCapitalize()
            let textToInsert = shouldCapitalize ? key.uppercased() : key.lowercased()
            insertText(textToInsert)
            lastTypedWord += textToInsert
            
            // Update suggestions after typing
            updateSuggestionsForWord(lastTypedWord)
            
            // Auto-release shift after typing (but not caps lock)
            if isShiftPressed {
                isShiftPressed = false
                updateKeyboardAppearance()
            }
        }
    }
    
    private func shouldAutoCapitalize() -> Bool {
        guard isAutoCapitalizationEnabled else { return false }
        
        // Check if we're at the beginning of a sentence
        // This is a simplified implementation - in a real app you'd want more sophisticated logic
        if let documentContext = textDocumentProxy.documentContextBeforeInput {
            let trimmedContext = documentContext.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmedContext.isEmpty || trimmedContext.hasSuffix(".") || trimmedContext.hasSuffix("!") || trimmedContext.hasSuffix("?")
        }
        
        return false
    }
    
    private func handleShiftKeyPress() {
        let currentTime = Date().timeIntervalSince1970
        
        // Check if this is a double tap (within 0.5 seconds) and caps lock is enabled
        if currentTime - lastShiftPressTime < 0.5 && isCapsLockEnabled {
            // Double tap - toggle caps lock (only if enabled in system settings)
            isCapsLock.toggle()
            isShiftPressed = false // Clear shift when caps lock is activated
        } else {
            // Single tap - toggle shift
            isShiftPressed.toggle()
            isCapsLock = false // Clear caps lock when shift is pressed
        }
        
        lastShiftPressTime = currentTime
        
        // Update keyboard appearance to show shift/caps lock state
        updateKeyboardAppearance()
    }
    
    private func handleSpaceKeyPress() {
        let currentTime = Date().timeIntervalSince1970
        
        // Check if this is a double tap (within 0.5 seconds) and period shortcut is enabled
        if currentTime - lastSpacePressTime < 0.5 && isPeriodShortcutEnabled {
            // Double tap - insert period and space
            insertText(". ")
        } else {
            // Single tap - insert space
            insertText(" ")
        }
        
        lastSpacePressTime = currentTime
        
        // Clear last typed word when space is pressed
        lastTypedWord = ""
        // Hide suggestions when space is pressed
        updateSuggestionBar(with: [])
    }
    
    private func triggerENSResolution() {
        // First try to get selected text
        if let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty {
            if HelperClass.checkFormat(selectedText) {
                handleSelectedText(selectedText)
                return
            } else {
                triggerErrorHaptic()
                return
            }
        }
        
        // Try the last typed word
        if !lastTypedWord.isEmpty {
            if HelperClass.checkFormat(lastTypedWord) {
                handleSelectedText(lastTypedWord)
                return
            } else {
                triggerErrorHaptic()
                return
            }
        }
        
        // Try to get current word from text document proxy
        if let currentWord = textDocumentProxy.currentWord, !currentWord.isEmpty {
            if HelperClass.checkFormat(currentWord) {
                handleSelectedText(currentWord)
                return
            } else {
                triggerErrorHaptic()
                return
            }
        }
        
        triggerErrorHaptic()
    }
    
    private func updateKeyboardAppearance() {
        // Recreate keyboard when shift state changes
        print("Shift state: \(isShiftPressed)")
        
        // Recreate with new shift state
        setupKeyboardView()
        isKeyboardViewSetup = true
    }
    
    private func switchToNumbersLayout() {
        isNumbersLayout = true
        isSecondarySymbolsLayout = false
        // Recreate with numbers layout
        setupKeyboardView()
        isKeyboardViewSetup = true
    }
    
    private func switchToLettersLayout() {
        isNumbersLayout = false
        isSecondarySymbolsLayout = false
        // Recreate with letters layout
        setupKeyboardView()
        isKeyboardViewSetup = true
    }
    
    private func switchToSecondarySymbolsLayout() {
        isSecondarySymbolsLayout = true
        // Recreate with secondary symbols layout
        setupKeyboardView()
        isKeyboardViewSetup = true
    }
    
    // MARK: - ENS Usage Tracking
    
    private func loadENSUsageData() {
        // Use default suggestions to avoid I/O operations
        mostTypedENS = defaultENSSuggestions
    }
    
    private func saveENSUsageData() {
        // No I/O operations to avoid performance issues
    }
    
    private func trackENSUsage(_ ensName: String) {
        // No tracking to avoid I/O operations
    }
    
    private func getDefaultSuggestions() -> [String] {
        // Return the 3 most typed ENS names, or defaults if none
        return mostTypedENS.count >= 3 ? Array(mostTypedENS.prefix(3)) : defaultENSSuggestions
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
        
        // Limit to top 3 suggestions
        return Array(suggestions.prefix(3))
    }
    
    private func updateSuggestionBar(with suggestions: [String]) {
        // Clear existing suggestion buttons and all subviews (including separators)
        suggestionButtons.forEach { $0.removeFromSuperview() }
        suggestionButtons.removeAll()
        
        // Clear all subviews from suggestion bar to remove any leftover separators
        suggestionBar?.subviews.forEach { $0.removeFromSuperview() }
        
        // Always show suggestion bar with exactly 3 items
        suggestionBar?.isHidden = false
        
        // Ensure we have exactly 3 suggestions (pad with empty strings if needed)
        let paddedSuggestions = Array(suggestions.prefix(3))
        let finalSuggestions = paddedSuggestions + Array(repeating: "", count: max(0, 3 - paddedSuggestions.count))
        
        // Create exactly 3 suggestion buttons with separators
        var previousButton: UIButton?
        
        for (index, suggestion) in finalSuggestions.enumerated() {
            let button = createSuggestionButton(text: suggestion)
            if suggestion.isEmpty {
                button.isUserInteractionEnabled = false
                button.alpha = 0.3
            }
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
            
            if index == finalSuggestions.count - 1 {
                // Leave space for the .eth button (40pt width + 12pt margin + 4pt spacing = 56pt)
                button.trailingAnchor.constraint(equalTo: suggestionBar!.trailingAnchor, constant: -56).isActive = true
            }
            
            // Always add separator after each button except the last one
            if index < finalSuggestions.count - 1 {
                let separator = UIView()
                separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                suggestionBar?.addSubview(separator)
                
                separator.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    separator.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 2),
                    separator.topAnchor.constraint(equalTo: suggestionBar!.topAnchor, constant: 12),
                    separator.bottomAnchor.constraint(equalTo: suggestionBar!.bottomAnchor, constant: -12),
                    separator.widthAnchor.constraint(equalToConstant: 0.5)
                ])
            }
            
            previousButton = button
        }
        
        // Add .eth button to the rightmost part of the suggestion bar
        addEthButton()
    }
    
    private func addEthButton() {
        guard let suggestionBar = suggestionBar else { return }
        
        let ethButton = UIButton(type: .system)
        ethButton.setTitle(".eth", for: .normal)
        ethButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        ethButton.setTitleColor(UIColor.white, for: .normal)
        
        ethButton.addAction(UIAction { _ in
            self.triggerHapticFeedback()
            self.insertText(".eth")
            self.lastTypedWord += ".eth"
        }, for: .touchUpInside)
        
        suggestionBar.addSubview(ethButton)
        suggestionButtons.append(ethButton)
        
        ethButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ethButton.topAnchor.constraint(equalTo: suggestionBar.topAnchor, constant: 8),
            ethButton.bottomAnchor.constraint(equalTo: suggestionBar.bottomAnchor, constant: -8),
            ethButton.trailingAnchor.constraint(equalTo: suggestionBar.trailingAnchor, constant: -12),
            ethButton.widthAnchor.constraint(equalToConstant: 40),
            ethButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - System Settings
    
    private var isCapsLockEnabled: Bool {
        return true
    }
    
    private var isPeriodShortcutEnabled: Bool {
        return true
    }
    
    private var isAutoCapitalizationEnabled: Bool {
        return true
    }
    
    private var isAutoCorrectionEnabled: Bool {
        return false
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
    
    private func insertSuggestion(_ suggestion: String) {
        // Get the current word that needs to be replaced
        let currentWord = textDocumentProxy.currentWord ?? ""
        
        // If there's a current word, delete it first
        if !currentWord.isEmpty {
            // Delete the current word by moving back and deleting
            for _ in 0..<currentWord.count {
                textDocumentProxy.deleteBackward()
            }
        }
        
        // Insert the suggestion
        textDocumentProxy.insertText(suggestion)
        
        // Update lastTypedWord to the suggestion
        lastTypedWord = suggestion
        
        // Track ENS usage if it's an ENS domain
        if suggestion.hasSuffix(".eth") {
            trackENSUsage(suggestion)
        }
        
        // Clear suggestions after selection
        updateSuggestionBar(with: [])
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
        
        // Get contextual suggestions
        let contextualSuggestions = getContextualSuggestions(for: word)
        
        if !contextualSuggestions.isEmpty {
            // Show contextual suggestions if available
            updateSuggestionBar(with: contextualSuggestions)
        } else {
            // Show default suggestions when no contextual matches
            let defaultSuggestions = getDefaultSuggestions()
            updateSuggestionBar(with: defaultSuggestions)
        }
        
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




