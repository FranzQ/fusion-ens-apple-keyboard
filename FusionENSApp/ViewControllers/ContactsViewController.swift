import UIKit
import Alamofire

class ContactsViewController: UIViewController, AddContactViewControllerDelegate {
    
    // MARK: - UI Components
    private let contentView = UIView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()
    private let addContactButton = UIButton(type: .system)
    private let emptyStateView = UIView()
    private let emptyStateLabel = UILabel()
    
    
    
    // MARK: - Data
    private var contacts: [Contact] = []
    private var filteredContacts: [Contact] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadContacts()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = ColorTheme.primaryBackground
        
        // Navigation Bar
        navigationItem.title = "Contacts"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: ColorTheme.primaryText]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: ColorTheme.primaryText]
        navigationController?.navigationBar.barTintColor = ColorTheme.navigationBarBackground
        navigationController?.navigationBar.tintColor = ColorTheme.navigationBarTint
        
        setupContent()
        setupConstraints()
    }
    
    private func setupContent() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        // Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search contacts"
        searchController.searchBar.barTintColor = ColorTheme.secondaryBackground
        searchController.searchBar.searchTextField.backgroundColor = ColorTheme.searchBarBackground
        searchController.searchBar.searchTextField.textColor = ColorTheme.primaryText
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        
        // Add Contact Button
        addContactButton.setTitle("+ Add Contact", for: .normal)
        addContactButton.setTitleColor(.white, for: .normal)
        addContactButton.backgroundColor = ColorTheme.tabBarTint
        addContactButton.layer.cornerRadius = 8
        addContactButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addContactButton.translatesAutoresizingMaskIntoConstraints = false
        addContactButton.addTarget(self, action: #selector(addContactButtonTapped), for: .touchUpInside)
        view.addSubview(addContactButton)
        
        // Table View
        tableView.backgroundColor = ColorTheme.primaryBackground
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "ContactCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        
        // Empty State View
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        
        emptyStateLabel.text = "No contacts yet\nTap '+ Add Contact' to get started"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emptyStateLabel.textColor = ColorTheme.secondaryText
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(emptyStateLabel)
    }
    
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Table View
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addContactButton.topAnchor, constant: -16),
            
            // Add Contact Button
            addContactButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addContactButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addContactButton.heightAnchor.constraint(equalToConstant: 50),
            addContactButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            // Empty State View
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func addContactButtonTapped() {
        showAddContactModal()
    }
    
    
    // MARK: - Data Management
    private func loadContacts() {
        // Load saved contacts from UserDefaults
        if let data = UserDefaults(suiteName: "group.com.fusionens.keyboard")?.data(forKey: "savedContacts"),
           let savedContacts = try? JSONDecoder().decode([Contact].self, from: data) {
            contacts = savedContacts
        } else {
            contacts = []
        }
        
        filteredContacts = contacts
        updateEmptyState()
        tableView.reloadData()
        
        // Save ENS names from contacts to shared storage for keyboard suggestions
        saveENSNamesToSharedStorage()
    }
    
    private func saveContacts() {
        // Save contacts to UserDefaults
        if let data = try? JSONEncoder().encode(contacts) {
            UserDefaults(suiteName: "group.com.fusionens.keyboard")?.set(data, forKey: "savedContacts")
            UserDefaults(suiteName: "group.com.fusionens.keyboard")?.synchronize()
        }
        
        // Also save ENS names for keyboard suggestions
        saveENSNamesToSharedStorage()
    }
    
    private func updateEmptyState() {
        let hasContacts = !filteredContacts.isEmpty
        emptyStateView.isHidden = hasContacts
        tableView.isHidden = !hasContacts
    }
    
    private func saveENSNamesToSharedStorage() {
        let ensNames = contacts.map { $0.ensName }
        UserDefaults(suiteName: "group.com.fusionens.keyboard")?.set(ensNames, forKey: "savedENSNames")
        UserDefaults(suiteName: "group.com.fusionens.keyboard")?.synchronize()
    }
    
    private func filterContacts(with searchText: String) {
        if searchText.isEmpty {
            filteredContacts = contacts
        } else {
            filteredContacts = contacts.filter { contact in
                contact.name.lowercased().contains(searchText.lowercased()) ||
                contact.ensName.lowercased().contains(searchText.lowercased())
            }
        }
        updateEmptyState()
        tableView.reloadData()
    }
    
    // MARK: - Add Contact Functionality
    private func showAddContactModal() {
        let addContactVC = AddContactViewController()
        addContactVC.delegate = self
        addContactVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        addContactVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(addContactVC, animated: true)
    }
    
    private func addContact(_ contact: Contact) {
        // Add to contacts array
        contacts.insert(contact, at: 0) // Add to top of list
        
        // Save contacts to persistent storage
        saveContacts()
        
        // Update filtered contacts
        filterContacts(with: searchController.searchBar.text ?? "")
        
        // Fetch ENS metadata and avatar
        fetchContactMetadata(for: contact.ensName, at: 0)
        
        // Update UI
        updateEmptyState()
        tableView.reloadData()
    }
    
    private func showLoadingAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func fetchContactMetadata(for ensName: String, at index: Int) {
        // Use the same approach as ENS list for consistency
        let baseDomain = extractBaseDomain(from: ensName)
        
        // First get the Ethereum address for avatar lookup
        APICaller.shared.resolveENSName(name: baseDomain) { [weak self] ethAddress in
            guard let self = self, !ethAddress.isEmpty else { return }
            
            // Use ENS metadata API with Ethereum address (same as ENS list)
            let metadataURL = "https://metadata.ens.domains/mainnet/\(ethAddress)/avatar"
            
            AF.request(metadataURL).responseString { [weak self] response in
                DispatchQueue.main.async {
                    guard let self = self,
                          index < self.contacts.count,
                          self.contacts[index].ensName == ensName else { return }
                    
                    guard let avatarURLString = response.value,
                          !avatarURLString.isEmpty,
                          avatarURLString != "data:image/svg+xml;base64," else {
                        // Fallback: try ENS Ideas API for avatar
                        self.loadContactAvatarFromENSIdeas(baseDomain: baseDomain, index: index)
                        return
                    }
                    
                    // Check if the response is a JSON error message
                    if avatarURLString.hasPrefix("{") && avatarURLString.contains("message") {
                        // Fallback: try ENS Ideas API for avatar
                        self.loadContactAvatarFromENSIdeas(baseDomain: baseDomain, index: index)
                        return
                    }
                    
                    // Clean HTML tags if present
                    let cleanURLString = self.cleanHTMLTags(from: avatarURLString)
                    
                    // Check if it's a valid URL
                    guard !cleanURLString.isEmpty,
                          let url = URL(string: cleanURLString) else {
                        // Fallback: try ENS Ideas API for avatar
                        self.loadContactAvatarFromENSIdeas(baseDomain: baseDomain, index: index)
                        return
                    }
                    
                    // Update contact with avatar URL
                    let updatedContact = Contact(
                        name: self.contacts[index].name,
                        ensName: self.contacts[index].ensName,
                        profileImage: nil,
                        address: self.contacts[index].address,
                        avatarURL: cleanURLString
                    )
                    
                    self.contacts[index] = updatedContact
                    
                    // Save updated contacts
                    self.saveContacts()
                    
                    // Reload the specific cell
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    private func loadContactAvatarFromENSIdeas(baseDomain: String, index: Int) {
        // Fallback: try ENS Ideas API for avatar (same as ENS list)
        let ensIdeasURL = "https://api.ensideas.com/ens/resolve/\(baseDomain)"
        
        AF.request(ensIdeasURL).response { [weak self] response in
            DispatchQueue.main.async {
                guard let self = self,
                      index < self.contacts.count else { return }
                
                guard let data = response.data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let avatarURL = json["avatar"] as? String,
                      !avatarURL.isEmpty else { return }
                
                // Update contact with avatar URL
                let updatedContact = Contact(
                    name: self.contacts[index].name,
                    ensName: self.contacts[index].ensName,
                    profileImage: nil,
                    address: self.contacts[index].address,
                    avatarURL: avatarURL
                )
                
                self.contacts[index] = updatedContact
                
                // Save updated contacts
                self.saveContacts()
                
                // Reload the specific cell
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
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
    
}

// MARK: - UITableViewDataSource
extension ContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactTableViewCell
        let contact = filteredContacts[indexPath.row]
        cell.configure(with: contact)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contact = filteredContacts[indexPath.row]
        // Handle contact selection
        print("Selected contact: \(contact.name) (\(contact.ensName))")
    }
}

// MARK: - UISearchResultsUpdating
extension ContactsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filterContacts(with: searchText)
    }
}

// MARK: - ContactTableViewCell
class ContactTableViewCell: UITableViewCell {
    
    // MARK: - Static Cache
    private static var avatarCache: [String: UIImage] = [:]
    private static var loadingRequests: Set<String> = []
    
    private let cardView = UIView()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let ensNameLabel = UILabel()
    private let efpButton = UIButton(type: .system)
    private let sendCryptoButton = UIButton(type: .system)
    
    private var currentContact: Contact?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Card View
        cardView.backgroundColor = ColorTheme.cardBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.1
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        // Profile Image
        profileImageView.backgroundColor = ColorTheme.tabBarTint
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(profileImageView)
        
        // Name Label
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = ColorTheme.primaryText
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
        // ENS Name Label
        ensNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        ensNameLabel.textColor = ColorTheme.tabBarTint
        ensNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(ensNameLabel)
        
        // EFP Button
        efpButton.setTitle("EFP", for: .normal)
        efpButton.setTitleColor(ColorTheme.tabBarTint, for: .normal)
        efpButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        efpButton.backgroundColor = ColorTheme.tabBarTint.withAlphaComponent(0.1)
        efpButton.layer.cornerRadius = 8
        efpButton.translatesAutoresizingMaskIntoConstraints = false
        efpButton.addTarget(self, action: #selector(efpButtonTapped), for: .touchUpInside)
        cardView.addSubview(efpButton)
        
        // Send Crypto Button (Text)
        sendCryptoButton.setTitle("Send Crypto", for: .normal)
        sendCryptoButton.setTitleColor(.white, for: .normal)
        sendCryptoButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        sendCryptoButton.backgroundColor = ColorTheme.tabBarTint
        sendCryptoButton.layer.cornerRadius = 8
        sendCryptoButton.translatesAutoresizingMaskIntoConstraints = false
        sendCryptoButton.addTarget(self, action: #selector(sendCryptoButtonTapped), for: .touchUpInside)
        cardView.addSubview(sendCryptoButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Card View
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Profile Image
            profileImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Name Label
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: efpButton.leadingAnchor, constant: -8),
            
            // ENS Name Label
            ensNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            ensNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            ensNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            // EFP Button
            efpButton.trailingAnchor.constraint(equalTo: sendCryptoButton.leadingAnchor, constant: -8),
            efpButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            efpButton.widthAnchor.constraint(equalToConstant: 50),
            efpButton.heightAnchor.constraint(equalToConstant: 28),
            
            // Send Crypto Button
            sendCryptoButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            sendCryptoButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            sendCryptoButton.widthAnchor.constraint(equalToConstant: 80),
            sendCryptoButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    func configure(with contact: Contact) {
        currentContact = contact
        nameLabel.text = contact.name
        ensNameLabel.text = contact.ensName
        
        // Set profile image with caching
        if let avatarURL = contact.avatarURL {
            // Check cache first
            if let cachedImage = Self.avatarCache[avatarURL] {
                profileImageView.image = cachedImage
                return
            }
            
            // Check if already loading
            if Self.loadingRequests.contains(avatarURL) {
                return
            }
            
            // Mark as loading
            Self.loadingRequests.insert(avatarURL)
            
            // Load avatar from URL with caching
            APICaller.shared.fetchAvatar(from: avatarURL) { [weak self] image in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    // Remove from loading requests
                    Self.loadingRequests.remove(avatarURL)
                    
                    if let image = image {
                        // Cache the image
                        Self.avatarCache[avatarURL] = image
                        self.profileImageView.image = image
                    } else {
                        // Fallback to placeholder if avatar loading fails
                        let firstLetter = String(contact.name.prefix(1)).uppercased()
                        self.profileImageView.image = self.createPlaceholderImage(with: firstLetter)
                    }
                }
            }
        } else {
            // Create a placeholder with the first letter of the name
            let firstLetter = String(contact.name.prefix(1)).uppercased()
            profileImageView.image = createPlaceholderImage(with: firstLetter)
        }
    }
    
    private func createPlaceholderImage(with text: String) -> UIImage? {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(ColorTheme.tabBarTint.cgColor)
        context?.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: UIColor.white
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: attributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    @objc private func efpButtonTapped() {
        // Open EFP app site with the contact's ENS name
        guard let contact = getCurrentContact() else { return }
        
        let ensName = contact.ensName
        let efpURL = "https://efp.app/\(ensName)"
        
        if let url = URL(string: efpURL) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func sendCryptoButtonTapped() {
        // Show chain selection and create deeplink
        showChainSelection()
    }
    
    private func showChainSelection() {
        let alert = UIAlertController(title: "Select Blockchain", message: "Choose which blockchain to send crypto", preferredStyle: .actionSheet)
        
        // Use the same chains as QR creation
        for chain in PaymentChain.allCases {
            let action = UIAlertAction(title: chain.displayName, style: .default) { [weak self] _ in
                self?.createAndOpenDeeplink(chain: chain)
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sendCryptoButton
            popover.sourceRect = sendCryptoButton.bounds
        }
        
        // Find the view controller to present the alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            var topController = rootViewController
            while let presentedController = topController.presentedViewController {
                topController = presentedController
            }
            topController.present(alert, animated: true)
        }
    }
    
    private func createAndOpenDeeplink(chain: PaymentChain) {
        // Get the contact's address
        guard let contact = getCurrentContact(),
              let address = contact.address else {
            return
        }
        
        // Check wallet preference setting (same as QR creation)
        let useTrustWallet = UserDefaults(suiteName: "group.com.fusionens.keyboard")?.bool(forKey: "useTrustWalletScheme") ?? true
        
        let deeplinkURL: String
        if useTrustWallet {
            // Use Trust Wallet scheme for all cryptocurrencies
            switch chain {
            case .bitcoin:
                deeplinkURL = "trust://send?coin=0&address=\(address)"
            case .ethereum:
                // For Ethereum with Trust Wallet, use ENS name instead of resolved address
                let ethereumAddress = contact.ensName
                deeplinkURL = "trust://send?coin=60&address=\(ethereumAddress)"
            case .solana:
                deeplinkURL = "trust://send?coin=501&address=\(address)"
            case .dogecoin:
                deeplinkURL = "trust://send?coin=3&address=\(address)"
            case .xrp:
                deeplinkURL = "trust://send?coin=144&address=\(address)"
            case .litecoin:
                deeplinkURL = "trust://send?coin=2&address=\(address)"
            case .cardano:
                deeplinkURL = "trust://send?coin=1815&address=\(address)"
            case .polkadot:
                deeplinkURL = "trust://send?coin=354&address=\(address)"
            }
        } else {
            // Use standard schemes for broader wallet compatibility (MetaMask, etc.)
            switch chain {
            case .bitcoin:
                deeplinkURL = "bitcoin:\(address)"
            case .ethereum:
                deeplinkURL = "ethereum:\(address)"
            case .solana:
                deeplinkURL = "solana:\(address)"
            case .dogecoin:
                deeplinkURL = "dogecoin:\(address)"
            case .xrp:
                deeplinkURL = "xrp:\(address)"
            case .litecoin:
                deeplinkURL = "litecoin:\(address)"
            case .cardano:
                deeplinkURL = "cardano:\(address)"
            case .polkadot:
                deeplinkURL = "polkadot:\(address)"
            }
        }
        
        // Open the deeplink
        if let url = URL(string: deeplinkURL) {
            UIApplication.shared.open(url)
        }
    }
    
    private func getCurrentContact() -> Contact? {
        return currentContact
    }
}

// MARK: - AddContactViewControllerDelegate
extension ContactsViewController {
    func didAddContact(_ contact: Contact) {
        addContact(contact)
    }
}

// MARK: - Contact Model
struct Contact: Codable {
    let name: String
    let ensName: String
    let address: String?
    let avatarURL: String?
    
    // Note: profileImage is not persisted as UIImage can't be directly encoded
    // It will be loaded from avatarURL when needed
    
    init(name: String, ensName: String, profileImage: UIImage? = nil, address: String?, avatarURL: String? = nil) {
        self.name = name
        self.ensName = ensName
        self.address = address
        self.avatarURL = avatarURL
    }
}
