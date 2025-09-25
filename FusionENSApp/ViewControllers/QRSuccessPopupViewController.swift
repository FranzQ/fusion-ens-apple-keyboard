import UIKit
import SnapKit

class QRSuccessPopupViewController: UIViewController {
    
    // MARK: - Properties
    private let ensName: String
    private let qrCodeImage: UIImage
    private let paymentURL: String
    private let onDismiss: (() -> Void)?
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let headerView = UIView()
    private let successIconView = UIView()
    private let checkmarkImageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let qrCodeImageView = UIImageView()
    private let qrCodeContainerView = UIView()
    private let paymentInfoStackView = UIStackView()
    private let buttonStackView = UIStackView()
    private let shareButton = UIButton(type: .system)
    private let dismissButton = UIButton(type: .system)
    
    // MARK: - Initialization
    init(ensName: String, qrCodeImage: UIImage, paymentURL: String, onDismiss: (() -> Void)? = nil) {
        self.ensName = ensName
        self.qrCodeImage = qrCodeImage
        self.paymentURL = paymentURL
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
        
        // Configure modal presentation
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Scroll View
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        // Container View
        containerView.backgroundColor = UIColor.systemBackground
        scrollView.addSubview(containerView)
        
        // Header View
        headerView.backgroundColor = UIColor.systemBackground
        containerView.addSubview(headerView)
        
        // Success Icon View
        successIconView.backgroundColor = UIColor.systemBlue
        successIconView.layer.cornerRadius = 40
        headerView.addSubview(successIconView)
        
        // Checkmark Image
        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = .white
        checkmarkImageView.contentMode = .scaleAspectFit
        successIconView.addSubview(checkmarkImageView)
        
        // Title Label
        titleLabel.text = "Payment Link Ready"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        headerView.addSubview(titleLabel)
        
        // Message Label
        messageLabel.text = "Your QR code for \(ensName) has been generated successfully."
        messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        headerView.addSubview(messageLabel)
        
        // QR Code Container
        qrCodeContainerView.backgroundColor = UIColor.white
        qrCodeContainerView.layer.cornerRadius = 16
        qrCodeContainerView.layer.shadowColor = UIColor.black.cgColor
        qrCodeContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        qrCodeContainerView.layer.shadowRadius = 8
        qrCodeContainerView.layer.shadowOpacity = 0.1
        containerView.addSubview(qrCodeContainerView)
        
        // QR Code Image
        qrCodeImageView.image = qrCodeImage
        qrCodeImageView.contentMode = .scaleAspectFit
        qrCodeImageView.backgroundColor = UIColor.white
        qrCodeContainerView.addSubview(qrCodeImageView)
        
        // Payment Info Stack View
        paymentInfoStackView.axis = .horizontal
        paymentInfoStackView.spacing = 8
        paymentInfoStackView.alignment = .center
        paymentInfoStackView.distribution = .fillProportionally
        containerView.addSubview(paymentInfoStackView)
        
        // Create payment info tags
        createPaymentInfoTags()
        
        // Button Stack View
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually
        containerView.addSubview(buttonStackView)
        
        // Share Button
        shareButton.setTitle("Share QR Code", for: .normal)
        shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        shareButton.backgroundColor = UIColor.systemBlue
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.layer.cornerRadius = 12
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        buttonStackView.addArrangedSubview(shareButton)
        
        // Done Button
        dismissButton.setTitle("Done", for: .normal)
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        dismissButton.backgroundColor = UIColor.systemGray5
        dismissButton.setTitleColor(UIColor.label, for: .normal)
        dismissButton.layer.cornerRadius = 12
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        buttonStackView.addArrangedSubview(dismissButton)
    }
    
    private func setupConstraints() {
        // Scroll View
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // Container View
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Header View
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview()
        }
        
        // Success Icon View
        successIconView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        // Checkmark Image
        checkmarkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        // Title Label
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(successIconView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
        
        // Message Label
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // QR Code Container
        qrCodeContainerView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(280)
        }
        
        // QR Code Image
        qrCodeImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        // Payment Info Stack View
        paymentInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(qrCodeContainerView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().offset(-24)
        }
        
        // Button Stack View
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(paymentInfoStackView.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        // Button Heights
        shareButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        dismissButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    private func setupTheme() {
        // This will automatically adapt to light/dark mode
        view.backgroundColor = UIColor.systemBackground
        containerView.backgroundColor = UIColor.systemBackground
        headerView.backgroundColor = UIColor.systemBackground
        titleLabel.textColor = UIColor.label
        messageLabel.textColor = UIColor.secondaryLabel
    }
    
    // MARK: - Animations
    private func animateIn() {
        // Simple fade in for full screen popover
        view.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.view.alpha = 1
        }
    }
    
