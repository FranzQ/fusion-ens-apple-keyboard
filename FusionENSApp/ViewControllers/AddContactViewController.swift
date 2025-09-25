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
    private let modalView = UIView()
    private let handleView = UIView()
    
    private let titleLabel = UILabel()
    
    private let ensNameLabel = UILabel()
    
    private let ensNameTextField = UITextField()
    
    private let ensPreviewLabel = UILabel()
    
    private let addButton = UIButton(type: .system)
    
    
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
        
        // Add tap gesture to dismiss modal when tapping outside (after layout is complete)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        // Cancel all pending network requests
        dataTasks.forEach { $0.cancel() }
        dataTasks.removeAll()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Full screen background with better blur effect
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Tap gesture will be added in viewDidAppear after layout
        
        // Modal View - positioned to appear above keyboard
        modalView.backgroundColor = UIColor.systemBackground
        modalView.layer.cornerRadius = 16
        modalView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        modalView.layer.shadowColor = UIColor.black.cgColor
        modalView.layer.shadowOffset = CGSize(width: 0, height: -2)
        modalView.layer.shadowRadius = 10
        modalView.layer.shadowOpacity = 0.3
        view.addSubview(modalView)
        
        // Handle View for drag-to-dismiss
        handleView.backgroundColor = UIColor.systemGray4
        handleView.layer.cornerRadius = 2.5
        modalView.addSubview(handleView)
        
        // Title Label
        titleLabel.text = "Add Contact"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.label
        modalView.addSubview(titleLabel)
        
        // ENS Name Label
        ensNameLabel.text = "ENS Name"
        ensNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        ensNameLabel.textColor = UIColor.label
        modalView.addSubview(ensNameLabel)
        
        // ENS Name Text Field
        ensNameTextField.placeholder = "e.g. vitalik"
        ensNameTextField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        ensNameTextField.textColor = UIColor.label
        ensNameTextField.backgroundColor = UIColor.secondarySystemBackground
        ensNameTextField.layer.cornerRadius = 8
        ensNameTextField.layer.borderWidth = 1
        ensNameTextField.layer.borderColor = UIColor.separator.cgColor
        ensNameTextField.autocapitalizationType = .none
        ensNameTextField.autocorrectionType = .no
        ensNameTextField.keyboardType = .default
        ensNameTextField.returnKeyType = .done
        ensNameTextField.delegate = self
        
        // Add internal padding to text field
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        ensNameTextField.leftView = leftPaddingView
        ensNameTextField.rightView = rightPaddingView
        ensNameTextField.leftViewMode = .always
        ensNameTextField.rightViewMode = .always
        
        modalView.addSubview(ensNameTextField)
        
        // ENS Preview Label
        ensPreviewLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        ensPreviewLabel.textColor = UIColor.secondaryLabel
        ensPreviewLabel.textAlignment = .center
        ensPreviewLabel.text = ""
        modalView.addSubview(ensPreviewLabel)
        
        // Add Button
        addButton.setTitle("Add Contact", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        addButton.backgroundColor = UIColor.systemBlue
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 12
        addButton.isEnabled = false
        addButton.alpha = 0.6
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        modalView.addSubview(addButton)
        
        // Loading Indicator
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = UIColor.systemBlue
        modalView.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        modalView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        handleView.snp.makeConstraints { make in
            make.top.equalTo(modalView.snp.top).offset(8)
            make.centerX.equalTo(modalView)
            make.width.equalTo(36)
            make.height.equalTo(5)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(handleView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(modalView).inset(20)
        }
        
        ensNameLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(modalView).inset(20)
        }
        
        ensNameTextField.snp.makeConstraints { make in
            make.top.equalTo(ensNameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(modalView).inset(20)
            make.height.equalTo(44)
        }
        
        ensPreviewLabel.snp.makeConstraints { make in
            make.top.equalTo(ensNameTextField.snp.bottom).offset(8)
            make.leading.trailing.equalTo(modalView).inset(20)
        }
        
        addButton.snp.makeConstraints { make in
            make.top.equalTo(ensPreviewLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(modalView).inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(modalView.snp.bottom).offset(-20)
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
        
        guard let url = URL(string: fusionServerURL) else {
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else {
                // Still fetch avatar URL even if resolved name fetch fails
                self?.fetchAvatarURL(for: ensName, address: address, resolvedName: nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let success = json?["success"] as? Bool,
                      success,
                      let dataDict = json?["data"] as? [String: Any],
                      let fullName = dataDict["address"] as? String,
                      !fullName.isEmpty else {
                    // Still fetch avatar URL even without resolved name
                    self?.fetchAvatarURL(for: ensName, address: address, resolvedName: nil)
                    return
                }
                
                // Clean HTML tags if present
                let cleanName = self?.cleanHTMLTags(from: fullName) ?? ""
                
                // Now fetch the avatar URL as well
                self?.fetchAvatarURL(for: ensName, address: address, resolvedName: cleanName.isEmpty ? nil : cleanName)
            } catch {
                // Still fetch avatar URL even if resolved name fetch fails
                self?.fetchAvatarURL(for: ensName, address: address, resolvedName: nil)
            }
        }
        dataTasks.append(dataTask)
        dataTask.resume()
    }
    
    private func fetchAvatarURL(for ensName: String, address: String, resolvedName: String?) {
        // Use ENS metadata API with correct endpoint format
        let metadataURL = "https://metadata.ens.domains/mainnet/avatar/\(ensName)"
        
        guard let metadataURL = URL(string: metadataURL) else {
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: metadataURL) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    // No data received, create contact without avatar
                    let contact = Contact(name: ensName, ensName: ensName, address: address, avatarURL: nil, resolvedName: resolvedName)
                    self?.delegate?.didAddContact(contact)
                    self?.dismiss(animated: true)
                    return
                }
                
                // Check if the response is binary image data
                if let fullImage = UIImage(data: data) {
                    // The API returned the actual image, resize it to optimize performance
                    let resizedImage = self?.resizeImage(fullImage, to: CGSize(width: 200, height: 200))
                    
                    // Save resized image locally and use local URL
                    let localAvatarURL = self?.saveResizedImageLocally(resizedImage, for: ensName)
                    
                    let contact = Contact(name: ensName, ensName: ensName, address: address, avatarURL: localAvatarURL, resolvedName: resolvedName)
                    self?.delegate?.didAddContact(contact)
                    self?.dismiss(animated: true)
                    return
                }
                
                // Try to parse as text (avatar URL)
                guard let avatarURLString = String(data: data, encoding: .utf8),
                      !avatarURLString.isEmpty,
                      avatarURLString != "data:image/svg+xml;base64," else {
                    // No valid avatar data, create contact without avatar
                    let contact = Contact(name: ensName, ensName: ensName, address: address, avatarURL: nil, resolvedName: resolvedName)
                    self?.delegate?.didAddContact(contact)
                    self?.dismiss(animated: true)
                    return
                }
                
            
                // Check if the response is a JSON error message
                if avatarURLString.hasPrefix("{") && avatarURLString.contains("message") {
                    // No avatar URL found, create contact without avatar
                    let contact = Contact(name: ensName, ensName: ensName, address: address, avatarURL: nil, resolvedName: resolvedName)
                    self?.delegate?.didAddContact(contact)
                    self?.dismiss(animated: true)
                    return
                }
                
                // Clean HTML tags if present
                let cleanURLString = self?.cleanHTMLTags(from: avatarURLString) ?? ""
                
                // Check if it's a valid URL
                guard !cleanURLString.isEmpty,
                      let _ = URL(string: cleanURLString) else {
                    // Invalid avatar URL, create contact without avatar
                    let contact = Contact(name: ensName, ensName: ensName, address: address, avatarURL: nil, resolvedName: resolvedName)
                    self?.delegate?.didAddContact(contact)
                    self?.dismiss(animated: true)
                    return
                }
                
                // Create contact with all data (address, resolved name, and avatar URL)
                let contact = Contact(name: ensName, ensName: ensName, address: address, avatarURL: cleanURLString, resolvedName: resolvedName)
                self?.delegate?.didAddContact(contact)
                self?.dismiss(animated: true)
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
    
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    private func saveResizedImageLocally(_ image: UIImage?, for ensName: String) -> String? {
        guard let image = image else { return nil }
        
        // Create a unique filename for the ENS name
        let filename = "\(ensName.replacingOccurrences(of: ".", with: "_"))_avatar.jpg"
        
        // Get the Application Support directory (more persistent than Documents)
        guard let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // Create the directory if it doesn't exist
        do {
            try FileManager.default.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }
        
        let fileURL = appSupportDirectory.appendingPathComponent(filename)
        
        // Convert image to JPEG data with compression
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        // Save to disk
        do {
            try imageData.write(to: fileURL)
            // Return the file path (not file:// URL) for local files
            return fileURL.path
        } catch {
            return nil
        }
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
        
        guard let url = URL(string: fusionServerURL) else {
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
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
        // Add fallback to standard UserDefaults if App Group fails
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        
        // Check if the ENS name already exists in Contacts
        if let data = userDefaults.data(forKey: "savedContacts"),
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
        // Only dismiss when tapping outside the modal view
        let location = touch.location(in: view)
        let modalFrame = modalView.frame
        
        // If modal frame is not set yet, allow the gesture
        if modalFrame.isEmpty {
            return true
        }
        
        return !modalFrame.contains(location)
    }
}


