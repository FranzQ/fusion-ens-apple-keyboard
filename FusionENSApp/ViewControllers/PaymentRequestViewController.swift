import UIKit
import SnapKit
import Alamofire

class PaymentRequestViewController: UIViewController {
    
    // MARK: - Properties
    private var ensName: ENSName
    private var selectedChain: PaymentChain = .ethereum
    private var amount: String = ""
    private var resolvedAddress: String = ""
    private var isUSDInput: Bool = true
    private var cryptoPrices: [String: Double] = [:]
    private var usdAmount: Double = 0.0
    private var cryptoAmount: Double = 0.0
    private var fullName: String = ""
    private var avatarURL: String? = nil
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let ensCardView = UIView()
    private let globeIconImageView = UIImageView()
    private let ensNameLabel = UILabel()
    private let fullNameLabel = UILabel()
    private let ensAddressLabel = UILabel()
    private let avatarImageView = UIImageView()
    
    // Amount Section
    private let amountContainerView = UIView()
    private let amountLabel = UILabel()
    private let amountTextField = UITextField()
    private let currencyToggleButton = UIButton(type: .system)
    private let conversionLabel = UILabel()
    
    // Cryptocurrency Section
    private let cryptoContainerView = UIView()
    private let cryptoLabel = UILabel()
    private let chainButton = UIButton(type: .system)
    private let chevronImageView = UIImageView()
    private let cryptoIconImageView = UIImageView()
    
    // Generate Button
    private let generateButton = UIButton(type: .system)
    private let qrIconImageView = UIImageView()
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
        view.backgroundColor = ColorTheme.primaryBackground
        
        // Scroll View
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Title Label
        titleLabel.text = "Make a Request"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = ColorTheme.primaryText
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        // ENS Card View
        ensCardView.backgroundColor = ColorTheme.cardBackground
        ensCardView.layer.cornerRadius = 12
        ensCardView.layer.borderWidth = 1
        ensCardView.layer.borderColor = ColorTheme.border.cgColor
        contentView.addSubview(ensCardView)
        
        // Default ENS Icon (same as bottom menu)
        globeIconImageView.image = UIImage(systemName: "person.crop.rectangle")
        globeIconImageView.tintColor = .white
        globeIconImageView.contentMode = .scaleAspectFit
        globeIconImageView.backgroundColor = ColorTheme.accent
        globeIconImageView.layer.cornerRadius = 8
        ensCardView.addSubview(globeIconImageView)
        
        // ENS Name Label
        ensNameLabel.text = ensName.name
        ensNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        ensNameLabel.textColor = UIColor.label
        ensNameLabel.numberOfLines = 1
        ensCardView.addSubview(ensNameLabel)
        
        // Full Name Label
        fullNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        fullNameLabel.textColor = UIColor.secondaryLabel
        fullNameLabel.numberOfLines = 1
        ensCardView.addSubview(fullNameLabel)
        
        // Address Label
        ensAddressLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        ensAddressLabel.textColor = UIColor.secondaryLabel
        ensAddressLabel.numberOfLines = 1
        ensCardView.addSubview(ensAddressLabel)
        
        // Avatar Image View (hidden by default, shown when avatar loads)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        avatarImageView.isHidden = true
        ensCardView.addSubview(avatarImageView)
        
