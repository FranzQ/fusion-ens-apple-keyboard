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
}

class AddContactViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: AddContactViewControllerDelegate?
    
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
        label.text = "Add New Contact"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor.label
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Contact Name"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        return textField
    }()
    
    private let ensNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "ENS Name (e.g., vitalik.eth)"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
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
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(UIColor.systemGray, for: .normal)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(nameTextField)
        containerView.addSubview(ensNameTextField)
        containerView.addSubview(addButton)
        containerView.addSubview(cancelButton)
        containerView.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(320)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        
        ensNameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        
        addButton.snp.makeConstraints { make in
            make.top.equalTo(ensNameTextField.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(addButton)
        }
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextFieldObservers() {
        nameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        ensNameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let ensName = ensNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty,
              !ensName.isEmpty else {
            return
        }
        
        // Show loading state
        showLoadingState()
        
        // Validate ENS name
        validateAndAddContact(name: name, ensName: ensName)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func textFieldChanged() {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let ensName = ensNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let isValid = !name.isEmpty && !ensName.isEmpty
        addButton.isEnabled = isValid
        addButton.alpha = isValid ? 1.0 : 0.6
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Validation and Adding
    private func validateAndAddContact(name: String, ensName: String) {
        // Validate ENS name using APICaller
        APICaller.shared.resolveENSName(name: ensName) { [weak self] resolvedAddress in
            DispatchQueue.main.async {
                self?.hideLoadingState()
                
                if !resolvedAddress.isEmpty {
                    // ENS name is valid, add the contact
                    let contact = Contact(name: name, ensName: ensName, address: resolvedAddress, avatarURL: nil)
                    self?.delegate?.didAddContact(contact)
                    self?.dismiss(animated: true)
                } else {
                    // ENS name is invalid
                    self?.showErrorAlert(message: "Invalid ENS name: \(ensName)\n\nPlease check the ENS name and try again.")
                }
            }
        }
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
    
    // MARK: - Error Handling
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

