//
//  AddContactViewController.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 21/09/2025.
//

import UIKit
import SnapKit

protocol AddContactViewControllerDelegate: AnyObject {
    func didAddContact(_ contact: Contact)
    func didUpdateContact(_ contact: Contact, at indexPath: IndexPath)
}

class AddContactViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: AddContactViewControllerDelegate?
    var contactToEdit: Contact?
    var editingIndexPath: IndexPath?
    private var dataTasks: [URLSessionDataTask] = []
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Contact"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor.label
        return label
    }()
    
    private let ensNameLabel: UILabel = {
        let label = UILabel()
        label.text = "ENS Name"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.label
        return label
    }()
    
    private let ensNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "e.g. vitalik"
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.textColor = UIColor.label
        textField.backgroundColor = UIColor.secondarySystemBackground
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.separator.cgColor
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .default
        textField.returnKeyType = .done
        return textField
    }()
    
    private let ensPreviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.secondaryLabel
        label.text = ""
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Contact", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.isEnabled = false
        button.alpha = 0.6
        return button
    }()
    
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupTextFieldObservers()
        populateFieldsIfEditing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ensNameTextField.becomeFirstResponder()
    }
    
    deinit {
        // Cancel all pending network requests
        dataTasks.forEach { $0.cancel() }
        dataTasks.removeAll()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(ensNameLabel)
        containerView.addSubview(ensNameTextField)
        containerView.addSubview(ensPreviewLabel)
        containerView.addSubview(addButton)
        containerView.addSubview(loadingIndicator)
        
        // Add tap gesture to dismiss modal when tapping outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(280)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        ensNameLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        ensNameTextField.snp.makeConstraints { make in
            make.top.equalTo(ensNameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        ensPreviewLabel.snp.makeConstraints { make in
            make.top.equalTo(ensNameTextField.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        addButton.snp.makeConstraints { make in
            make.top.equalTo(ensPreviewLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(addButton)
        }
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextFieldObservers() {
        ensNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        ensNameTextField.delegate = self
    }
    
    // MARK: - Actions
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
    
    @objc private func addButtonTapped() {
        guard let ensName = ensNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !ensName.isEmpty else {
            return
        }
        
        // Automatically append .eth if not already present
        let fullENSName = ensName.hasSuffix(".eth") ? ensName : ensName + ".eth"
        
        // Check for duplicates in Contacts (only when adding new contact, not editing)
        if contactToEdit == nil && isDuplicateContact(fullENSName) {
            showErrorAlert(message: "The ENS name '\(fullENSName)' is already in your contacts.")
            return
        }
        
        // Show loading state
        showLoadingState()
        
        // Check if we're editing or adding
        if let contactToEdit = contactToEdit, let indexPath = editingIndexPath {
            // Editing existing contact
            validateAndUpdateContact(ensName: fullENSName, originalContact: contactToEdit, at: indexPath)
        } else {
            // Adding new contact
            validateAndAddContact(ensName: fullENSName)
        }
    }
    
    @objc private func textFieldDidChange() {
        guard let inputText = ensNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            ensPreviewLabel.text = ""
            updateAddButtonState()
            return
        }
        
        if inputText.isEmpty {
            ensPreviewLabel.text = ""
        } else {
            // Show the full ENS name with .eth suffix
            let fullENSName = inputText.hasSuffix(".eth") ? inputText : inputText + ".eth"
            ensPreviewLabel.text = "Will save as: \(fullENSName)"
        }
        
        updateAddButtonState()
    }
    
    private func updateAddButtonState() {
        let ensName = ensNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isValid = !ensName.isEmpty
        addButton.isEnabled = isValid
        addButton.alpha = isValid ? 1.0 : 0.6
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Validation and Adding
    private func validateAndAddContact(ensName: String) {
        // Validate ENS name using APICaller
        APICaller.shared.resolveENSName(name: ensName) { [weak self] resolvedAddress in
            DispatchQueue.main.async {
                self?.hideLoadingState()
                
                if !resolvedAddress.isEmpty {
                    // ENS name is valid, now fetch the resolved name (like My ENS Names does)
                    self?.fetchResolvedName(for: ensName, address: resolvedAddress)
                } else {
                    // ENS name is invalid
                    self?.showErrorAlert(message: "Invalid ENS name: \(ensName)\n\nPlease check the ENS name and try again.")
                }
            }
        }
    }
    
    private func fetchResolvedName(for ensName: String, address: String) {
        // Fetch the resolved name from ENS (same as My ENS Names does)
        let baseDomain = extractBaseDomain(from: ensName)
        let fusionServerURL = "https://api.fusionens.com/resolve/\(baseDomain):name?network=mainnet&source=ios-app"
        
        let dataTask = URLSession.shared.dataTask(with: URL(string: fusionServerURL)!) { [weak self] data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    // Create contact without resolved name
                    let contact = Contact(name: ensName, ensName: ensName, address: address, avatarURL: nil, resolvedName: nil)
                    self?.delegate?.didAddContact(contact)
                    self?.dismiss(animated: true)
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let success = json?["success"] as? Bool,
                      success,
                      let dataDict = json?["data"] as? [String: Any],
                      let fullName = dataDict["address"] as? String,
                      !fullName.isEmpty else {
                    DispatchQueue.main.async {
                        // Create contact without resolved name
                        let contact = Contact(name: ensName, ensName: ensName, address: address, avatarURL: nil, resolvedName: nil)
                        self?.delegate?.didAddContact(contact)
                        self?.dismiss(animated: true)
                    }
                    return
                }
                
                // Clean HTML tags if present
                let cleanName = self?.cleanHTMLTags(from: fullName) ?? ""
                
                DispatchQueue.main.async {
                    // Create contact with resolved name
                    let contact = Contact(name: ensName, ensName: ensName, address: address, avatarURL: nil, resolvedName: cleanName.isEmpty ? nil : cleanName)
                    self?.delegate?.didAddContact(contact)
                    self?.dismiss(animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    // Create contact without resolved name
                    let contact = Contact(name: ensName, ensName: ensName, address: address, avatarURL: nil, resolvedName: nil)
                    self?.delegate?.didAddContact(contact)
                    self?.dismiss(animated: true)
                }
            }
        }
        dataTasks.append(dataTask)
        dataTask.resume()
    }
    
    private func extractBaseDomain(from ensName: String) -> String {
        // Handle multi-chain format (name.eth:chain) or shortcut format (name:chain)
        let colonIndex = ensName.lastIndex(of: ":")
        if let colonIndex = colonIndex {
            let baseDomain = String(ensName[..<colonIndex])
            // If it's shortcut format, add .eth
            if !baseDomain.contains(".eth") {
                return baseDomain + ".eth"
            }
            return baseDomain
        }
        return ensName
    }
    
    private func cleanHTMLTags(from text: String) -> String {
        return text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func validateAndUpdateContact(ensName: String, originalContact: Contact, at indexPath: IndexPath) {
        // If ENS name changed, validate it
        if ensName != originalContact.ensName {
            // Check for duplicates when changing ENS name
            if isDuplicateContact(ensName) {
                hideLoadingState()
                showErrorAlert(message: "The ENS name '\(ensName)' is already in your contacts.")
                return
            }
            
            APICaller.shared.resolveENSName(name: ensName) { [weak self] resolvedAddress in
                DispatchQueue.main.async {
                    self?.hideLoadingState()
                    
                    if !resolvedAddress.isEmpty {
                        // ENS name is valid, now fetch the resolved name
                        self?.fetchResolvedNameForUpdate(for: ensName, address: resolvedAddress, originalContact: originalContact, at: indexPath)
                    } else {
                        // ENS name is invalid
                        self?.showErrorAlert(message: "Invalid ENS name: \(ensName)\n\nPlease check the ENS name and try again.")
                    }
                }
            }
        } else {
            // ENS name didn't change, just update the display name
            let updatedContact = Contact(name: ensName, ensName: ensName, address: originalContact.address, avatarURL: originalContact.avatarURL, resolvedName: originalContact.resolvedName)
            delegate?.didUpdateContact(updatedContact, at: indexPath)
            dismiss(animated: true)
        }
    }
    
    private func fetchResolvedNameForUpdate(for ensName: String, address: String, originalContact: Contact, at indexPath: IndexPath) {
        // Fetch the resolved name from ENS (same as My ENS Names does)
        let baseDomain = extractBaseDomain(from: ensName)
        let fusionServerURL = "https://api.fusionens.com/resolve/\(baseDomain):name?network=mainnet&source=ios-app"
        
        let dataTask = URLSession.shared.dataTask(with: URL(string: fusionServerURL)!) { [weak self] data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    // Update contact without resolved name
                    let updatedContact = Contact(name: ensName, ensName: ensName, address: address, avatarURL: originalContact.avatarURL, resolvedName: nil)
                    self?.delegate?.didUpdateContact(updatedContact, at: indexPath)
                    self?.dismiss(animated: true)
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let success = json?["success"] as? Bool,
                      success,
                      let dataDict = json?["data"] as? [String: Any],
                      let fullName = dataDict["address"] as? String,
                      !fullName.isEmpty else {
                    DispatchQueue.main.async {
                        // Update contact without resolved name
                        let updatedContact = Contact(name: ensName, ensName: ensName, address: address, avatarURL: originalContact.avatarURL, resolvedName: nil)
                        self?.delegate?.didUpdateContact(updatedContact, at: indexPath)
                        self?.dismiss(animated: true)
                    }
                    return
                }
                
                // Clean HTML tags if present
                let cleanName = self?.cleanHTMLTags(from: fullName) ?? ""
                
                DispatchQueue.main.async {
                    // Update contact with resolved name
                    let updatedContact = Contact(name: ensName, ensName: ensName, address: address, avatarURL: originalContact.avatarURL, resolvedName: cleanName.isEmpty ? nil : cleanName)
                    self?.delegate?.didUpdateContact(updatedContact, at: indexPath)
                    self?.dismiss(animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    // Update contact without resolved name
                    let updatedContact = Contact(name: ensName, ensName: ensName, address: address, avatarURL: originalContact.avatarURL, resolvedName: nil)
                    self?.delegate?.didUpdateContact(updatedContact, at: indexPath)
                    self?.dismiss(animated: true)
                }
            }
        }
        dataTasks.append(dataTask)
        dataTask.resume()
    }
    
    private func populateFieldsIfEditing() {
        guard let contactToEdit = contactToEdit else { return }
        
        // Update UI for editing mode
        titleLabel.text = "Edit Contact"
        addButton.setTitle("Update Contact", for: .normal)
        
        // Populate ENS name field (remove .eth suffix for editing)
        let ensNameWithoutSuffix = contactToEdit.ensName.replacingOccurrences(of: ".eth", with: "")
        ensNameTextField.text = ensNameWithoutSuffix
        
        // Update preview and button state
        textFieldDidChange()
    }
    
    // MARK: - Loading State
    private func showLoadingState() {
        addButton.isEnabled = false
        addButton.alpha = 0.6
        loadingIndicator.startAnimating()
        addButton.setTitle("", for: .normal)
    }
    
    private func hideLoadingState() {
        addButton.isEnabled = true
        addButton.alpha = 1.0
        loadingIndicator.stopAnimating()
        addButton.setTitle("Add Contact", for: .normal)
    }
    
    // MARK: - Validation
    private func isDuplicateContact(_ ensName: String) -> Bool {
        // Check if the ENS name already exists in Contacts
        if let data = UserDefaults(suiteName: "group.com.fusionens.keyboard")?.data(forKey: "savedContacts"),
           let savedContacts = try? JSONDecoder().decode([Contact].self, from: data) {
            return savedContacts.contains { $0.ensName.lowercased() == ensName.lowercased() }
        }
        return false
    }
    
    // MARK: - Error Handling
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AddContactViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == ensNameTextField {
            addButtonTapped()
        }
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AddContactViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Only dismiss when tapping outside the container view
        let location = touch.location(in: view)
        return !containerView.frame.contains(location)
    }
}


