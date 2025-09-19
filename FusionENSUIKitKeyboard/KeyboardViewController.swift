//
//  KeyboardViewController.swift
//  FusionENSUIKitKeyboard
//
//  Created by Franz Quarshie on 17/09/2025.
//

import UIKit

// Protocol for keyboard functionality
protocol KeyboardController {
    func insertText(_ text: String)
    func deleteBackward()
    func triggerENSResolution()
}

class KeyboardViewController: UIInputViewController, KeyboardController {
    
    // MARK: - Properties
    private var containerView: UIView!
    private var keyboardStackView: UIStackView!
    private var suggestionBar: UIScrollView?
    private var suggestionButtons: [UIButton] = []
    private var isKeyboardViewSetup = false
    private var isSettingUpView = false
    private var isShiftPressed = false
    private var isCapsLock = false
    private var isNumbersLayout = false
    private var isSecondarySymbolsLayout = false
    private var suggestionOverlay: UIView?
    private var lastTypedWord: String = ""
    private var lastShiftPressTime: TimeInterval = 0
    private var lastSpacePressTime: TimeInterval = 0
    
    // Default ENS suggestions
    private let defaultENSSuggestions = ["linea.eth", "base.eth", "vitalik.eth"]
    
    // Track most typed ENS names
    private var ensUsageCount: [String: Int] = [:]
    private var mostTypedENS: [String] = []
    
    // Selection monitoring
    private var lastSelectedText: String = ""
    private var selectionTimer: Timer?
    
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
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load ENS usage data
        loadENSUsageData()
        
        // Delay setup to ensure proper view dimensions
        DispatchQueue.main.async {
            self.setupKeyboardView()
            self.isKeyboardViewSetup = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Only refresh if not already set up
        if !isKeyboardViewSetup {
            setupKeyboardView()
            isKeyboardViewSetup = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Setup Methods
    private func setupKeyboardView() {
        guard !isSettingUpView else {
            print("⚠️ Already setting up view, skipping")
            return
        }
        
        isSettingUpView = true
        
        cleanupExistingViews()
        
        print("🔧 Creating UIKit keyboard view - Numbers: \(isNumbersLayout), Secondary: \(isSecondarySymbolsLayout), Shift: \(isShiftPressed), CapsLock: \(isCapsLock)")
        let keyboardView = createSimpleKeyboard()
        view.addSubview(keyboardView)
        
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            keyboardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 216.0)
        ])
        print("🔧 UIKit keyboard view created and added")
        
