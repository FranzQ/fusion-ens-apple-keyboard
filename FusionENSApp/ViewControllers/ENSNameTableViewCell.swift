import UIKit
import Alamofire

protocol ENSNameTableViewCellDelegate: AnyObject {
    func didTapQRCode(for ensName: ENSName)
    func didTapSettings(for ensName: ENSName)
    func didTapDelete(for ensName: ENSName)
    func didTapManage(for ensName: ENSName)
    func didTapRefresh(for ensName: ENSName)
}

class ENSNameTableViewCell: UITableViewCell, UIContextMenuInteractionDelegate {
    
    // MARK: - Properties
    weak var delegate: ENSNameTableViewCellDelegate?
    private var currentENSName: ENSName?
    
    // MARK: - Static Caching
    private static var avatarCache: [String: UIImage] = [:]
    private static var loadingRequests: Set<String> = []
    private static let maxCacheSize = 50 // Limit cache size to prevent memory issues
    
    // MARK: - UI Elements
    private let cardView = UIView()
    private let globeIconView = UIView()
    private let globeIcon = UIImageView()
    private let avatarImageView = UIImageView()
    private let ensNameLabel = UILabel()
    private let fullNameLabel = UILabel()
    private let addressLabel = UILabel()
    private let qrCodeButton = UIButton(type: .system)
    private let settingsButton = UIButton(type: .system)
    private let refreshButton = UIButton(type: .system)
    
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
        
        // Default ENS Icon (same as bottom menu)
        globeIcon.image = UIImage(systemName: "person.crop.rectangle")
        globeIcon.tintColor = ColorTheme.primaryText
        globeIcon.contentMode = .scaleAspectFit
        globeIcon.translatesAutoresizingMaskIntoConstraints = false
        globeIconView.addSubview(globeIcon)
        
        // Avatar Image View (hidden by default, shown when avatar loads)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        avatarImageView.isHidden = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        globeIconView.addSubview(avatarImageView)
        
        // ENS Name Label
        ensNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        ensNameLabel.textColor = ColorTheme.primaryText
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
        
        // Settings Button
        settingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        settingsButton.tintColor = ColorTheme.primaryText
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        cardView.addSubview(settingsButton)
        
        // Refresh Button (hidden by default, shown when address is "Resolving...")
        refreshButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        refreshButton.tintColor = ColorTheme.tabBarTint
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        refreshButton.isHidden = true
        cardView.addSubview(refreshButton)
        
        // Add context menu interaction to card view for long press
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        cardView.addInteraction(contextMenuInteraction)
        cardView.isUserInteractionEnabled = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            globeIconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            globeIconView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            globeIconView.widthAnchor.constraint(equalToConstant: 40),
            globeIconView.heightAnchor.constraint(equalToConstant: 40),
            
            globeIcon.centerXAnchor.constraint(equalTo: globeIconView.centerXAnchor),
            globeIcon.centerYAnchor.constraint(equalTo: globeIconView.centerYAnchor),
            globeIcon.widthAnchor.constraint(equalToConstant: 20),
            globeIcon.heightAnchor.constraint(equalToConstant: 20),
            
            avatarImageView.topAnchor.constraint(equalTo: globeIconView.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: globeIconView.leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: globeIconView.trailingAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: globeIconView.bottomAnchor),
            
            ensNameLabel.leadingAnchor.constraint(equalTo: globeIconView.trailingAnchor, constant: 16),
            ensNameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            ensNameLabel.trailingAnchor.constraint(equalTo: settingsButton.leadingAnchor, constant: -16),
            
            fullNameLabel.leadingAnchor.constraint(equalTo: ensNameLabel.leadingAnchor),
            fullNameLabel.topAnchor.constraint(equalTo: ensNameLabel.bottomAnchor, constant: 1),
            fullNameLabel.trailingAnchor.constraint(equalTo: ensNameLabel.trailingAnchor),
            
