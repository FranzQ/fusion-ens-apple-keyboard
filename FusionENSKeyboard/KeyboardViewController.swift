//
//  KeyboardViewController.swift
//  FusionENSKeyboard
//
//  Created by Franz Quarshie on 05/09/2025.
//

import UIKit
import KeyboardKit
import SwiftUI

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
            // Only resolve if it's an ENS domain
            if HelperClass.checkFormat(selectedText) {
                handleSelectedText(selectedText)
            } else {
                triggerErrorHaptic()
            }
        } else {
            triggerErrorHaptic()
        }
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
        
        // Check if it's an ENS domain and resolve automatically
        if HelperClass.checkFormat(selectedText) {
            handleSelectedText(selectedText)
        }
    }
   
}




