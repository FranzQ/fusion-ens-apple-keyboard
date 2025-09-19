import UIKit

class ENSNameTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let cardView = UIView()
    private let globeIconView = UIView()
    private let globeIcon = UIImageView()
    private let nameLabel = UILabel()
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
        
        // Name Label
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = ColorTheme.primaryText
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
        // Address Label
        addressLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        addressLabel.textColor = ColorTheme.secondaryText
        addressLabel.numberOfLines = 0
        addressLabel.lineBreakMode = .byCharWrapping
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
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            globeIconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            globeIconView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            globeIconView.widthAnchor.constraint(equalToConstant: 40),
            globeIconView.heightAnchor.constraint(equalToConstant: 40),
            
            globeIcon.centerXAnchor.constraint(equalTo: globeIconView.centerXAnchor),
            globeIcon.centerYAnchor.constraint(equalTo: globeIconView.centerYAnchor),
            globeIcon.widthAnchor.constraint(equalToConstant: 20),
            globeIcon.heightAnchor.constraint(equalToConstant: 20),
            
            nameLabel.leadingAnchor.constraint(equalTo: globeIconView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: qrCodeButton.leadingAnchor, constant: -12),
            
            addressLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            addressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            addressLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            addressLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            
            qrCodeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            qrCodeButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            qrCodeButton.widthAnchor.constraint(equalToConstant: 24),
            qrCodeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Configuration
    func configure(with ensName: ENSName) {
        nameLabel.text = ensName.name
        addressLabel.text = ensName.address
    }
    
    // MARK: - Actions
    @objc private func qrCodeButtonTapped() {
        // Handle QR code generation
        print("QR Code tapped for: \(nameLabel.text ?? "")")
    }
}