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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Clear avatar caches to free memory
        ContactTableViewCell.clearAvatarCache()
        ENSNameTableViewCell.clearAvatarCache()
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
    
    private func showContactOptions(for contact: Contact, at indexPath: IndexPath) {
        let alert = UIAlertController(title: contact.name, message: contact.ensName, preferredStyle: .actionSheet)
        
        // Edit action
        alert.addAction(UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            self?.editContact(contact, at: indexPath)
        })
        
        // Delete action
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteContact(contact, at: indexPath)
        })
        
        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad
        if let popover = alert.popoverPresentationController {
            let cell = tableView.cellForRow(at: indexPath)
            popover.sourceView = cell
            popover.sourceRect = cell?.bounds ?? CGRect.zero
        }
        
        present(alert, animated: true)
    }
    
    private func editContact(_ contact: Contact, at indexPath: IndexPath) {
        let editContactVC = AddContactViewController()
        editContactVC.delegate = self
        editContactVC.contactToEdit = contact
        editContactVC.editingIndexPath = indexPath
        editContactVC.modalPresentationStyle = .overFullScreen
        editContactVC.modalTransitionStyle = .crossDissolve
        present(editContactVC, animated: true)
    }
    
    private func deleteContact(_ contact: Contact, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete Contact",
            message: "Are you sure you want to delete \(contact.name)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDeleteContact(contact, at: indexPath)
        })
        
        present(alert, animated: true)
    }
    
    private func performDeleteContact(_ contact: Contact, at indexPath: IndexPath) {
        // Remove from contacts array
        contacts.removeAll { $0.name == contact.name && $0.ensName == contact.ensName }
        
        // Update filtered contacts
        filterContacts(with: searchController.searchBar.text ?? "")
        
        // Save contacts
        saveContacts()
        
        // Update UI
        updateEmptyState()
        tableView.reloadData()
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
    
    func extractBaseDomain(from ensName: String) -> String {
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
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contact = filteredContacts[indexPath.row]
        showContactOptions(for: contact, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = filteredContacts[indexPath.row]
            deleteContact(contact, at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
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
    private static let maxCacheSize = 50 // Limit cache size to prevent memory issues
    
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
        
        // ENS Name Label (primary, bold)
        ensNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        ensNameLabel.textColor = ColorTheme.primaryText
        ensNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(ensNameLabel)
        
        // Name Label (secondary, resolved name)
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        nameLabel.textColor = ColorTheme.secondaryText
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
        // EFP Button
        efpButton.setTitle("EFP", for: .normal)
        efpButton.setTitleColor(.white, for: .normal)
        efpButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        efpButton.backgroundColor = ColorTheme.cardBackground.withAlphaComponent(0.8)
        efpButton.layer.cornerRadius = 10
        efpButton.layer.borderWidth = 1
        efpButton.layer.borderColor = ColorTheme.secondaryText.withAlphaComponent(0.3).cgColor
        efpButton.translatesAutoresizingMaskIntoConstraints = false
        efpButton.addTarget(self, action: #selector(efpButtonTapped), for: .touchUpInside)
        cardView.addSubview(efpButton)
        
        // Send Crypto Button (Text)
        sendCryptoButton.setTitle("Send Crypto", for: .normal)
        sendCryptoButton.setTitleColor(.white, for: .normal)
        sendCryptoButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        sendCryptoButton.backgroundColor = ColorTheme.cardBackground.withAlphaComponent(0.8)
        sendCryptoButton.layer.cornerRadius = 10
        sendCryptoButton.layer.borderWidth = 1
        sendCryptoButton.layer.borderColor = ColorTheme.secondaryText.withAlphaComponent(0.3).cgColor
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
            profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // ENS Name Label (primary, top)
            ensNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            ensNameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            ensNameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // Name Label (secondary, below ENS name)
            nameLabel.leadingAnchor.constraint(equalTo: ensNameLabel.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: ensNameLabel.bottomAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: ensNameLabel.trailingAnchor),
            
            // EFP Button (positioned under the name with padding)
            efpButton.leadingAnchor.constraint(equalTo: ensNameLabel.leadingAnchor),
            efpButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            efpButton.widthAnchor.constraint(equalToConstant: 60),
            efpButton.heightAnchor.constraint(equalToConstant: 36),
            efpButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            
            // Send Crypto Button (positioned under the name with padding, next to EFP)
            sendCryptoButton.leadingAnchor.constraint(equalTo: efpButton.trailingAnchor, constant: 12),
            sendCryptoButton.topAnchor.constraint(equalTo: efpButton.topAnchor),
            sendCryptoButton.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -16),
            sendCryptoButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func configure(with contact: Contact) {
        currentContact = contact
        
        // Display format: ENS Name first, then resolved name (like My ENS Names page)
        ensNameLabel.text = contact.ensName
        
        // Use the resolved name from ENS query as the secondary name
        if let resolvedName = contact.resolvedName, !resolvedName.isEmpty {
            nameLabel.text = resolvedName
            nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            nameLabel.textColor = ColorTheme.secondaryText
        } else {
            // If no resolved name, try to fetch it
            nameLabel.text = "Loading..."
            nameLabel.font = UIFont.italicSystemFont(ofSize: 14)
            nameLabel.textColor = ColorTheme.secondaryText.withAlphaComponent(0.7)
            
            // Try to fetch the resolved name
            fetchResolvedNameForContact(contact)
        }
        
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
            
            // Load avatar from URL with caching and retry logic
            loadAvatarWithRetry(from: avatarURL, contact: contact, retryCount: 0)
        } else {
            // Create a placeholder with the first letter of the ENS name
            let firstLetter = String(contact.ensName.prefix(1)).uppercased()
            profileImageView.image = createPlaceholderImage(with: firstLetter)
        }
    }
    
    private func loadAvatarWithRetry(from avatarURL: String, contact: Contact, retryCount: Int) {
        let maxRetries = 2
        
            APICaller.shared.fetchAvatar(from: avatarURL) { [weak self] image in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    // Remove from loading requests
                    Self.loadingRequests.remove(avatarURL)
                    
                    if let image = image {
                        // Cache the image with size limit
                        Self.addToCache(image, for: avatarURL)
                        self.profileImageView.image = image
                } else if retryCount < maxRetries {
                    // Retry loading with exponential backoff
                    let delay = Double(retryCount + 1) * 1.0 // 1s, 2s delays
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        self.loadAvatarWithRetry(from: avatarURL, contact: contact, retryCount: retryCount + 1)
                    }
                    } else {
                    // Final fallback to placeholder if all retries fail
                        let firstLetter = String(contact.name.prefix(1)).uppercased()
                        self.profileImageView.image = self.createPlaceholderImage(with: firstLetter)
                    }
                }
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
        // Get the contact
        guard let contact = getCurrentContact() else {
            showErrorAlert(message: "Contact not available")
            return
        }
        
        // Always resolve ENS first to check if mapping exists
        resolveENSForChain(ensName: contact.ensName, chain: chain) { [weak self] resolvedAddress in
            DispatchQueue.main.async {
                if let address = resolvedAddress {
                    // Address found, create and open deeplink
                    self?.openDeeplinkWithAddress(address: address, ensName: contact.ensName, chain: chain)
                } else {
                    // No address found for this chain, show options
                    self?.showChainNotMappedAlert(ensName: contact.ensName, chain: chain)
                }
            }
        }
    }
    
    private func resolveENSForChain(ensName: String, chain: PaymentChain, completion: @escaping (String?) -> Void) {
        // Extract base domain from ENS name (handle formats like vitalik.eth:btc)
        let baseDomain = extractBaseDomain(from: ensName)
        
        // Create the full ENS name with chain suffix
        let chainSuffix = getChainSuffix(for: chain)
        let fullENSName = "\(baseDomain):\(chainSuffix)"
        
        print("🔍 Resolving ENS for chain: \(fullENSName)")
        
        // Resolve using APICaller
        APICaller.shared.resolveENSName(name: fullENSName) { resolvedAddress in
            print("🔍 Resolved address for \(fullENSName): \(resolvedAddress)")
            
            // Additional validation: if we're looking for a non-ETH chain but got an ETH address, it's likely a fallback
            if chain != .ethereum && resolvedAddress.hasPrefix("0x") && resolvedAddress.count == 42 {
                print("⚠️ Got Ethereum address for non-ETH chain, treating as no mapping")
                completion(nil)
            } else {
                completion(resolvedAddress.isEmpty ? nil : resolvedAddress)
            }
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
    
    private func openDeeplinkWithAddress(address: String, ensName: String, chain: PaymentChain) {
        // Check wallet preference setting
        let useTrustWallet = UserDefaults(suiteName: "group.com.fusionens.keyboard")?.bool(forKey: "useTrustWalletScheme") ?? true
        
        // For Trust Wallet, use ENS name in deeplink (since mapping exists)
        // For other wallets, use the resolved address
        let effectiveAddress = useTrustWallet ? ensName : address
        
        let deeplinkInfo = createDeeplinkInfo(chain: chain, address: effectiveAddress, ensName: ensName, useTrustWallet: useTrustWallet)
        
        // Validate and open deeplink
        openDeeplinkWithValidation(deeplinkInfo: deeplinkInfo, chain: chain)
    }
    
    private func showChainNotMappedAlert(ensName: String, chain: PaymentChain) {
        let alert = UIAlertController(
            title: "\(chain.displayName) Address Not Found",
            message: "The ENS name '\(ensName)' doesn't have a \(chain.displayName) address mapped. Would you like to:",
            preferredStyle: .alert
        )
        
        // Option 1: Add the address mapping
        alert.addAction(UIAlertAction(title: "Add \(chain.displayName) Address", style: .default) { [weak self] _ in
            self?.openENSAppToAddAddress(ensName: ensName, chain: chain)
        })
        
        // Option 2: Choose a different chain
        alert.addAction(UIAlertAction(title: "Choose Different Chain", style: .default) { [weak self] _ in
            self?.showChainSelection()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
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
    
    private func openENSAppToAddAddress(ensName: String, chain: PaymentChain) {
        // Extract base domain for ENS app
        let baseDomain = extractBaseDomain(from: ensName)
        
        // Create URL for ENS app
        let ensAppURL = "https://app.ens.domains/name/\(baseDomain)"
        
        if let url = URL(string: ensAppURL) {
            UIApplication.shared.open(url) { success in
                if !success {
                    // Fallback: show instructions
                    self.showENSAppInstructions(for: baseDomain, chain: chain)
                }
            }
        }
    }
    
    private func showENSAppInstructions(for ensName: String, chain: PaymentChain) {
        let alert = UIAlertController(
            title: "Add \(chain.displayName) Address",
            message: "To add a \(chain.displayName) address for '\(ensName)', please visit:\n\napp.ens.domains/name/\(ensName)\n\nIn your browser and add the address in the 'Records' section.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Copy Link", style: .default) { _ in
            UIPasteboard.general.string = "https://app.ens.domains/name/\(ensName)"
            self.showSuccessAlert(message: "ENS app link copied to clipboard")
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
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
    
    private func createDeeplinkInfo(chain: PaymentChain, address: String, ensName: String, useTrustWallet: Bool) -> DeeplinkInfo {
        if useTrustWallet {
            // Use Trust Wallet scheme for all cryptocurrencies
            // For Trust Wallet, use ENS name instead of resolved address for better UX
            switch chain {
            case .bitcoin:
                return DeeplinkInfo(url: "trust://send?coin=0&address=\(ensName)", scheme: "trust", walletName: "Trust Wallet")
            case .ethereum:
                return DeeplinkInfo(url: "trust://send?coin=60&address=\(ensName)", scheme: "trust", walletName: "Trust Wallet")
            case .solana:
                return DeeplinkInfo(url: "trust://send?coin=501&address=\(ensName)", scheme: "trust", walletName: "Trust Wallet")
            case .dogecoin:
                return DeeplinkInfo(url: "trust://send?coin=3&address=\(ensName)", scheme: "trust", walletName: "Trust Wallet")
            case .xrp:
                return DeeplinkInfo(url: "trust://send?coin=144&address=\(ensName)", scheme: "trust", walletName: "Trust Wallet")
            case .litecoin:
                return DeeplinkInfo(url: "trust://send?coin=2&address=\(ensName)", scheme: "trust", walletName: "Trust Wallet")
            case .cardano:
                return DeeplinkInfo(url: "trust://send?coin=1815&address=\(ensName)", scheme: "trust", walletName: "Trust Wallet")
            case .polkadot:
                return DeeplinkInfo(url: "trust://send?coin=354&address=\(ensName)", scheme: "trust", walletName: "Trust Wallet")
            }
        } else {
            // Use wallet-specific schemes for better compatibility
            switch chain {
            case .bitcoin:
                return DeeplinkInfo(url: "bitcoin:\(address)", scheme: "bitcoin", walletName: "Bitcoin Wallet")
            case .ethereum:
                // Try multiple Ethereum wallet formats
                return createEthereumDeeplinkInfo(address: address, ensName: ensName)
            case .solana:
                return DeeplinkInfo(url: "solana:\(address)", scheme: "solana", walletName: "Solana Wallet")
            case .dogecoin:
                return DeeplinkInfo(url: "dogecoin:\(address)", scheme: "dogecoin", walletName: "Dogecoin Wallet")
            case .xrp:
                return DeeplinkInfo(url: "xrp:\(address)", scheme: "xrp", walletName: "XRP Wallet")
            case .litecoin:
                return DeeplinkInfo(url: "litecoin:\(address)", scheme: "litecoin", walletName: "Litecoin Wallet")
            case .cardano:
                return DeeplinkInfo(url: "cardano:\(address)", scheme: "cardano", walletName: "Cardano Wallet")
            case .polkadot:
                return DeeplinkInfo(url: "polkadot:\(address)", scheme: "polkadot", walletName: "Polkadot Wallet")
            }
        }
    }
    
    private func createEthereumDeeplinkInfo(address: String, ensName: String) -> DeeplinkInfo {
        // Use standard ENSIP-11 format as primary choice
        let ethereumURL = "ethereum:\(address)@1"
        if let url = URL(string: ethereumURL), UIApplication.shared.canOpenURL(url) {
            return DeeplinkInfo(url: ethereumURL, scheme: "ethereum", walletName: "Ethereum Wallet")
        }
        
        // Fallback to MetaMask app link if standard format doesn't work
        let metamaskURL = "https://metamask.app.link/send/\(address)@1"
        return DeeplinkInfo(url: metamaskURL, scheme: "https", walletName: "MetaMask")
    }
    
    private func openDeeplinkWithValidation(deeplinkInfo: DeeplinkInfo, chain: PaymentChain) {
        guard let url = URL(string: deeplinkInfo.url) else {
            showErrorAlert(message: "Invalid deeplink URL")
            return
        }
        
        // Check if the wallet app is installed
        if UIApplication.shared.canOpenURL(url) {
            // Wallet app is installed, open the deeplink silently
            UIApplication.shared.open(url) { [weak self] success in
                DispatchQueue.main.async {
                    if !success {
                        // Deeplink failed, try alternative scheme automatically
                        self?.tryAlternativeSchemeAutomatically(chain: chain, failedDeeplinkInfo: deeplinkInfo)
                    }
                    // If success, just let the wallet app open without any popup
                }
            }
        } else {
            // Wallet app not installed, try alternative scheme automatically first
            tryAlternativeSchemeAutomatically(chain: chain, failedDeeplinkInfo: deeplinkInfo)
        }
    }
    
    private func tryAlternativeSchemeAutomatically(chain: PaymentChain, failedDeeplinkInfo: DeeplinkInfo) {
        // Try the alternative scheme automatically before showing fallback options
        guard let contact = getCurrentContact(),
              let address = contact.address else {
            showDeeplinkFallback(deeplinkInfo: failedDeeplinkInfo, chain: chain)
            return
        }
        
        // If current scheme is Trust Wallet, try standard schemes
        // If current scheme is standard, try Trust Wallet
        let useTrustWallet = failedDeeplinkInfo.scheme != "trust"
        let alternativeInfo = createDeeplinkInfo(chain: chain, address: address, ensName: contact.ensName, useTrustWallet: useTrustWallet)
        
        // Check if alternative scheme is available
        if let alternativeURL = URL(string: alternativeInfo.url),
           UIApplication.shared.canOpenURL(alternativeURL) {
            // Alternative scheme is available, open it silently
            UIApplication.shared.open(alternativeURL) { [weak self] success in
                DispatchQueue.main.async {
                    if !success {
                        // Both schemes failed, show fallback options
                        self?.showDeeplinkFallback(deeplinkInfo: failedDeeplinkInfo, chain: chain)
                    }
                    // If success, just let the wallet app open without any popup
                }
            }
        } else {
            // Alternative scheme not available either, show fallback options
            showDeeplinkFallback(deeplinkInfo: failedDeeplinkInfo, chain: chain)
        }
    }
    
    private func showDeeplinkFallback(deeplinkInfo: DeeplinkInfo, chain: PaymentChain) {
        let alert = UIAlertController(
            title: "\(deeplinkInfo.walletName) Not Found",
            message: "The \(deeplinkInfo.walletName) app doesn't appear to be installed on your device. Would you like to:",
            preferredStyle: .alert
        )
        
        // Option 1: Copy address to clipboard
        alert.addAction(UIAlertAction(title: "Copy Address", style: .default) { [weak self] _ in
            self?.copyAddressToClipboard(deeplinkInfo: deeplinkInfo, chain: chain)
        })
        
        // Option 2: Try alternative wallet schemes (works both ways)
        let alternativeTitle = deeplinkInfo.scheme == "trust" ? "Try Standard Scheme" : "Try Trust Wallet"
        alert.addAction(UIAlertAction(title: alternativeTitle, style: .default) { [weak self] _ in
            self?.tryAlternativeScheme(chain: chain, deeplinkInfo: deeplinkInfo)
        })
        
        // Option 3: Open App Store (for Trust Wallet)
        if deeplinkInfo.scheme == "trust" {
            alert.addAction(UIAlertAction(title: "Install Trust Wallet", style: .default) { _ in
                if let appStoreURL = URL(string: "https://apps.apple.com/app/trust-crypto-bitcoin-wallet/id1288339409") {
                    UIApplication.shared.open(appStoreURL)
                }
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
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
    
    private func copyAddressToClipboard(deeplinkInfo: DeeplinkInfo, chain: PaymentChain) {
        // Extract address from the deeplink URL
        let address = extractAddressFromDeeplink(deeplinkInfo.url)
        UIPasteboard.general.string = address
        
        showSuccessAlert(message: "\(chain.displayName) address copied to clipboard")
    }
    
    private func tryAlternativeScheme(chain: PaymentChain, deeplinkInfo: DeeplinkInfo) {
        // Try the alternative scheme (Trust Wallet ↔ Standard schemes)
        guard let contact = getCurrentContact(),
              let address = contact.address else {
            showErrorAlert(message: "Contact address not available")
            return
        }
        
        // If current scheme is Trust Wallet, try standard schemes
        // If current scheme is standard, try Trust Wallet
        let useTrustWallet = deeplinkInfo.scheme != "trust"
        let alternativeInfo = createDeeplinkInfo(chain: chain, address: address, ensName: contact.ensName, useTrustWallet: useTrustWallet)
        openDeeplinkWithValidation(deeplinkInfo: alternativeInfo, chain: chain)
    }
    
    private func extractAddressFromDeeplink(_ deeplinkURL: String) -> String {
        // Extract address from various deeplink formats
        if deeplinkURL.contains("address=") {
            // Trust Wallet format: trust://send?coin=0&address=1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa
            if let range = deeplinkURL.range(of: "address=") {
                return String(deeplinkURL[range.upperBound...])
            }
        } else if deeplinkURL.contains(":") {
            // Standard format: bitcoin:1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa
            if let range = deeplinkURL.range(of: ":") {
                return String(deeplinkURL[range.upperBound...])
            }
        }
        
        return deeplinkURL
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
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
    
    private func getCurrentContact() -> Contact? {
        return currentContact
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
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
    
    private func fetchResolvedNameForContact(_ contact: Contact) {
        let baseDomain = extractBaseDomain(from: contact.ensName)
        let fusionServerURL = "https://api.fusionens.com/resolve/\(baseDomain):name?network=mainnet&source=ios-app"
        
        URLSession.shared.dataTask(with: URL(string: fusionServerURL)!) { [weak self] data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.nameLabel.text = "Unknown Name"
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let success = json?["success"] as? Bool,
                      success,
                      let dataDict = json?["data"] as? [String: Any],
                      let fullName = dataDict["address"] as? String,
                      !fullName.isEmpty else {
                    DispatchQueue.main.async {
                        self?.nameLabel.text = "Unknown Name"
                    }
                    return
                }
                
                // Clean HTML tags if present
                let cleanName = self?.cleanHTMLTags(from: fullName) ?? ""
                
                DispatchQueue.main.async {
                    if !cleanName.isEmpty {
                        self?.nameLabel.text = cleanName
                        self?.nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
                        self?.nameLabel.textColor = ColorTheme.secondaryText
                    } else {
                        self?.nameLabel.text = "Unknown Name"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.nameLabel.text = "Unknown Name"
                }
            }
        }.resume()
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
}

// MARK: - AddContactViewControllerDelegate
extension ContactsViewController {
    func didAddContact(_ contact: Contact) {
        addContact(contact)
    }
    
    func didUpdateContact(_ contact: Contact, at indexPath: IndexPath) {
        // Update the contact in the array
        contacts[indexPath.row] = contact
        
        // Update filtered contacts
        filterContacts(with: searchController.searchBar.text ?? "")
        
        // Save contacts
        saveContacts()
        
        // Update UI
        tableView.reloadData()
    }
}

// MARK: - Contact Model
struct Contact: Codable {
    let name: String
    let ensName: String
    let address: String?
    let avatarURL: String?
    let resolvedName: String?
    
    // Note: profileImage is not persisted as UIImage can't be directly encoded
    // It will be loaded from avatarURL when needed
    
    init(name: String, ensName: String, profileImage: UIImage? = nil, address: String?, avatarURL: String? = nil, resolvedName: String? = nil) {
        self.name = name
        self.ensName = ensName
        self.address = address
        self.avatarURL = avatarURL
        self.resolvedName = resolvedName
    }
}

// MARK: - Deeplink Info Model
struct DeeplinkInfo {
    let url: String
    let scheme: String
    let walletName: String
}