        // Add tap gesture to ENS card
        let ensCardTapGesture = UITapGestureRecognizer(target: self, action: #selector(ensCardTapped))
        ensCardView.addGestureRecognizer(ensCardTapGesture)
        ensCardView.isUserInteractionEnabled = true
        
        // Amount Container
        amountContainerView.backgroundColor = ColorTheme.searchBarBackground
        amountContainerView.layer.cornerRadius = 8
        amountContainerView.layer.borderWidth = 1
        amountContainerView.layer.borderColor = ColorTheme.border.cgColor
        contentView.addSubview(amountContainerView)
        
        // Amount Text Field
        amountTextField.placeholder = "0.00"
        amountTextField.borderStyle = .none
        amountTextField.keyboardType = .decimalPad
        amountTextField.delegate = self
        amountTextField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        amountTextField.textColor = ColorTheme.primaryText
        amountContainerView.addSubview(amountTextField)
        
        // Currency Toggle Button
        currencyToggleButton.setTitle("USD", for: .normal)
        currencyToggleButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        currencyToggleButton.setTitleColor(.white, for: .normal)
        currencyToggleButton.backgroundColor = ColorTheme.accent
        currencyToggleButton.layer.cornerRadius = 6
        currencyToggleButton.addTarget(self, action: #selector(currencyToggleTapped), for: .touchUpInside)
        amountContainerView.addSubview(currencyToggleButton)
        
        // Conversion Label
        conversionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        conversionLabel.textColor = ColorTheme.secondaryText
        conversionLabel.textAlignment = .center
        conversionLabel.numberOfLines = 0
        contentView.addSubview(conversionLabel)
        
        // Crypto Container
        cryptoContainerView.backgroundColor = ColorTheme.searchBarBackground
        cryptoContainerView.layer.cornerRadius = 8
        cryptoContainerView.layer.borderWidth = 1
        cryptoContainerView.layer.borderColor = ColorTheme.border.cgColor
        contentView.addSubview(cryptoContainerView)
        
        // Crypto Icon
        cryptoIconImageView.contentMode = .scaleAspectFit
        cryptoIconImageView.image = selectedChain.systemIcon
        cryptoIconImageView.tintColor = .white
        cryptoContainerView.addSubview(cryptoIconImageView)
        
        // Chain Selection Button
        chainButton.setTitle("\(selectedChain.displayName)", for: .normal)
        chainButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        chainButton.setTitleColor(ColorTheme.primaryText, for: .normal)
        chainButton.contentHorizontalAlignment = .left
        chainButton.addTarget(self, action: #selector(chainButtonTapped), for: .touchUpInside)
        cryptoContainerView.addSubview(chainButton)
        
        // Chevron Image
        chevronImageView.image = UIImage(systemName: "chevron.up.chevron.down")
        chevronImageView.tintColor = ColorTheme.secondaryText
        chevronImageView.contentMode = .scaleAspectFit
        cryptoContainerView.addSubview(chevronImageView)
        
        // Generate Button
        generateButton.setTitle("Generate QR", for: .normal)
        generateButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        generateButton.backgroundColor = ColorTheme.accent
        generateButton.setTitleColor(.white, for: .normal)
        generateButton.layer.cornerRadius = 8
        generateButton.addTarget(self, action: #selector(generateButtonTapped), for: .touchUpInside)
        contentView.addSubview(generateButton)
        
        // QR Icon
        qrIconImageView.image = UIImage(systemName: "qrcode")
        qrIconImageView.tintColor = .white
        qrIconImageView.contentMode = .scaleAspectFit
        generateButton.addSubview(qrIconImageView)
        
        // QR Code Image View
        qrCodeImageView.contentMode = .scaleAspectFit
        qrCodeImageView.backgroundColor = ColorTheme.searchBarBackground
        qrCodeImageView.layer.cornerRadius = 8
        qrCodeImageView.isHidden = true
        contentView.addSubview(qrCodeImageView)
        
        // Address Label
        addressLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        addressLabel.textColor = ColorTheme.secondaryText
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center
        addressLabel.isHidden = true
        contentView.addSubview(addressLabel)
        
        // Copy Button
        copyButton.setTitle("Copy Address", for: .normal)
        copyButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        copyButton.setTitleColor(ColorTheme.accent, for: .normal)
        copyButton.layer.borderColor = ColorTheme.accent.cgColor
        copyButton.layer.borderWidth = 1
        copyButton.layer.cornerRadius = 6
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        copyButton.isHidden = true
        contentView.addSubview(copyButton)
        
        // Share Button
        shareButton.setTitle("Share QR Code", for: .normal)
        shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        shareButton.setTitleColor(ColorTheme.accent, for: .normal)
        shareButton.layer.borderColor = ColorTheme.accent.cgColor
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
        
        // ENS Card View
        ensCardView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        // Globe Icon (hidden when avatar is shown)
        globeIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        // Avatar Image View (moved to left side)
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        // ENS Name Label
        ensNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        // Full Name Label
        fullNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(ensNameLabel)
            make.top.equalTo(ensNameLabel.snp.bottom).offset(4)
            make.trailing.equalTo(ensNameLabel)
        }
        
        // Address Label
        ensAddressLabel.snp.makeConstraints { make in
            make.leading.equalTo(ensNameLabel)
            make.top.equalTo(fullNameLabel.snp.bottom).offset(4)
            make.trailing.equalTo(ensNameLabel)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        // Crypto Container
        cryptoContainerView.snp.makeConstraints { make in
            make.top.equalTo(ensCardView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // Amount Container
        amountContainerView.snp.makeConstraints { make in
            make.top.equalTo(cryptoContainerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // Amount Text Field
        amountTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(currencyToggleButton.snp.leading).offset(-8)
        }
        
        // Currency Toggle Button
        currencyToggleButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(28)
        }
        
        // Conversion Label
        conversionLabel.snp.makeConstraints { make in
            make.top.equalTo(amountContainerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Crypto Icon
        cryptoIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        // Chain Button
        chainButton.snp.makeConstraints { make in
            make.leading.equalTo(cryptoIconImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
        }
        
        // Chevron
        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        generateButton.snp.makeConstraints { make in
            make.top.equalTo(conversionLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        // QR Icon
        qrIconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
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
    }
    
    private func setupInitialState() {
        // Hide QR code and related elements initially
        qrCodeImageView.isHidden = true
        copyButton.isHidden = true
        shareButton.isHidden = true
        
        // Set initial avatar state
        avatarImageView.isHidden = true
        globeIconImageView.isHidden = false
        
        // Set initial ENS display
        ensNameLabel.text = ensName.name
        fullNameLabel.text = ensName.fullName ?? ensName.name // Use existing fullName or show ENS name
        
        // Truncate address consistently
        if !ensName.address.isEmpty {
            let truncatedAddress = "\(ensName.address.prefix(6))...\(ensName.address.suffix(4))"
            ensAddressLabel.text = truncatedAddress
        } else {
            ensAddressLabel.text = ensName.address
        }
        
        // Load crypto prices
        loadCryptoPrices()
        
        // Set initial conversion display
        updateConversionDisplay()
        
        // Load ENS details
        loadENSDetails()
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    
    @objc private func ensCardTapped() {
        // Same action as tapping ENS name - could open ENS profile or copy address
        copyENSAddress()
    }
    
    @objc private func currencyToggleTapped() {
        isUSDInput.toggle()
        updateCurrencyToggle()
        updateConversionDisplay()
    }
    
    @objc private func chainButtonTapped() {
        showChainSelectionAlert()
    }
    
    private func showChainSelectionAlert() {
        let alert = UIAlertController(title: "Select Blockchain", message: "Choose which blockchain to generate a payment request for:", preferredStyle: .actionSheet)
        
        for chain in PaymentChain.allCases {
            alert.addAction(UIAlertAction(title: chain.displayName, style: .default) { _ in
                self.selectedChain = chain
                self.chainButton.setTitle(chain.displayName, for: .normal)
                self.cryptoIconImageView.image = chain.systemIcon
                self.cryptoIconImageView.tintColor = .white
                self.updateConversionDisplay()
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
        
        // Use the appropriate amount based on input type
        if isUSDInput {
            amount = String(cryptoAmount)
        } else {
            amount = amountText
        }
        
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
                guard let self = self else { return }
                self.generateButton.setTitle("Generate Payment Request", for: .normal)
                self.generateButton.isEnabled = true
                
                if let address = address {
                    self.resolvedAddress = address
                    self.updateENSAddressDisplay(address: address)
                    self.createPaymentRequest()
                } else {
                    let chainName = self.selectedChain.displayName.lowercased()
                    let ensName = self.ensName.name
                    self.showMissingAddressAlert(ensName: ensName, chainName: chainName)
                }
            }
        }
    }
    
    private func resolveENSName(completion: @escaping (String?) -> Void) {
        // For Ethereum, use standard ENS resolution (same as "My ENS Names" and keyboards)
        if selectedChain == .ethereum {
            APICaller.shared.resolveENSName(name: ensName.name) { resolvedAddress in
                DispatchQueue.main.async {
                    if !resolvedAddress.isEmpty {
                        completion(resolvedAddress)
                    } else {
                        let chainName = self.selectedChain.displayName
                        let ensName = self.ensName.name
                        self.showMissingAddressAlert(ensName: ensName, chainName: chainName)
                        completion(nil)
                    }
                }
            }
            return
        }
        
        // For other chains, use multi-chain resolution
        let baseDomain = extractBaseDomain(from: ensName.name)
        let chainSuffix = getChainSuffix(for: selectedChain)
        let multiChainENSName = "\(baseDomain):\(chainSuffix)"
        
        // Use Fusion ENS Server API for multi-chain resolution
        let apiURL = "https://api.fusionens.com/resolve/\(multiChainENSName)?network=mainnet"
        
        AF.request(apiURL).responseData { response in
            guard let data = response.data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let success = json["success"] as? Bool,
                  success,
                  let dataDict = json["data"] as? [String: Any],
                  let address = dataDict["address"] as? String,
                  !address.isEmpty else {
                // Multi-chain resolution failed - show error instead of falling back
                DispatchQueue.main.async {
                    let chainName = self.selectedChain.displayName
                    let ensName = self.ensName.name
                    self.showMissingAddressAlert(ensName: ensName, chainName: chainName)
                }
                completion(nil)
                return
            }
            
            completion(address)
        }
    }
    
    
    private func getChainSuffix(for chain: PaymentChain) -> String {
        switch chain {
        case .bitcoin: return "btc"
        case .ethereum: return "eth"
        case .solana: return "sol"
        case .dogecoin: return "doge"
        case .xrp: return "xrp"
        case .litecoin: return "ltc"
        case .cardano: return "ada"
        case .polkadot: return "dot"
        }
    }
    
    private func createPaymentRequest() {
        let paymentURL = createPaymentURL()
        generateQRCode(from: paymentURL)
        
        // Show success popup with QR code
        showQRSuccessPopup()
    }
    
    private func createPaymentURL() -> String {
        // Check wallet preference setting
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        let useTrustWallet = userDefaults.bool(forKey: "useTrustWalletScheme")
        
        if useTrustWallet {
            // Use Trust Wallet scheme for all cryptocurrencies
            switch selectedChain {
            case .bitcoin:
                return "trust://send?coin=0&address=\(resolvedAddress)&amount=\(amount)"
            case .ethereum:
                // For Ethereum with Trust Wallet, use ENS name instead of resolved address
                let ethereumAddress = ensName.name
                return "trust://send?coin=60&address=\(ethereumAddress)&amount=\(amount)"
            case .solana:
                return "trust://send?coin=501&address=\(resolvedAddress)&amount=\(amount)"
            case .dogecoin:
                return "trust://send?coin=3&address=\(resolvedAddress)&amount=\(amount)"
            case .xrp:
                return "trust://send?coin=144&address=\(resolvedAddress)&amount=\(amount)"
            case .litecoin:
                return "trust://send?coin=2&address=\(resolvedAddress)&amount=\(amount)"
            case .cardano:
                return "trust://send?coin=1815&address=\(resolvedAddress)&amount=\(amount)"
            case .polkadot:
                return "trust://send?coin=354&address=\(resolvedAddress)&amount=\(amount)"
            }
        } else {
            // Use standard schemes for broader wallet compatibility
            switch selectedChain {
            case .bitcoin:
                return "bitcoin:\(resolvedAddress)?amount=\(amount)"
            case .ethereum:
                return "ethereum:\(resolvedAddress)?amount=\(amount)"
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
            case .polkadot:
                return "polkadot:\(resolvedAddress)?amount=\(amount)"
            }
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
        _ = PaymentChain.allCases
        
        // You could add visual indicators here, like:
        // - Gray out unavailable chains
        // - Add checkmarks to available chains
        // - Show a small info icon with available chains
    }
    
    // MARK: - ENS Details Loading
    private func loadENSDetails() {
        // Only load missing data - use cached data when available
        
        // Only resolve address if we don't have it
        if ensName.address.isEmpty {
            resolveEthereumAddress()
        }
        
        // Only load full name if we don't have it
        if ensName.fullName == nil || ensName.fullName?.isEmpty == true {
            loadENSFullName()
        }
        
        // Always try to load avatar (with cache check)
        loadENSAvatar()
    }
    
    private func resolveEthereumAddress() {
        // Resolve the ENS name to get Ethereum address for display (same as keyboards)
        APICaller.shared.resolveENSName(name: ensName.name) { [weak self] resolvedAddress in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if !resolvedAddress.isEmpty {
                    self.updateENSAddressDisplay(address: resolvedAddress)
                }
            }
        }
    }
    
    private func loadENSFullName() {
        // Use Fusion ENS Server API like the Chrome extension does
        let baseDomain = extractBaseDomain(from: ensName.name)
        let fusionServerURL = "https://api.fusionens.com/resolve/\(baseDomain):name?network=mainnet&source=ios-app"
        
        AF.request(fusionServerURL).responseData { [weak self] response in
            guard let self = self else { return }
            
            guard let data = response.data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let success = json["success"] as? Bool,
                  success,
                  let dataDict = json["data"] as? [String: Any],
                  let fullName = dataDict["address"] as? String,
                  !fullName.isEmpty else {
                // Fallback: try ENSData API for full name
                self.loadENSFullNameFromENSData()
                return
            }
            
            // Clean HTML tags if present
            let cleanName = self.cleanHTMLTags(from: fullName)
            
            DispatchQueue.main.async {
                if !cleanName.isEmpty {
                    self.fullName = cleanName
                    self.fullNameLabel.text = cleanName
                } else {
                    // If still empty, try fallback
                    self.loadENSFullNameFromENSData()
                }
            }
        }
    }
    
    private func loadENSFullNameFromENSData() {
        // Fallback: try ENSData API
        let baseDomain = extractBaseDomain(from: ensName.name)
        let ensDataURL = "https://api.ensdata.net/\(baseDomain)"
        
        AF.request(ensDataURL).responseData { [weak self] response in
            guard let self = self else { return }
            
            guard let data = response.data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let fullName = json["name"] as? String,
                  !fullName.isEmpty else {
                // If both APIs fail, show the ENS name as fallback
                DispatchQueue.main.async {
                    if self.fullNameLabel.text == "Loading..." {
                        self.fullNameLabel.text = self.ensName.name
                    }
                }
                return
            }
            
            DispatchQueue.main.async {
                self.fullName = fullName
                self.fullNameLabel.text = fullName
            }
        }
    }
    
    private func loadENSAvatar() {
        let baseDomain = extractBaseDomain(from: ensName.name)
        
        // First check if we have a cached image from ENSNameTableViewCell
        if let cachedImage = ENSNameTableViewCell.getCachedAvatar(for: baseDomain) {
            self.avatarImageView.image = cachedImage
            self.avatarImageView.isHidden = false
            self.globeIconImageView.isHidden = true
            return
        }
        
        // If no cached image, proceed with API loading
        // Use ENSData API first for avatar (same as resolution)
        self.loadENSAvatarFromENSData(baseDomain: baseDomain)
    }
    
    private func loadENSAvatarFromENSData(baseDomain: String) {
        // Fallback: try ENSData API for avatar (same as Chrome extension)
        let ensDataURL = "https://api.ensdata.net/\(baseDomain)"
        
        AF.request(ensDataURL).responseData { [weak self] response in
            guard let self = self,
                  let data = response.data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let avatarURLString = json["avatar_small"] as? String,
                  !avatarURLString.isEmpty else {
                return
            }
            
            // Load avatar image
            if let url = URL(string: avatarURLString) {
                self.loadImage(from: url) { [weak self] image in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        if let image = image {
                            self.avatarImageView.image = image
                            self.avatarImageView.isHidden = false
                            self.globeIconImageView.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        AF.request(url).responseData { response in
            guard let data = response.data,
                  let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }
    }
    
    private func copyENSAddress() {
        // Show list of saved ENS names to choose from
        showENSNameSelector()
    }
    
    private func showENSNameSelector() {
        // Get all saved ENS names from UserDefaults
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        guard let data = userDefaults.data(forKey: "savedENSNamesData"),
              let savedENSNames = try? JSONDecoder().decode([ENSName].self, from: data) else {
            showAlert(title: "No ENS Names", message: "You don't have any saved ENS names yet.")
            return
        }
        
        guard !savedENSNames.isEmpty else {
            showAlert(title: "No ENS Names", message: "You don't have any saved ENS names yet.")
            return
        }
        
        let alert = UIAlertController(title: "Select ENS Name", message: "Choose which ENS name to use for this payment request", preferredStyle: .actionSheet)
        
        // Add action for each saved ENS name
        for ensName in savedENSNames {
            let action = UIAlertAction(title: ensName.name, style: .default) { _ in
                self.switchToENSName(ensName)
            }
            alert.addAction(action)
        }
        
        // Add cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad, set the popover source
        if let popover = alert.popoverPresentationController {
            popover.sourceView = ensCardView
            popover.sourceRect = ensCardView.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func switchToENSName(_ newENSName: ENSName) {
        // Update the current ENS name
        self.ensName = newENSName
        
        // Update the UI
        ensNameLabel.text = newENSName.name
        fullNameLabel.text = newENSName.fullName ?? newENSName.name // Use cached fullName or show ENS name
        
        // Truncate address consistently
        if !newENSName.address.isEmpty {
            let truncatedAddress = "\(newENSName.address.prefix(6))...\(newENSName.address.suffix(4))"
            ensAddressLabel.text = truncatedAddress
        } else {
            ensAddressLabel.text = newENSName.address
        }
        
        // Reset avatar state
        avatarImageView.isHidden = true
        globeIconImageView.isHidden = false
        
        // Reload ENS details for the new name
        loadENSDetails()
    }
    
    private func showSetupInstructions() {
        let setupVC = GettingStartedVC()
        setupVC.isFromSettings = true
        setupVC.modalPresentationStyle = .pageSheet
        present(setupVC, animated: true)
    }
    
    private func updateENSAddressDisplay(address: String) {
        // Update the ENS card with the resolved address
        let truncatedAddress = "\(address.prefix(6))...\(address.suffix(4))"
        ensAddressLabel.text = truncatedAddress
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
    
    // MARK: - Price Conversion
    private func loadCryptoPrices() {
        let coinIds = PaymentChain.allCases.map { $0.coinGeckoId }.joined(separator: ",")
        let url = "https://api.coingecko.com/api/v3/simple/price?ids=\(coinIds)&vs_currencies=usd"
        
        AF.request(url).responseData { [weak self] response in
            guard let self = self,
                  let data = response.data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            
            DispatchQueue.main.async {
                for chain in PaymentChain.allCases {
                    if let priceData = json[chain.coinGeckoId] as? [String: Any],
                       let price = priceData["usd"] as? Double {
                        self.cryptoPrices[chain.symbol] = price
                    }
                }
                self.updateConversionDisplay()
            }
        }
    }
    
    private func updateCurrencyToggle() {
        let title = isUSDInput ? "USD" : selectedChain.symbol
        currencyToggleButton.setTitle(title, for: .normal)
    }
    
    private func updateConversionDisplay() {
        guard let amountText = amountTextField.text,
              !amountText.isEmpty,
              let amountValue = Double(amountText),
              let cryptoPrice = cryptoPrices[selectedChain.symbol] else {
            conversionLabel.text = ""
            return
        }
        
        if isUSDInput {
            // Convert USD to crypto
            cryptoAmount = amountValue / cryptoPrice
            conversionLabel.text = "≈ \(String(format: "%.6f", cryptoAmount)) \(selectedChain.symbol)"
        } else {
            // Convert crypto to USD
            usdAmount = amountValue * cryptoPrice
            conversionLabel.text = "≈ $\(String(format: "%.2f", usdAmount)) USD"
        }
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
        
        // Add Try Ethereum button (if not already selected)
        if chainName.lowercased() != "ethereum" {
            alert.addAction(UIAlertAction(title: "Try Ethereum", style: .default) { _ in
                self.selectedChain = .ethereum
                self.chainButton.setTitle(self.selectedChain.displayName, for: .normal)
                self.cryptoIconImageView.image = self.selectedChain.systemIcon
                // Retry with Ethereum
                self.resolveENSName { address in
                    if let address = address {
                        self.resolvedAddress = address
                        self.createPaymentRequest()
                    }
                }
            })
        }
        
        // Add ENS App button
        alert.addAction(UIAlertAction(title: "Add \(chainName.capitalized) Address", style: .default) { _ in
            self.openENSApp(for: ensName)
        })
        
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
                    } else {
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
        // Handle new format like onshow.eth:btc
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
    
    // MARK: - QR Success Popup
    private func showQRSuccessPopup() {
        guard let qrCodeImage = qrCodeImageView.image else {
            return
        }
        
        let paymentURL = createPaymentURL()
        let successPopup = QRSuccessPopupViewController(
            ensName: ensName.name,
            qrCodeImage: qrCodeImage,
            paymentURL: paymentURL
        ) {
            // Optional: Add any additional actions after popup dismissal
        }
        successPopup.show(from: self)
    }
}

// MARK: - UITextFieldDelegate
extension PaymentRequestViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Update conversion display after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateConversionDisplay()
        }
        
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
    case polkadot
    
    var displayName: String {
        switch self {
        case .bitcoin: return "Bitcoin"
        case .ethereum: return "Ethereum"
        case .solana: return "Solana"
        case .dogecoin: return "Dogecoin"
        case .xrp: return "XRP"
        case .litecoin: return "Litecoin"
        case .cardano: return "Cardano"
        case .polkadot: return "Polkadot"
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
        case .polkadot: return "DOT"
        }
    }
    
    var coinGeckoId: String {
        switch self {
        case .bitcoin: return "bitcoin"
        case .ethereum: return "ethereum"
        case .solana: return "solana"
        case .dogecoin: return "dogecoin"
        case .xrp: return "ripple"
        case .litecoin: return "litecoin"
        case .cardano: return "cardano"
        case .polkadot: return "polkadot"
        }
    }
    
    var systemIcon: UIImage? {
        switch self {
        case .bitcoin: return UIImage(named: "BitcoinLogo")
        case .ethereum: return UIImage(named: "EthereumLogo")
        case .solana: return UIImage(named: "SolanaLogo")
        case .dogecoin: return UIImage(named: "DogecoinLogo")
        case .xrp: return UIImage(named: "XRPLogo")
        case .litecoin: return UIImage(named: "LitecoinLogo")
        case .cardano: return UIImage(named: "CardanoLogo")
        case .polkadot: return UIImage(named: "PolkadotLogo")
        }
    }
    
    var iconColor: UIColor {
        switch self {
        case .bitcoin: return UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0) // Orange
        case .ethereum: return UIColor(red: 0.4, green: 0.4, blue: 0.8, alpha: 1.0) // Purple-Blue
        case .solana: return UIColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0) // Cyan
        case .dogecoin: return UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0) // Yellow
        case .xrp: return UIColor(red: 0.0, green: 0.0, blue: 0.8, alpha: 1.0) // Blue
        case .litecoin: return UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) // Gray
        case .cardano: return UIColor(red: 0.0, green: 0.6, blue: 0.8, alpha: 1.0) // Teal
        case .polkadot: return UIColor(red: 0.8, green: 0.0, blue: 0.8, alpha: 1.0) // Purple
        }
    }
}
