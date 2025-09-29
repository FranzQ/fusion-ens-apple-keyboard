//
//  SettingsViewController.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 12/09/2025.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI Components
    private let contentView = UIView()
    
    private let setupCardView = UIView()
    private let setupTitleLabel = UILabel()
    private let setupDescriptionLabel = UILabel()
    private let setupChevronImageView = UIImageView()
    
    private let walletCardView = UIView()
    private let walletTitleLabel = UILabel()
    private let walletDescriptionLabel = UILabel()
    private let walletToggle = UISwitch()
    
    private let aboutCardView = UIView()
    private let aboutTitleLabel = UILabel()
    private let aboutDescriptionLabel = UILabel()
    private let aboutButton = UIButton(type: .system)
    
    private let contactCardView = UIView()
    private let contactTitleLabel = UILabel()
    private let contactDescriptionLabel = UILabel()
    private let contactButton = UIButton(type: .system)
    
    // Bottom Navigation
    private let bottomNavView = UIView()
    private let myENSButton = UIButton(type: .system)
    private let contactsButton = UIButton(type: .system)
    private let settingsNavButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let walletPreferenceKey = "useTrustWalletScheme"
    
    private var useTrustWalletScheme: Bool {
        get {
            // Add fallback to standard UserDefaults if App Group fails
            let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
            return userDefaults.bool(forKey: walletPreferenceKey)
        }
        set {
            // Add fallback to standard UserDefaults if App Group fails
            let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
            userDefaults.set(newValue, forKey: walletPreferenceKey)
            userDefaults.synchronize()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        loadSettings()
        
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
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: ColorTheme.primaryText]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: ColorTheme.primaryText]
        navigationController?.navigationBar.barTintColor = ColorTheme.navigationBarBackground
        navigationController?.navigationBar.tintColor = ColorTheme.navigationBarTint
    }
    
    private func setupContent() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        setupSetupInstructionsCard()
        setupWalletCard()
        setupAboutCard()
        setupContactCard()
    }
    
    
    private func setupWalletCard() {
        // Wallet Card
        walletCardView.backgroundColor = ColorTheme.cardBackground
        walletCardView.layer.cornerRadius = 12
        walletCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(walletCardView)
        
        // Wallet Title
        walletTitleLabel.text = "Trust Wallet Integration"
        walletTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        walletTitleLabel.textColor = ColorTheme.primaryText
        walletTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        walletCardView.addSubview(walletTitleLabel)
        
        // Wallet Description
        walletDescriptionLabel.text = "Prioritize Trust Wallet's custom scheme (trust://) for deeplinks. When disabled, prioritizes standard schemes (bitcoin:, ethereum:, etc.) but will automatically try both if needed."
        walletDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        walletDescriptionLabel.textColor = ColorTheme.secondaryText
        walletDescriptionLabel.numberOfLines = 0
        walletDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        walletCardView.addSubview(walletDescriptionLabel)
        
        // Wallet Toggle
        walletToggle.onTintColor = ColorTheme.accent
        walletToggle.backgroundColor = ColorTheme.accentSecondary
        walletToggle.layer.cornerRadius = 16
        walletToggle.addTarget(self, action: #selector(walletToggleChanged), for: .valueChanged)
        walletToggle.translatesAutoresizingMaskIntoConstraints = false
        walletCardView.addSubview(walletToggle)
    }
    
    private func setupAboutCard() {
        // About Card
        aboutCardView.backgroundColor = ColorTheme.cardBackground
        aboutCardView.layer.cornerRadius = 12
        aboutCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(aboutCardView)
        
        // About Title
        aboutTitleLabel.text = "About Fusion ENS"
        aboutTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        aboutTitleLabel.textColor = ColorTheme.primaryText
        aboutTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutCardView.addSubview(aboutTitleLabel)
        
        // About Description
        aboutDescriptionLabel.text = "Learn more about Fusion ENS on our website."
        aboutDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        aboutDescriptionLabel.textColor = ColorTheme.secondaryText
        aboutDescriptionLabel.numberOfLines = 0
        aboutDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutCardView.addSubview(aboutDescriptionLabel)
        
        // About Button
        aboutButton.setTitle("Visit Website", for: .normal)
        aboutButton.setTitleColor(.white, for: .normal)
        aboutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        aboutButton.backgroundColor = ColorTheme.accent
        aboutButton.layer.cornerRadius = 8
        aboutButton.addTarget(self, action: #selector(aboutButtonTapped), for: .touchUpInside)
        aboutButton.translatesAutoresizingMaskIntoConstraints = false
        aboutCardView.addSubview(aboutButton)
    }
    
    private func setupContactCard() {
        // Contact Card
        contactCardView.backgroundColor = ColorTheme.cardBackground
        contactCardView.layer.cornerRadius = 12
        contactCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contactCardView)
        
        // Contact Title
        contactTitleLabel.text = "Contact Support"
        contactTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        contactTitleLabel.textColor = ColorTheme.primaryText
        contactTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contactCardView.addSubview(contactTitleLabel)
        
        // Contact Description
        contactDescriptionLabel.text = "Need help or have feedback?"
        contactDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contactDescriptionLabel.textColor = ColorTheme.secondaryText
        contactDescriptionLabel.numberOfLines = 0
        contactDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contactCardView.addSubview(contactDescriptionLabel)
        
        // Contact Button
        contactButton.setTitle("Send Email", for: .normal)
        contactButton.setTitleColor(.white, for: .normal)
        contactButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        contactButton.backgroundColor = ColorTheme.accent
        contactButton.layer.cornerRadius = 8
        contactButton.addTarget(self, action: #selector(contactButtonTapped), for: .touchUpInside)
        contactButton.translatesAutoresizingMaskIntoConstraints = false
        contactCardView.addSubview(contactButton)
    }
    
    private func setupSetupInstructionsCard() {
        // Setup Instructions Card
        setupCardView.backgroundColor = ColorTheme.cardBackground
        setupCardView.layer.cornerRadius = 12
        setupCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(setupCardView)
        
        // Add tap gesture to the card
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(setupCardTapped))
        setupCardView.addGestureRecognizer(tapGesture)
        setupCardView.isUserInteractionEnabled = true
        
        // Setup Title
        setupTitleLabel.text = "Show Setup Instructions"
        setupTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        setupTitleLabel.textColor = ColorTheme.primaryText
        setupTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        setupCardView.addSubview(setupTitleLabel)
        
        // Setup Description
        setupDescriptionLabel.text = "Show the initial onboarding flow"
        setupDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        setupDescriptionLabel.textColor = ColorTheme.secondaryText
        setupDescriptionLabel.numberOfLines = 0
        setupDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        setupCardView.addSubview(setupDescriptionLabel)
        
        // Setup Chevron
        setupChevronImageView.image = UIImage(systemName: "chevron.right")
        setupChevronImageView.tintColor = ColorTheme.primaryText
        setupChevronImageView.contentMode = .scaleAspectFit
        setupChevronImageView.translatesAutoresizingMaskIntoConstraints = false
        setupCardView.addSubview(setupChevronImageView)
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
        contactsButton.setTitleColor(ColorTheme.tabBarUnselectedTint, for: .normal)
        contactsButton.setImage(UIImage(systemName: "person.2"), for: .normal)
        contactsButton.tintColor = ColorTheme.tabBarUnselectedTint
        contactsButton.translatesAutoresizingMaskIntoConstraints = false
        contactsButton.addTarget(self, action: #selector(contactsButtonTapped), for: .touchUpInside)
        bottomNavView.addSubview(contactsButton)
        
        // Settings Nav Button
        settingsNavButton.setTitle("Settings", for: .normal)
        settingsNavButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        settingsNavButton.setTitleColor(ColorTheme.tabBarTint, for: .normal)
        settingsNavButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        settingsNavButton.tintColor = ColorTheme.tabBarTint
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
            
            // Setup Instructions Card Constraints
            setupCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            setupCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            setupCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            setupCardView.heightAnchor.constraint(equalToConstant: 100),
            
            setupTitleLabel.topAnchor.constraint(equalTo: setupCardView.topAnchor, constant: 16),
            setupTitleLabel.leadingAnchor.constraint(equalTo: setupCardView.leadingAnchor, constant: 16),
            setupTitleLabel.trailingAnchor.constraint(equalTo: setupChevronImageView.leadingAnchor, constant: -16),
            
            setupChevronImageView.topAnchor.constraint(equalTo: setupCardView.topAnchor, constant: 16),
            setupChevronImageView.trailingAnchor.constraint(equalTo: setupCardView.trailingAnchor, constant: -16),
            setupChevronImageView.widthAnchor.constraint(equalToConstant: 20),
            setupChevronImageView.heightAnchor.constraint(equalToConstant: 20),
            
            setupDescriptionLabel.topAnchor.constraint(equalTo: setupTitleLabel.bottomAnchor, constant: 8),
            setupDescriptionLabel.leadingAnchor.constraint(equalTo: setupCardView.leadingAnchor, constant: 16),
            setupDescriptionLabel.trailingAnchor.constraint(equalTo: setupCardView.trailingAnchor, constant: -16),
            setupDescriptionLabel.bottomAnchor.constraint(equalTo: setupCardView.bottomAnchor, constant: -16),
            
            // Wallet Card Constraints
            walletCardView.topAnchor.constraint(equalTo: setupCardView.bottomAnchor, constant: 16),
            walletCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            walletCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            walletCardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),
            
            walletTitleLabel.topAnchor.constraint(equalTo: walletCardView.topAnchor, constant: 16),
            walletTitleLabel.leadingAnchor.constraint(equalTo: walletCardView.leadingAnchor, constant: 16),
            walletTitleLabel.trailingAnchor.constraint(equalTo: walletToggle.leadingAnchor, constant: -16),
            
            walletToggle.topAnchor.constraint(equalTo: walletCardView.topAnchor, constant: 16),
            walletToggle.trailingAnchor.constraint(equalTo: walletCardView.trailingAnchor, constant: -16),
            walletToggle.widthAnchor.constraint(equalToConstant: 51),
            walletToggle.heightAnchor.constraint(equalToConstant: 31),
            
            walletDescriptionLabel.topAnchor.constraint(equalTo: walletTitleLabel.bottomAnchor, constant: 8),
            walletDescriptionLabel.leadingAnchor.constraint(equalTo: walletCardView.leadingAnchor, constant: 16),
            walletDescriptionLabel.trailingAnchor.constraint(equalTo: walletCardView.trailingAnchor, constant: -16),
            walletDescriptionLabel.bottomAnchor.constraint(equalTo: walletCardView.bottomAnchor, constant: -16),
            
            // About Card Constraints
            aboutCardView.topAnchor.constraint(equalTo: walletCardView.bottomAnchor, constant: 16),
            aboutCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            aboutCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            aboutCardView.heightAnchor.constraint(equalToConstant: 140),
            
            aboutTitleLabel.topAnchor.constraint(equalTo: aboutCardView.topAnchor, constant: 16),
            aboutTitleLabel.leadingAnchor.constraint(equalTo: aboutCardView.leadingAnchor, constant: 16),
            aboutTitleLabel.trailingAnchor.constraint(equalTo: aboutCardView.trailingAnchor, constant: -16),
            
            aboutDescriptionLabel.topAnchor.constraint(equalTo: aboutTitleLabel.bottomAnchor, constant: 8),
            aboutDescriptionLabel.leadingAnchor.constraint(equalTo: aboutCardView.leadingAnchor, constant: 16),
            aboutDescriptionLabel.trailingAnchor.constraint(equalTo: aboutCardView.trailingAnchor, constant: -16),
            
            aboutButton.topAnchor.constraint(equalTo: aboutDescriptionLabel.bottomAnchor, constant: 16),
            aboutButton.leadingAnchor.constraint(equalTo: aboutCardView.leadingAnchor, constant: 16),
            aboutButton.trailingAnchor.constraint(equalTo: aboutCardView.trailingAnchor, constant: -16),
            aboutButton.bottomAnchor.constraint(equalTo: aboutCardView.bottomAnchor, constant: -16),
            aboutButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Contact Card Constraints
            contactCardView.topAnchor.constraint(equalTo: aboutCardView.bottomAnchor, constant: 16),
            contactCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contactCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contactCardView.heightAnchor.constraint(equalToConstant: 140),
            
            contactTitleLabel.topAnchor.constraint(equalTo: contactCardView.topAnchor, constant: 16),
            contactTitleLabel.leadingAnchor.constraint(equalTo: contactCardView.leadingAnchor, constant: 16),
            contactTitleLabel.trailingAnchor.constraint(equalTo: contactCardView.trailingAnchor, constant: -16),
            
            contactDescriptionLabel.topAnchor.constraint(equalTo: contactTitleLabel.bottomAnchor, constant: 8),
            contactDescriptionLabel.leadingAnchor.constraint(equalTo: contactCardView.leadingAnchor, constant: 16),
            contactDescriptionLabel.trailingAnchor.constraint(equalTo: contactCardView.trailingAnchor, constant: -16),
            
            contactButton.topAnchor.constraint(equalTo: contactDescriptionLabel.bottomAnchor, constant: 16),
            contactButton.leadingAnchor.constraint(equalTo: contactCardView.leadingAnchor, constant: 16),
            contactButton.trailingAnchor.constraint(equalTo: contactCardView.trailingAnchor, constant: -16),
            contactButton.bottomAnchor.constraint(equalTo: contactCardView.bottomAnchor, constant: -16),
            contactButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Bottom Navigation Constraints
        NSLayoutConstraint.activate([
            bottomNavView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomNavView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomNavView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomNavView.heightAnchor.constraint(equalToConstant: 80),
            
            myENSButton.leadingAnchor.constraint(equalTo: bottomNavView.leadingAnchor, constant: 20),
            myENSButton.centerYAnchor.constraint(equalTo: bottomNavView.centerYAnchor),
            myENSButton.widthAnchor.constraint(equalToConstant: 100),
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
            
            // Use modern UIButton.Configuration for iOS 15+
            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.plain()
                config.imagePlacement = .top
                config.imagePadding = 8
                config.titlePadding = 4
                button.configuration = config
            } else {
                // Fallback for older iOS versions
                button.titleEdgeInsets = UIEdgeInsets(top: 25, left: -button.imageView!.frame.width, bottom: 0, right: 0)
                button.imageEdgeInsets = UIEdgeInsets(top: -15, left: 0, bottom: 0, right: -button.titleLabel!.frame.width)
            }
            
            // Ensure the button content is properly aligned
            button.contentVerticalAlignment = .center
            button.contentHorizontalAlignment = .center
            
            // Force layout update
            button.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    
    
    
    @objc private func walletToggleChanged() {
        useTrustWalletScheme = walletToggle.isOn
        
        // Provide immediate feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    @objc private func aboutButtonTapped() {
        // Open Fusion ENS website
        if let url = URL(string: "https://fusionens.com") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url) { success in
                    if !success {
                        // Fallback: show alert
                        DispatchQueue.main.async {
                            self.showAlert(title: "Unable to Open Website", message: "Could not open the Fusion ENS website. Please try again later.")
                        }
                    }
                }
            } else {
                // URL scheme not supported
                showAlert(title: "Unable to Open Website", message: "Could not open the Fusion ENS website. Please try again later.")
            }
        } else {
            // Invalid URL
            showAlert(title: "Invalid URL", message: "The website URL is invalid. Please try again later.")
        }
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    @objc private func contactButtonTapped() {
        // Open email client with pre-filled email
        let email = "hello@fusionens.com"
        let subject = "Fusion ENS iOS App - Support Request"
        let body = "Hi Fusion ENS Team,\n\nI need help with:\n\n[Please describe your issue or feedback here]\n\nThanks!"
        
        // Create mailto URL with proper encoding
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = email
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        
        if let emailURL = components.url {
            if UIApplication.shared.canOpenURL(emailURL) {
                UIApplication.shared.open(emailURL) { success in
                    if !success {
                        // Fallback: copy email to clipboard
                        DispatchQueue.main.async {
                            UIPasteboard.general.string = email
                            self.showAlert(title: "Email Copied", message: "Email address copied to clipboard: \(email)")
                        }
                    }
                }
            } else {
                // Mail app not available, copy to clipboard
                UIPasteboard.general.string = email
                showAlert(title: "Email Copied", message: "Email address copied to clipboard: \(email)")
            }
        } else {
            // Fallback: copy email to clipboard
            UIPasteboard.general.string = email
            showAlert(title: "Email Copied", message: "Email address copied to clipboard: \(email)")
        }
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    @objc private func myENSButtonTapped() {
        let vc = ENSManagerViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .pageSheet
        navController.modalTransitionStyle = .coverVertical
        present(navController, animated: true)
    }
    
    @objc private func contactsButtonTapped() {
        let vc = ContactsViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .pageSheet
        navController.modalTransitionStyle = .coverVertical
        present(navController, animated: true)
    }
    
    @objc private func settingsNavButtonTapped() {
        // Already on settings page, do nothing or show feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    @objc private func setupCardTapped() {
        // Navigate to onboarding flow
        let vc = GettingStartedVC()
        vc.isFromSettings = true
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .pageSheet
        navController.modalTransitionStyle = .coverVertical
        present(navController, animated: true)
    }
    
    // MARK: - Helper Methods
    private func loadSettings() {
        walletToggle.isOn = useTrustWalletScheme
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}