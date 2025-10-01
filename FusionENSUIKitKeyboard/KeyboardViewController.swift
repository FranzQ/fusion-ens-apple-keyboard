//
//  KeyboardViewController.swift
//  FusionENSUIKitKeyboard
//
//  Created by Franz Quarshie on 17/09/2025.
//

import UIKit
import FusionENSShared

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
    
    // MARK: - iPad Detection
    private var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
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
        
        // Setup accessibility
        setupAccessibility()
        
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
        ethLongPressTimer?.invalidate()
        ethLongPressTimer = nil
        backspaceLongPressTimer?.invalidate()
        backspaceLongPressTimer = nil
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
        
        // Only update layout if we haven't set up yet and view has proper bounds
        if !isKeyboardViewSetup && view.bounds.width > 0 {
            setupKeyboardView()
            isKeyboardViewSetup = true
        }
    }
    
    // MARK: - Setup Methods
    private func setupKeyboardView() {
        guard !isSettingUpView else {
            return
        }
        
        isSettingUpView = true
        
        cleanupExistingViews()
        
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
        
        isSettingUpView = false
    }
    
    private func cleanupExistingViews() {
        
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
        
    }
    
    // MARK: - Keyboard Creation
    private func createSimpleKeyboard() -> UIView {
        
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
        
        // Get the available width for the keyboard - use view bounds instead of screen bounds
        let availableWidth = view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width
        
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
        guard let suggestionBar = suggestionBar else { return }
        containerView.addSubview(suggestionBar)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Suggestion bar constraints
            suggestionBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            suggestionBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            suggestionBar.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            suggestionBar.heightAnchor.constraint(equalToConstant: 40),
            
            // Suggestion stack view constraints
            suggestionStackView.leadingAnchor.constraint(equalTo: suggestionBar.leadingAnchor),
            suggestionStackView.trailingAnchor.constraint(equalTo: suggestionBar.trailingAnchor),
            suggestionStackView.topAnchor.constraint(equalTo: suggestionBar.topAnchor),
            suggestionStackView.bottomAnchor.constraint(equalTo: suggestionBar.bottomAnchor),
            suggestionStackView.heightAnchor.constraint(equalTo: suggestionBar.heightAnchor)
        ])
        
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
        
        // Use modern UIButton.Configuration for iOS 15+
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            button.configuration = config
        } else {
            // Fallback for older iOS versions
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        }
        
        // Add accessibility support for suggestion buttons
        button.accessibilityLabel = "Suggestion: \(title)"
        button.accessibilityHint = "Double tap to insert this suggestion"
        button.isAccessibilityElement = true
        button.accessibilityTraits = [.button]
        
        // Support Dynamic Type
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body, compatibleWith: traitCollection)
        
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
                    isIPad ? ["ABC", "🌐", ".eth", "space", ":btc", "return"] : ["ABC", ".eth", "space", ":btc", "return"]
                ]
            } else {
                rows = [
                    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                    ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
                    ["#+=", ".", ",", "?", "!", "'", "⌫"],
                    isIPad ? ["ABC", "🌐", ".eth", "space", ":btc", "return"] : ["ABC", ".eth", "space", ":btc", "return"]
                ]
            }
        } else {
            if isShiftPressed || isCapsLock {
                rows = [
                    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
                    ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
                    ["⇧", "Z", "X", "C", "V", "B", "N", "M", "⌫"],
                    isIPad ? ["123", "🌐", ".eth", "space", ":btc", "return"] : ["123", ".eth", "space", ":btc", "return"]
                ]
            } else {
                rows = [
                    ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
                    ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
                    ["⇧", "z", "x", "c", "v", "b", "n", "m", "⌫"],
                    isIPad ? ["123", "🌐", ".eth", "space", ":btc", "return"] : ["123", ".eth", "space", ":btc", "return"]
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
            
            // Add trailing constraint for the last button to prevent overflow
            if let lastButton = previousButton {
                lastButton.trailingAnchor.constraint(lessThanOrEqualTo: rowView.trailingAnchor, constant: -3).isActive = true
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
        
    }
    
    private func createKeyboardButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        
        // Use text for all buttons to avoid image loading issues
        button.setTitle(title, for: .normal)
        
        // Use smaller font for bottom row keys
        let fontSize: CGFloat
        if title == "123" || title == "ABC" || title == ".eth" || title == ":btc" || title == "space" || title == "return" || title == "🌐" {
            fontSize = 16  // Smaller font for bottom row
        } else {
            fontSize = 22  // Standard font for other keys
        }
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        
        // Add accessibility support
        setupAccessibilityForButton(button, title: title)
        
        // iPhone keyboard styling - adapts to dark/light mode and high contrast
        applyButtonStyling(button, title: title)
        
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
            // Special handling for :btc key with long press
            button.addTarget(self, action: #selector(btcButtonTouchDown), for: .touchDown)
            button.addTarget(self, action: #selector(btcButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        } else if title == ".eth" {
            // Special handling for .eth key with long press
            button.addTarget(self, action: #selector(ethButtonTouchDown), for: .touchDown)
            button.addTarget(self, action: #selector(ethButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        } else if title == "⌫" {
            // Special handling for backspace key with long press
            button.addTarget(self, action: #selector(backspaceButtonTouchDown), for: .touchDown)
            button.addTarget(self, action: #selector(backspaceButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        } else if title == "space" {
            // Special handling for space bar with long press
            button.addTarget(self, action: #selector(spaceButtonTouchDown), for: .touchDown)
            button.addTarget(self, action: #selector(spaceButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        } else if title == "🌐" {
            // Globe key for keyboard switching (iPad only)
            button.addAction(UIAction { _ in
                self.handleGlobeKeyPress()
            }, for: .touchUpInside)
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
            longPressGesture.cancelsTouchesInView = false
            longPressGesture.delaysTouchesBegan = false
            longPressGesture.delaysTouchesEnded = false
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
    
    // MARK: - Accessibility Support
    
    private func setupAccessibilityForButton(_ button: UIButton, title: String) {
        // Set accessibility label based on button function
        switch title {
        case "⇧":
            button.accessibilityLabel = isCapsLock ? "Caps Lock" : "Shift"
            button.accessibilityHint = isCapsLock ? "Double tap to turn off caps lock" : "Double tap to enable caps lock"
        case "⌫":
            button.accessibilityLabel = "Delete"
            button.accessibilityHint = "Double tap to delete character, long press for continuous deletion"
        case "123":
            button.accessibilityLabel = "Numbers"
            button.accessibilityHint = "Double tap to switch to numbers keyboard, long press to switch to emoji keyboard"
        case "ABC":
            button.accessibilityLabel = "Letters"
            button.accessibilityHint = "Double tap to switch to letters keyboard"
        case "#+=":
            button.accessibilityLabel = "Symbols"
            button.accessibilityHint = "Double tap to switch to symbols keyboard"
        case "🙂":
            button.accessibilityLabel = "Emoji"
            button.accessibilityHint = "Double tap to switch to emoji keyboard"
        case "space":
            button.accessibilityLabel = "Space"
            button.accessibilityHint = "Double tap to insert space, long press to resolve ENS names"
        case "return":
            button.accessibilityLabel = "Return"
            button.accessibilityHint = "Double tap to insert new line"
        case ".eth":
            button.accessibilityLabel = "Ethereum domain"
            button.accessibilityHint = "Double tap to insert .eth, long press for ENS resolution options"
        case ":btc":
            button.accessibilityLabel = "Bitcoin address"
            button.accessibilityHint = "Double tap to insert :btc, long press for cryptocurrency options"
        case "🌐":
            button.accessibilityLabel = "Globe"
            button.accessibilityHint = "Double tap to switch keyboards"
        default:
            // For letter and number keys
            if title.count == 1 {
                button.accessibilityLabel = "\(title) key"
                button.accessibilityHint = "Double tap to insert \(title)"
            } else {
                button.accessibilityLabel = title
                button.accessibilityHint = "Double tap to activate"
            }
        }
        
        // Enable accessibility
        button.isAccessibilityElement = true
        button.accessibilityTraits = [.keyboardKey]
        
        // Support Dynamic Type
        if button.titleLabel?.font != nil {
            button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body, compatibleWith: traitCollection)
        }
    }
    
    private func setupAccessibility() {
        // Set up accessibility for the main keyboard view
        view.accessibilityLabel = "Fusion ENS Keyboard"
        view.accessibilityHint = "Custom keyboard with ENS resolution capabilities"
        
        // Register for accessibility notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessibilityVoiceOverStatusChanged),
            name: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessibilityReduceMotionStatusChanged),
            name: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func accessibilityVoiceOverStatusChanged() {
        // Update UI when VoiceOver status changes
        DispatchQueue.main.async {
            self.updateAccessibilityForVoiceOver()
        }
    }
    
    @objc private func accessibilityReduceMotionStatusChanged() {
        // Update animations when reduce motion preference changes
        DispatchQueue.main.async {
            self.updateAnimationsForReduceMotion()
        }
    }
    
    private func updateAccessibilityForVoiceOver() {
        // Update button accessibility when VoiceOver is enabled
        if UIAccessibility.isVoiceOverRunning {
            // Make sure all buttons are properly accessible
            updateAllButtonAccessibility()
        }
    }
    
    private func updateAnimationsForReduceMotion() {
        // Reduce or disable animations if user prefers reduced motion
        if UIAccessibility.isReduceMotionEnabled {
            // Disable or reduce animations
            UIView.setAnimationsEnabled(false)
        } else {
            UIView.setAnimationsEnabled(true)
        }
    }
    
    private func updateAllButtonAccessibility() {
        // Update accessibility for all existing buttons
        for button in suggestionButtons {
            if let title = button.title(for: .normal) {
                setupAccessibilityForButton(button, title: title)
            }
        }
    }
    
    private func announceAccessibilityMessage(_ message: String) {
        // Announce messages to VoiceOver users
        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIAccessibility.post(notification: .announcement, argument: message)
            }
        }
    }
    
    private func applyButtonStyling(_ button: UIButton, title: String) {
        // Check for high contrast mode
        let isHighContrast = UIAccessibility.isDarkerSystemColorsEnabled
        
        if title == "return" {
            // Blue return key
            if isHighContrast {
                button.backgroundColor = UIColor.systemBlue
                button.setTitleColor(UIColor.white, for: .normal)
            } else {
                button.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
                button.setTitleColor(UIColor.white, for: .normal)
            }
        } else if title == ":btc" {
            // Orange crypto ticker key
            if isHighContrast {
                button.backgroundColor = UIColor.systemOrange
                button.setTitleColor(UIColor.white, for: .normal)
            } else {
                button.backgroundColor = UIColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0)
                button.setTitleColor(UIColor.white, for: .normal)
            }
        } else if title == ".eth" {
            // Blue .eth key
            if isHighContrast {
                button.backgroundColor = UIColor.systemBlue
                button.setTitleColor(UIColor.white, for: .normal)
            } else {
                button.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 0.74, alpha: 1.0)
                button.setTitleColor(UIColor.white, for: .normal)
            }
        } else if title == "⇧" || title == "⌫" || title == "123" || title == "ABC" || title == "#+=" || title == "🙂" || title == "🌐" {
            // Function keys - adapt to dark/light mode and high contrast
            if isHighContrast {
                button.backgroundColor = UIColor.systemGray
                button.setTitleColor(UIColor.label, for: .normal)
            } else if traitCollection.userInterfaceStyle == .dark {
                button.backgroundColor = UIColor(red: 0.27, green: 0.27, blue: 0.30, alpha: 1.0)
                button.setTitleColor(UIColor.white, for: .normal)
            } else {
                button.backgroundColor = UIColor(red: 0.68, green: 0.68, blue: 0.70, alpha: 1.0)
                button.setTitleColor(UIColor.black, for: .normal)
            }
            
            // Special styling for caps lock
            if title == "⇧" && isCapsLock {
                button.backgroundColor = UIColor.systemBlue
                button.setTitleColor(UIColor.white, for: .normal)
            }
        } else {
            // Letter/number keys - adapt to dark/light mode and high contrast
            if isHighContrast {
                button.backgroundColor = UIColor.systemBackground
                button.setTitleColor(UIColor.label, for: .normal)
                button.layer.borderWidth = 1.0
                button.layer.borderColor = UIColor.label.cgColor
            } else if traitCollection.userInterfaceStyle == .dark {
                button.backgroundColor = UIColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1.0)
                button.setTitleColor(UIColor.white, for: .normal)
            } else {
                button.backgroundColor = UIColor.white
                button.setTitleColor(UIColor.black, for: .normal)
            }
        }
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
            if HelperClass.checkFormat(selectedText) {
                handleSelectedText(selectedText)
            } else {
            }
        } else {
        }
    }
    
    // MARK: - Key Handling
    private func handleKeyPress(_ key: String) {
        
        switch key {
        case "⌫":
            deleteBackward()
            announceAccessibilityMessage("Deleted character")
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
            announceAccessibilityMessage("Space inserted")
        case "return":
            // Check if we're in a browser address bar and handle auto-resolve
            let isBrowser = isInBrowserAddressBar()
            if isBrowser {
                // Show loading indicator on return key
                updateReturnKeyToLoading()
                announceAccessibilityMessage("Resolving ENS name")
                handleReturnKeyInAddressBar()
            } else {
                insertText("\n")
                announceAccessibilityMessage("New line inserted")
                // Clear last typed word when return is pressed
                lastTypedWord = ""
            }
        case "123":
            // Switch to numbers layout OR next keyboard (long press)
            switchToNumbersLayout()
            announceAccessibilityMessage("Switched to numbers keyboard")
        case "ABC":
            // Switch back to letters layout
            switchToLettersLayout()
            announceAccessibilityMessage("Switched to letters keyboard")
        case "🌐":
            // Globe key - switch to next keyboard (iPad only)
            handleGlobeKeyPress()
        case "#+=":
            // Switch to secondary symbols layout
            switchToSecondarySymbolsLayout()
            announceAccessibilityMessage("Switched to symbols keyboard")
        case ".eth":
            // .eth key - insert .eth at cursor position
            insertText(".eth")
            lastTypedWord += ".eth"
            announceAccessibilityMessage("Ethereum domain suffix inserted")
            // Turn off shift after key press (unless caps lock is on)
            if isShiftPressed && !isCapsLock {
                isShiftPressed = false
                isKeyboardViewSetup = false
                setupKeyboardView()
                isKeyboardViewSetup = true
            }
        case ":btc":
            // Crypto ticker key - insert :btc at cursor position
            insertText(":btc")
            lastTypedWord += ":btc"
            // Turn off shift after key press (unless caps lock is on)
            if isShiftPressed && !isCapsLock {
                isShiftPressed = false
                isKeyboardViewSetup = false
                setupKeyboardView()
                isKeyboardViewSetup = true
            }
        case "🙂":
            // Emoji key - insert smiley face
            insertText("🙂")
            lastTypedWord += "🙂"
            // Turn off shift after key press (unless caps lock is on)
            if isShiftPressed && !isCapsLock {
                isShiftPressed = false
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
            } else {
                // Single tap shift - enable for next key only
                isShiftPressed = true
                isCapsLock = false
            }
            lastShiftPressTime = currentTime
            // Recreate keyboard with new case
            isKeyboardViewSetup = false
            setupKeyboardView()
            isKeyboardViewSetup = true
        case ".":
            insertText(".")
            lastTypedWord += "."
            // Turn off shift after key press (unless caps lock is on)
            if isShiftPressed && !isCapsLock {
                isShiftPressed = false
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
        // Use the same logic as handleSelectedText for consistency
        if HelperClass.checkFormat(ensDomain) {
            // Check if we're in a browser context for default action
            if isInBrowserAddressBar() {
                // In browser context - use user's default action
                resolveENSWithDefaultAction(ensDomain) { [weak self] resolvedURL in
                    DispatchQueue.main.async {
                        if let url = resolvedURL, !url.isEmpty {
                            // Smart approach: find the ENS domain position and replace it properly
                            self?.smartReplaceENS(ensDomain, with: url)
                            
                            // Add ENS name to suggestions for future use
                            self?.addENSNameToSuggestions(ensDomain)
                        } else {
                            // Fallback to address resolution if default action fails
                            self?.resolveToAddressForSpacebar(ensDomain)
                        }
                    }
                }
            } else {
                // Not in browser context - resolve to address
                resolveToAddressForSpacebar(ensDomain)
            }
        } else {
            // Trigger error haptic feedback for invalid format
        }
    }
    
    private func resolveToAddressForSpacebar(_ selectedText: String) {
        APICaller.shared.resolveENSName(name: selectedText) { mappedAddress in
            DispatchQueue.main.async { [weak self] in
                if !mappedAddress.isEmpty {
                    // In non-browser context, always resolve to the Ethereum address
                    // Base subdomain detection only applies in browser context when Etherscan would be used
                    let finalResult = mappedAddress
                    
                    // Smart approach: find the ENS domain position and replace it properly
                    self?.smartReplaceENS(selectedText, with: finalResult)
                    
                    // Add ENS name to suggestions for future use
                    self?.addENSNameToSuggestions(selectedText)
                    
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
            
            // Announce successful resolution
            announceAccessibilityMessage("ENS name \(ensDomain) resolved to address \(resolvedAddress)")
        } else {
            // Fallback: just delete the ENS domain length and insert
            for _ in 0..<ensDomain.count {
                textDocumentProxy.deleteBackward()
            }
            textDocumentProxy.insertText(resolvedAddress)
            
            // Announce successful resolution
            announceAccessibilityMessage("ENS name \(ensDomain) resolved to address \(resolvedAddress)")
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
            // Check if we're in a browser context for default action
            if isInBrowserAddressBar() {
                // In browser context - use user's default action
                resolveENSWithDefaultAction(selectedText) { [weak self] resolvedURL in
                    DispatchQueue.main.async {
                        if let url = resolvedURL, !url.isEmpty {
                            // Check if we have selected text (proper selection)
                            if let currentSelectedText = self?.textDocumentProxy.selectedText, currentSelectedText == selectedText {
                                // We have proper selected text, so we can replace it directly
                                self?.textDocumentProxy.insertText(url)
                            } else {
                                // For spacebar long-press or other cases, we need to find and replace the text
                                self?.replaceTextInDocument(selectedText, with: url)
                            }
                            
                            // Add ENS name to suggestions for future use
                            self?.addENSNameToSuggestions(selectedText)
                        } else {
                            // Fallback to address resolution if default action fails
                            self?.resolveToAddress(selectedText)
                        }
                    }
                }
            } else {
                // Not in browser context - resolve to address
                resolveToAddress(selectedText)
            }
        } else {
            // Trigger error haptic feedback for invalid format
        }
    }
    
    private func resolveToAddress(_ selectedText: String) {
        APICaller.shared.resolveENSName(name: selectedText) { mappedAddress in
            DispatchQueue.main.async { [weak self] in
                if !mappedAddress.isEmpty {
                    // In non-browser context, always resolve to the Ethereum address
                    // Base subdomain detection only applies in browser context when Etherscan would be used
                    let finalResult = mappedAddress
                    
                    // Check if we have selected text (proper selection)
                    if let currentSelectedText = self?.textDocumentProxy.selectedText, currentSelectedText == selectedText {
                        // We have proper selected text, so we can replace it directly
                        // The text document proxy will handle the replacement correctly
                        self?.textDocumentProxy.insertText(finalResult)
                    } else {
                        // For spacebar long-press or other cases, we need to find and replace the text
                        self?.replaceTextInDocument(selectedText, with: finalResult)
                    }
                    
                    // Add ENS name to suggestions for future use
                    self?.addENSNameToSuggestions(selectedText)
                    
                    // Trigger success haptic feedback
                } else {
                    // Trigger error haptic feedback
                }
            }
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
        
        // Check if it's an ENS domain and resolve automatically
        if HelperClass.checkFormat(selectedText) {
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
        case "123", "ABC", ".eth", "⇧", "⌫", "#+=", "🙂", "🌐":
            return availableWidthForKeys * 0.12 // Function keys
        default:
            // Regular keys - distribute remaining space equally
            let functionKeys = row.filter { ["space", "return", "123", "ABC", ".eth", "⇧", "⌫", "#+=", "🙂", "🌐"].contains($0) }
            let regularKeys = row.filter { !["space", "return", "123", "ABC", ".eth", "⇧", "⌫", "#+=", "🙂", "🌐"].contains($0) }
            
            // Calculate function key widths without recursion
            let functionKeyWidth = functionKeys.reduce(0) { total, functionKey in
                switch functionKey {
                case "space":
                    return total + (availableWidthForKeys * 0.4)
                case "return":
                    return total + (availableWidthForKeys * 0.15)
                case "123", "ABC", ".eth", "⇧", "⌫", "#+=", "🙂", "🌐":
                    return total + (availableWidthForKeys * 0.12)
                default:
                    return total
                }
            }
            
            let remainingWidth = availableWidthForKeys - functionKeyWidth - (CGFloat(row.count - 1) * spacing)
            return max(remainingWidth / CGFloat(regularKeys.count), 30) // Minimum width of 30 points
        }
    }
    
    // MARK: - ENS Usage Tracking
    
    private func loadENSUsageData() {
        var allENSNames: [String] = []
        
        // Add fallback to standard UserDefaults if App Group fails
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        
        // Load ENS names from "My ENS Names" page
        if let myENSNames = userDefaults.array(forKey: "myENSNames") as? [String] {
            allENSNames.append(contentsOf: myENSNames)
        }
        
        // Load ENS names from contacts
        if let contactENSNames = userDefaults.array(forKey: "contactENSNames") as? [String] {
            allENSNames.append(contentsOf: contactENSNames)
        }
        
        // Load individual ENS names from usage tracking
        if let savedENSNames = userDefaults.array(forKey: "savedENSNames") as? [String] {
            allENSNames.append(contentsOf: savedENSNames)
        }
        
        // Remove duplicates and use combined list
        if !allENSNames.isEmpty {
            mostTypedENS = Array(Set(allENSNames)) // Remove duplicates
        } else {
            // Use default suggestions if no saved names
            mostTypedENS = defaultENSSuggestions
        }
        
        // Also load ENS names from contacts (legacy method)
        loadContactsENSNames()
    }
    
    private func loadContactsENSNames() {
        // Load contacts and extract their ENS names
        // Add fallback to standard UserDefaults if App Group fails
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        
        if let data = userDefaults.data(forKey: "savedContacts"),
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
        // Add fallback to standard UserDefaults if App Group fails
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        userDefaults.set(mostTypedENS, forKey: "savedENSNames")
        userDefaults.synchronize()
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
            return 
        }
        
        // Find the stack view
        guard let suggestionStackView = suggestionBar.subviews.first as? UIStackView else {
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
        
    }
    
    // MARK: - Layout Switching
    
    @objc private func switchToNumbersLayout() {
        isNumbersLayout = true
        isSecondarySymbolsLayout = false
        isKeyboardViewSetup = false
        setupKeyboardView()
        isKeyboardViewSetup = true
    }
    
    @objc private func switchToLettersLayout() {
        isNumbersLayout = false
        isSecondarySymbolsLayout = false
        isKeyboardViewSetup = false
        setupKeyboardView()
        isKeyboardViewSetup = true
    }
    
    @objc private func switchToSecondarySymbolsLayout() {
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
        btcButtonPressed = true
        btcLongPressOccurred = false
        
        // Start long press timer
        btcLongPressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            if self?.btcButtonPressed == true {
                // Long press detected - show crypto options
                self?.btcLongPressOccurred = true
                self?.showCryptoTickerOptions()
            } else {
            }
        }
    }
    
    @objc private func btcButtonTouchUp(_ sender: UIButton) {
        
        btcButtonPressed = false
        btcLongPressTimer?.invalidate()
        btcLongPressTimer = nil
        
        // If it was a short press (no long press occurred), handle as normal tap
        if !btcLongPressOccurred {
            handleKeyPress(":btc")
        } else {
        }
        
        // Reset the long press flag
        btcLongPressOccurred = false
    }
    
    // MARK: - .eth Key Handling
    
    private var ethLongPressTimer: Timer?
    private var ethButtonPressed = false
    private var ethLongPressOccurred = false
    
    @objc private func ethButtonTouchDown(_ sender: UIButton) {
        ethButtonPressed = true
        ethLongPressOccurred = false
        
        // Start long press timer
        ethLongPressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            if self?.ethButtonPressed == true {
                // Long press detected - show ENS subdomain options
                self?.ethLongPressOccurred = true
                self?.showENSSubdomainOptions()
            }
        }
    }
    
    @objc private func ethButtonTouchUp(_ sender: UIButton) {
        ethButtonPressed = false
        ethLongPressTimer?.invalidate()
        ethLongPressTimer = nil
        
        // If it was a short press (no long press occurred), handle as normal tap
        if !ethLongPressOccurred {
            handleKeyPress(".eth")
        }
        
        // Reset the long press flag
        ethLongPressOccurred = false
    }
    
    private func showENSSubdomainOptions() {
        // Add haptic feedback - use notification feedback for keyboard extensions
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        let subdomainOptions = [
            ".base.eth",
            ".uni.eth", 
            ".dao.eth",
            ".ens.eth",
            ".defi.eth"
        ]
        
        // Create a popup view similar to crypto options
        let popupView = UIView()
        popupView.backgroundColor = UIColor.systemBackground
        popupView.layer.cornerRadius = 12
        popupView.layer.shadowColor = UIColor.black.cgColor
        popupView.layer.shadowOffset = CGSize(width: 0, height: 2)
        popupView.layer.shadowRadius = 8
        popupView.layer.shadowOpacity = 0.3
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        
        // Create stack view for buttons
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(stackView)
        
        // Create buttons for each subdomain
        for subdomain in subdomainOptions {
            let button = UIButton(type: .system)
            button.setTitle(subdomain, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            button.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 0.74, alpha: 1.0) // Same blue as .eth key
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.addAction(UIAction { _ in
                self.insertText(subdomain)
                self.lastTypedWord += subdomain
                popupView.removeFromSuperview()
            }, for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        // Position the popup above the .eth button
        NSLayoutConstraint.activate([
            popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            popupView.heightAnchor.constraint(equalToConstant: 50),
            popupView.widthAnchor.constraint(equalToConstant: 380),
            
            stackView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -8)
        ])
        
        // Auto-dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            popupView.removeFromSuperview()
        }
    }
    
    // MARK: - ⌫ Backspace Key Handling
    
    private var backspaceLongPressTimer: Timer?
    private var backspaceButtonPressed = false
    private var backspaceLongPressOccurred = false
    private var backspaceContinuousTimer: Timer?
    
    @objc private func backspaceButtonTouchDown(_ sender: UIButton) {
        backspaceButtonPressed = true
        backspaceLongPressOccurred = false
        
        // Start long press timer
        backspaceLongPressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            if self?.backspaceButtonPressed == true {
                // Long press detected - start continuous deletion
                self?.backspaceLongPressOccurred = true
                self?.startContinuousDeletion()
            }
        }
    }
    
    @objc private func backspaceButtonTouchUp(_ sender: UIButton) {
        backspaceButtonPressed = false
        backspaceLongPressTimer?.invalidate()
        backspaceLongPressTimer = nil
        backspaceContinuousTimer?.invalidate()
        backspaceContinuousTimer = nil
        
        // If it was a short press (no long press occurred), handle as normal tap
        if !backspaceLongPressOccurred {
            handleKeyPress("⌫")
        }
        
        // Reset the long press flag
        backspaceLongPressOccurred = false
    }
    
    private func startContinuousDeletion() {
        // Add haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        // Start continuous deletion timer
        backspaceContinuousTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard self?.backspaceButtonPressed == true else {
                self?.backspaceContinuousTimer?.invalidate()
                self?.backspaceContinuousTimer = nil
                return
            }
            self?.textDocumentProxy.deleteBackward()
        }
    }
    
    private func showCryptoTickerOptions() {
        
        // Add haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        let cryptoOptions = [
            // Most popular blockchain networks
            ":btc", ":sol", ":doge",
            // Additional blockchain networks  
            ":xrp", ":ltc", ":ada", ":dot",
            // Text records
            ":url", ":x", ":github", ":name", ":bio"
        ]
        
        
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
                guard let currentRowStackView = currentRowStackView else { return }
                mainStackView.addArrangedSubview(currentRowStackView)
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
                self.insertText(ticker)
                self.lastTypedWord += ticker
                // Turn off shift after key press (unless caps lock is on)
                if self.isShiftPressed && !self.isCapsLock {
                    self.isShiftPressed = false
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
        
    }
    
    @objc private func handleSpacebarLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        // Prevent keyboard switching by consuming the gesture
        gesture.cancelsTouchesInView = true
        
        // Add haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        // Detect and resolve ENS domain around cursor
        detectAndResolveENSAroundCursor()
    }
    
    @objc private func handle123LongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        // Prevent normal 123 key action by consuming the gesture
        gesture.cancelsTouchesInView = true
        
        // Add haptic feedback to indicate keyboard switch
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        // Switch to Apple's emoji keyboard
        // advanceToNextInputMode() cycles through all available keyboards including emoji
        advanceToNextInputMode()
    }
    
    // MARK: - Browser Address Bar Auto-Resolve
    
    private func isInBrowserAddressBar() -> Bool {
        // Get the current text context
        let beforeText = textDocumentProxy.documentContextBeforeInput ?? ""
        let afterText = textDocumentProxy.documentContextAfterInput ?? ""
        let fullText = beforeText + afterText
        
        
        // Check return key type for browser-like behavior (more restrictive)
        if let returnKeyType = textDocumentProxy.returnKeyType {
            // Only look for specific browser return key types
            if returnKeyType == .go {
                return true
            }
        }
        
        // Check for clear browser indicators in the text context (more restrictive)
        if beforeText.contains("http://") || beforeText.contains("https://") || 
           beforeText.contains("www.") {
            return true
        }
        
        // Check if we're in a search context (like Google search with parameters)
        if fullText.contains("search") && (fullText.contains("q=") || fullText.contains("&q=")) {
            return true
        }
        
        // Get the current input
        let currentInput = extractInputFromAddressBar(fullText)
        
        // Check for ENS names (both plain ENS names and text records) in browser context
        let hasStrongBrowserIndicators = (textDocumentProxy.returnKeyType == .go || 
                                        textDocumentProxy.returnKeyType == .search || 
                                        textDocumentProxy.returnKeyType == .done) ||
                                       beforeText.contains("http://") || 
                                       beforeText.contains("https://") || 
                                       beforeText.contains("www.")
        
        if hasStrongBrowserIndicators {
            // Check if it's an ENS text record (like name.eth:x)
            if currentInput.contains(":") && isENSName(currentInput.components(separatedBy: ":").first ?? "") {
                return true
            }
            // Check if it's a plain ENS name (like name.eth)
            else if isENSName(currentInput) {
                return true
            }
        }
        
        return false
    }
    
    private func handleReturnKeyInAddressBar() {
        // Get the current text in the address bar
        let beforeText = textDocumentProxy.documentContextBeforeInput ?? ""
        let afterText = textDocumentProxy.documentContextAfterInput ?? ""
        let fullText = beforeText + afterText
        
        
        // Extract the input (everything after the last space or from the beginning)
        let input = extractInputFromAddressBar(fullText)
        
        if !input.isEmpty {
            // Check if this is an ENS text record first (e.g., name.eth:x, name.eth:url)
            if input.contains(":") && isENSName(input.components(separatedBy: ":").first ?? "") {
                // For ENS text records, try to auto-resolve with timeout
                autoResolveInput(input) { resolvedURL in
                    DispatchQueue.main.async {
                        
                        if let resolvedURL = resolvedURL {
                            // Clear the address bar and insert the resolved URL
                            self.clearAddressBarAndInsertURL(resolvedURL)
                            
                            // Restore return key and trigger navigation
                            self.updateReturnKeyToNormal()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self.textDocumentProxy.insertText("\n")
                            }
                        } else {
                            // If no resolution, proceed with normal return key
                            self.updateReturnKeyToNormal()
                            self.textDocumentProxy.insertText("\n")
                        }
                    }
                }
                return
            }
            
            // Check if this is a simple case that can be resolved immediately
            if isCryptoAddress(input) || isURL(input) {
                // Handle simple cases immediately
                let resolvedURL = isCryptoAddress(input) ? getExplorerURL(for: input) : ensureProperURL(input)
                if let resolvedURL = resolvedURL {
                    clearAddressBarAndInsertURL(resolvedURL)
                    
                    // Trigger the return key to navigate
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.textDocumentProxy.insertText("\n")
                    }
                    return
                }
            }
            
            // For ENS names or complex cases, try to auto-resolve with timeout
            autoResolveInput(input) { resolvedURL in
                DispatchQueue.main.async {
                    
                    if let resolvedURL = resolvedURL {
                        // Clear the address bar and insert the resolved URL
                        self.clearAddressBarAndInsertURL(resolvedURL)
                        
                        // Restore return key and trigger navigation
                        self.updateReturnKeyToNormal()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.textDocumentProxy.insertText("\n")
                        }
                    } else {
                        // If no resolution, proceed with normal return key
                        self.updateReturnKeyToNormal()
                        self.textDocumentProxy.insertText("\n")
                    }
                }
            }
        } else {
            // No input, proceed with normal return key
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
            resolveENSToExplorer(input, completion: completion)
        } else if isCryptoAddress(input) {
            // For crypto addresses, append the appropriate explorer URL (immediate)
            let explorerURL = getExplorerURL(for: input)
            completion(explorerURL)
        } else if isURL(input) {
            // For URLs, ensure proper protocol (immediate)
            let properURL = ensureProperURL(input)
            completion(properURL)
        } else if isENSName(input) {
            // For ENS names, resolve to address and then to explorer (with timeout)
            resolveENSToExplorer(input, completion: completion)
        } else {
            // Try to resolve as ENS name anyway (with timeout)
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
        
        // Plain ENS name - use user's default browser action
        resolveENSWithDefaultAction(ensName, completion: completion)
    }
    
    private func resolveENSWithDefaultAction(_ ensName: String, completion: @escaping (String?) -> Void) {
        let defaultAction = HelperClass.getDefaultBrowserAction()
        
        // Try to resolve the user's preferred action first
        let preferredRecordType = defaultAction.rawValue
        
        // Check if this is a supported record type for default actions
        if ["url", "github", "x"].contains(preferredRecordType) {
            // Try to resolve the preferred text record
            resolveTextRecord(baseName: ensName, recordType: preferredRecordType) { resolvedURL in
                if let url = resolvedURL, !url.isEmpty {
                    completion(url)
                   } else {
                       // Fallback to Etherscan if preferred action not available
                       // Check if this is an L2 subdomain for Etherscan fallback
                       if HelperClass.isL2ChainDetectionEnabled() && HelperClass.isL2Subdomain(ensName) {
                           // Need to resolve the address first to create proper L2 Explorer URL
                           APICaller.shared.resolveENSName(name: ensName) { resolvedAddress in
                               if !resolvedAddress.isEmpty {
                                   let l2ExplorerURL = HelperClass.resolveL2SubdomainToExplorer(ensName, resolvedAddress: resolvedAddress)
                                   completion(l2ExplorerURL)
                               } else {
                                   // Fallback to regular Etherscan if address resolution fails
                                   self.resolveToEtherscan(ensName, completion: completion)
                               }
                           }
                       } else {
                           self.resolveToEtherscan(ensName, completion: completion)
                       }
                   }
            }
        } else {
            // Default action is Etherscan, check if this is an L2 subdomain
            if HelperClass.isL2ChainDetectionEnabled() && HelperClass.isL2Subdomain(ensName) {
                // Need to resolve the address first to create proper L2 Explorer URL
                APICaller.shared.resolveENSName(name: ensName) { resolvedAddress in
                    if !resolvedAddress.isEmpty {
                        let l2ExplorerURL = HelperClass.resolveL2SubdomainToExplorer(ensName, resolvedAddress: resolvedAddress)
                        completion(l2ExplorerURL)
                    } else {
                        // Fallback to regular Etherscan if address resolution fails
                        self.resolveToEtherscan(ensName, completion: completion)
                    }
                }
            } else {
                resolveToEtherscan(ensName, completion: completion)
            }
        }
    }
    
    private func resolveToEtherscan(_ ensName: String, completion: @escaping (String?) -> Void) {
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
        
        
        // Create URLSession with timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 3.0 // 3 second timeout
        config.timeoutIntervalForResource = 5.0 // 5 second total timeout
        let session = URLSession(configuration: config)
        
        // Make API call to resolve text record
        guard let url = URL(string: apiURL) else {
            return
        }
        session.dataTask(with: url) { data, response, error in
            // Check for timeout or network error
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Debug: Print raw response
            if String(data: data, encoding: .utf8) != nil {
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            
            guard let success = json["success"] as? Bool, success else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let dataDict = json["data"] as? [String: Any] else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            
            // Try different possible keys for the text record value
            let recordValue: String?
            if let value = dataDict["value"] as? String, !value.isEmpty {
                recordValue = value
            } else if let address = dataDict["address"] as? String, !address.isEmpty {
                recordValue = address
            } else if let result = dataDict["result"] as? String, !result.isEmpty {
                recordValue = result
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Convert text record to appropriate URL
            guard let recordValue = recordValue else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let resolvedURL = HelperClass.convertTextRecordToURL(recordType: recordType, value: recordValue)
            DispatchQueue.main.async {
                completion(resolvedURL)
            }
        }.resume()
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
            }
        }
    }
    
    private func updateReturnKeyToNormal() {
        // Find the return key button and restore its normal title
        DispatchQueue.main.async {
            if let returnButton = self.findReturnKeyButton() {
                returnButton.setTitle("return", for: .normal)
                returnButton.isEnabled = true
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
    
    // MARK: - Globe Key Handling (iPad Only)
    
    private func handleGlobeKeyPress() {
        // Only available on iPad
        guard isIPad else { return }
        
        // Add haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        // Announce accessibility message
        announceAccessibilityMessage("Switching keyboards")
        
        // Switch to next keyboard
        advanceToNextInputMode()
    }
    
}
