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

// Contact model for keyboard suggestions
struct Contact: Codable {
    let name: String
    let ensName: String
    let address: String?
    let avatarURL: String?
    
    init(name: String, ensName: String, profileImage: UIImage? = nil, address: String?, avatarURL: String? = nil) {
        self.name = name
        self.ensName = ensName
        self.address = address
        self.avatarURL = avatarURL
    }
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
    
    deinit {
        // Clean up timers to prevent memory leaks
        selectionTimer?.invalidate()
        selectionTimer = nil
        btcLongPressTimer?.invalidate()
        btcLongPressTimer = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Refresh ENS data to get latest contacts and saved names
        loadENSUsageData()
        
        // Only refresh if not already set up
        if !isKeyboardViewSetup {
            setupKeyboardView()
            isKeyboardViewSetup = true
        } else {
            // Update suggestions with latest data
            updateSuggestionBar(with: getDefaultSuggestions())
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
                let topConstraint = button.topAnchor.constraint(greaterThanOrEqualTo: rowView.topAnchor, constant: 6)
                let bottomConstraint = button.bottomAnchor.constraint(lessThanOrEqualTo: rowView.bottomAnchor, constant: -6)
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
                rowView.topAnchor.constraint(equalTo: previousRowView.bottomAnchor, constant: 4).isActive = true
            } else {
                // First row - position below suggestion bar
                rowView.topAnchor.constraint(equalTo: suggestionBar!.bottomAnchor, constant: 4).isActive = true
            }
            
            // Row constraints
            rowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 3).isActive = true
            rowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -3).isActive = true
            rowView.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
            
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
        
        // Add touch feedback (except for special buttons that handle their own feedback)
        if title != ":btc" && title != "space" {
            button.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
            button.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
        
        
        // Handle button actions
        if title == ":btc" {
            print("🔶 Setting up :btc button with special touch handling")
            // Special handling for :btc key with long press
            button.addTarget(self, action: #selector(btcButtonTouchDown), for: .touchDown)
            button.addTarget(self, action: #selector(btcButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
            print("🔶 :btc button targets added successfully")
        } else if title == "space" {
            // Special handling for space bar with long press
            button.addTarget(self, action: #selector(spaceButtonTouchDown), for: .touchDown)
            button.addTarget(self, action: #selector(spaceButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
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
        
        // Add long press gesture for 123 button to switch keyboards
        if title == "123" {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handle123LongPress(_:)))
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
    
    // MARK: - Space Bar Touch Handling
    @objc private func spaceButtonTouchDown(_ sender: UIButton) {
        // Visual feedback for space bar press
        if traitCollection.userInterfaceStyle == .dark {
            sender.backgroundColor = UIColor(red: 0.30, green: 0.30, blue: 0.32, alpha: 1.0) // Lighter dark mode
        } else {
            sender.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0) // Darker light mode
        }
    }
    
    @objc private func spaceButtonTouchUp(_ sender: UIButton) {
        // Restore original appearance
        if traitCollection.userInterfaceStyle == .dark {
            sender.backgroundColor = UIColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1.0) // Dark mode
        } else {
            sender.backgroundColor = UIColor.white // Light mode
        }
        
        // Handle space key press
        handleKeyPress("space")
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
        
        // Only resolve if there's selected text
        if let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty {
            print("📝 Selected text: '\(selectedText)'")
            if HelperClass.checkFormat(selectedText) {
                print("✅ ENS format detected, resolving...")
                handleSelectedText(selectedText)
            } else {
                print("❌ Not a valid ENS format")
            }
        } else {
            print("❌ No text selected")
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
            // Check if we're in a browser address bar and handle auto-resolve
            print("🔍 Return key pressed - checking browser context...")
            let isBrowser = isInBrowserAddressBar()
            print("🔍 Browser context result: \(isBrowser)")
            if isBrowser {
                print("🔍 Browser context detected - handling auto-resolve")
                // Show loading indicator on return key
                updateReturnKeyToLoading()
                handleReturnKeyInAddressBar()
            } else {
                print("🔍 No browser context - normal return")
                insertText("\n")
                // Clear last typed word when return is pressed
                lastTypedWord = ""
            }
        case "123":
            // Switch to numbers layout OR next keyboard (long press)
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
    }
    
    private func replaceENSInText(_ ensDomain: String) {
        // Trigger haptic feedback when starting resolution
        
        APICaller.shared.resolveENSName(name: ensDomain) { mappedAddress in
            DispatchQueue.main.async { [weak self] in
                if !mappedAddress.isEmpty {
                    // Smart approach: find the ENS domain position and replace it properly
                    self?.smartReplaceENS(ensDomain, with: mappedAddress)
                    
                    // Add ENS name to suggestions for future use
                    self?.addENSNameToSuggestions(ensDomain)
                    
                    // Trigger success haptic feedback
                } else {
                    // Trigger error haptic feedback
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
                        
                        // Add ENS name to suggestions for future use
                        self?.addENSNameToSuggestions(selectedText)
                        
                        // Trigger success haptic feedback
                    } else {
                        // Trigger error haptic feedback
                    }
                }
            }
        } else {
            // Trigger error haptic feedback for invalid format
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
        // Load saved ENS names from shared UserDefaults
        if let savedENSNames = UserDefaults(suiteName: "group.com.fusionens.keyboard")?.array(forKey: "savedENSNames") as? [String] {
            mostTypedENS = savedENSNames
        } else {
            // Use default suggestions if no saved names
            mostTypedENS = defaultENSSuggestions
        }
        
        // Also load ENS names from contacts
        loadContactsENSNames()
    }
    
    private func loadContactsENSNames() {
        // Load contacts and extract their ENS names
        if let data = UserDefaults(suiteName: "group.com.fusionens.keyboard")?.data(forKey: "savedContacts"),
           let contacts = try? JSONDecoder().decode([Contact].self, from: data) {
            let contactENSNames = contacts.map { $0.ensName }
            
            // Add contact ENS names to mostTypedENS if not already present
            for ensName in contactENSNames {
                if !mostTypedENS.contains(ensName) {
                    mostTypedENS.append(ensName)
                }
            }
            
            // Keep only top 10 most recent
            if mostTypedENS.count > 10 {
                mostTypedENS = Array(mostTypedENS.prefix(10))
            }
        }
    }
    
    private func saveENSNames() {
        UserDefaults(suiteName: "group.com.fusionens.keyboard")?.set(mostTypedENS, forKey: "savedENSNames")
        UserDefaults(suiteName: "group.com.fusionens.keyboard")?.synchronize()
    }
    
    private func addENSNameToSuggestions(_ ensName: String) {
        // Remove if already exists to avoid duplicates
        mostTypedENS.removeAll { $0 == ensName }
        
        // Add to beginning of list
        mostTypedENS.insert(ensName, at: 0)
        
        // Keep only top 10 most recent
        if mostTypedENS.count > 10 {
            mostTypedENS = Array(mostTypedENS.prefix(10))
        }
        
        // Save to shared storage
        saveENSNames()
        
        // Update suggestion bar
        updateSuggestionBar(with: getDefaultSuggestions())
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
        
        // Combine user's saved ENS names with popular domains for suggestions
        let allDomains = mostTypedENS + popularENSDomains
        
        // Find domains that start with the input (prioritize user's saved names)
        for domain in allDomains {
            let domainName = String(domain.dropLast(4)) // Remove ".eth"
            if domainName.lowercased().hasPrefix(lowercaseInput) {
                suggestions.append(domain)
            }
        }
        
        // If no exact prefix matches, find domains that contain the input
        if suggestions.isEmpty {
            for domain in allDomains {
                let domainName = String(domain.dropLast(4)) // Remove ".eth"
                if domainName.lowercased().contains(lowercaseInput) {
                    suggestions.append(domain)
                }
            }
        }
        
        // Remove duplicates while preserving order (user's names first)
        var uniqueSuggestions: [String] = []
        for suggestion in suggestions {
            if !uniqueSuggestions.contains(suggestion) {
                uniqueSuggestions.append(suggestion)
            }
        }
        
        // Limit to top 3 suggestions
        return Array(uniqueSuggestions.prefix(3))
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
        
        // Detect and resolve ENS domain around cursor
        detectAndResolveENSAroundCursor()
    }
    
    @objc private func handle123LongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        // Prevent normal 123 key action by consuming the gesture
        gesture.cancelsTouchesInView = true
        
        // Add haptic feedback
        
        // Switch to next keyboard - required by Apple
        advanceToNextInputMode()
    }
    
    // MARK: - Browser Address Bar Auto-Resolve
    
    private func isInBrowserAddressBar() -> Bool {
        // Get the current text context
        let beforeText = textDocumentProxy.documentContextBeforeInput ?? ""
        let afterText = textDocumentProxy.documentContextAfterInput ?? ""
        let fullText = beforeText + afterText
        
        print("🔍 isInBrowserAddressBar: beforeText = '\(beforeText)'")
        print("🔍 isInBrowserAddressBar: afterText = '\(afterText)'")
        print("🔍 isInBrowserAddressBar: fullText = '\(fullText)'")
        
        // Check return key type for browser-like behavior
        if let textInputTraits = textDocumentProxy as? UITextInputTraits {
            if let keyboardType = textInputTraits.keyboardType {
                print("🔍 isInBrowserAddressBar: keyboardType = \(keyboardType.rawValue)")
            }
            if let returnKeyType = textInputTraits.returnKeyType {
                print("🔍 isInBrowserAddressBar: returnKeyType = \(returnKeyType.rawValue)")
                // Look for browser-like return key types
                if returnKeyType == .go || returnKeyType == .search || returnKeyType == .done {
                    print("🔍 isInBrowserAddressBar: Browser-like return key type detected")
                    return true
                }
            }
        }
        
        // Check for clear browser indicators in the text context
        if beforeText.contains("http://") || beforeText.contains("https://") || 
           beforeText.contains("www.") || 
           beforeText.contains("google.com") || beforeText.contains("search") ||
           fullText.contains("q=") || fullText.contains("&q=") ||
           afterText.contains(".com") || afterText.contains(".org") || afterText.contains(".net") {
            print("🔍 isInBrowserAddressBar: Browser context detected from URL patterns")
            return true
        }
        
        // Check if we're in a search context (like Google search with parameters)
        if fullText.contains("search") && (fullText.contains("q=") || fullText.contains("&q=")) {
            print("🔍 isInBrowserAddressBar: Search context detected")
            return true
        }
        
        // Get the current input
        let currentInput = extractInputFromAddressBar(fullText)
        print("🔍 isInBrowserAddressBar: currentInput = '\(currentInput)'")
        
        // Check for ENS names (both plain ENS names and text records) in browser context
        let textInputTraits = textDocumentProxy as? UITextInputTraits
        let hasStrongBrowserIndicators = (textInputTraits?.returnKeyType == .go || 
                                        textInputTraits?.returnKeyType == .search || 
                                        textInputTraits?.returnKeyType == .done) ||
                                       beforeText.contains("http://") || 
                                       beforeText.contains("https://") || 
                                       beforeText.contains("www.")
        
        if hasStrongBrowserIndicators {
            // Check if it's an ENS text record (like name.eth:x)
            if currentInput.contains(":") && isENSName(currentInput.components(separatedBy: ":").first ?? "") {
                print("🔍 isInBrowserAddressBar: ENS text record with strong browser indicators - assuming browser")
                return true
            }
            // Check if it's a plain ENS name (like name.eth)
            else if isENSName(currentInput) {
                print("🔍 isInBrowserAddressBar: Plain ENS name with strong browser indicators - assuming browser")
                return true
            }
        }
        
        print("🔍 isInBrowserAddressBar: No browser context detected")
        return false
    }
    
    private func handleReturnKeyInAddressBar() {
        // Get the current text in the address bar
        let beforeText = textDocumentProxy.documentContextBeforeInput ?? ""
        let afterText = textDocumentProxy.documentContextAfterInput ?? ""
        let fullText = beforeText + afterText
        
        print("🔍 handleReturnKeyInAddressBar: beforeText = '\(beforeText)'")
        print("🔍 handleReturnKeyInAddressBar: afterText = '\(afterText)'")
        print("🔍 handleReturnKeyInAddressBar: fullText = '\(fullText)'")
        
        // Extract the input (everything after the last space or from the beginning)
        let input = extractInputFromAddressBar(fullText)
        print("🔍 handleReturnKeyInAddressBar: extracted input = '\(input)'")
        
        if !input.isEmpty {
            // Check if this is an ENS text record first (e.g., name.eth:x, name.eth:url)
            if input.contains(":") && isENSName(input.components(separatedBy: ":").first ?? "") {
                print("🔍 handleReturnKeyInAddressBar: ENS text record detected - calling autoResolveInput")
                // For ENS text records, try to auto-resolve with timeout
                autoResolveInput(input) { resolvedURL in
                    DispatchQueue.main.async {
                        print("🔍 handleReturnKeyInAddressBar: autoResolveInput completed with result: '\(resolvedURL ?? "nil")'")
                        
                        if let resolvedURL = resolvedURL {
                            // Clear the address bar and insert the resolved URL
                            print("🔍 handleReturnKeyInAddressBar: Clearing address bar and inserting '\(resolvedURL)'")
                            self.clearAddressBarAndInsertURL(resolvedURL)
                            
                            // Restore return key and trigger navigation
                            self.updateReturnKeyToNormal()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                print("🔍 handleReturnKeyInAddressBar: Triggering return key after resolution")
                                self.textDocumentProxy.insertText("\n")
                            }
                        } else {
                            // If no resolution, proceed with normal return key
                            print("🔍 handleReturnKeyInAddressBar: No resolution - proceeding with normal return")
                            self.updateReturnKeyToNormal()
                            self.textDocumentProxy.insertText("\n")
                        }
                    }
                }
                return
            }
            
            // Check if this is a simple case that can be resolved immediately
            if isCryptoAddress(input) || isURL(input) {
                print("🔍 handleReturnKeyInAddressBar: Simple case detected")
                // Handle simple cases immediately
                let resolvedURL = isCryptoAddress(input) ? getExplorerURL(for: input) : ensureProperURL(input)
                if let resolvedURL = resolvedURL {
                    print("🔍 handleReturnKeyInAddressBar: Resolved to '\(resolvedURL)'")
                    clearAddressBarAndInsertURL(resolvedURL)
                    
                    // Trigger the return key to navigate
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("🔍 handleReturnKeyInAddressBar: Triggering return key")
                        self.textDocumentProxy.insertText("\n")
                    }
                    return
                }
            }
            
            print("🔍 handleReturnKeyInAddressBar: Complex case - calling autoResolveInput")
            // For ENS names or complex cases, try to auto-resolve with timeout
            autoResolveInput(input) { resolvedURL in
                DispatchQueue.main.async {
                    print("🔍 handleReturnKeyInAddressBar: autoResolveInput completed with result: '\(resolvedURL ?? "nil")'")
                    
                    if let resolvedURL = resolvedURL {
                        // Clear the address bar and insert the resolved URL
                        print("🔍 handleReturnKeyInAddressBar: Clearing address bar and inserting '\(resolvedURL)'")
                        self.clearAddressBarAndInsertURL(resolvedURL)
                        
                        // Restore return key and trigger navigation
                        self.updateReturnKeyToNormal()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            print("🔍 handleReturnKeyInAddressBar: Triggering return key after resolution")
                            self.textDocumentProxy.insertText("\n")
                        }
                    } else {
                        // If no resolution, proceed with normal return key
                        print("🔍 handleReturnKeyInAddressBar: No resolution - proceeding with normal return")
                        self.updateReturnKeyToNormal()
                        self.textDocumentProxy.insertText("\n")
                    }
                }
            }
        } else {
            // No input, proceed with normal return key
            print("🔍 handleReturnKeyInAddressBar: No input - proceeding with normal return")
            textDocumentProxy.insertText("\n")
        }
    }
    
    private func extractInputFromAddressBar(_ fullText: String) -> String {
        // Extract the last word or phrase that looks like an input
        let components = fullText.components(separatedBy: .whitespacesAndNewlines)
        
        // Look for the last component that could be an address/domain
        for component in components.reversed() {
            let trimmed = component.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty && (isCryptoAddress(trimmed) || isENSName(trimmed) || isURL(trimmed)) {
                return trimmed
            }
        }
        
        // If no specific pattern found, return the last non-empty component
        return components.last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    private func isCryptoAddress(_ input: String) -> Bool {
        // Check for Ethereum address (0x followed by 40 hex characters)
        if input.hasPrefix("0x") && input.count == 42 && input.dropFirst(2).allSatisfy({ $0.isHexDigit }) {
            return true
        }
        
        // Check for Bitcoin address (starts with 1, 3, or bc1)
        if input.hasPrefix("1") || input.hasPrefix("3") || input.hasPrefix("bc1") {
            return true
        }
        
        // Add more crypto address patterns as needed
        return false
    }
    
    private func isENSName(_ input: String) -> Bool {
        return HelperClass.checkFormat(input)
    }
    
    private func isURL(_ input: String) -> Bool {
        // Check if it looks like a URL, but exclude ENS names
        if isENSName(input) {
            return false // ENS names are not URLs
        }
        
        return input.contains(".") && (input.hasPrefix("http://") || input.hasPrefix("https://") || 
                input.hasPrefix("www.") || input.contains(".com") || input.contains(".org") || 
                input.contains(".net"))
    }
    
    private func autoResolveInput(_ input: String, completion: @escaping (String?) -> Void) {
        // Check for ENS text records first (e.g., name.eth:x, name.eth:url)
        if input.contains(":") && isENSName(input.components(separatedBy: ":").first ?? "") {
            print("🔍 autoResolveInput: ENS text record detected - calling resolveENSToExplorer")
            resolveENSToExplorer(input, completion: completion)
        } else if isCryptoAddress(input) {
            // For crypto addresses, append the appropriate explorer URL (immediate)
            print("🔍 autoResolveInput: Crypto address detected")
            let explorerURL = getExplorerURL(for: input)
            completion(explorerURL)
        } else if isURL(input) {
            // For URLs, ensure proper protocol (immediate)
            print("🔍 autoResolveInput: URL detected")
            let properURL = ensureProperURL(input)
            completion(properURL)
        } else if isENSName(input) {
            // For ENS names, resolve to address and then to explorer (with timeout)
            print("🔍 autoResolveInput: ENS name detected")
            resolveENSToExplorer(input, completion: completion)
        } else {
            // Try to resolve as ENS name anyway (with timeout)
            print("🔍 autoResolveInput: Unknown input - trying ENS resolution")
            resolveENSToExplorer(input, completion: completion)
        }
    }
    
    private func getExplorerURL(for address: String) -> String? {
        if address.hasPrefix("0x") && address.count == 42 {
            // Ethereum address
            return "https://etherscan.io/address/\(address)"
        } else if address.hasPrefix("1") || address.hasPrefix("3") || address.hasPrefix("bc1") {
            // Bitcoin address
            return "https://blockstream.info/address/\(address)"
        } else if address.hasPrefix("D") && address.count >= 32 && address.count <= 44 {
            // Solana address
            return "https://solscan.io/account/\(address)"
        } else if address.hasPrefix("r") && address.count == 34 {
            // XRP address
            return "https://xrpscan.com/account/\(address)"
        }
        return nil
    }
    
    private func resolveENSToExplorer(_ ensName: String, completion: @escaping (String?) -> Void) {
        // Check if this is a text record request (e.g., name.eth:x, name.eth:url)
        if ensName.contains(":") {
            let components = ensName.components(separatedBy: ":")
            if components.count == 2 {
                let baseName = components[0]
                let recordType = components[1]
                
                // Handle text records
                if ["x", "url", "github", "name", "bio"].contains(recordType) {
                    resolveTextRecord(baseName: baseName, recordType: recordType, completion: completion)
                    return
                }
            }
        }
        
        // Add timeout mechanism for ENS resolution
        let timeoutWorkItem = DispatchWorkItem {
            completion(nil)
        }
        
        // Schedule timeout after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: timeoutWorkItem)
        
        // Regular ENS resolution to address
        APICaller.shared.resolveENSName(name: ensName) { resolvedAddress in
            // Cancel timeout if we got a response
            timeoutWorkItem.cancel()
            
            DispatchQueue.main.async {
                if !resolvedAddress.isEmpty {
                    // Add ENS name to suggestions for future use
                    self.addENSNameToSuggestions(ensName)
                    
                    // Resolve the address to an explorer URL
                    let explorerURL = self.getExplorerURL(for: resolvedAddress)
                    completion(explorerURL)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    private func resolveTextRecord(baseName: String, recordType: String, completion: @escaping (String?) -> Void) {
        // Use the Fusion ENS Server API to resolve text records
        let apiURL = "https://api.fusionens.com/resolve/\(baseName):\(recordType)?network=mainnet"
        
        print("🔍 resolveTextRecord: Calling API: \(apiURL)")
        
        // Create URLSession with timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 3.0 // 3 second timeout
        config.timeoutIntervalForResource = 5.0 // 5 second total timeout
        let session = URLSession(configuration: config)
        
        // Make API call to resolve text record
        session.dataTask(with: URL(string: apiURL)!) { data, response, error in
            // Check for timeout or network error
            if let error = error {
                print("🔍 resolveTextRecord: API error: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data else {
                print("🔍 resolveTextRecord: No data received")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Debug: Print raw response
            if let responseString = String(data: data, encoding: .utf8) {
                print("🔍 resolveTextRecord: Raw API response: \(responseString)")
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("🔍 resolveTextRecord: Failed to parse JSON")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            print("🔍 resolveTextRecord: Parsed JSON: \(json)")
            
            guard let success = json["success"] as? Bool, success else {
                print("🔍 resolveTextRecord: API returned success=false")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let dataDict = json["data"] as? [String: Any] else {
                print("🔍 resolveTextRecord: No data dict in response")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            print("🔍 resolveTextRecord: Data dict: \(dataDict)")
            
            // Try different possible keys for the text record value
            let recordValue: String?
            if let value = dataDict["value"] as? String, !value.isEmpty {
                recordValue = value
                print("🔍 resolveTextRecord: Found value in 'value' key: \(value)")
            } else if let address = dataDict["address"] as? String, !address.isEmpty {
                recordValue = address
                print("🔍 resolveTextRecord: Found value in 'address' key: \(address)")
            } else if let result = dataDict["result"] as? String, !result.isEmpty {
                recordValue = result
                print("🔍 resolveTextRecord: Found value in 'result' key: \(result)")
            } else {
                print("🔍 resolveTextRecord: No valid text record value found")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Convert text record to appropriate URL
            let resolvedURL = self.convertTextRecordToURL(recordType: recordType, value: recordValue!)
            print("🔍 resolveTextRecord: Converted to URL: \(resolvedURL)")
            DispatchQueue.main.async {
                completion(resolvedURL)
            }
        }.resume()
    }
    
    private func convertTextRecordToURL(recordType: String, value: String) -> String {
        switch recordType {
        case "url":
            return ensureProperURL(value)
        case "x":
            return "https://x.com/\(value)"
        case "github":
            return "https://github.com/\(value)"
        case "name", "bio":
            // For name/bio, just return the value as is (could be copied to clipboard)
            return value
        default:
            return value
        }
    }
    
    private func ensureProperURL(_ url: String) -> String {
        if url.hasPrefix("http://") || url.hasPrefix("https://") {
            return url
        } else if url.hasPrefix("www.") {
            return "https://\(url)"
        } else {
            return "https://\(url)"
        }
    }
    
    private func clearAddressBarAndInsertURL(_ resolvedURL: String) {
        // Get the current document context
        let beforeText = textDocumentProxy.documentContextBeforeInput ?? ""
        let afterText = textDocumentProxy.documentContextAfterInput ?? ""
        let totalCharacters = beforeText.count + afterText.count
        
        // Delete all text in the address bar (with safety limit)
        let maxDeletions = min(totalCharacters, 1000) // Safety limit to prevent infinite loops
        for _ in 0..<maxDeletions {
            textDocumentProxy.deleteBackward()
        }
        
        // Insert the resolved URL
        textDocumentProxy.insertText(resolvedURL)
    }
    
    private func updateReturnKeyToLoading() {
        // Find the return key button and update its title to show loading
        DispatchQueue.main.async {
            if let returnButton = self.findReturnKeyButton() {
                returnButton.setTitle("...", for: .normal)
                returnButton.isEnabled = false
                print("🔍 Return key updated to loading state")
            }
        }
    }
    
    private func updateReturnKeyToNormal() {
        // Find the return key button and restore its normal title
        DispatchQueue.main.async {
            if let returnButton = self.findReturnKeyButton() {
                returnButton.setTitle("return", for: .normal)
                returnButton.isEnabled = true
                print("🔍 Return key restored to normal state")
            }
        }
    }
    
    private func findReturnKeyButton() -> UIButton? {
        // Search through all subviews to find the return key button
        return findButtonWithTitle("return") ?? findButtonWithTitle("...")
    }
    
    private func findButtonWithTitle(_ title: String) -> UIButton? {
        // Recursively search for a button with the specified title
        for subview in containerView.subviews {
            if let button = subview as? UIButton, button.titleLabel?.text == title {
                return button
            }
            if let foundButton = findButtonInSubviews(subview, title: title) {
                return foundButton
            }
        }
        return nil
    }
    
    private func findButtonInSubviews(_ view: UIView, title: String) -> UIButton? {
        for subview in view.subviews {
            if let button = subview as? UIButton, button.titleLabel?.text == title {
                return button
            }
            if let foundButton = findButtonInSubviews(subview, title: title) {
                return foundButton
            }
        }
        return nil
    }
    
}
