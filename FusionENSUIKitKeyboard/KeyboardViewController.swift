//
//  KeyboardViewController.swift
//  FusionENSUIKitKeyboard
//
//  Created by Franz Quarshie on 17/09/2025.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    
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
        print("🚀 UIKit KeyboardViewController: viewDidLoad called")
        
        // Load ENS usage data
        loadENSUsageData()
        
        // Delay setup to ensure proper view dimensions
        DispatchQueue.main.async {
            self.setupKeyboardView()
            self.isKeyboardViewSetup = true
        }
        
        print("🚀 UIKit KeyboardViewController: Setup completed")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("👁️ UIKit KeyboardViewController: viewDidAppear called")
        print("👁️ View frame: \(view.frame)")
        print("👁️ View bounds: \(view.bounds)")
        
        // Only refresh if not already set up
        if !isKeyboardViewSetup {
            print("👁️ Refreshing UIKit keyboard view")
            setupKeyboardView()
            isKeyboardViewSetup = true
        } else {
            print("👁️ UIKit keyboard already set up, skipping refresh")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("📐 UIKit KeyboardViewController: viewDidLayoutSubviews called")
        print("📐 View frame: \(view.frame)")
        print("📐 View bounds: \(view.bounds)")
        
        if view.frame.height < 100 {
            print("⚠️ UIKit KeyboardViewController: View height is unexpectedly small: \(view.frame.height)")
        }
    }
    
    // MARK: - Setup Methods
    private func setupKeyboardView() {
        print("🔧 UIKit KeyboardViewController: setupKeyboardView called")
        
        guard !isSettingUpView else {
            print("🔧 Already setting up view, skipping...")
            return
        }
        
        if isKeyboardViewSetup {
            print("🔧 UIKit keyboard already set up, skipping")
            return
        }
        
        isSettingUpView = true
        
        cleanupExistingViews()
        
        print("🔧 Creating UIKit keyboard view")
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
        
        var previousRowView: UIView?
        
        for (rowIndex, row) in rows.enumerated() {
            let rowView = UIView()
            rowView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(rowView)
            
            var previousButton: UIButton?
            
            for (keyIndex, key) in row.enumerated() {
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
        if title == "123" || title == "ABC" || title == ".eth" || title == "space" || title == "return" {
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
        } else if title == "⇧" || title == "⌫" || title == "123" || title == ".eth" || title == "ABC" || title == "#+=" || title == "🙂" {
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
        
        // Add long press gesture for space bar to trigger ENS resolution
        if title == "space" {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(spaceBarLongPress(_:)))
            longPressGesture.minimumPressDuration = 0.5
            button.addGestureRecognizer(longPressGesture)
        }
        
        button.addAction(UIAction { _ in
            self.handleKeyPress(title)
        }, for: .touchUpInside)
        
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
            } else if title == "⇧" || title == "⌫" || title == "123" || title == ".eth" || title == "ABC" || title == "#+=" || title == "🙂" {
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
            } else if title == "⇧" || title == "⌫" || title == "123" || title == ".eth" || title == "ABC" || title == "#+=" || title == "🙂" {
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
    
    @objc private func spaceBarLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            print("🔍 Space bar long press detected - triggering ENS resolution")
            triggerENSResolution()
        }
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
        
        // Try to get current word from context
        if let currentWord = getCurrentWord(), !currentWord.isEmpty {
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
            switchToNumbersLayout()
        case "ABC":
            // Switch back to letters layout
            switchToLettersLayout()
        case "#+=":
            // Switch to secondary symbols layout
            switchToSecondarySymbolsLayout()
        case ".eth":
            // .eth key - insert .eth at cursor position
            insertText(".eth")
            lastTypedWord += ".eth"
        case "🙂":
            // Emoji key - insert smiley face
            insertText("🙂")
            lastTypedWord += "🙂"
        case "⇧":
            // Shift key
            let currentTime = Date().timeIntervalSince1970
            if currentTime - lastShiftPressTime < 0.3 {
                // Double tap shift - toggle caps lock
                isCapsLock.toggle()
                isShiftPressed = false
                print("🔒 Caps lock toggled: \(isCapsLock)")
            } else {
                // Single tap shift
                isShiftPressed.toggle()
                isCapsLock = false
                print("⇧ Shift toggled: \(isShiftPressed)")
            }
            lastShiftPressTime = currentTime
            // Recreate keyboard with new case
            setupKeyboardView()
            isKeyboardViewSetup = true
        case ".":
            insertText(".")
            lastTypedWord += "."
        default:
            insertText(key)
            lastTypedWord += key
            // Update suggestions as user types
            updateSuggestionsForWord(lastTypedWord)
        }
    }
    
    // MARK: - Text Change Handling
    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        print("📝 UIKit KeyboardViewController: textDidChange called")
        
        // Check if there's selected text first
        if let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty {
            print("Selected text: \(selectedText)")
            // Only resolve if it's an ENS domain
            if HelperClass.checkFormat(selectedText) {
                handleSelectedText(selectedText)
            }
        }
        // Try to detect ENS domains from the current context
        else {
            detectAndResolveENSFromContext()
        }
    }
    
    private func detectAndResolveENSFromContext() {
        // Try to get the current word or recent text
        if let currentWord = getCurrentWord(), HelperClass.checkFormat(currentWord) {
            print("🔍 Detected ENS domain in context: \(currentWord)")
            handleSelectedText(currentWord)
        }
        // UIKit keyboard handles suggestions through its own UI
        else {
            print("UIKit keyboard - suggestions handled by UIKit interface")
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
        print("🔍 UIKit KeyboardViewController: Attempting ENS resolution for: \(selectedText)")
        
        if HelperClass.checkFormat(selectedText) {
            print("🔍 Text format is valid for ENS resolution")
            
            // Trigger haptic feedback when starting resolution
            triggerHapticFeedback()
            
            APICaller.shared.resolveENSName(name: selectedText) { mappedAddress in
                DispatchQueue.main.async {
                    if !mappedAddress.isEmpty {
                        print("🔍 ENS resolved to: \(mappedAddress)")
                        // Delete the original text and insert the resolved address
                        for _ in 0..<selectedText.count {
                            self.textDocumentProxy.deleteBackward()
                        }
                        self.textDocumentProxy.insertText(mappedAddress)
                        
                        // Trigger success haptic feedback
                        self.triggerSuccessHaptic()
                    } else {
                        print("🔍 ENS resolution failed for: \(selectedText)")
                        // Trigger error haptic feedback
                        self.triggerErrorHaptic()
                    }
                }
            }
        } else {
            print("🔍 Text format is not valid for ENS resolution: \(selectedText)")
            // Trigger error haptic feedback for invalid format
            triggerErrorHaptic()
        }
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
        
        // Add separators and suggestions
        for (index, suggestion) in suggestions.enumerated() {
            let button = createSuggestionButton(title: suggestion)
            suggestionStackView.addArrangedSubview(button)
            suggestionButtons.append(button)
            
            // Add separator (except after last item)
            if index < suggestions.count - 1 {
                let separator = UIView()
                separator.backgroundColor = traitCollection.userInterfaceStyle == .dark ? 
                    UIColor.white.withAlphaComponent(0.3) : UIColor.black.withAlphaComponent(0.3)
                separator.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    separator.widthAnchor.constraint(equalToConstant: 1)
                ])
                suggestionStackView.addArrangedSubview(separator)
            }
        }
        
        print("📝 Updated suggestion bar with \(suggestions.count) suggestions")
    }
    
    // MARK: - Layout Switching
    
    @objc private func switchToNumbersLayout() {
        print("🔢 Switching to numbers layout")
        isNumbersLayout = true
        isSecondarySymbolsLayout = false
        setupKeyboardView()
        isKeyboardViewSetup = true
    }
    
    @objc private func switchToLettersLayout() {
        print("🔤 Switching to letters layout")
        isNumbersLayout = false
        isSecondarySymbolsLayout = false
        setupKeyboardView()
        isKeyboardViewSetup = true
    }
    
    @objc private func switchToSecondarySymbolsLayout() {
        print("🔣 Switching to secondary symbols layout")
        isSecondarySymbolsLayout = true
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
}
