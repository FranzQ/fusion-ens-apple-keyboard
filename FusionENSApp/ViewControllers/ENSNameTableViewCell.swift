import UIKit
import SnapKit

class ENSNameTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let avatarImageView = UIImageView()
    private let ensNameLabel = UILabel()
    private let displayNameLabel = UILabel()
    private let dateLabel = UILabel()
    private let chevronImageView = UIImageView()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        selectionStyle = .default
        accessoryType = .disclosureIndicator
        
        // Avatar Image View
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.layer.masksToBounds = true
        avatarImageView.backgroundColor = .systemGray5
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .systemGray3
        contentView.addSubview(avatarImageView)
        
        // ENS Name Label
        ensNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        ensNameLabel.textColor = .label
        contentView.addSubview(ensNameLabel)
        
        // Display Name Label
        displayNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        displayNameLabel.textColor = .secondaryLabel
        contentView.addSubview(displayNameLabel)
        
        // Date Label
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .tertiaryLabel
        contentView.addSubview(dateLabel)
        
        // Layout
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        ensNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-40)
        }
        
        displayNameLabel.snp.makeConstraints { make in
            make.top.equalTo(ensNameLabel.snp.bottom).offset(4)
            make.leading.equalTo(ensNameLabel)
            make.trailing.equalTo(ensNameLabel)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(displayNameLabel.snp.bottom).offset(4)
            make.leading.equalTo(ensNameLabel)
            make.trailing.equalTo(ensNameLabel)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    // MARK: - Configuration
    func configure(with ensName: ENSName) {
        ensNameLabel.text = ensName.name
        displayNameLabel.text = ensName.displayName
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = "Added: \(formatter.string(from: ensName.dateAdded))"
        
        // Load avatar
        loadAvatar(for: ensName.name)
    }
    
    // MARK: - Avatar Loading
    private func loadAvatar(for ensName: String) {
        // Reset to default avatar
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .systemGray3
        
        // Extract base domain for avatar lookup
        let baseDomain = extractBaseDomain(from: ensName)
        
        // First, get the Ethereum address for avatar lookup
        APICaller.shared.resolveENSName(name: baseDomain) { [weak self] address in
            guard let self = self, !address.isEmpty else { return }
            
            // Try to fetch avatar from ENS metadata
            self.fetchAvatarFromENS(address: address)
        }
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
    
    private func fetchAvatarFromENS(address: String) {
        // Try ENS metadata first
        let metadataURL = "https://metadata.ens.domains/mainnet/\(address)/avatar"
        
        guard let url = URL(string: metadataURL) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data),
                  !data.isEmpty else {
                // Fallback to ENS Ideas API
                self?.fetchAvatarFromENSIdeas(address: address)
                return
            }
            
            DispatchQueue.main.async {
                self.avatarImageView.image = image
                self.avatarImageView.tintColor = nil
            }
        }.resume()
    }
    
    private func fetchAvatarFromENSIdeas(address: String) {
        // Fallback: try ENS Ideas API for avatar
        let ensIdeasURL = "https://api.ensideas.com/ens/resolve/\(address)"
        
        guard let url = URL(string: ensIdeasURL) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let avatarURL = json["avatar"] as? String,
                  let avatarImageURL = URL(string: avatarURL) else {
                return
            }
            
            // Fetch the actual avatar image
            URLSession.shared.dataTask(with: avatarImageURL) { data, response, error in
                guard let data = data,
                      let image = UIImage(data: data) else { return }
                
                DispatchQueue.main.async {
                    self.avatarImageView.image = image
                    self.avatarImageView.tintColor = nil
                }
            }.resume()
        }.resume()
    }
}
