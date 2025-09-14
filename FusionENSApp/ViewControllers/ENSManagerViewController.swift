//
//  ENSManagerViewController.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 12/09/2025.
//

import UIKit
import SnapKit

class ENSManagerViewController: UIViewController {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let ensCardsStackView = UIStackView()
    private let addButton = UIButton(type: .system)
    private let emptyStateView = UIView()
    private let emptyStateImageView = UIImageView()
    private let emptyStateTitleLabel = UILabel()
    private let emptyStateSubtitleLabel = UILabel()
    
    // MARK: - Data
    private var ensNames: [ENSName] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadENSNames()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadENSNames()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Navigation Bar
        navigationItem.title = "ENS Names"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        
        // Scroll View
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Header
        setupHeader()
        
        // ENS Cards Stack
        setupENSCardsStack()
        
        // Add Button
        setupAddButton()
        
        // Empty State
        setupEmptyState()
    }
    
    private func setupHeader() {
        contentView.addSubview(headerView)
        
        titleLabel.text = "Your ENS Names"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        headerView.addSubview(titleLabel)
        
        subtitleLabel.text = "Manage your ENS names and generate payment requests"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        headerView.addSubview(subtitleLabel)
    }
    
    private func setupENSCardsStack() {
        ensCardsStackView.axis = .vertical
        ensCardsStackView.spacing = 16
        ensCardsStackView.alignment = .fill
        contentView.addSubview(ensCardsStackView)
    }
    
    private func setupAddButton() {
        addButton.setTitle("+ Add ENS Name", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        addButton.backgroundColor = .systemBlue
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 12
        addButton.layer.shadowColor = UIColor.systemBlue.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addButton.layer.shadowRadius = 8
        addButton.layer.shadowOpacity = 0.3
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        contentView.addSubview(addButton)
    }
    
    private func setupEmptyState() {
        contentView.addSubview(emptyStateView)
        
        // Empty state image (using system icon)
        emptyStateImageView.image = UIImage(systemName: "globe")
        emptyStateImageView.tintColor = .systemGray3
        emptyStateImageView.contentMode = .scaleAspectFit
        emptyStateView.addSubview(emptyStateImageView)
        
        emptyStateTitleLabel.text = "No ENS Names Yet"
        emptyStateTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        emptyStateTitleLabel.textColor = .label
        emptyStateTitleLabel.textAlignment = .center
        emptyStateView.addSubview(emptyStateTitleLabel)
        
        emptyStateSubtitleLabel.text = "Add your first ENS name to start generating payment requests"
        emptyStateSubtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        emptyStateSubtitleLabel.textColor = .secondaryLabel
        emptyStateSubtitleLabel.textAlignment = .center
        emptyStateSubtitleLabel.numberOfLines = 0
        emptyStateView.addSubview(emptyStateSubtitleLabel)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Header
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // ENS Cards Stack
        ensCardsStackView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Add Button
        addButton.snp.makeConstraints { make in
            make.top.equalTo(ensCardsStackView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        // Empty State
        emptyStateView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(60)
            make.leading.trailing.equalToSuperview().inset(40)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        emptyStateImageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        emptyStateTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyStateImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
        }
        
        emptyStateSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyStateTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let vc = AddENSNameViewController()
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true)
    }
    
    // MARK: - Data Management
    private func loadENSNames() {
        // Load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "savedENSNames"),
           let names = try? JSONDecoder().decode([ENSName].self, from: data) {
            ensNames = names
        }
        
        updateUI()
    }
    
    private func updateUI() {
        // Clear existing cards
        ensCardsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if ensNames.isEmpty {
            emptyStateView.isHidden = false
            ensCardsStackView.isHidden = true
        } else {
            emptyStateView.isHidden = true
            ensCardsStackView.isHidden = false
            
            // Create cards for each ENS name
            for ensName in ensNames {
                let cardView = createENSCard(for: ensName)
                ensCardsStackView.addArrangedSubview(cardView)
            }
        }
    }
    
    private func createENSCard(for ensName: ENSName) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOpacity = 0.1
        
        // Avatar
        let avatarImageView = UIImageView()
        avatarImageView.backgroundColor = .systemBlue
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        cardView.addSubview(avatarImageView)
        
        // ENS Name
        let nameLabel = UILabel()
        nameLabel.text = ensName.name
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textColor = .label
        cardView.addSubview(nameLabel)
        
        // Display Name (if available)
        let displayNameLabel = UILabel()
        if let displayName = ensName.displayName, !displayName.isEmpty {
            displayNameLabel.text = displayName
        } else {
            displayNameLabel.text = "No display name"
        }
        displayNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        displayNameLabel.textColor = .secondaryLabel
        cardView.addSubview(displayNameLabel)
        
        // Date Added
        let dateLabel = UILabel()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateLabel.text = "Added \(formatter.string(from: ensName.dateAdded))"
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .tertiaryLabel
        cardView.addSubview(dateLabel)
        
        // Arrow
        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .tertiaryLabel
        cardView.addSubview(arrowImageView)
        
        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ensCardTapped(_:)))
        cardView.addGestureRecognizer(tapGesture)
        cardView.tag = ensNames.firstIndex(where: { $0.name == ensName.name }) ?? 0
        
        // Constraints
        cardView.snp.makeConstraints { make in
            make.height.equalTo(80)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(16)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-12)
        }
        
        displayNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.trailing.equalTo(nameLabel)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(displayNameLabel.snp.bottom).offset(4)
            make.trailing.equalTo(nameLabel)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        // Load avatar
        loadAvatar(for: ensName.name, into: avatarImageView)
        
        return cardView
    }
    
    private func loadAvatar(for ensName: String, into imageView: UIImageView) {
        // Extract base domain (remove any chain suffix)
        let baseDomain = ensName.components(separatedBy: ":").first ?? ensName
        
        // Try to resolve to Ethereum address first
        APICaller.shared.resolveENSName(name: baseDomain) { address in
            DispatchQueue.main.async {
                if !address.isEmpty {
                    // Try to load avatar from ENS metadata
                    self.loadAvatarFromENS(baseDomain: baseDomain, address: address, into: imageView)
                } else {
                    // Fallback to initials
                    self.setInitialsAvatar(for: baseDomain, into: imageView)
                }
            }
        }
    }
    
    private func loadAvatarFromENS(baseDomain: String, address: String, into imageView: UIImageView) {
        // Try ENS metadata API
        let metadataURL = "https://metadata.ens.domains/mainnet/avatar/\(baseDomain)"
        
        if let url = URL(string: metadataURL) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        imageView.image = image
                    } else {
                        // Fallback to ENS Ideas API
                        self.loadAvatarFromENSIdeas(baseDomain: baseDomain, into: imageView)
                    }
                }
            }.resume()
        } else {
            setInitialsAvatar(for: baseDomain, into: imageView)
        }
    }
    
    private func loadAvatarFromENSIdeas(baseDomain: String, into imageView: UIImageView) {
        let ensIdeasURL = "https://api.ensideas.com/ens/avatar/\(baseDomain)"
        
        if let url = URL(string: ensIdeasURL) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        imageView.image = image
                    } else {
                        self.setInitialsAvatar(for: baseDomain, into: imageView)
                    }
                }
            }.resume()
        } else {
            setInitialsAvatar(for: baseDomain, into: imageView)
        }
    }
    
    private func setInitialsAvatar(for ensName: String, into imageView: UIImageView) {
        // Create initials from ENS name
        let components = ensName.components(separatedBy: ".")
        let initials = components.prefix(2).compactMap { $0.first?.uppercased() }.joined()
        
        // Create a simple avatar with initials
        let size = CGSize(width: 50, height: 50)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            // Background
            UIColor.systemBlue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let textSize = initials.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            initials.draw(in: textRect, withAttributes: attributes)
        }
        
        imageView.image = image
    }
    
    @objc private func ensCardTapped(_ gesture: UITapGestureRecognizer) {
        guard let cardView = gesture.view,
              cardView.tag < ensNames.count else { return }
        
        let ensName = ensNames[cardView.tag]
        let vc = PaymentRequestViewController(ensName: ensName)
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true)
    }
    
    private func saveENSNames() {
        if let data = try? JSONEncoder().encode(ensNames) {
            UserDefaults.standard.set(data, forKey: "savedENSNames")
        }
    }
}

// MARK: - AddENSNameDelegate
extension ENSManagerViewController: AddENSNameDelegate {
    func didAddENSName(_ ensName: ENSName) {
        ensNames.append(ensName)
        updateUI()
        saveENSNames()
    }
}

// MARK: - ENSName Model
struct ENSName: Codable {
    let name: String
    let displayName: String?
    let dateAdded: Date
}