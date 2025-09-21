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
    
    // Bottom Navigation
    private let bottomNavView = UIView()
    private let myENSButton = UIButton(type: .system)
    private let contactsButton = UIButton(type: .system)
    private let settingsNavButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let walletPreferenceKey = "useTrustWalletScheme"
    
    private var useTrustWalletScheme: Bool {
        get {
            return UserDefaults(suiteName: "group.com.fusionens.keyboard")?.bool(forKey: walletPreferenceKey) ?? true
        }
        set {
            UserDefaults(suiteName: "group.com.fusionens.keyboard")?.set(newValue, forKey: walletPreferenceKey)
            UserDefaults(suiteName: "group.com.fusionens.keyboard")?.synchronize()
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
        walletDescriptionLabel.text = "Use Trust Wallet's custom scheme (trust://) for all QR codes. When disabled, uses standard schemes (bitcoin:, ethereum:, etc.) for broader wallet compatibility."
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
        setupDescriptionLabel.text = "Re-run the initial onboarding flow"
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
            walletCardView.heightAnchor.constraint(equalToConstant: 120),
            
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
            walletDescriptionLabel.bottomAnchor.constraint(equalTo: walletCardView.bottomAnchor, constant: -16)
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
    
    
    
    @objc private func walletToggleChanged() {
        useTrustWalletScheme = walletToggle.isOn
        
        // Provide immediate feedback
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
}