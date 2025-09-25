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
    private var activeRequests: [String: DataRequest] = [:]
    
    
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
    
    deinit {
        // Cancel all active network requests
        for (_, request) in activeRequests {
            request.cancel()
        }
        activeRequests.removeAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Only reload if we don't have any contacts loaded
        if contacts.isEmpty {
            loadContacts()
        } else {
            // Just update the display without reloading data
            updateEmptyState()
            tableView.reloadData()
        }
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
        
        // Add long press gesture recognizer for edit/delete options
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        tableView.addGestureRecognizer(longPressGesture)
        
        
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
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let location = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: location) else { return }
        
        let contact = filteredContacts[indexPath.row]
        showContactOptions(for: contact, at: indexPath)
    }
    
    
    // MARK: - Data Management
    private func loadContacts() {
        // Add fallback to standard UserDefaults if App Group fails
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        
        // Load saved contacts from UserDefaults
        if let data = userDefaults.data(forKey: "savedContacts"),
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
        // Add fallback to standard UserDefaults if App Group fails
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        
        // Save contacts to UserDefaults
        if let data = try? JSONEncoder().encode(contacts) {
            userDefaults.set(data, forKey: "savedContacts")
            userDefaults.synchronize()
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
        // Add fallback to standard UserDefaults if App Group fails
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        
        let ensNames = contacts.map { $0.ensName }
        userDefaults.set(ensNames, forKey: "contactENSNames")
        userDefaults.synchronize()
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
        let alert = UIAlertController(title: contact.ensName, message: contact.name, preferredStyle: .actionSheet)
        
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
        
        // First get the Ethereum address for avatar lookup (use full ENS name for subdomain support)
        APICaller.shared.resolveENSName(name: ensName) { [weak self] ethAddress in
            guard let self = self, !ethAddress.isEmpty else { return }
            
            // Use ENS metadata API with Ethereum address (same as ENS list)
            let metadataURL = "https://metadata.ens.domains/mainnet/\(ethAddress)/avatar"
            
            let request = AF.request(metadataURL)
            activeRequests["avatar_\(baseDomain)"] = request
            request.responseString { [weak self] response in
                DispatchQueue.main.async {
                    guard let self = self,
                          index < self.contacts.count,
                          self.contacts[index].ensName == ensName else { return }
                    
                    // Remove from active requests
                    self.activeRequests.removeValue(forKey: "avatar_\(baseDomain)")
                    
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
                          let _ = URL(string: cleanURLString) else {
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
                    if indexPath.row < self.tableView.numberOfRows(inSection: 0) {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    } else {
                        // Fallback: reload entire table if index is out of bounds
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func loadContactAvatarFromENSIdeas(baseDomain: String, index: Int) {
        // Fallback: try ENS Ideas API for avatar (same as ENS list)
        let ensIdeasURL = "https://api.ensideas.com/ens/resolve/\(baseDomain)"
        
        let request = AF.request(ensIdeasURL)
        activeRequests["avatar_ideas_\(baseDomain)"] = request
        request.response { [weak self] response in
            DispatchQueue.main.async {
                guard let self = self,
                      index < self.contacts.count else { return }
                
                // Remove from active requests
                self.activeRequests.removeValue(forKey: "avatar_ideas_\(baseDomain)")
                
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
                if indexPath.row < self.tableView.numberOfRows(inSection: 0) {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                } else {
                    // Fallback: reload entire table if index is out of bounds
                    self.tableView.reloadData()
                }
            }
        }
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as? ContactTableViewCell else {
            // Fallback to basic cell if casting fails
            let fallbackCell = UITableViewCell(style: .subtitle, reuseIdentifier: "FallbackCell")
            let contact = filteredContacts[indexPath.row]
            fallbackCell.textLabel?.text = contact.name
            fallbackCell.detailTextLabel?.text = contact.ensName
            return fallbackCell
        }
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
        // No action on tap - use long press for edit/delete options
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
    
    // MARK: - Contact Resolution
    func updateContactWithResolvedName(_ contact: Contact, resolvedName: String) {
        // Find the contact in the array and update it
        if let index = contacts.firstIndex(where: { $0.ensName == contact.ensName }) {
            let updatedContact = Contact(
                name: contact.name,
                ensName: contact.ensName,
                profileImage: nil,
                address: contact.address,
                avatarURL: contact.avatarURL,
                resolvedName: resolvedName
            )
            contacts[index] = updatedContact
            saveContacts()
            
            // Reload the specific row
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func fetchResolvedNameForContact(_ contact: Contact, completion: @escaping (String?) -> Void) {
        let baseDomain = extractBaseDomain(from: contact.ensName)
        let fusionServerURL = "https://api.fusionens.com/resolve/\(baseDomain):name?network=mainnet&source=ios-app"
        
        guard let url = URL(string: fusionServerURL) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let success = json?["success"] as? Bool,
                      success,
                      let dataDict = json?["data"] as? [String: Any],
                      let fullName = dataDict["address"] as? String,
                      !fullName.isEmpty else {
                    completion(nil)
                    return
                }
                
                // Clean HTML tags if present
                let cleanName = self.cleanHTMLTags(from: fullName)
                completion(cleanName.isEmpty ? nil : cleanName)
            } catch {
                completion(nil)
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
}

// MARK: - ContactTableViewCell
class ContactTableViewCell: UITableViewCell {
    
    // MARK: - Static Cache
    private static var avatarCache: [String: UIImage] = [:]
    private static var loadingRequests: Set<String> = []
    private static let maxCacheSize = 50 // Limit cache size to prevent memory issues
    
    // MARK: - Disk Cache
    private static let cacheDirectory: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheURL = urls[0].appendingPathComponent("ContactAvatars")
        try? FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true)
        return cacheURL
    }()
    
    private static func cacheImageToDisk(_ image: UIImage, for key: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let fileURL = cacheDirectory.appendingPathComponent("\(key.hash).jpg")
        try? data.write(to: fileURL)
    }
    
    private static func loadImageFromDisk(for key: String) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key.hash).jpg")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Clear the avatar image to prevent showing wrong avatar during cell reuse
        profileImageView.image = nil
        currentContact = nil
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
        efpButton.setTitle("Follow Protocol", for: .normal)
        efpButton.setTitleColor(.white, for: .normal)
        efpButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        efpButton.backgroundColor = ColorTheme.accent
        efpButton.layer.cornerRadius = 10
        efpButton.layer.borderWidth = 1
        efpButton.layer.borderColor = ColorTheme.accent.cgColor
        efpButton.translatesAutoresizingMaskIntoConstraints = false
        efpButton.addTarget(self, action: #selector(efpButtonTapped), for: .touchUpInside)
        cardView.addSubview(efpButton)
        
        // Send Crypto Button (Text)
        sendCryptoButton.setTitle("Send Crypto", for: .normal)
        sendCryptoButton.setTitleColor(.white, for: .normal)
        sendCryptoButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        sendCryptoButton.backgroundColor = ColorTheme.accent
        sendCryptoButton.layer.cornerRadius = 10
        sendCryptoButton.layer.borderWidth = 1
        sendCryptoButton.layer.borderColor = ColorTheme.accent.cgColor
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
            efpButton.heightAnchor.constraint(equalToConstant: 36),
            efpButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            
            // Send Crypto Button (positioned under the name with padding, next to EFP)
            sendCryptoButton.leadingAnchor.constraint(equalTo: efpButton.trailingAnchor, constant: 12),
            sendCryptoButton.topAnchor.constraint(equalTo: efpButton.topAnchor),
            sendCryptoButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            sendCryptoButton.heightAnchor.constraint(equalToConstant: 36),
            
            // Make both buttons equal width
            efpButton.widthAnchor.constraint(equalTo: sendCryptoButton.widthAnchor)
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
            // If no resolved name, show a fallback and try to fetch it in background
            nameLabel.text = contact.name.isEmpty ? contact.ensName : contact.name
            nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            nameLabel.textColor = ColorTheme.secondaryText.withAlphaComponent(0.7)
            
            // Try to fetch the resolved name in background (don't show loading)
            if let contactsVC = self.findViewController() as? ContactsViewController {
                contactsVC.fetchResolvedNameForContact(contact) { [weak self] (resolvedName: String?) in
                    DispatchQueue.main.async {
                        if let resolvedName = resolvedName, !resolvedName.isEmpty {
                            self?.nameLabel.text = resolvedName
                            self?.nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
                            self?.nameLabel.textColor = ColorTheme.secondaryText
                            
                            // Update the contact in the view controller
                            contactsVC.updateContactWithResolvedName(contact, resolvedName: resolvedName)
                        }
                        // If fetch fails, keep showing the fallback (don't change to "Unknown Name")
                    }
                }
            }
        }
        
        // Set profile image without caching (always load fresh)
        if let avatarURL = contact.avatarURL {
            
            // Check if already loading
            if Self.loadingRequests.contains(avatarURL) {
                return
            }
            
            // Mark as loading
            Self.loadingRequests.insert(avatarURL)
            
            // Load avatar from URL without caching
            loadAvatarWithRetry(from: avatarURL, contact: contact, retryCount: 0)
        } else {
            // Create a placeholder with the first letter of the ENS name
            let firstLetter = String(contact.ensName.prefix(1)).uppercased()
            profileImageView.image = createPlaceholderImage(with: firstLetter)
        }
    }
    
    private func loadAvatarWithRetry(from avatarURL: String, contact: Contact, retryCount: Int) {
        let maxRetries = 2
        
        // Check if this is a local file path or file URL
        if avatarURL.hasPrefix("file://") || avatarURL.hasPrefix("/") {
            // Handle local file
            let fileURL: URL
            if avatarURL.hasPrefix("file://") {
                guard let url = URL(string: avatarURL) else {
                    // Invalid file URL, use placeholder
                    let firstLetter = String(contact.name.prefix(1)).uppercased()
                    self.profileImageView.image = self.createPlaceholderImage(with: firstLetter)
                    return
                }
                fileURL = url
            } else {
                // It's a file path
                fileURL = URL(fileURLWithPath: avatarURL)
            }
            
            guard let imageData = try? Data(contentsOf: fileURL),
                  let image = UIImage(data: imageData) else {
                // File doesn't exist or can't be loaded, use placeholder
                let firstLetter = String(contact.name.prefix(1)).uppercased()
                self.profileImageView.image = self.createPlaceholderImage(with: firstLetter)
                return
            }
            
            // Remove from loading requests
            Self.loadingRequests.remove(avatarURL)
            
            // Display the local image
            self.profileImageView.image = image
            return
        }
        
        // Handle network URL
        APICaller.shared.fetchAvatar(from: avatarURL) { [weak self] image in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Remove from loading requests
                Self.loadingRequests.remove(avatarURL)
                
                if let image = image {
                    // Don't cache - always load fresh
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
        // For Ethereum, use standard ENS resolution (same as keyboards and payment requests)
        if chain == .ethereum {
            APICaller.shared.resolveENSName(name: ensName) { resolvedAddress in
                DispatchQueue.main.async {
                    completion(resolvedAddress.isEmpty ? nil : resolvedAddress)
                }
            }
            return
        }
        
        // For other chains, use multi-chain resolution
        let baseDomain = extractBaseDomain(from: ensName)
        let chainSuffix = getChainSuffix(for: chain)
        let fullENSName = "\(baseDomain):\(chainSuffix)"
        
        // Resolve using APICaller
        APICaller.shared.resolveENSName(name: fullENSName) { resolvedAddress in
            
            // Additional validation: if we're looking for a non-ETH chain but got an ETH address, it's likely a fallback
            if chain != .ethereum && resolvedAddress.hasPrefix("0x") && resolvedAddress.count == 42 {
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
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        let useTrustWallet = userDefaults.bool(forKey: "useTrustWalletScheme")
        
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

// MARK: - UIView Extension
extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
