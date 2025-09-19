import UIKit

class ENSNameTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let cardView = UIView()
    private let globeIconView = UIView()
    private let globeIcon = UIImageView()
    private let ensNameLabel = UILabel()
    private let fullNameLabel = UILabel()
    private let addressLabel = UILabel()
    private let qrCodeButton = UIButton(type: .system)
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = ColorTheme.primaryBackground
        selectionStyle = .none
        
        // Card View
        cardView.backgroundColor = ColorTheme.cardBackground
        cardView.layer.cornerRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        // Globe Icon Container
        globeIconView.backgroundColor = ColorTheme.accentSecondary
        globeIconView.layer.cornerRadius = 20
        globeIconView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(globeIconView)
        
        // Globe Icon
        globeIcon.image = UIImage(systemName: "globe")
        globeIcon.tintColor = ColorTheme.primaryText
        globeIcon.contentMode = .scaleAspectFit
        globeIcon.translatesAutoresizingMaskIntoConstraints = false
        globeIconView.addSubview(globeIcon)
        
        // ENS Name Label
        ensNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        ensNameLabel.textColor = .white
        ensNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(ensNameLabel)
        
        // Full Name Label
        fullNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        fullNameLabel.textColor = ColorTheme.secondaryText
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(fullNameLabel)
        
        // Address Label
        addressLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        addressLabel.textColor = ColorTheme.secondaryText
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(addressLabel)
        
        // QR Code Button
        qrCodeButton.setImage(UIImage(systemName: "qrcode"), for: .normal)
        qrCodeButton.tintColor = ColorTheme.primaryText
        qrCodeButton.translatesAutoresizingMaskIntoConstraints = false
        qrCodeButton.addTarget(self, action: #selector(qrCodeButtonTapped), for: .touchUpInside)
        cardView.addSubview(qrCodeButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            globeIconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            globeIconView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            globeIconView.widthAnchor.constraint(equalToConstant: 40),
            globeIconView.heightAnchor.constraint(equalToConstant: 40),
            
            globeIcon.centerXAnchor.constraint(equalTo: globeIconView.centerXAnchor),
            globeIcon.centerYAnchor.constraint(equalTo: globeIconView.centerYAnchor),
            globeIcon.widthAnchor.constraint(equalToConstant: 20),
            globeIcon.heightAnchor.constraint(equalToConstant: 20),
            
            ensNameLabel.leadingAnchor.constraint(equalTo: globeIconView.trailingAnchor, constant: 12),
            ensNameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            ensNameLabel.trailingAnchor.constraint(equalTo: qrCodeButton.leadingAnchor, constant: -12),
            
            fullNameLabel.leadingAnchor.constraint(equalTo: ensNameLabel.leadingAnchor),
            fullNameLabel.topAnchor.constraint(equalTo: ensNameLabel.bottomAnchor, constant: 4),
            fullNameLabel.trailingAnchor.constraint(equalTo: ensNameLabel.trailingAnchor),
            
            addressLabel.leadingAnchor.constraint(equalTo: ensNameLabel.leadingAnchor),
            addressLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 4),
            addressLabel.trailingAnchor.constraint(equalTo: ensNameLabel.trailingAnchor),
            addressLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            
            qrCodeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            qrCodeButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            qrCodeButton.widthAnchor.constraint(equalToConstant: 24),
            qrCodeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Configuration
    func configure(with ensName: ENSName) {
        ensNameLabel.text = ensName.name
        fullNameLabel.text = ensName.fullName ?? ""
        
        // Truncate address for display
        let truncatedAddress = "\(ensName.address.prefix(6))...\(ensName.address.suffix(4))"
        addressLabel.text = truncatedAddress
    }
    
    // MARK: - Actions
    @objc private func qrCodeButtonTapped() {
        // Handle QR code generation
        print("QR Code tapped for: \(ensNameLabel.text ?? "")")
    }
}