            addressLabel.leadingAnchor.constraint(equalTo: ensNameLabel.leadingAnchor),
            addressLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 2),
            addressLabel.trailingAnchor.constraint(equalTo: ensNameLabel.trailingAnchor),
            addressLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            settingsButton.trailingAnchor.constraint(equalTo: qrCodeButton.leadingAnchor, constant: -12),
            settingsButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 24),
            settingsButton.heightAnchor.constraint(equalToConstant: 24),
            
            qrCodeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            qrCodeButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            qrCodeButton.widthAnchor.constraint(equalToConstant: 24),
            qrCodeButton.heightAnchor.constraint(equalToConstant: 24),
            
            refreshButton.trailingAnchor.constraint(equalTo: settingsButton.leadingAnchor, constant: -8),
            refreshButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 24),
            refreshButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Configuration
    func configure(with ensName: ENSName) {
        self.currentENSName = ensName
        ensNameLabel.text = ensName.name
        
        // Handle full name with default styling
        if let fullName = ensName.fullName, !fullName.isEmpty {
            fullNameLabel.text = fullName
            fullNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            fullNameLabel.textColor = ColorTheme.secondaryText
        } else {
            fullNameLabel.text = "Unknown Name"
            fullNameLabel.font = UIFont.italicSystemFont(ofSize: 14)
            fullNameLabel.textColor = ColorTheme.secondaryText.withAlphaComponent(0.7)
        }
        
        // Handle address display and refresh button visibility
        if ensName.address == "Resolving..." {
            addressLabel.text = "Resolving..."
            addressLabel.textColor = ColorTheme.tabBarTint
            refreshButton.isHidden = false
        } else {
            let truncatedAddress = "\(ensName.address.prefix(6))...\(ensName.address.suffix(4))"
            addressLabel.text = truncatedAddress
            addressLabel.textColor = ColorTheme.secondaryText
            refreshButton.isHidden = true
        }
        
        // Reset avatar state
        avatarImageView.isHidden = true
        globeIcon.isHidden = false
        
        // Load avatar if available
        loadENSAvatar(for: ensName)
    }
    
    // MARK: - Avatar Loading
    private func loadENSAvatar(for ensName: ENSName) {
        let baseDomain = extractBaseDomain(from: ensName.name)
        
        // Check cache first
        if let cachedImage = Self.avatarCache[baseDomain] {
            DispatchQueue.main.async {
                self.avatarImageView.image = cachedImage
                self.avatarImageView.isHidden = false
                self.globeIcon.isHidden = true
            }
            return
        }
        
        // Check if already loading
        if Self.loadingRequests.contains(baseDomain) {
            return
        }
        
        // Mark as loading
        Self.loadingRequests.insert(baseDomain)
        
        // First get the Ethereum address for avatar lookup
        APICaller.shared.resolveENSName(name: baseDomain) { [weak self] ethAddress in
            guard let self = self, !ethAddress.isEmpty else { 
                // Remove from loading requests
                Self.loadingRequests.remove(baseDomain)
                return 
            }
            
            
            // Use ENS metadata API with Ethereum address (same as Chrome extension)
            let metadataURL = "https://metadata.ens.domains/mainnet/\(ethAddress)/avatar"
            
            AF.request(metadataURL).responseString { [weak self] response in
                guard let self = self else { return }
                
                guard let avatarURLString = response.value,
                      !avatarURLString.isEmpty,
                      avatarURLString != "data:image/svg+xml;base64," else {
                    // Fallback: try ENS Ideas API for avatar
                    self.loadENSAvatarFromENSIdeas(baseDomain: baseDomain)
                    return
                }
                
                
                // Check if the response is a JSON error message
                if avatarURLString.hasPrefix("{") && avatarURLString.contains("message") {
                    // Fallback: try ENS Ideas API for avatar
                    self.loadENSAvatarFromENSIdeas(baseDomain: baseDomain)
                    return
                }
                
                // Clean HTML tags if present
                let cleanURLString = self.cleanHTMLTags(from: avatarURLString)
                
                // Check if it's a valid URL
                guard !cleanURLString.isEmpty,
                      let url = URL(string: cleanURLString) else {
                    // Fallback: try ENS Ideas API for avatar
                    self.loadENSAvatarFromENSIdeas(baseDomain: baseDomain)
                    return
                }
                
                
                // Load avatar image
                self.loadImage(from: url) { [weak self] image in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        // Remove from loading requests
                        Self.loadingRequests.remove(baseDomain)
                        
                        if let image = image {
                            
                            // Cache the image
                            Self.addToCache(image, for: baseDomain)
                            
                            self.avatarImageView.image = image
                            self.avatarImageView.isHidden = false
                            self.globeIcon.isHidden = true
                        } else {
                        }
                    }
                }
            }
        }
    }
    
    private func loadENSAvatarFromENSIdeas(baseDomain: String) {
        // Fallback: try ENS Ideas API for avatar (same as Chrome extension)
        let ensIdeasURL = "https://api.ensideas.com/ens/resolve/\(baseDomain)"
        
        AF.request(ensIdeasURL).responseData { [weak self] response in
            guard let self = self,
                  let data = response.data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let avatarURLString = json["avatar"] as? String,
                  !avatarURLString.isEmpty else {
                // Remove from loading requests
                Self.loadingRequests.remove(baseDomain)
                return
            }
            
            
            // Load avatar image
            if let url = URL(string: avatarURLString) {
                self.loadImage(from: url) { [weak self] image in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        // Remove from loading requests
                        Self.loadingRequests.remove(baseDomain)
                        
                        if let image = image {
                            
                            // Cache the image
                            Self.addToCache(image, for: baseDomain)
                            
                            self.avatarImageView.image = image
                            self.avatarImageView.isHidden = false
                            self.globeIcon.isHidden = true
                        } else {
                        }
                    }
                }
            } else {
                // Remove from loading requests
                Self.loadingRequests.remove(baseDomain)
            }
        }
    }
    
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        AF.request(url).responseData { response in
            if let error = response.error {
                completion(nil)
                return
            }
            
            guard let data = response.data else {
                completion(nil)
                return
            }
            
            
            // Check the content type
            if let contentType = response.response?.allHeaderFields["Content-Type"] as? String {
            }
            
            // Try to create UIImage from data
            guard let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            completion(image)
        }
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
    
    // MARK: - Actions
    @objc private func qrCodeButtonTapped() {
        guard let ensName = currentENSName else { return }
        delegate?.didTapQRCode(for: ensName)
    }
    
    @objc private func settingsButtonTapped() {
        showContextMenu()
    }
    
    @objc private func refreshButtonTapped() {
        guard let ensName = currentENSName else { return }
        delegate?.didTapRefresh(for: ensName)
    }
    
    private func showContextMenu() {
        guard let ensName = currentENSName else { return }
        
        let manageAction = UIAction(title: "Manage", image: UIImage(systemName: "gearshape")) { [weak self] _ in
            self?.delegate?.didTapManage(for: ensName)
        }
        
        let removeAction = UIAction(title: "Remove", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            self?.delegate?.didTapDelete(for: ensName)
        }
        
        let menu = UIMenu(title: ensName.name, children: [manageAction, removeAction])
        
        // Show context menu from the settings button
        settingsButton.showsMenuAsPrimaryAction = true
        settingsButton.menu = menu
        settingsButton.sendActions(for: .menuActionTriggered)
    }
    
    // MARK: - UIContextMenuInteractionDelegate
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let ensName = currentENSName else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let manageAction = UIAction(title: "Manage", image: UIImage(systemName: "gearshape")) { [weak self] _ in
                self?.delegate?.didTapManage(for: ensName)
            }
            
            let removeAction = UIAction(title: "Remove", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.delegate?.didTapDelete(for: ensName)
            }
            
            return UIMenu(title: ensName.name, children: [manageAction, removeAction])
        }
    }
    
    // MARK: - Cache Management
    private static func addToCache(_ image: UIImage, for key: String) {
        // Remove oldest entries if cache is full
        if avatarCache.count >= maxCacheSize {
            let keysToRemove = Array(avatarCache.keys.prefix(avatarCache.count - maxCacheSize + 1))
            keysToRemove.forEach { avatarCache.removeValue(forKey: $0) }
        }
        avatarCache[key] = image
    }
    
    static func clearAvatarCache() {
        avatarCache.removeAll()
        loadingRequests.removeAll()
    }
}