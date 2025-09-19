//
//  ContactsViewController.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 12/09/2025.
//

import UIKit

class ContactsViewController: UIViewController {
    
    // MARK: - UI Components
    private let contentView = UIView()
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    
    // Bottom Navigation
    private let bottomNavView = UIView()
    private let myENSButton = UIButton(type: .system)
    private let contactsButton = UIButton(type: .system)
    private let settingsNavButton = UIButton(type: .system)
    
    // MARK: - Data
    private var contacts: [Contact] = []
    private var filteredContacts: [Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        loadContacts()
        
        // Hide bottom navigation if we're in a tab bar controller
        if tabBarController != nil {
            bottomNavView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure icons are properly configured after layout
        configureButtonLayouts()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Dynamic theme background
        view.backgroundColor = ColorTheme.primaryBackground
        
        // Setup navigation bar
        setupNavigationBar()
        setupContent()
        setupBottomNavigation()
    }
    
    private func setupNavigationBar() {
        // Navigation Bar
        navigationItem.title = "Contacts"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: ColorTheme.primaryText]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: ColorTheme.primaryText]
        navigationController?.navigationBar.barTintColor = ColorTheme.navigationBarBackground
        navigationController?.navigationBar.tintColor = ColorTheme.navigationBarTint
    }
    
    private func setupContent() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        // Search Bar
        searchBar.placeholder = "Search contacts"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = ColorTheme.searchBarBackground
        searchBar.layer.cornerRadius = 12
        searchBar.layer.masksToBounds = true
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Customize search bar appearance
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = ColorTheme.searchBarBackground
            textField.textColor = ColorTheme.primaryText
            textField.attributedPlaceholder = NSAttributedString(
                string: "Search contacts",
                attributes: [NSAttributedString.Key.foregroundColor: ColorTheme.secondaryText]
            )
        }
        
        contentView.addSubview(searchBar)
        
        // Table View
        tableView.backgroundColor = ColorTheme.primaryBackground
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "ContactCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tableView)
    }
    
    private func setupBottomNavigation() {
        bottomNavView.backgroundColor = ColorTheme.tabBarBackground
        bottomNavView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomNavView)
        
        // My ENS Button
        myENSButton.setTitle("My ENS", for: .normal)
        myENSButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        myENSButton.setTitleColor(ColorTheme.tabBarUnselectedTint, for: .normal)
        myENSButton.setImage(UIImage(systemName: "person.crop.rectangle"), for: .normal)
        myENSButton.tintColor = ColorTheme.tabBarUnselectedTint
        myENSButton.translatesAutoresizingMaskIntoConstraints = false
        myENSButton.addTarget(self, action: #selector(myENSButtonTapped), for: .touchUpInside)
        bottomNavView.addSubview(myENSButton)
        
        // Contacts Button
        contactsButton.setTitle("Contacts", for: .normal)
        contactsButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        contactsButton.setTitleColor(ColorTheme.tabBarTint, for: .normal)
        contactsButton.setImage(UIImage(systemName: "person.2"), for: .normal)
        contactsButton.tintColor = ColorTheme.tabBarTint
        contactsButton.translatesAutoresizingMaskIntoConstraints = false
        contactsButton.addTarget(self, action: #selector(contactsButtonTapped), for: .touchUpInside)
        bottomNavView.addSubview(contactsButton)
        
        // Settings Nav Button
        settingsNavButton.setTitle("Settings", for: .normal)
        settingsNavButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        settingsNavButton.setTitleColor(ColorTheme.tabBarUnselectedTint, for: .normal)
        settingsNavButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        settingsNavButton.tintColor = ColorTheme.tabBarUnselectedTint
        settingsNavButton.translatesAutoresizingMaskIntoConstraints = false
        settingsNavButton.addTarget(self, action: #selector(settingsNavButtonTapped), for: .touchUpInside)
        bottomNavView.addSubview(settingsNavButton)
    }
    
    private func setupConstraints() {
        // Content Constraints
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomNavView.topAnchor),
            
            searchBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Bottom Navigation Constraints
        NSLayoutConstraint.activate([
            bottomNavView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomNavView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomNavView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomNavView.heightAnchor.constraint(equalToConstant: 80),
            
            myENSButton.leadingAnchor.constraint(equalTo: bottomNavView.leadingAnchor, constant: 20),
            myENSButton.centerYAnchor.constraint(equalTo: bottomNavView.centerYAnchor),
            myENSButton.widthAnchor.constraint(equalToConstant: 80),
            myENSButton.heightAnchor.constraint(equalToConstant: 60),
            
            contactsButton.centerXAnchor.constraint(equalTo: bottomNavView.centerXAnchor),
            contactsButton.centerYAnchor.constraint(equalTo: bottomNavView.centerYAnchor),
            contactsButton.widthAnchor.constraint(equalToConstant: 80),
            contactsButton.heightAnchor.constraint(equalToConstant: 60),
            
            settingsNavButton.trailingAnchor.constraint(equalTo: bottomNavView.trailingAnchor, constant: -20),
            settingsNavButton.centerYAnchor.constraint(equalTo: bottomNavView.centerYAnchor),
            settingsNavButton.widthAnchor.constraint(equalToConstant: 80),
            settingsNavButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Configure button layouts
        configureButtonLayouts()
    }
    
    private func configureButtonLayouts() {
        // Configure bottom navigation buttons with image and title
        [myENSButton, contactsButton, settingsNavButton].forEach { button in
            // Set content mode to ensure proper icon rendering
            button.imageView?.contentMode = .scaleAspectFit
            button.imageView?.tintColor = button.tintColor
            
            // Reset edge insets first
            button.titleEdgeInsets = UIEdgeInsets.zero
            button.imageEdgeInsets = UIEdgeInsets.zero
            
            // Configure edge insets for proper icon and text positioning
            // Move text down and center it horizontally
            button.titleEdgeInsets = UIEdgeInsets(top: 25, left: -button.imageView!.frame.width, bottom: 0, right: 0)
            // Move image up and center it horizontally
            button.imageEdgeInsets = UIEdgeInsets(top: -15, left: 0, bottom: 0, right: -button.titleLabel!.frame.width)
            
            // Ensure the button content is properly aligned
            button.contentVerticalAlignment = .center
            button.contentHorizontalAlignment = .center
            
            // Force layout update
            button.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    
    
    @objc private func myENSButtonTapped() {
        let vc = ENSManagerViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .pageSheet
        navController.modalTransitionStyle = .coverVertical
        present(navController, animated: true)
    }
    
    @objc private func contactsButtonTapped() {
        // Already on contacts page, do nothing or show feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    @objc private func settingsNavButtonTapped() {
        let vc = SettingsViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .pageSheet
        navController.modalTransitionStyle = .coverVertical
        present(navController, animated: true)
    }
    
    // MARK: - Data Management
    private func loadContacts() {
        // Load sample contacts for demonstration
        contacts = [
            Contact(name: "Ethan", ensName: "eth.eth", profileImage: nil),
            Contact(name: "Liam", ensName: "liam.eth", profileImage: nil),
            Contact(name: "Olivia", ensName: "olivia.eth", profileImage: nil),
            Contact(name: "Sophia", ensName: "sophia.eth", profileImage: nil)
        ]
        
        filteredContacts = contacts
        tableView.reloadData()
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
        tableView.reloadData()
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
        return 120
    }
}

// MARK: - UISearchBarDelegate
extension ContactsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContacts(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - ContactTableViewCell
class ContactTableViewCell: UITableViewCell {
    
    private let cardView = UIView()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let ensNameLabel = UILabel()
    private let messageButton = UIButton(type: .system)
    private let sendCryptoButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = ColorTheme.primaryBackground
        selectionStyle = .none
        
        // Card View
        cardView.backgroundColor = ColorTheme.cardBackground
        cardView.layer.cornerRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        // Profile Image
        profileImageView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.8, alpha: 1.0)
        profileImageView.layer.cornerRadius = 25
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(profileImageView)
        
        // Name Label
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = ColorTheme.primaryText
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
        // ENS Name Label
        ensNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        ensNameLabel.textColor = ColorTheme.secondaryText
        ensNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(ensNameLabel)
        
        // Message Button
        messageButton.setTitle("Message", for: .normal)
        messageButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        messageButton.setTitleColor(ColorTheme.primaryText, for: .normal)
        messageButton.backgroundColor = ColorTheme.accentSecondary
        messageButton.layer.cornerRadius = 8
        messageButton.setImage(UIImage(systemName: "message"), for: .normal)
        messageButton.tintColor = ColorTheme.primaryText
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.addTarget(self, action: #selector(messageButtonTapped), for: .touchUpInside)
        cardView.addSubview(messageButton)
        
        // Send Crypto Button
        sendCryptoButton.setTitle("Send Crypto", for: .normal)
        sendCryptoButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        sendCryptoButton.setTitleColor(ColorTheme.primaryText, for: .normal)
        sendCryptoButton.backgroundColor = ColorTheme.accentSecondary
        sendCryptoButton.layer.cornerRadius = 8
        sendCryptoButton.setImage(UIImage(systemName: "bitcoinsign.circle"), for: .normal)
        sendCryptoButton.tintColor = ColorTheme.primaryText
        sendCryptoButton.translatesAutoresizingMaskIntoConstraints = false
        sendCryptoButton.addTarget(self, action: #selector(sendCryptoButtonTapped), for: .touchUpInside)
        cardView.addSubview(sendCryptoButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            profileImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            ensNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            ensNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            ensNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            messageButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messageButton.topAnchor.constraint(equalTo: ensNameLabel.bottomAnchor, constant: 12),
            messageButton.widthAnchor.constraint(equalToConstant: 100),
            messageButton.heightAnchor.constraint(equalToConstant: 32),
            messageButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            
            sendCryptoButton.leadingAnchor.constraint(equalTo: messageButton.trailingAnchor, constant: 12),
            sendCryptoButton.topAnchor.constraint(equalTo: messageButton.topAnchor),
            sendCryptoButton.widthAnchor.constraint(equalToConstant: 120),
            sendCryptoButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(with contact: Contact) {
        nameLabel.text = contact.name
        ensNameLabel.text = contact.ensName
        
        // Set placeholder profile image with initials
        if let profileImage = contact.profileImage {
            profileImageView.image = profileImage
        } else {
            // Create initials from name
            let initials = String(contact.name.prefix(1)).uppercased()
            profileImageView.image = createInitialsImage(initials: initials)
        }
    }
    
    private func createInitialsImage(initials: String) -> UIImage? {
        let size = CGSize(width: 50, height: 50)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Background
            UIColor(red: 0.9, green: 0.9, blue: 0.8, alpha: 1.0).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor.black
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
    }
    
    @objc private func messageButtonTapped() {
        print("Message button tapped for: \(nameLabel.text ?? "")")
    }
    
    @objc private func sendCryptoButtonTapped() {
        print("Send Crypto button tapped for: \(nameLabel.text ?? "")")
    }
}

// MARK: - Contact Model
struct Contact {
    let name: String
    let ensName: String
    let profileImage: UIImage?
}
