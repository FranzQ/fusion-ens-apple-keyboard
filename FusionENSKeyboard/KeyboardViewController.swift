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
    
    // Track the current hosting controller for proper cleanup
    private var currentHostingController: UIHostingController<KeyboardView>?
    
    // Prevent multiple simultaneous view setup calls
    private var isSettingUpView = false
    private var lastKeyboardType: KeyboardType?
    
    // This keyboard is now SwiftUI-only
    enum KeyboardType: String {
        case swiftui = "SwiftUI" // Modern SwiftUI-based keyboard with simplified interface
    }
    
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
    
    // ENS AutoComplete Provider
    private let autoCompleteProvider = FusionENSAutoCompleteProvider()
    
    // Selection monitoring
    private var lastSelectedText: String = ""
    private var selectionTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize lastKeyboardType to SwiftUI
        lastKeyboardType = .swiftui
        
        // Delay setup to ensure proper view dimensions
        DispatchQueue.main.async {
            self.setupKeyboardView()
            self.isKeyboardViewSetup = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        // Clean up hosting controller if it exists
        if let hostingController = currentHostingController {
            hostingController.willMove(toParent: nil)
            hostingController.view.removeFromSuperview()
            hostingController.removeFromParent()
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Only refresh if not already set up
        if !isKeyboardViewSetup {
            setupKeyboardView()
            isKeyboardViewSetup = true
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        print("📐 KeyboardViewController: updateViewConstraints called")
        print("📐 View frame: \(view.frame)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("📐 KeyboardViewController: viewDidLayoutSubviews called")
        print("📐 View frame: \(view.frame)")
        print("📐 View bounds: \(view.bounds)")
        
        // Just log the height - don't try to fix it here to avoid infinite loops
        if view.frame.height < 216.0 {
            print("📐 Warning: View height is small (\(view.frame.height))")
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
        print("🔧 SwiftUI KeyboardViewController: setupKeyboardView called")
        
        // Prevent multiple simultaneous setup calls
        guard !isSettingUpView else {
            print("🔧 Already setting up view, skipping...")
            return
        }
        
        // Check if already set up
        if isKeyboardViewSetup {
            print("🔧 SwiftUI keyboard already set up, skipping")
            return
        }
        
        isSettingUpView = true
        
        // Properly clean up existing views and child view controllers
        cleanupExistingViews()
        
        // Create SwiftUI keyboard view
        print("🔧 Creating SwiftUI keyboard view")
        let swiftUIView = UIHostingController(rootView: KeyboardView(controller: self))
        currentHostingController = swiftUIView
        swiftUIView.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Properly add as child view controller
        addChild(swiftUIView)
        view.addSubview(swiftUIView.view)
        swiftUIView.didMove(toParent: self)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            swiftUIView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            swiftUIView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            swiftUIView.view.topAnchor.constraint(equalTo: view.topAnchor),
            swiftUIView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        print("🔧 SwiftUI keyboard view created and added")
        
        isSettingUpView = false
        print("🔧 SwiftUI setupKeyboardView completed")
    }
    
    private func cleanupExistingViews() {
        print("🧹 KeyboardViewController: cleanupExistingViews called")
        print("🧹 Current subviews count: \(view.subviews.count)")
        print("🧹 Current hosting controller: \(currentHostingController != nil ? "exists" : "nil")")
        
        // Properly remove any existing hosting controller first
        if let hostingController = currentHostingController {
            print("🧹 Removing existing hosting controller")
            hostingController.willMove(toParent: nil)
            hostingController.view.removeFromSuperview()
            hostingController.removeFromParent()
            currentHostingController = nil
        }
        
        // Remove all subviews (this will also remove any constraints)
        view.subviews.forEach { subview in
            // Remove all constraints from the subview
            subview.removeFromSuperview()
        }
        
        // Clear suggestion-related views
        suggestionOverlay?.removeFromSuperview()
        suggestionOverlay = nil
        suggestionBar = nil
        suggestionButtons.removeAll()
        
        // Force layout update to clear any lingering constraints
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        print("🧹 Cleanup completed. Subviews count: \(view.subviews.count)")
    }
    
    // Public method to force refresh the keyboard view (useful for debugging)
    func refreshKeyboardView() {
        print("🔄 Manual refresh requested")
        DispatchQueue.main.async {
            self.isKeyboardViewSetup = false
            self.setupKeyboardView()
            self.isKeyboardViewSetup = true
        }
    }
    
    // MARK: - KeyboardController Protocol Methods
    
    override func insertText(_ text: String) {
        textDocumentProxy.insertText(text)
    }
    
    override func deleteBackward() {
        textDocumentProxy.deleteBackward()
    }
    
    func triggerENSResolution() {
        print("🔍 ENS Resolution triggered")
        
        // Only resolve if there's selected text
        if let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty {
            print("📝 Selected text: '\(selectedText)'")
            // Only resolve if it's an ENS domain
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
    
    func getENSSuggestions() -> [String] {
        // Return a subset of popular ENS domains for suggestions
        return Array(popularENSDomains.prefix(8))
    }
    
    private func handleSelectedText(_ selectedText: String) {
        if HelperClass.checkFormat(selectedText) {
            // Use the AutoCompleteProvider to resolve ENS names
            autoCompleteProvider.getSuggestions(for: selectedText) { [weak self] suggestions in
                DispatchQueue.main.async {
                    if let resolvedAddress = suggestions.first, !resolvedAddress.isEmpty {
                        // Delete the original text and insert the resolved address
                        for _ in 0..<selectedText.count {
                            self?.textDocumentProxy.deleteBackward()
                        }
                        self?.textDocumentProxy.insertText(resolvedAddress)
                        
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
    
    // MARK: - Haptic Feedback
    
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
        print("📝 Text selected: '\(selectedText)'")
        
        // Check if it's an ENS domain and resolve automatically
        if HelperClass.checkFormat(selectedText) {
            print("✅ ENS format detected, auto-resolving...")
            handleSelectedText(selectedText)
        }
    }
   
}




