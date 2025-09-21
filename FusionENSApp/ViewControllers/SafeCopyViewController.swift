//
//  SafeCopyViewController.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 12/09/2025.
//

import UIKit
import SnapKit

class SafeCopyViewController: UIViewController {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // ENS Input Section
    private let inputSectionView = UIView()
    private let inputTitleLabel = UILabel()
    private let ensInputField = UITextField()
    private let resolveButton = UIButton(type: .system)
    
    // Result Section
    private let resultSectionView = UIView()
    private let resultTitleLabel = UILabel()
    private let addressLabel = UILabel()
    private let copyButton = UIButton(type: .system)
    private let successLabel = UILabel()
    
    // MARK: - Properties
    private var resolvedAddress: String = ""
    
    private var isHapticFeedbackEnabled: Bool {
        return UserDefaults(suiteName: "group.com.fusionens.keyboard")?.bool(forKey: "hapticFeedbackEnabled") ?? true
    }
    
    private func addENSNameToSuggestions(_ ensName: String) {
        // Load current saved names
        var savedENSNames = UserDefaults(suiteName: "group.com.fusionens.keyboard")?.array(forKey: "savedENSNames") as? [String] ?? []
        
        // Remove if already exists to avoid duplicates
        savedENSNames.removeAll { $0 == ensName }
        
        // Add to beginning of list
        savedENSNames.insert(ensName, at: 0)
        
        // Keep only top 10 most recent
        if savedENSNames.count > 10 {
            savedENSNames = Array(savedENSNames.prefix(10))
        }
        
        // Save to shared storage
        UserDefaults(suiteName: "group.com.fusionens.keyboard")?.set(savedENSNames, forKey: "savedENSNames")
        UserDefaults(suiteName: "group.com.fusionens.keyboard")?.synchronize()
        
        print("📝 Added '\(ensName)' to ENS suggestions from SafeCopy")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Navigation Bar
        setupNavigationBar()
        
        // Scroll View
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Title
        titleLabel.text = "Safe Copy"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        // Description
        descriptionLabel.text = "Resolve ENS names and safely copy addresses to your clipboard"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
        
        // Input Section
        setupInputSection()
        
        // Result Section
        setupResultSection()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Safe Copy"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }
    
    private func setupInputSection() {
        contentView.addSubview(inputSectionView)
        
        // Input Title
        inputTitleLabel.text = "Enter ENS Name"
        inputTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        inputTitleLabel.textColor = .label
        inputSectionView.addSubview(inputTitleLabel)
        
        // ENS Input Field
        ensInputField.placeholder = "e.g., vitalik.eth"
        ensInputField.borderStyle = .roundedRect
        ensInputField.font = UIFont.systemFont(ofSize: 16)
        ensInputField.autocapitalizationType = .none
        ensInputField.autocorrectionType = .no
        ensInputField.returnKeyType = .done
        ensInputField.delegate = self
        inputSectionView.addSubview(ensInputField)
        
        // Resolve Button
        resolveButton.setTitle("Resolve", for: .normal)
        resolveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        resolveButton.setTitleColor(.white, for: .normal)
        resolveButton.backgroundColor = .systemBlue
        resolveButton.layer.cornerRadius = 8
        resolveButton.isEnabled = false
        inputSectionView.addSubview(resolveButton)
    }
    
    private func setupResultSection() {
        contentView.addSubview(resultSectionView)
        resultSectionView.isHidden = true
        
        // Result Title
        resultTitleLabel.text = "Resolved Address"
        resultTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        resultTitleLabel.textColor = .label
        resultSectionView.addSubview(resultTitleLabel)
        
        // Address Label
        addressLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        addressLabel.textColor = .secondaryLabel
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center
        addressLabel.backgroundColor = UIColor.systemGray6
        addressLabel.layer.cornerRadius = 8
        addressLabel.layer.masksToBounds = true
        resultSectionView.addSubview(addressLabel)
        
        // Copy Button
        copyButton.setTitle("Copy to Clipboard", for: .normal)
        copyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        copyButton.setTitleColor(.white, for: .normal)
        copyButton.backgroundColor = .systemGreen
        copyButton.layer.cornerRadius = 8
        resultSectionView.addSubview(copyButton)
        
        // Success Label
        successLabel.text = "✅ Address copied to clipboard!"
        successLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        successLabel.textColor = .systemGreen
        successLabel.textAlignment = .center
        successLabel.isHidden = true
        resultSectionView.addSubview(successLabel)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Input Section
        inputSectionView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        inputTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        ensInputField.snp.makeConstraints { make in
            make.top.equalTo(inputTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        resolveButton.snp.makeConstraints { make in
            make.top.equalTo(ensInputField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // Result Section
        resultSectionView.snp.makeConstraints { make in
            make.top.equalTo(inputSectionView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        resultTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(resultTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(60)
        }
        
        copyButton.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        successLabel.snp.makeConstraints { make in
            make.top.equalTo(copyButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupActions() {
        resolveButton.addTarget(self, action: #selector(resolveButtonTapped), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        
        // Enable resolve button when text changes
        ensInputField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    // MARK: - Actions
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
    
    @objc private func textFieldChanged() {
        let hasText = !(ensInputField.text?.isEmpty ?? true)
        resolveButton.isEnabled = hasText
        resolveButton.alpha = hasText ? 1.0 : 0.6
    }
    
    @objc private func resolveButtonTapped() {
        guard let ensName = ensInputField.text, !ensName.isEmpty else { return }
        
        // Show loading state
        resolveButton.setTitle("Resolving...", for: .normal)
        resolveButton.isEnabled = false
        
        // Resolve ENS name
        APICaller.shared.resolveENSName(name: ensName) { [weak self] resolvedAddress in
            DispatchQueue.main.async {
                self?.handleResolutionResult(resolvedAddress, for: ensName)
            }
        }
    }
    
    @objc private func copyButtonTapped() {
        // Copy to clipboard
        UIPasteboard.general.string = resolvedAddress
        
        // Show success feedback
        showCopySuccess()
        
        // Haptic feedback
        if isHapticFeedbackEnabled {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
    
    // MARK: - Helper Methods
    private func handleResolutionResult(_ address: String, for ensName: String) {
        // Reset button state
        resolveButton.setTitle("Resolve", for: .normal)
        resolveButton.isEnabled = true
        
        if !address.isEmpty {
            // Success
            resolvedAddress = address
            displayResolvedAddress(address, for: ensName)
            resultSectionView.isHidden = false
            
            // Add ENS name to keyboard suggestions
            addENSNameToSuggestions(ensName)
            
            // Scroll to result
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.scrollToResult()
            }
        } else {
            // Error
            showError(message: "Failed to resolve \(ensName)")
        }
    }
    
    private func displayResolvedAddress(_ address: String, for ensName: String) {
        let truncatedAddress = truncateAddress(address)
        addressLabel.text = "\(ensName)\n\(truncatedAddress)"
    }
    
    private func truncateAddress(_ address: String) -> String {
        guard address.count > 10 else { return address }
        let start = String(address.prefix(6))
        let end = String(address.suffix(4))
        return "\(start)...\(end)"
    }
    
    private func showCopySuccess() {
        successLabel.isHidden = false
        
        // Hide after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.successLabel.isHidden = true
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func scrollToResult() {
        let resultRect = resultSectionView.convert(resultSectionView.bounds, to: scrollView)
        scrollView.scrollRectToVisible(resultRect, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension SafeCopyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if resolveButton.isEnabled {
            resolveButtonTapped()
        }
        return true
    }
}
