import UIKit
import SnapKit

protocol AddENSNameDelegate: AnyObject {
    func didAddENSName(_ ensName: ENSName)
}

class AddENSNameViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: AddENSNameDelegate?
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let ensNameTextField = UITextField()
    private let displayNameTextField = UITextField()
    private let descriptionLabel = UILabel()
    private let addButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Scroll View
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Title Label
        titleLabel.text = "Add ENS Name"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        // ENS Name Text Field
        ensNameTextField.placeholder = "Enter ENS name (e.g., vitalik.eth)"
        ensNameTextField.borderStyle = .roundedRect
        ensNameTextField.autocapitalizationType = .none
        ensNameTextField.autocorrectionType = .no
        ensNameTextField.keyboardType = .default
        ensNameTextField.returnKeyType = .next
        ensNameTextField.delegate = self
        contentView.addSubview(ensNameTextField)
        
        // Display Name Text Field
        displayNameTextField.placeholder = "Display name (optional)"
        displayNameTextField.borderStyle = .roundedRect
        displayNameTextField.autocapitalizationType = .words
        displayNameTextField.autocorrectionType = .yes
        displayNameTextField.returnKeyType = .done
        displayNameTextField.delegate = self
        contentView.addSubview(displayNameTextField)
        
        // Description Label
        descriptionLabel.text = "Add ENS names to quickly generate payment requests. You can use any ENS name like 'vitalik.eth' or multi-chain formats like 'vitalik.eth:btc'."
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        contentView.addSubview(descriptionLabel)
        
        // Add Button
        addButton.setTitle("Add ENS Name", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        addButton.backgroundColor = .systemBlue
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 8
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        contentView.addSubview(addButton)
        
        // Layout
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
        
        ensNameTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        displayNameTextField.snp.makeConstraints { make in
            make.top.equalTo(ensNameTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(displayNameTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        addButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Add ENS Name"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func addButtonTapped() {
        guard let ensName = ensNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !ensName.isEmpty else {
            showAlert(title: "Error", message: "Please enter an ENS name")
            return
        }
        
        // Validate ENS name format
        if !isValidENSName(ensName) {
            showAlert(title: "Invalid ENS Name", message: "Please enter a valid ENS name (e.g., vitalik.eth)")
            return
        }
        
        let displayName = displayNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let newENSName = ENSName(name: ensName, displayName: displayName, dateAdded: Date())
        
        delegate?.didAddENSName(newENSName)
        dismiss(animated: true)
    }
    
    // MARK: - Validation
    private func isValidENSName(_ name: String) -> Bool {
        // Basic ENS name validation
        let ensPattern = "^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](\\.eth)?(:[a-zA-Z0-9]+)?$"
        let regex = try? NSRegularExpression(pattern: ensPattern)
        let range = NSRange(location: 0, length: name.utf16.count)
        return regex?.firstMatch(in: name, options: [], range: range) != nil
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
        if textField == ensNameTextField {
            displayNameTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            addButtonTapped()
        }
        return true
    }
}
