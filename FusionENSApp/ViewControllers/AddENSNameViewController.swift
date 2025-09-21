import UIKit
import SnapKit

protocol AddENSNameDelegate: AnyObject {
    func didAddENSName(_ ensName: ENSName)
}

class AddENSNameViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: AddENSNameDelegate?
    
    // MARK: - UI Elements
    private let modalView = UIView()
    private let handleView = UIView()
    private let titleLabel = UILabel()
    private let ensNameLabel = UILabel()
    private let ensNameTextField = UITextField()
    private let ensPreviewLabel = UILabel()
    private let saveButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ensNameTextField.becomeFirstResponder()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Full screen background with better blur effect
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Modal View - positioned to appear above keyboard
        modalView.backgroundColor = UIColor.systemBackground
        modalView.layer.cornerRadius = 16
        modalView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        modalView.layer.shadowColor = UIColor.black.cgColor
        modalView.layer.shadowOffset = CGSize(width: 0, height: -2)
        modalView.layer.shadowRadius = 10
        modalView.layer.shadowOpacity = 0.3
        view.addSubview(modalView)
        
        // Handle View
        handleView.backgroundColor = ColorTheme.secondaryText
        handleView.layer.cornerRadius = 2
        modalView.addSubview(handleView)
        
        // Title Label
        titleLabel.text = "Add ENS Name"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor.label
        titleLabel.textAlignment = .center
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
        
        // Add target for text changes to show .eth suffix
        ensNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Add padding to text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 44))
        ensNameTextField.leftView = paddingView
        ensNameTextField.leftViewMode = .always
        ensNameTextField.rightView = paddingView
        ensNameTextField.rightViewMode = .always
        
        modalView.addSubview(ensNameTextField)
        
        // ENS Preview Label
        ensPreviewLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        ensPreviewLabel.textColor = UIColor.secondaryLabel
        ensPreviewLabel.text = ""
        modalView.addSubview(ensPreviewLabel)
        
        // Save Button
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        saveButton.backgroundColor = ColorTheme.accent
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        modalView.addSubview(saveButton)
        
        // Add tap gesture to dismiss modal
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        modalView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(320)
        }
        
        handleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(36)
            make.height.equalTo(4)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(handleView.snp.bottom).offset(20)
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
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(ensPreviewLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
    }
    
    // MARK: - Actions
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        guard let inputText = ensNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            ensPreviewLabel.text = ""
            return
        }
        
        if inputText.isEmpty {
            ensPreviewLabel.text = ""
        } else {
            // Show the full ENS name with .eth suffix
            let fullENSName = inputText.hasSuffix(".eth") ? inputText : inputText + ".eth"
            ensPreviewLabel.text = "Will save as: \(fullENSName)"
        }
    }
    
    @objc private func saveButtonTapped() {
        guard let inputText = ensNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !inputText.isEmpty else {
            showAlert(title: "Error", message: "Please enter an ENS name")
            return
        }
        
        // Automatically append .eth if not already present
        let ensName = inputText.hasSuffix(".eth") ? inputText : inputText + ".eth"
        
        // Validate ENS name format
        if !isValidENSName(ensName) {
            showAlert(title: "Invalid ENS Name", message: "Please enter a valid ENS name (e.g., vitalik)")
            return
        }
        
        // Show loading state
        showLoadingState()
        
        // Resolve ENS name to get the actual address
        resolveENSName(ensName) { [weak self] resolvedAddress in
            DispatchQueue.main.async {
                self?.hideLoadingState()
                
                if let address = resolvedAddress, !address.isEmpty {
                    // ENS name resolved successfully
                    let newENSName = ENSName(name: ensName, address: address, dateAdded: Date())
                    
                    // Load full name asynchronously
                    self?.loadFullName(for: newENSName) { fullName in
                        DispatchQueue.main.async {
                            var updatedENSName = newENSName
                            updatedENSName.fullName = fullName
                            self?.delegate?.didAddENSName(updatedENSName)
                        }
                    }
                    
                    self?.dismiss(animated: true)
                } else {
                    // ENS name could not be resolved
                    self?.showAlert(title: "ENS Name Not Found", message: "The ENS name '\(ensName)' could not be resolved. Please check the name and try again.")
                }
            }
        }
    }
    
    // MARK: - Validation
    private func isValidENSName(_ name: String) -> Bool {
        // Enhanced ENS name validation supporting subdomains
        // Supports: jessie.base.eth, uni.eth, name.eth:chain, etc.
        let ensPattern = "^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](\\.[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9])*(\\.eth)?(:[a-zA-Z0-9]+)?$"
        let regex = try? NSRegularExpression(pattern: ensPattern)
        let range = NSRange(location: 0, length: name.utf16.count)
        return regex?.firstMatch(in: name, options: [], range: range) != nil
    }
    
    // MARK: - ENS Resolution
    private func resolveENSName(_ name: String, completion: @escaping (String?) -> Void) {
        // Use the same API caller as the keyboard extension
        APICaller.shared.resolveENSName(name: name) { resolvedAddress in
            if !resolvedAddress.isEmpty {
                completion(resolvedAddress)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - Loading State
    private func showLoadingState() {
        saveButton.setTitle("Resolving...", for: .normal)
        saveButton.isEnabled = false
        saveButton.alpha = 0.7
        
        // Add loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        activityIndicator.tag = 999 // For easy removal
        
        saveButton.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func hideLoadingState() {
        saveButton.setTitle("Save", for: .normal)
        saveButton.isEnabled = true
        saveButton.alpha = 1.0
        
        // Remove loading indicator
        if let activityIndicator = saveButton.viewWithTag(999) {
            activityIndicator.removeFromSuperview()
        }
    }
    
    // MARK: - Full Name Loading
    private func loadFullName(for ensName: ENSName, completion: @escaping (String?) -> Void) {
        let baseDomain = extractBaseDomain(from: ensName.name)
        let fusionServerURL = "https://api.fusionens.com/resolve/\(baseDomain):name?network=mainnet&source=ios-app"
        
        URLSession.shared.dataTask(with: URL(string: fusionServerURL)!) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let success = json?["success"] as? Bool,
                      success,
                      let dataDict = json?["data"] as? [String: Any],
                      let fullName = dataDict["address"] as? String,
                      !fullName.isEmpty else {
                    completion(nil)
                    return
                }
                
                // Clean HTML tags if present
                let cleanName = self.cleanHTMLTags(from: fullName)
                completion(cleanName.isEmpty ? nil : cleanName)
            } catch {
                completion(nil)
            }
        }.resume()
    }
    
    private func extractBaseDomain(from ensName: String) -> String {
        // Handle new format like vitalik.eth:btc
        if ensName.contains(":") {
            let parts = ensName.components(separatedBy: ":")
            if parts.count == 2 {
                return parts[0]
            }
        }
        
        // Handle shortcut format like vitalik:btc
        if ensName.contains(":") && !ensName.contains(".eth") {
            let parts = ensName.components(separatedBy: ":")
            if parts.count == 2 {
                return parts[0] + ".eth"
            }
        }
        
        // Return as is for standard .eth domains
        return ensName
    }
    
    private func cleanHTMLTags(from htmlString: String) -> String {
        // Remove HTML tags and decode HTML entities
        let cleanString = htmlString
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If the result is empty or contains only HTML artifacts, return empty string
        if cleanString.isEmpty || cleanString.contains("DOCTYPE") || cleanString.contains("html") {
            return ""
        }
        
        return cleanString
    }
    
    // MARK: - Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AddENSNameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        saveButtonTapped()
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AddENSNameViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == view
    }
}