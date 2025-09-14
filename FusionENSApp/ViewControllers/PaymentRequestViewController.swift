import UIKit
import SnapKit

class PaymentRequestViewController: UIViewController {
    
    // MARK: - Properties
    private let ensName: ENSName
    private var selectedChain: PaymentChain = .bitcoin
    private var amount: String = ""
    private var resolvedAddress: String = ""
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let ensNameLabel = UILabel()
    private let amountTextField = UITextField()
    private let chainButton = UIButton(type: .system)
    private let generateButton = UIButton(type: .system)
    private let qrCodeImageView = UIImageView()
    private let addressLabel = UILabel()
    private let copyButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    
    // MARK: - Initialization
    init(ensName: ENSName) {
        self.ensName = ensName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupInitialState()
        checkAvailableChains()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Scroll View
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Title Label
        titleLabel.text = "Payment Request"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        // ENS Name Label
        ensNameLabel.text = ensName.name
        ensNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        ensNameLabel.textColor = .systemBlue
        ensNameLabel.textAlignment = .center
        ensNameLabel.numberOfLines = 0
        contentView.addSubview(ensNameLabel)
        
        // Amount Text Field
        amountTextField.placeholder = "Enter amount (e.g., 0.01)"
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .decimalPad
        amountTextField.delegate = self
        contentView.addSubview(amountTextField)
        
        // Chain Selection Button
        chainButton.setTitle("Select Chain: \(selectedChain.displayName)", for: .normal)
        chainButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        chainButton.backgroundColor = .systemGray6
        chainButton.setTitleColor(.label, for: .normal)
        chainButton.layer.cornerRadius = 8
        chainButton.layer.borderWidth = 1
        chainButton.layer.borderColor = UIColor.systemGray4.cgColor
        chainButton.addTarget(self, action: #selector(chainButtonTapped), for: .touchUpInside)
        contentView.addSubview(chainButton)
        
        // Generate Button
        generateButton.setTitle("Generate Payment Request", for: .normal)
        generateButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        generateButton.backgroundColor = .systemBlue
        generateButton.setTitleColor(.white, for: .normal)
        generateButton.layer.cornerRadius = 8
        generateButton.addTarget(self, action: #selector(generateButtonTapped), for: .touchUpInside)
        contentView.addSubview(generateButton)
        
        // QR Code Image View
        qrCodeImageView.contentMode = .scaleAspectFit
        qrCodeImageView.backgroundColor = .systemGray6
        qrCodeImageView.layer.cornerRadius = 8
        qrCodeImageView.isHidden = true
        contentView.addSubview(qrCodeImageView)
        
        // Address Label
        addressLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        addressLabel.textColor = .secondaryLabel
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center
        addressLabel.isHidden = true
        contentView.addSubview(addressLabel)
        
        // Copy Button
        copyButton.setTitle("Copy Address", for: .normal)
        copyButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        copyButton.setTitleColor(.systemBlue, for: .normal)
        copyButton.layer.borderColor = UIColor.systemBlue.cgColor
        copyButton.layer.borderWidth = 1
        copyButton.layer.cornerRadius = 6
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        copyButton.isHidden = true
        contentView.addSubview(copyButton)
        
        // Share Button
        shareButton.setTitle("Share QR Code", for: .normal)
        shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        shareButton.setTitleColor(.systemBlue, for: .normal)
        shareButton.layer.borderColor = UIColor.systemBlue.cgColor
        shareButton.layer.borderWidth = 1
        shareButton.layer.cornerRadius = 6
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        shareButton.isHidden = true
        contentView.addSubview(shareButton)
        
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
        
        ensNameLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(ensNameLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        chainButton.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        generateButton.snp.makeConstraints { make in
            make.top.equalTo(chainButton.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        qrCodeImageView.snp.makeConstraints { make in
            make.top.equalTo(generateButton.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(200)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(qrCodeImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        copyButton.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(20)
            make.width.equalTo(120)
            make.height.equalTo(36)
        }
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(120)
            make.height.equalTo(36)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Payment Request"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }
    
    private func setupInitialState() {
        // Hide QR code and related elements initially
        qrCodeImageView.isHidden = true
        addressLabel.isHidden = true
        copyButton.isHidden = true
        shareButton.isHidden = true
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
    
    @objc private func chainButtonTapped() {
        showChainSelectionAlert()
    }
    
    private func showChainSelectionAlert() {
        let alert = UIAlertController(title: "Select Blockchain", message: "Choose which blockchain to generate a payment request for:", preferredStyle: .actionSheet)
        
        for chain in PaymentChain.allCases {
            alert.addAction(UIAlertAction(title: chain.displayName, style: .default) { _ in
                self.selectedChain = chain
                self.chainButton.setTitle("Select Chain: \(chain.displayName)", for: .normal)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = chainButton
            popover.sourceRect = chainButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    @objc private func generateButtonTapped() {
        guard let amountText = amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !amountText.isEmpty,
              let amountValue = Double(amountText),
              amountValue > 0 else {
            showAlert(title: "Error", message: "Please enter a valid amount")
            return
        }
        
        amount = amountText
        generatePaymentRequest()
    }
    
    @objc private func copyButtonTapped() {
        UIPasteboard.general.string = resolvedAddress
        showAlert(title: "Copied", message: "Address copied to clipboard")
    }
    
    @objc private func shareButtonTapped() {
        guard let qrImage = qrCodeImageView.image else { return }
        
        let activityVC = UIActivityViewController(activityItems: [qrImage], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
        }
        present(activityVC, animated: true)
    }
    
    // MARK: - Payment Request Generation
    private func generatePaymentRequest() {
        // Show loading state
        generateButton.setTitle("Resolving ENS...", for: .normal)
        generateButton.isEnabled = false
        
        // Resolve ENS name to address
        resolveENSName { [weak self] address in
            DispatchQueue.main.async {
                self?.generateButton.setTitle("Generate Payment Request", for: .normal)
                self?.generateButton.isEnabled = true
                
                if let address = address {
                    self?.resolvedAddress = address
                    self?.createPaymentRequest()
                } else {
                    let chainName = self?.selectedChain.displayName.lowercased() ?? "crypto"
                    let ensName = self?.ensName.name ?? ""
                    self?.showMissingAddressAlert(ensName: ensName, chainName: chainName)
                }
            }
        }
    }
    
    private func resolveENSName(completion: @escaping (String?) -> Void) {
        // Create the full ENS name with chain suffix for multi-chain resolution
        let fullENSName: String
        if selectedChain == .ethereum {
            // For Ethereum, use the original name
            fullENSName = ensName.name
        } else {
            // For other chains, add the chain suffix
            fullENSName = "\(ensName.name):\(selectedChain.symbol.lowercased())"
        }
        
        // Use the same API caller as the keyboard extension
        APICaller.shared.resolveENSName(name: fullENSName) { resolvedAddress in
            if !resolvedAddress.isEmpty {
                completion(resolvedAddress)
            } else {
                completion(nil)
            }
        }
    }
    
    private func createPaymentRequest() {
        let paymentURL = createPaymentURL()
        generateQRCode(from: paymentURL)
        addressLabel.text = "Payment Address:\n\(resolvedAddress)"
        
        // Show QR code and related elements
        qrCodeImageView.isHidden = false
        addressLabel.isHidden = false
        copyButton.isHidden = false
        shareButton.isHidden = false
    }
    
    private func createPaymentURL() -> String {
        switch selectedChain {
        case .bitcoin:
            return "bitcoin:\(resolvedAddress)?amount=\(amount)"
        case .ethereum:
            return "ethereum:\(resolvedAddress)@1?value=\(amount)e18"
        case .solana:
            return "solana:\(resolvedAddress)?amount=\(amount)"
        case .dogecoin:
            return "dogecoin:\(resolvedAddress)?amount=\(amount)"
        case .xrp:
            return "xrp:\(resolvedAddress)?amount=\(amount)"
        case .litecoin:
            return "litecoin:\(resolvedAddress)?amount=\(amount)"
        case .cardano:
            return "cardano:\(resolvedAddress)?amount=\(amount)"
        case .polygon:
            return "ethereum:\(resolvedAddress)@137?value=\(amount)e18"
        case .avalanche:
            return "ethereum:\(resolvedAddress)@43114?value=\(amount)e18"
        case .bsc:
            return "ethereum:\(resolvedAddress)@56?value=\(amount)e18"
        case .arbitrum:
            return "ethereum:\(resolvedAddress)@42161?value=\(amount)e18"
        case .optimism:
            return "ethereum:\(resolvedAddress)@10?value=\(amount)e18"
        case .base:
            return "ethereum:\(resolvedAddress)@8453?value=\(amount)e18"
        }
    }
    
    private func generateQRCode(from string: String) {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let context = CIContext()
                if let cgImage = context.createCGImage(output, from: output.extent) {
                    qrCodeImageView.image = UIImage(cgImage: cgImage)
                }
            }
        }
    }
    
    // MARK: - Available Chains Check
    private func checkAvailableChains() {
        // Add a subtle indicator to show which chains are available
        // This could be enhanced with visual indicators on the segmented control
        let availableChains = PaymentChain.allCases
        print("Available chains for \(ensName.name): \(availableChains.map { $0.displayName })")
        
        // You could add visual indicators here, like:
        // - Gray out unavailable chains
        // - Add checkmarks to available chains
        // - Show a small info icon with available chains
    }
    
    // MARK: - Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showMissingAddressAlert(ensName: String, chainName: String) {
        let alert = UIAlertController(
            title: "No \(chainName.capitalized) Address Found",
            message: "The ENS name '\(ensName)' doesn't have a \(chainName) address configured. You can add one using the ENS app.",
            preferredStyle: .alert
        )
        
        // Add ENS App button
        alert.addAction(UIAlertAction(title: "Add \(chainName.capitalized) Address", style: .default) { _ in
            self.openENSApp(for: ensName)
        })
        
        // Add Try Different Chain button
        alert.addAction(UIAlertAction(title: "Try Different Chain", style: .default))
        
        // Add Cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func openENSApp(for ensName: String) {
        // Extract base domain for ENS app
        let baseDomain = extractBaseDomain(from: ensName)
        
        // Create URL for ENS app
        let ensAppURL = "https://app.ens.domains/name/\(baseDomain)"
        
        if let url = URL(string: ensAppURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if success {
                        print("Successfully opened ENS app for \(baseDomain)")
                    } else {
                        print("Failed to open ENS app")
                    }
                }
            } else {
                // Fallback: show alert with instructions
                showENSAppInstructions(for: baseDomain)
            }
        }
    }
    
    private func showENSAppInstructions(for ensName: String) {
        let alert = UIAlertController(
            title: "Open ENS App",
            message: "To add a \(selectedChain.displayName.lowercased()) address for '\(ensName)', please visit:\n\napp.ens.domains/name/\(ensName)\n\nIn your browser and add the address in the 'Records' section.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Copy Link", style: .default) { _ in
            UIPasteboard.general.string = "https://app.ens.domains/name/\(ensName)"
            self.showAlert(title: "Link Copied", message: "The ENS app link has been copied to your clipboard.")
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
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
}

// MARK: - UITextFieldDelegate
extension PaymentRequestViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - PaymentChain Enum
enum PaymentChain: CaseIterable {
    case bitcoin
    case ethereum
    case solana
    case dogecoin
    case xrp
    case litecoin
    case cardano
    case polygon
    case avalanche
    case bsc
    case arbitrum
    case optimism
    case base
    
    var displayName: String {
        switch self {
        case .bitcoin: return "Bitcoin"
        case .ethereum: return "Ethereum"
        case .solana: return "Solana"
        case .dogecoin: return "Dogecoin"
        case .xrp: return "XRP"
        case .litecoin: return "Litecoin"
        case .cardano: return "Cardano"
        case .polygon: return "Polygon"
        case .avalanche: return "Avalanche"
        case .bsc: return "BSC"
        case .arbitrum: return "Arbitrum"
        case .optimism: return "Optimism"
        case .base: return "Base"
        }
    }
    
    var symbol: String {
        switch self {
        case .bitcoin: return "BTC"
        case .ethereum: return "ETH"
        case .solana: return "SOL"
        case .dogecoin: return "DOGE"
        case .xrp: return "XRP"
        case .litecoin: return "LTC"
        case .cardano: return "ADA"
        case .polygon: return "POLYGON"
        case .avalanche: return "AVAX"
        case .bsc: return "BSC"
        case .arbitrum: return "ARBI"
        case .optimism: return "OP"
        case .base: return "BASE"
        }
    }
}
