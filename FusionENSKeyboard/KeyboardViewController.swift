//
//  KeyboardViewController.swift
//  FusionENSKeyboard
//
//  Created by Franz Quarshie on 05/09/2025.
//

import UIKit
import KeyboardKit
import FusionENSShared

// Protocol for keyboard functionality
protocol KeyboardController {
    func insertText(_ text: String)
    func deleteBackward()
    func triggerENSResolution()
}


class KeyboardViewController: KeyboardInputViewController, KeyboardController {
    
    private var isKeyboardViewSetup = false
    
    // ENS AutoComplete Provider
    private let autoCompleteProvider = FusionENSAutoCompleteProvider()
    
    // Selection monitoring
    private var lastSelectedText: String = ""
    private var selectionTimer: Timer?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Let the system handle the keyboard layout - we just provide ENS resolution
        setupKeyboardView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        selectionTimer?.invalidate()
        selectionTimer = nil
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        // Don't set up any custom views - let the system handle the keyboard layout
        // Just ensure our controller is ready for ENS resolution
        isKeyboardViewSetup = true
    }
    
    // MARK: - KeyboardController Protocol Methods
    
    override func insertText(_ text: String) {
        textDocumentProxy.insertText(text)
    }
    
    override func deleteBackward() {
        textDocumentProxy.deleteBackward()
    }
    
    func triggerENSResolution() {
        // Only resolve if there's selected text
        if let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty {
            print("🔍 Basic Keyboard: Selected text: '\(selectedText)'")
            // Only resolve if it's an ENS domain
            if HelperClass.checkFormat(selectedText) {
                print("✅ Basic Keyboard: Format check passed for '\(selectedText)'")
                handleSelectedText(selectedText)
            } else {
                print("❌ Basic Keyboard: Format check failed for '\(selectedText)'")
            }
        } else {
            print("🔍 Basic Keyboard: No selected text")
        }
    }
    
    private func handleSelectedText(_ selectedText: String) {
        if HelperClass.checkFormat(selectedText) {
            print("🚀 Basic Keyboard: Calling APICaller for '\(selectedText)'")
            // Use APICaller directly (same as Pro Keyboard) for consistent subdomain resolution
            APICaller.shared.resolveENSName(name: selectedText) { [weak self] resolvedAddress in
                DispatchQueue.main.async {
                    print("📡 Basic Keyboard: APICaller response for '\(selectedText)': '\(resolvedAddress)'")
                    if !resolvedAddress.isEmpty {
                        // Check if we have selected text (proper selection)
                        if let currentSelectedText = self?.textDocumentProxy.selectedText, currentSelectedText == selectedText {
                            // We have proper selected text, so we can replace it directly
                            // The text document proxy will handle the replacement correctly
                            print("✅ Basic Keyboard: Replacing selected text with address")
                            self?.textDocumentProxy.insertText(resolvedAddress)
                        } else {
                            // For cases where text is not properly selected, use smart replacement
                            print("🔄 Basic Keyboard: Using smart replacement")
                            self?.smartReplaceENS(selectedText, with: resolvedAddress)
                        }
                        
                        // Trigger success haptic feedback
                    } else {
                        print("❌ Basic Keyboard: Empty address response")
                        // Trigger error haptic feedback
                    }
                }
            }
        } else {
            print("❌ Basic Keyboard: Format check failed in handleSelectedText")
            // Trigger error haptic feedback for invalid format
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
            
            // Position cursor after the resolved address
            let cursorPosition = textBeforeENS.count + resolvedAddress.count
            for _ in 0..<(newText.count - cursorPosition) {
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
        print("🔍 Basic Keyboard: processSelectedText called with: '\(selectedText)'")
        
        // Check if it's an ENS domain and resolve automatically
        if HelperClass.checkFormat(selectedText) {
            print("✅ Basic Keyboard: Format check passed in processSelectedText for '\(selectedText)'")
            // Check if we're in a browser context for auto-resolve
            if isInBrowserAddressBar() {
                print("🌐 Basic Keyboard: Browser context detected")
                handleBrowserENSResolution(selectedText)
            } else {
                print("📝 Basic Keyboard: Regular context, calling handleSelectedText")
                handleSelectedText(selectedText)
            }
        } else {
            print("❌ Basic Keyboard: Format check failed in processSelectedText for '\(selectedText)'")
        }
    }
    
    // MARK: - Browser Auto-Resolve
    
    private func isInBrowserAddressBar() -> Bool {
        // Get the current text context
        let beforeText = textDocumentProxy.documentContextBeforeInput ?? ""
        let afterText = textDocumentProxy.documentContextAfterInput ?? ""
        let fullText = beforeText + afterText
        
        // Check return key type for browser-like behavior
        if let returnKeyType = textDocumentProxy.returnKeyType {
            // Look for browser-like return key types
            if returnKeyType == .go || returnKeyType == .search || returnKeyType == .done {
                return true
            }
        }
        
        // Check for clear browser indicators in the text context
        if beforeText.contains("http://") || beforeText.contains("https://") || 
           beforeText.contains("www.") || 
           beforeText.contains("google.com") || beforeText.contains("search") ||
           fullText.contains("q=") || fullText.contains("&q=") ||
           afterText.contains(".com") || afterText.contains(".org") || afterText.contains(".net") {
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
        for component in components.reversed() {
            let trimmed = component.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return trimmed
            }
        }
        
        return ""
    }
    
    private func isENSName(_ input: String) -> Bool {
        return HelperClass.checkFormat(input)
    }
    
    private func isCryptoAddress(_ input: String) -> Bool {
        // Check if it looks like a crypto address (starts with 0x and is 42 characters)
        return input.hasPrefix("0x") && input.count == 42
    }
    
    private func isURL(_ input: String) -> Bool {
        // Check if it looks like a URL
        return input.contains("://") || input.hasPrefix("www.") || 
               input.contains(".com") || input.contains(".org") || input.contains(".net")
    }
    
    private func handleBrowserENSResolution(_ ensName: String) {
        
        // Check if browser has auto-completed the ENS name with https://
        if ensName.hasPrefix("https://") && ensName.hasSuffix("/") {
            let potentialENSName = String(ensName.dropFirst(8).dropLast(1)) // Remove "https://" and "/"
            if isENSName(potentialENSName) {
                resolveENSToExplorer(potentialENSName) { [weak self] resolvedURL in
                    DispatchQueue.main.async {
                        if let url = resolvedURL, !url.isEmpty {
                            self?.replaceSelectedText(with: url)
                        }
                    }
                }
                return
            }
        }
        
        // For browser context, resolve ENS to explorer URL
        if ensName.contains(":") && isENSName(ensName.components(separatedBy: ":").first ?? "") {
            // ENS text record - resolve to appropriate URL
            resolveENSToExplorer(ensName) { [weak self] resolvedURL in
                DispatchQueue.main.async {
                    if let url = resolvedURL, !url.isEmpty {
                        self?.replaceSelectedText(with: url)
                    } else {
                    }
                }
            }
        } else if isENSName(ensName) {
            // Plain ENS name - resolve to Etherscan
            resolveENSToExplorer(ensName) { [weak self] resolvedURL in
                DispatchQueue.main.async {
                    if let url = resolvedURL, !url.isEmpty {
                        self?.replaceSelectedText(with: url)
                    } else {
                    }
                }
            }
        } else {
        }
    }
    
    private func resolveENSToExplorer(_ input: String, completion: @escaping (String?) -> Void) {
        if input.contains(":") {
            // ENS text record (e.g., name.eth:x, name.eth:url)
            let components = input.components(separatedBy: ":")
            if components.count == 2 {
                let _ = components[0] // baseName
                let recordType = components[1]
                
                // Handle text records using the same API as pro keyboard
                if ["x", "url", "github", "name", "bio"].contains(recordType) {
                    // Use the shared APICaller for text records
                    APICaller.shared.resolveENSName(name: input) { resolvedValue in
                        if !resolvedValue.isEmpty {
                            // Convert text record to appropriate URL
                            let resolvedURL = self.convertTextRecordToURL(recordType: recordType, value: resolvedValue)
                            completion(resolvedURL)
                        } else {
                            completion(nil)
                        }
                    }
                    return
                }
            }
            completion(nil)
        } else {
            // Plain ENS name - resolve to Etherscan URL using shared APICaller
            APICaller.shared.resolveENSName(name: input) { resolvedAddress in
                if !resolvedAddress.isEmpty {
                    // Create Etherscan URL
                    let etherscanURL = "https://etherscan.io/address/\(resolvedAddress)"
                    completion(etherscanURL)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    
    private func convertTextRecordToURL(recordType: String, value: String) -> String {
        switch recordType {
        case "x":
            // Twitter/X handle
            if value.hasPrefix("@") {
                return "https://x.com/\(String(value.dropFirst()))"
            } else {
                return "https://x.com/\(value)"
            }
        case "url":
            // Direct URL
            if value.hasPrefix("http://") || value.hasPrefix("https://") {
                return value
            } else {
                return "https://\(value)"
            }
        case "github":
            // GitHub profile
            if value.hasPrefix("@") {
                return "https://github.com/\(String(value.dropFirst()))"
            } else {
                return "https://github.com/\(value)"
            }
        case "name":
            // Name - could be a search or profile
            return "https://google.com/search?q=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value)"
        case "bio":
            // Bio - could be a search
            return "https://google.com/search?q=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value)"
        default:
            // Default to search
            return "https://google.com/search?q=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value)"
        }
    }
    
    private func replaceSelectedText(with newText: String) {
        // Replace the selected text with the new text
        if let selectedText = textDocumentProxy.selectedText, !selectedText.isEmpty {
            // Delete the selected text
            for _ in 0..<selectedText.count {
                textDocumentProxy.deleteBackward()
            }
            // Insert the new text
            textDocumentProxy.insertText(newText)
        }
    }
    
}