    private func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.view.alpha = 0
        } completion: { _ in
            completion()
        }
    }
    
    // MARK: - Actions
    @objc private func shareButtonTapped() {
        let shareText = "Scan this QR code to send payment"
        let activityViewController = UIActivityViewController(activityItems: [shareText, qrCodeImage], applicationActivities: nil)
        
        // For iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
        }
        
        present(activityViewController, animated: true)
    }
    
    @objc private func dismissButtonTapped() {
        animateOut { [weak self] in
            self?.dismiss(animated: false) {
                self?.onDismiss?()
            }
        }
    }
    
    // MARK: - Payment Info Tags
    private func createPaymentInfoTags() {
        // Parse the payment URL to extract cryptocurrency and amount
        let (cryptoType, amount) = parsePaymentURL(paymentURL)
        
        // Create cryptocurrency tag
        let cryptoTag = createCryptoTag(cryptoType: cryptoType)
        paymentInfoStackView.addArrangedSubview(cryptoTag)
        
        // Create amount tag if amount is available
        if let amount = amount, !amount.isEmpty {
            let amountTag = createAmountTag(amount: amount)
            paymentInfoStackView.addArrangedSubview(amountTag)
        }
    }
    
    private func parsePaymentURL(_ url: String) -> (cryptoType: String, amount: String?) {
        // Handle Trust Wallet scheme
        if url.hasPrefix("trust://") {
            if let amount = extractAmountFromTrustWalletURL(url) {
                let cryptoType = extractCryptoTypeFromTrustWalletURL(url)
                return (cryptoType, amount)
            }
        }
        
        // Handle standard schemes (bitcoin:, ethereum:, etc.)
        if let colonIndex = url.firstIndex(of: ":") {
            let scheme = String(url[..<colonIndex])
            let remaining = String(url[url.index(after: colonIndex)...])
            
            // Extract amount from query parameters
            if let amount = extractAmountFromStandardURL(remaining) {
                return (scheme.capitalized, amount)
            }
        }
        
        // Fallback: try to extract from URL components
        if let urlComponents = URLComponents(string: url) {
            let scheme = urlComponents.scheme?.capitalized ?? "Unknown"
            let amount = urlComponents.queryItems?.first(where: { $0.name == "amount" })?.value
            return (scheme, amount)
        }
        
        return ("Unknown", nil)
    }
    
    private func extractAmountFromTrustWalletURL(_ url: String) -> String? {
        guard let urlComponents = URLComponents(string: url) else { return nil }
        return urlComponents.queryItems?.first(where: { $0.name == "amount" })?.value
    }
    
    private func extractCryptoTypeFromTrustWalletURL(_ url: String) -> String {
        guard let urlComponents = URLComponents(string: url),
              let coinValue = urlComponents.queryItems?.first(where: { $0.name == "coin" })?.value,
              let coinID = Int(coinValue) else {
            return "Unknown"
        }
        
        // Map Trust Wallet coin IDs to cryptocurrency names
        switch coinID {
        case 0: return "Bitcoin"
        case 60: return "Ethereum"
        case 501: return "Solana"
        case 3: return "Dogecoin"
        case 144: return "XRP"
        case 2: return "Litecoin"
        case 1815: return "Cardano"
        case 354: return "Polkadot"
        default: return "Unknown"
        }
    }
    
    private func extractAmountFromStandardURL(_ url: String) -> String? {
        if let questionIndex = url.firstIndex(of: "?") {
            let queryString = String(url[url.index(after: questionIndex)...])
            if let amountIndex = queryString.range(of: "amount=") {
                let amountStart = amountIndex.upperBound
                let amountString = String(queryString[amountStart...])
                // Remove any additional parameters
                if let ampersandIndex = amountString.firstIndex(of: "&") {
                    return String(amountString[..<ampersandIndex])
                }
                return amountString
            }
        }
        return nil
    }
    
    private func createCryptoTag(cryptoType: String) -> UIView {
        let tagView = UIView()
        tagView.backgroundColor = UIColor.systemGray6
        tagView.layer.cornerRadius = 16
        tagView.layer.borderWidth = 1
        tagView.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Get the corresponding PaymentChain for the crypto type
        let chain = getPaymentChain(from: cryptoType)
        
        // Create icon image view
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = chain.systemIcon
        iconImageView.tintColor = .white
        
        tagView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.width.height.equalTo(20)
        }
        
        // Create label for the crypto type
        let label = UILabel()
        label.text = cryptoType
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor.label
        label.textAlignment = .center
        
        tagView.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconImageView.snp.trailing).offset(6)
            make.trailing.equalToSuperview().offset(-12)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        return tagView
    }
    
    private func createAmountTag(amount: String) -> UIView {
        let tagView = UIView()
        tagView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        tagView.layer.cornerRadius = 16
        tagView.layer.borderWidth = 1
        tagView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        
        let label = UILabel()
        label.text = amount
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor.systemBlue
        label.textAlignment = .center
        
        tagView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        }
        
        return tagView
    }
    
    // MARK: - Helper Methods
    private func getPaymentChain(from cryptoType: String) -> PaymentChain {
        switch cryptoType.lowercased() {
        case "bitcoin": return .bitcoin
        case "ethereum": return .ethereum
        case "solana": return .solana
        case "dogecoin": return .dogecoin
        case "xrp": return .xrp
        case "litecoin": return .litecoin
        case "cardano": return .cardano
        case "polkadot": return .polkadot
        default: return .ethereum // Default fallback
        }
    }
    
    // MARK: - Public Methods
    func show(from presentingViewController: UIViewController) {
        presentingViewController.present(self, animated: false)
    }
}