        isSettingUpView = false
        print("🔧 UIKit setupKeyboardView completed")
    }
    
    private func cleanupExistingViews() {
        print("🧹 UIKit KeyboardViewController: Cleaning up existing views")
        
        // Remove all subviews
        view.subviews.forEach { $0.removeFromSuperview() }
        
        // Reset references
        containerView = nil
        keyboardStackView = nil
        suggestionBar = nil
        suggestionButtons.removeAll()
        
        // Force layout update
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        print("🧹 UIKit KeyboardViewController: Cleanup completed")
    }
    
    // MARK: - Keyboard Creation
    private func createSimpleKeyboard() -> UIView {
        print("🔧 UIKit KeyboardViewController: Creating advanced keyboard")
        
        // Create main container
        containerView = UIView()
        
        // iPhone keyboard background - adapts to dark/light mode
        if traitCollection.userInterfaceStyle == .dark {
            containerView.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Dark mode
        } else {
            containerView.backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0) // Light mode
        }
        
        // Remove debugging border
        containerView.layer.borderWidth = 0.0
        print("🔧 UIKit Container view background color set: \(containerView.backgroundColor?.description ?? "nil")")
        
        // Get the available width for the keyboard
        let availableWidth = UIScreen.main.bounds.width
        print("🔧 Available keyboard width: \(availableWidth)")
        
        // Set a minimum height for the container view to prevent 0 height issues
        let minimumHeight: CGFloat = 216.0 // Standard keyboard height
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create suggestion bar
        addSuggestionBar()
        
        // Create keyboard rows
        addKeyboardRows(availableWidth: availableWidth)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: minimumHeight)
        ])
        
        print("🔧 UIKit KeyboardViewController: Advanced keyboard created")
        return containerView
    }
    
    private func addSuggestionBar() {
        suggestionBar = UIScrollView()
        suggestionBar?.translatesAutoresizingMaskIntoConstraints = false
        suggestionBar?.showsHorizontalScrollIndicator = false
        suggestionBar?.backgroundColor = UIColor.clear
        
        // Create horizontal stack view for suggestions
        let suggestionStackView = UIStackView()
        suggestionStackView.axis = .horizontal
        suggestionStackView.distribution = .fillEqually
        suggestionStackView.spacing = 0
        suggestionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add default suggestions
        let defaultSuggestions = getDefaultSuggestions()
        for suggestion in defaultSuggestions {
            let button = createSuggestionButton(title: suggestion)
            suggestionStackView.addArrangedSubview(button)
            suggestionButtons.append(button)
        }
        
        suggestionBar?.addSubview(suggestionStackView)
        containerView.addSubview(suggestionBar!)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Suggestion bar constraints
            suggestionBar!.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            suggestionBar!.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            suggestionBar!.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            suggestionBar!.heightAnchor.constraint(equalToConstant: 40),
            
            // Suggestion stack view constraints
            suggestionStackView.leadingAnchor.constraint(equalTo: suggestionBar!.leadingAnchor),
            suggestionStackView.trailingAnchor.constraint(equalTo: suggestionBar!.trailingAnchor),
            suggestionStackView.topAnchor.constraint(equalTo: suggestionBar!.topAnchor),
            suggestionStackView.bottomAnchor.constraint(equalTo: suggestionBar!.bottomAnchor),
            suggestionStackView.heightAnchor.constraint(equalTo: suggestionBar!.heightAnchor)
        ])
        
        print("🔧 UIKit KeyboardViewController: Suggestion bar added")
    }
    
    private func createSuggestionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        
        // Apple-style suggestion button styling
        button.backgroundColor = UIColor.clear
        if traitCollection.userInterfaceStyle == .dark {
            button.setTitleColor(UIColor.white, for: .normal)
        } else {
            button.setTitleColor(UIColor.black, for: .normal)
        }
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        
        button.addTarget(self, action: #selector(suggestionButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(suggestionButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }
    
    private func addKeyboardRows(availableWidth: CGFloat) {
        let rows: [[String]]
        if isNumbersLayout {
            if isSecondarySymbolsLayout {
                rows = [
                    ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
                    ["-", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"],
                    ["123", ".", ",", "?", "!", "'", "⌫"],
                    ["ABC", ".eth", "space", ":btc", "return"]
                ]
            } else {
                rows = [
                    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                    ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
                    ["#+=", ".", ",", "?", "!", "'", "⌫"],
                    ["ABC", ".eth", "space", ":btc", "return"]
                ]
            }
        } else {
            if isShiftPressed || isCapsLock {
                rows = [
                    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
                    ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
                    ["⇧", "Z", "X", "C", "V", "B", "N", "M", "⌫"],
                    ["123", ".eth", "space", ":btc", "return"]
                ]
            } else {
                rows = [
                    ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
                    ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
                    ["⇧", "z", "x", "c", "v", "b", "n", "m", "⌫"],
                    ["123", ".eth", "space", ":btc", "return"]
                ]
            }
        }
        
        var previousRowView: UIView?
        
        for (rowIndex, row) in rows.enumerated() {
            let rowView = UIView()
            rowView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(rowView)
            
            var previousButton: UIButton?
            
            for (_, key) in row.enumerated() {
                let button = createKeyboardButton(title: key)
                rowView.addSubview(button)
                
                button.translatesAutoresizingMaskIntoConstraints = false
                print("🔧 Created button '\(key)' for row \(rowIndex)")
                
                // Calculate appropriate width based on available space and key type
                let keyWidth = calculateKeyWidth(for: key, in: row, rowIndex: rowIndex, availableWidth: availableWidth)
                
                // Create width constraint with high priority to ensure buttons have proper size
                let widthConstraint = button.widthAnchor.constraint(equalToConstant: keyWidth)
                widthConstraint.priority = UILayoutPriority(999) // High priority to ensure proper sizing
                
                // Use flexible constraints for vertical positioning
                let topConstraint = button.topAnchor.constraint(greaterThanOrEqualTo: rowView.topAnchor, constant: 4)
                let bottomConstraint = button.bottomAnchor.constraint(lessThanOrEqualTo: rowView.bottomAnchor, constant: -4)
                topConstraint.priority = UILayoutPriority(999)
                bottomConstraint.priority = UILayoutPriority(999)
                
                NSLayoutConstraint.activate([
                    topConstraint,
                    bottomConstraint,
                    widthConstraint,
                    // Center the button vertically in the row
                    button.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
                ])
                
                if let previousButton = previousButton {
                    // Position this button after the previous one
                    button.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor, constant: 6).isActive = true
                } else {
                    // First button in the row
                    button.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 3).isActive = true
                }
                
                previousButton = button
            }
            
            // Position the row
            if let previousRowView = previousRowView {
                rowView.topAnchor.constraint(equalTo: previousRowView.bottomAnchor, constant: 8).isActive = true
            } else {
                // First row - position below suggestion bar
                rowView.topAnchor.constraint(equalTo: suggestionBar!.bottomAnchor, constant: 8).isActive = true
            }
            
            // Row constraints
            rowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 3).isActive = true
            rowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -3).isActive = true
            rowView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            // Last row
            if rowIndex == rows.count - 1 {
                rowView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8).isActive = true
            }
            
            previousRowView = rowView
        }
        
        print("🔧 UIKit KeyboardViewController: Keyboard rows added")
    }
    
    private func createKeyboardButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        
        // Use text for all buttons to avoid image loading issues
        button.setTitle(title, for: .normal)
        
        // Use smaller font for bottom row keys
        let fontSize: CGFloat
        if title == "123" || title == "ABC" || title == ".eth" || title == ":btc" || title == "space" || title == "return" {
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
        } else if title == ":btc" {
            // Orange crypto ticker key
            button.backgroundColor = UIColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0) // Orange color
            button.setTitleColor(UIColor.white, for: .normal)
        } else if title == ".eth" {
            // Blue .eth key
            button.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 0.74, alpha: 1.0) // #0080BC
            button.setTitleColor(UIColor.white, for: .normal)
        } else if title == "⇧" || title == "⌫" || title == "123" || title == "ABC" || title == "#+=" || title == "🙂" {
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
        button.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        
        // Handle button actions
        if title == ":btc" {
            print("🔶 Setting up :btc button with special touch handling")
            // Special handling for :btc key with long press
            button.addTarget(self, action: #selector(btcButtonTouchDown), for: .touchDown)
            button.addTarget(self, action: #selector(btcButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
            print("🔶 :btc button targets added successfully")
        } else {
            // Standard button handling
            button.addAction(UIAction { _ in
                self.handleKeyPress(title)
            }, for: .touchUpInside)
        }
        
        // Add long press gesture for spacebar to resolve ENS
        if title == "space" {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleSpacebarLongPress(_:)))
            longPressGesture.minimumPressDuration = 0.5
            longPressGesture.cancelsTouchesInView = true
            longPressGesture.delaysTouchesBegan = true
            longPressGesture.delaysTouchesEnded = true
            button.addGestureRecognizer(longPressGesture)
        }
        
        return button
    }
    
    // MARK: - Button Actions
    @objc private func suggestionButtonTouchDown(_ sender: UIButton) {
        // Apple-style suggestion button press feedback
        if traitCollection.userInterfaceStyle == .dark {
            sender.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        } else {
            sender.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        }
    }
    
    @objc private func suggestionButtonTouchUp(_ sender: UIButton) {
        // Restore original appearance
        sender.backgroundColor = UIColor.clear
        
        if let title = sender.title(for: .normal) {
            print("📝 Inserting suggestion: \(title)")
            
            // Get the current word being typed (last word in lastTypedWord)
            let words = lastTypedWord.components(separatedBy: .whitespacesAndNewlines)
            if let currentWord = words.last, !currentWord.isEmpty {
                // Delete only the current word being typed
                for _ in 0..<currentWord.count {
                    textDocumentProxy.deleteBackward()
                }
            }
            
            // Insert the suggestion
            textDocumentProxy.insertText(title + " ")
            lastTypedWord = ""
            // Update suggestions after insertion
            updateSuggestionBar(with: getDefaultSuggestions())
        }
    }
    
    @objc private func handleSpacePress() {
        textDocumentProxy.insertText(" ")
    }
    
    @objc private func handleReturnPress() {
        textDocumentProxy.insertText("\n")
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        // Visual feedback for button press
        if let title = sender.title(for: .normal) {
            if title == "return" {
                sender.backgroundColor = UIColor(red: 0.0, green: 0.38, blue: 0.8, alpha: 1.0) // Darker blue
            } else if title == ":btc" {
                sender.backgroundColor = UIColor(red: 0.8, green: 0.48, blue: 0.0, alpha: 1.0) // Darker orange
            } else if title == ".eth" {
                sender.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.64, alpha: 1.0) // Darker blue
            } else if title == "⇧" || title == "⌫" || title == "123" || title == "ABC" || title == "#+=" || title == "🙂" {
                // Function keys
                if traitCollection.userInterfaceStyle == .dark {
                    sender.backgroundColor = UIColor(red: 0.37, green: 0.37, blue: 0.40, alpha: 1.0) // Lighter dark mode gray
                } else {
                    sender.backgroundColor = UIColor(red: 0.58, green: 0.58, blue: 0.60, alpha: 1.0) // Darker light mode gray
                }
            } else {
                // Letter/number keys
                if traitCollection.userInterfaceStyle == .dark {
                    sender.backgroundColor = UIColor(red: 0.30, green: 0.30, blue: 0.32, alpha: 1.0) // Lighter dark mode
                } else {
                    sender.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0) // Darker light mode
                }
            }
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        // Restore original button color
        if let title = sender.title(for: .normal) {
            if title == "return" {
                sender.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // Blue return key
            } else if title == ":btc" {
                sender.backgroundColor = UIColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0) // Orange crypto ticker key
            } else if title == ".eth" {
                sender.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 0.74, alpha: 1.0) // #0080BC
            } else if title == "⇧" || title == "⌫" || title == "123" || title == "ABC" || title == "#+=" || title == "🙂" {
                // Function keys - adapt to dark/light mode
                if traitCollection.userInterfaceStyle == .dark {
                    sender.backgroundColor = UIColor(red: 0.27, green: 0.27, blue: 0.30, alpha: 1.0) // Dark mode gray
                } else {
                    sender.backgroundColor = UIColor(red: 0.68, green: 0.68, blue: 0.70, alpha: 1.0) // Light mode gray
                }
                
                // Special styling for caps lock
                if title == "⇧" && isCapsLock {
                    sender.backgroundColor = UIColor.systemBlue
                }
            } else {
                // Letter/number keys - adapt to dark/light mode
                if traitCollection.userInterfaceStyle == .dark {
                    sender.backgroundColor = UIColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1.0) // Dark mode
                } else {
                    sender.backgroundColor = UIColor.white // Light mode
                }
            }
        }
    }
    
    
    func triggerENSResolution() {
        print("🔍 ENS Resolution triggered (Lite Version)")
        
        // Only resolve if there's selected text
        if let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty {
            print("📝 Selected text: '\(selectedText)'")
            if HelperClass.checkFormat(selectedText) {
                print("✅ ENS format detected, resolving...")
                handleSelectedText(selectedText)
            } else {
                print("❌ Not a valid ENS format")
                triggerErrorHaptic()
            }
        } else {
            print("❌ No text selected")
            triggerErrorHaptic()
        }
    }
    
    // MARK: - Key Handling
    private func handleKeyPress(_ key: String) {
        print("🔤 UIKit KeyboardViewController: Key pressed: \(key)")
        
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
                    updateSuggestionBar(with: getDefaultSuggestions())
                }
            }
        case "space":
            handleSpaceKeyPress()
        case "return":
            insertText("\n")
            // Clear last typed word when return is pressed
            lastTypedWord = ""
        case "123":
            // Switch to numbers layout
            print("🔢 123 key pressed - switching to numbers layout")
            switchToNumbersLayout()
        case "ABC":
            // Switch back to letters layout
            print("🔤 ABC key pressed - switching to letters layout")
            switchToLettersLayout()
        case "#+=":
            // Switch to secondary symbols layout
            print("🔣 #+= key pressed - switching to secondary symbols layout")
            switchToSecondarySymbolsLayout()
        case ".eth":
            // .eth key - insert .eth at cursor position
            insertText(".eth")
            lastTypedWord += ".eth"
            // Turn off shift after key press (unless caps lock is on)
            if isShiftPressed && !isCapsLock {
                isShiftPressed = false
                print("⇧ Shift turned off after .eth key press")
                isKeyboardViewSetup = false
                setupKeyboardView()
                isKeyboardViewSetup = true
            }
        case ":btc":
            print("🔶 handleKeyPress called for :btc - inserting :btc text")
            // Crypto ticker key - insert :btc at cursor position
            insertText(":btc")
            lastTypedWord += ":btc"
            // Turn off shift after key press (unless caps lock is on)
            if isShiftPressed && !isCapsLock {
                isShiftPressed = false
                print("⇧ Shift turned off after :btc key press")
                isKeyboardViewSetup = false
                setupKeyboardView()
                isKeyboardViewSetup = true
            }
            print("🔶 :btc text inserted successfully")
        case "🙂":
            // Emoji key - insert smiley face
            insertText("🙂")
            lastTypedWord += "🙂"
            // Turn off shift after key press (unless caps lock is on)
            if isShiftPressed && !isCapsLock {
                isShiftPressed = false
                print("⇧ Shift turned off after emoji key press")
                isKeyboardViewSetup = false
                setupKeyboardView()
                isKeyboardViewSetup = true
            }
        case "⇧":
            // Shift key
            let currentTime = Date().timeIntervalSince1970
            if currentTime - lastShiftPressTime < 0.3 {
                // Double tap shift - toggle caps lock
                isCapsLock.toggle()
                isShiftPressed = false
                print("🔒 Caps lock toggled: \(isCapsLock)")
            } else {
                // Single tap shift - enable for next key only
                isShiftPressed = true
                isCapsLock = false
                print("⇧ Shift enabled for next key: \(isShiftPressed)")
            }
            lastShiftPressTime = currentTime
            // Recreate keyboard with new case
            print("🔄 Recreating keyboard for shift state: shift=\(isShiftPressed), capslock=\(isCapsLock)")
            isKeyboardViewSetup = false
            setupKeyboardView()
            isKeyboardViewSetup = true
        case ".":
            insertText(".")
            lastTypedWord += "."
            // Turn off shift after key press (unless caps lock is on)
            if isShiftPressed && !isCapsLock {
                isShiftPressed = false
                print("⇧ Shift turned off after period key press")
                isKeyboardViewSetup = false
                setupKeyboardView()
                isKeyboardViewSetup = true
            }
        default:
            insertText(key)
            lastTypedWord += key
            
            // Turn off shift after key press (unless caps lock is on)
            if isShiftPressed && !isCapsLock {
                isShiftPressed = false
                print("⇧ Shift turned off after key press")
                // Recreate keyboard to show lowercase
                isKeyboardViewSetup = false
                setupKeyboardView()
                isKeyboardViewSetup = true
            }
            
            // Update suggestions as user types
            updateSuggestionsForWord(lastTypedWord)
        }
    }
    
    
    private func detectAndResolveENSFromContext() {
        // First try to get selected text from the text document proxy
        if let selectedText = textDocumentProxy.selectedText, HelperClass.checkFormat(selectedText) {
            handleSelectedText(selectedText)
            return
        }
        
        // Fallback: Try to get the current word or recent text
        if let currentWord = getCurrentWord(), HelperClass.checkFormat(currentWord) {
            handleSelectedText(currentWord)
        }
    }
    
    private func detectAndResolveENSAroundCursor() {
        // Get text around the cursor
        let beforeText = textDocumentProxy.documentContextBeforeInput ?? ""
        let afterText = textDocumentProxy.documentContextAfterInput ?? ""
        let fullText = beforeText + afterText
        let cursorPosition = beforeText.count
        
        // Look for ENS domains in the text around the cursor
        let words = fullText.components(separatedBy: .whitespacesAndNewlines)
        
        // Check each word to see if it's an ENS domain and if cursor is at the end
        for word in words {
            if HelperClass.checkFormat(word) {
                // Find the position of this ENS domain in the full text
                if let range = fullText.range(of: word) {
                    let ensEndIndex = fullText.distance(from: fullText.startIndex, to: range.upperBound)
                    
                    // Only resolve if cursor is at the end of the ENS domain
                    if cursorPosition == ensEndIndex {
                        replaceENSInText(word)
                        return
                    }
                }
            }
        }
        
        // If no ENS domain found or cursor not at the end, show error
        triggerErrorHaptic()
    }
    
    private func replaceENSInText(_ ensDomain: String) {
        // Trigger haptic feedback when starting resolution
        triggerHapticFeedback()
        
        APICaller.shared.resolveENSName(name: ensDomain) { mappedAddress in
            DispatchQueue.main.async { [weak self] in
                if !mappedAddress.isEmpty {
                    // Smart approach: find the ENS domain position and replace it properly
                    self?.smartReplaceENS(ensDomain, with: mappedAddress)
                    
                    // Trigger success haptic feedback
                    self?.triggerSuccessHaptic()
                } else {
                    // Trigger error haptic feedback
                    self?.triggerErrorHaptic()
                }
            }
        }
    }
    
    private func smartReplaceENS(_ ensDomain: String, with resolvedAddress: String) {
        // Get the current document context
        let beforeText = textDocumentProxy.documentContextBeforeInput ?? ""
        let afterText = textDocumentProxy.documentContextAfterInput ?? ""
        let fullText = beforeText + afterText
        
        // Find the ENS domain in the full text
        if let range = fullText.range(of: ensDomain, options: .backwards) {
            let ensStartIndex = range.lowerBound
            let ensEndIndex = range.upperBound
            
            // Simple and reliable approach: reconstruct the text without the ENS domain
            let textBeforeENS = String(fullText[..<ensStartIndex])
            let textAfterENS = String(fullText[ensEndIndex...])
            let newText = textBeforeENS + resolvedAddress + textAfterENS
            
            // Delete all text from cursor to the beginning
            let charactersToDelete = beforeText.count
            for _ in 0..<charactersToDelete {
                textDocumentProxy.deleteBackward()
            }
            
            // Delete all text after cursor
            let charactersAfterToDelete = afterText.count
            for _ in 0..<charactersAfterToDelete {
                textDocumentProxy.deleteBackward()
            }
            
            // Insert the reconstructed text
            textDocumentProxy.insertText(newText)
            
            // Position cursor after the resolved address (where the ENS domain was)
            let cursorPosition = textBeforeENS.count + resolvedAddress.count
            let charactersToDeleteFromEnd = newText.count - cursorPosition
            for _ in 0..<charactersToDeleteFromEnd {
                textDocumentProxy.deleteBackward()
            }
        } else {
            // Fallback: just delete the ENS domain length and insert
            for _ in 0..<ensDomain.count {
                textDocumentProxy.deleteBackward()
            }
            textDocumentProxy.insertText(resolvedAddress)
        }
    }
    
    private func getCurrentWord() -> String? {
        // Try to get the last typed word
        if !lastTypedWord.isEmpty {
            return lastTypedWord
        }
        
        // Try to get text around the cursor
        if let beforeContext = textDocumentProxy.documentContextBeforeInput,
           let afterContext = textDocumentProxy.documentContextAfterInput {
            
            // Look for ENS domains in the recent context
            let fullContext = beforeContext + afterContext
            let words = fullContext.components(separatedBy: .whitespacesAndNewlines)
            
            // Check the last few words for ENS domains
            for word in words.suffix(3) {
                if HelperClass.checkFormat(word) {
                    return word
                }
            }
        }
        
        return nil
    }
    
    private func handleSelectedText(_ selectedText: String) {
        if HelperClass.checkFormat(selectedText) {
            // Trigger haptic feedback when starting resolution
            triggerHapticFeedback()
            
            APICaller.shared.resolveENSName(name: selectedText) { mappedAddress in
                DispatchQueue.main.async { [weak self] in
                    if !mappedAddress.isEmpty {
                        // Check if we have selected text (proper selection)
                        if let currentSelectedText = self?.textDocumentProxy.selectedText, currentSelectedText == selectedText {
                            // We have proper selected text, so we can replace it directly
                            // The text document proxy will handle the replacement correctly
                            self?.textDocumentProxy.insertText(mappedAddress)
                        } else {
                            // For spacebar long-press or other cases, we need to find and replace the text
                            self?.replaceTextInDocument(selectedText, with: mappedAddress)
                        }
                        
                        // Trigger success haptic feedback
                        self?.triggerSuccessHaptic()
                    } else {
                        // Trigger error haptic feedback
                        self?.triggerErrorHaptic()
                    }
                }
            }
        } else {
            // Trigger error haptic feedback for invalid format
            triggerErrorHaptic()
        }
    }
    
    private func replaceTextInDocument(_ textToReplace: String, with replacementText: String) {
        // Simple and safe approach: just delete the text length and insert
        // This works regardless of cursor position and avoids complex calculations
        for _ in 0..<textToReplace.count {
            textDocumentProxy.deleteBackward()
        }
        textDocumentProxy.insertText(replacementText)
    }
    
    // MARK: - Haptic Feedback
    
    private func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func triggerSuccessHaptic() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    private func triggerErrorHaptic() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    // MARK: - Selection Monitoring
    
    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        checkForSelectedText()
    }
    
    private func checkForSelectedText() {
        // Cancel previous timer
        selectionTimer?.invalidate()
        
        // Start a new timer to check for selection after a short delay
        selectionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
            self?.processSelectedText()
        }
    }
    
    private func processSelectedText() {
        guard let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty else {
            lastSelectedText = ""
            return
        }
        
        // Only process if the selection has changed
        guard selectedText != lastSelectedText else { return }
        
        lastSelectedText = selectedText
        print("📝 Text selected (Lite): '\(selectedText)'")
        
        // Check if it's an ENS domain and resolve automatically
        if HelperClass.checkFormat(selectedText) {
            print("✅ ENS format detected, auto-resolving (Lite)...")
            handleSelectedText(selectedText)
        }
    }
    
    // MARK: - Helper Methods
    
    private func calculateKeyWidth(for key: String, in row: [String], rowIndex: Int, availableWidth: CGFloat) -> CGFloat {
        let spacing: CGFloat = 6
        let margins: CGFloat = 6
        let availableWidthForKeys = availableWidth - margins
        
        // Special key widths
        switch key {
        case "space":
            return availableWidthForKeys * 0.4 // Space bar takes 40% of available width
        case "return":
            return availableWidthForKeys * 0.15 // Return key
        case "123", "ABC", ".eth", "⇧", "⌫", "#+=", "🙂":
            return availableWidthForKeys * 0.12 // Function keys
        default:
            // Regular keys - distribute remaining space equally
            let functionKeys = row.filter { ["space", "return", "123", "ABC", ".eth", "⇧", "⌫", "#+=", "🙂"].contains($0) }
            let regularKeys = row.filter { !["space", "return", "123", "ABC", ".eth", "⇧", "⌫", "#+=", "🙂"].contains($0) }
            
            let functionKeyWidth = functionKeys.reduce(0) { total, key in
                total + calculateKeyWidth(for: key, in: row, rowIndex: rowIndex, availableWidth: availableWidth)
            }
            
            let remainingWidth = availableWidthForKeys - functionKeyWidth - (CGFloat(row.count - 1) * spacing)
            return remainingWidth / CGFloat(regularKeys.count)
        }
    }
    
    // MARK: - ENS Usage Tracking
    
    private func loadENSUsageData() {
        // Use default suggestions to avoid I/O operations
        mostTypedENS = defaultENSSuggestions
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
        guard let suggestionBar = suggestionBar else { 
            print("⚠️ Suggestion bar is nil")
            return 
        }
        
        // Find the stack view
        guard let suggestionStackView = suggestionBar.subviews.first as? UIStackView else {
            print("⚠️ Suggestion stack view not found")
            return
        }
        
        // Clear existing buttons
        suggestionButtons.forEach { $0.removeFromSuperview() }
        suggestionButtons.removeAll()
        suggestionStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add suggestions
        for suggestion in suggestions {
            let button = createSuggestionButton(title: suggestion)
            suggestionStackView.addArrangedSubview(button)
            suggestionButtons.append(button)
        }
        
        print("📝 Updated suggestion bar with \(suggestions.count) suggestions")
    }
    
    // MARK: - Layout Switching
    
    @objc private func switchToNumbersLayout() {
        print("🔢 Switching to numbers layout")
        isNumbersLayout = true
        isSecondarySymbolsLayout = false
        isKeyboardViewSetup = false
        setupKeyboardView()
        isKeyboardViewSetup = true
    }
    
    @objc private func switchToLettersLayout() {
        print("🔤 Switching to letters layout")
        isNumbersLayout = false
        isSecondarySymbolsLayout = false
        isKeyboardViewSetup = false
        setupKeyboardView()
        isKeyboardViewSetup = true
    }
    
    @objc private func switchToSecondarySymbolsLayout() {
        print("🔣 Switching to secondary symbols layout")
        isSecondarySymbolsLayout = true
        isKeyboardViewSetup = false
        setupKeyboardView()
        isKeyboardViewSetup = true
    }
    
    // MARK: - Key Handling
    
    private func handleSpaceKeyPress() {
        let currentTime = Date().timeIntervalSince1970
        
        // Check for double space press (within 0.5 seconds)
        if currentTime - lastSpacePressTime < 0.5 {
            // Double space - insert period and space
            textDocumentProxy.deleteBackward() // Remove the first space
            textDocumentProxy.insertText(". ")
            lastTypedWord = ""
        } else {
            // Single space
            textDocumentProxy.insertText(" ")
            lastTypedWord += " "
        }
        
        lastSpacePressTime = currentTime
        
        // Update suggestions after space
        if !lastTypedWord.isEmpty {
            updateSuggestionsForWord(lastTypedWord)
        } else {
            updateSuggestionBar(with: getDefaultSuggestions())
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
    }
    
    // MARK: - Text Input Methods
    
    func insertText(_ text: String) {
        textDocumentProxy.insertText(text)
    }
    
    func deleteBackward() {
        textDocumentProxy.deleteBackward()
    }
    
    // MARK: - Crypto Ticker Options
    
    // MARK: - :btc Key Handling
    
    private var btcLongPressTimer: Timer?
    private var btcButtonPressed = false
    private var btcLongPressOccurred = false
    
    @objc private func btcButtonTouchDown(_ sender: UIButton) {
        print("🔶 :btc button touch down - starting long press detection")
        btcButtonPressed = true
        btcLongPressOccurred = false
        
        // Start long press timer
        btcLongPressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            print("🔶 :btc long press timer fired - checking if button still pressed")
            if self?.btcButtonPressed == true {
                print("🔶 :btc long press detected - showing crypto options")
                // Long press detected - show crypto options
                self?.btcLongPressOccurred = true
                self?.showCryptoTickerOptions()
            } else {
                print("🔶 :btc long press timer fired but button no longer pressed")
            }
        }
        print("🔶 :btc long press timer started with 0.5 second delay")
    }
    
    @objc private func btcButtonTouchUp(_ sender: UIButton) {
        print("🔶 :btc button touch up - checking if long press occurred")
        print("🔶 :btc btcLongPressOccurred: \(btcLongPressOccurred)")
        
        btcButtonPressed = false
        btcLongPressTimer?.invalidate()
        btcLongPressTimer = nil
        
        // If it was a short press (no long press occurred), handle as normal tap
        if !btcLongPressOccurred {
            print("🔶 :btc short press detected - inserting :btc")
            handleKeyPress(":btc")
        } else {
            print("🔶 :btc long press occurred - not inserting :btc")
        }
        
        // Reset the long press flag
        btcLongPressOccurred = false
    }
    
    private func showCryptoTickerOptions() {
        print("🔶 showCryptoTickerOptions called - starting crypto options display")
        
        // Add haptic feedback
        print("🔶 Triggering haptic feedback")
        triggerHapticFeedback()
        
        let cryptoOptions = [
            // Most popular blockchain networks
            ":btc", ":sol", ":doge",
            // Additional blockchain networks  
            ":xrp", ":ltc", ":ada", ":dot",
            // Text records
            ":url", ":x", ":github", ":name", ":bio"
        ]
        
        print("🔶 Creating custom popup with \(cryptoOptions.count) crypto options")
        
        // Create custom popup view instead of UIAlertController
        createCustomCryptoPopup(with: cryptoOptions)
    }
    
    private func createCustomCryptoPopup(with options: [String]) {
        // Remove any existing popup
        view.subviews.forEach { subview in
            if subview.tag == 999 { // Tag for our custom popup
                subview.removeFromSuperview()
            }
        }
        
        // Create popup container
        let popupContainer = UIView()
        popupContainer.tag = 999
        popupContainer.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        popupContainer.layer.cornerRadius = 12
        popupContainer.layer.shadowColor = UIColor.black.cgColor
        popupContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        popupContainer.layer.shadowRadius = 8
        popupContainer.layer.shadowOpacity = 0.3
        popupContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Create scroll view for options
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        popupContainer.addSubview(scrollView)
        
        // Create container view for centering content
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)
        
        // Create main vertical stack view for rows
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 8
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(mainStackView)
        
        // Add title label
        let titleLabel = UILabel()
        titleLabel.text = "Ticker Options"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        popupContainer.addSubview(titleLabel)
        
        // Create grid layout - 3 columns
        let columnsPerRow = 3
        var currentRowStackView: UIStackView?
        
        for (index, ticker) in options.enumerated() {
            // Create new row every 3 items
            if index % columnsPerRow == 0 {
                currentRowStackView = UIStackView()
                currentRowStackView?.axis = .horizontal
                currentRowStackView?.distribution = .fillEqually
                currentRowStackView?.spacing = 8
                currentRowStackView?.translatesAutoresizingMaskIntoConstraints = false
                mainStackView.addArrangedSubview(currentRowStackView!)
            }
            
            let button = UIButton(type: .system)
            button.setTitle(ticker, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.backgroundColor = UIColor.systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.translatesAutoresizingMaskIntoConstraints = false
            
            // Set button height
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            button.addAction(UIAction { _ in
                print("🔶 Crypto option selected: \(ticker)")
                self.insertText(ticker)
                self.lastTypedWord += ticker
                // Turn off shift after key press (unless caps lock is on)
                if self.isShiftPressed && !self.isCapsLock {
                    self.isShiftPressed = false
                    print("⇧ Shift turned off after \(ticker) key press")
                    self.isKeyboardViewSetup = false
                    self.setupKeyboardView()
                    self.isKeyboardViewSetup = true
                }
                // Remove popup
                popupContainer.removeFromSuperview()
            }, for: .touchUpInside)
            
            currentRowStackView?.addArrangedSubview(button)
        }
        
        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        closeButton.backgroundColor = UIColor.systemGray
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 8
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton.addAction(UIAction { _ in
            print("🔶 Crypto options closed")
            popupContainer.removeFromSuperview()
        }, for: .touchUpInside)
        
        mainStackView.addArrangedSubview(closeButton)
        
        // Add to main view
        view.addSubview(popupContainer)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Popup container constraints
            popupContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupContainer.widthAnchor.constraint(equalToConstant: 280),
            popupContainer.heightAnchor.constraint(equalToConstant: 400),
            
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: popupContainer.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: popupContainer.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: popupContainer.trailingAnchor, constant: -16),
            
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: popupContainer.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: popupContainer.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: popupContainer.bottomAnchor, constant: -16),
            
            // Container view constraints (centers content in scroll view)
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            containerView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
            
            // Stack view constraints (centered in container)
            mainStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mainStackView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 8),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8)
        ])
        
        print("🔶 Custom crypto popup created and displayed successfully")
    }
    
    @objc private func handleSpacebarLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        // Prevent keyboard switching by consuming the gesture
        gesture.cancelsTouchesInView = true
        
        // Add haptic feedback
        triggerHapticFeedback()
        
        // Detect and resolve ENS domain around cursor
        detectAndResolveENSAroundCursor()
    }
    
}
