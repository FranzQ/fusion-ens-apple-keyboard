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
    private let addressLabel = UILabel()
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
        
        // Address Label
        addressLabel.text = paymentURL
        addressLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 0
        addressLabel.textColor = UIColor.secondaryLabel
        containerView.addSubview(addressLabel)
        
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
        
        // Address Label
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(qrCodeContainerView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }
        
        // Button Stack View
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(32)
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
        addressLabel.textColor = UIColor.secondaryLabel
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
        let activityViewController = UIActivityViewController(activityItems: [qrCodeImage, paymentURL], applicationActivities: nil)
        
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
    
    // MARK: - Public Methods
    func show(from presentingViewController: UIViewController) {
        presentingViewController.present(self, animated: false)
    }
}
