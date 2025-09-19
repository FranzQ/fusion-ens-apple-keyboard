//
//  GettingStartedVC.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 05/09/2025.
//

import UIKit

class GettingStartedVC: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let helpButton = UIButton(type: .system)
    
    // Welcome Section
    private let welcomeView = UIView()
    private let keyboardIconView = UIView()
    private let keyboardIcon = UIImageView()
    private let welcomeTitleLabel = UILabel()
    private let welcomeDescriptionLabel = UILabel()
    
    // Setup Steps
    private let step1View = UIView()
    private let step1TitleLabel = UILabel()
    
    private let step2View = UIView()
    private let step2TitleLabel = UILabel()
    
    
    // Done Button
    private let doneButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    private func setupUI() {
        // Use system background color for proper light/dark mode support
        view.backgroundColor = UIColor.systemBackground
        
        setupScrollView()
        setupHeader()
        setupWelcomeSection()
        setupSteps()
        setupDoneButton()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)
        
        // Title
        titleLabel.text = "Fusion ENS"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor.label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        // Help Button
        helpButton.setTitle("?", for: .normal)
        helpButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        helpButton.setTitleColor(UIColor.label, for: .normal)
        helpButton.backgroundColor = UIColor.secondarySystemBackground
        helpButton.layer.cornerRadius = 15
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
        headerView.addSubview(helpButton)
    }
    
    private func setupWelcomeSection() {
        welcomeView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(welcomeView)
        
        // Keyboard Icon Container
        keyboardIconView.backgroundColor = UIColor.systemBlue
        keyboardIconView.layer.cornerRadius = 50
        keyboardIconView.translatesAutoresizingMaskIntoConstraints = false
        welcomeView.addSubview(keyboardIconView)
        
        // Keyboard Icon (placeholder)
        keyboardIcon.image = UIImage(systemName: "keyboard")
        keyboardIcon.tintColor = .white
        keyboardIcon.contentMode = .scaleAspectFit
        keyboardIcon.translatesAutoresizingMaskIntoConstraints = false
        keyboardIconView.addSubview(keyboardIcon)
        
        // Welcome Title
        welcomeTitleLabel.text = "Welcome to Fusion ENS"
        welcomeTitleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        welcomeTitleLabel.textColor = UIColor.label
        welcomeTitleLabel.textAlignment = .center
        welcomeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeView.addSubview(welcomeTitleLabel)
        
        // Welcome Description
        welcomeDescriptionLabel.text = "A custom keyboard to seamlessly resolve ENS names across iOS. Follow the steps to get started."
        welcomeDescriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        welcomeDescriptionLabel.textColor = UIColor.secondaryLabel
        welcomeDescriptionLabel.textAlignment = .center
        welcomeDescriptionLabel.numberOfLines = 0
        welcomeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeView.addSubview(welcomeDescriptionLabel)
    }
    
    private func setupSteps() {
        setupStep1()
        setupStep2()
    }
    
    private func setupStep1() {
        step1View.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(step1View)
        
        // Step 1 Title
        step1TitleLabel.text = "Step 1: Add the Keyboard"
        step1TitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        step1TitleLabel.textColor = UIColor.label
        step1TitleLabel.translatesAutoresizingMaskIntoConstraints = false
        step1View.addSubview(step1TitleLabel)
        
        // Step 1.1: Open Keyboard Settings
        let step1_1View = createStepCard(
            icon: "gearshape",
            title: "Open Keyboard Settings",
            description: "Settings > General > Keyboard > Keyboards > Add New Keyboard...",
            parentView: step1View
        )
        
        // Step 1.2: Select Fusion ENS
        let step1_2View = createStepCard(
            icon: "plus",
            title: "Select Fusion ENS",
            description: "Choose Fusion ENS from the list of third-party keyboards.",
            parentView: step1View
        )
        
        // Layout constraints for step 1
        NSLayoutConstraint.activate([
            step1_1View.topAnchor.constraint(equalTo: step1TitleLabel.bottomAnchor, constant: 16),
            step1_1View.leadingAnchor.constraint(equalTo: step1View.leadingAnchor),
            step1_1View.trailingAnchor.constraint(equalTo: step1View.trailingAnchor),
            
            step1_2View.topAnchor.constraint(equalTo: step1_1View.bottomAnchor, constant: 12),
            step1_2View.leadingAnchor.constraint(equalTo: step1View.leadingAnchor),
            step1_2View.trailingAnchor.constraint(equalTo: step1View.trailingAnchor),
            step1_2View.bottomAnchor.constraint(equalTo: step1View.bottomAnchor)
        ])
    }
    
    private func setupStep2() {
        step2View.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(step2View)
        
        // Step 2 Title
        step2TitleLabel.text = "Step 2: Allow Full Access"
        step2TitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        step2TitleLabel.textColor = UIColor.label
        step2TitleLabel.translatesAutoresizingMaskIntoConstraints = false
        step2View.addSubview(step2TitleLabel)
        
        // Step 2.1: Tap on Fusion ENS
        let step2_1View = createStepCard(
            icon: "hand.tap",
            title: "Tap on Fusion ENS",
            description: "Select Fusion ENS in your list of active keyboards.",
            parentView: step2View
        )
        
        // Step 2.2: Allow Full Access
        let step2_2View = createStepCard(
            icon: "switch.2",
            title: "Allow Full Access",
            description: "Enable 'Allow Full Access' for ENS resolution. We respect your privacy and do not collect data.",
            parentView: step2View
        )
        
        // Layout constraints for step 2
        NSLayoutConstraint.activate([
            step2_1View.topAnchor.constraint(equalTo: step2TitleLabel.bottomAnchor, constant: 16),
            step2_1View.leadingAnchor.constraint(equalTo: step2View.leadingAnchor),
            step2_1View.trailingAnchor.constraint(equalTo: step2View.trailingAnchor),
            
            step2_2View.topAnchor.constraint(equalTo: step2_1View.bottomAnchor, constant: 12),
            step2_2View.leadingAnchor.constraint(equalTo: step2View.leadingAnchor),
            step2_2View.trailingAnchor.constraint(equalTo: step2View.trailingAnchor),
            step2_2View.bottomAnchor.constraint(equalTo: step2View.bottomAnchor)
        ])
    }
    
    private func createStepCard(icon: String, title: String, description: String, parentView: UIView) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor.secondarySystemBackground
        cardView.layer.cornerRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(cardView)
        
        // Icon container
        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor.tertiarySystemBackground
        iconContainer.layer.cornerRadius = 20
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconContainer)
        
        // Icon
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = UIColor.label
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = UIColor.label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)
        
        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = UIColor.secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(descriptionLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            iconContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
        
        return cardView
    }
    
    
    private func setupDoneButton() {
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        doneButton.backgroundColor = UIColor.systemBlue
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 12
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        view.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        // Scroll View Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -20),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Header Constraints
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            helpButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            helpButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            helpButton.widthAnchor.constraint(equalToConstant: 30),
            helpButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Welcome Section Constraints
        NSLayoutConstraint.activate([
            welcomeView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 30),
            welcomeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            welcomeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            keyboardIconView.centerXAnchor.constraint(equalTo: welcomeView.centerXAnchor),
            keyboardIconView.topAnchor.constraint(equalTo: welcomeView.topAnchor),
            keyboardIconView.widthAnchor.constraint(equalToConstant: 100),
            keyboardIconView.heightAnchor.constraint(equalToConstant: 100),
            
            keyboardIcon.centerXAnchor.constraint(equalTo: keyboardIconView.centerXAnchor),
            keyboardIcon.centerYAnchor.constraint(equalTo: keyboardIconView.centerYAnchor),
            keyboardIcon.widthAnchor.constraint(equalToConstant: 50),
            keyboardIcon.heightAnchor.constraint(equalToConstant: 50),
            
            welcomeTitleLabel.centerXAnchor.constraint(equalTo: welcomeView.centerXAnchor),
            welcomeTitleLabel.topAnchor.constraint(equalTo: keyboardIconView.bottomAnchor, constant: 20),
            welcomeTitleLabel.leadingAnchor.constraint(equalTo: welcomeView.leadingAnchor, constant: 20),
            welcomeTitleLabel.trailingAnchor.constraint(equalTo: welcomeView.trailingAnchor, constant: -20),
            
            welcomeDescriptionLabel.centerXAnchor.constraint(equalTo: welcomeView.centerXAnchor),
            welcomeDescriptionLabel.topAnchor.constraint(equalTo: welcomeTitleLabel.bottomAnchor, constant: 16),
            welcomeDescriptionLabel.leadingAnchor.constraint(equalTo: welcomeView.leadingAnchor, constant: 20),
            welcomeDescriptionLabel.trailingAnchor.constraint(equalTo: welcomeView.trailingAnchor, constant: -20),
            welcomeDescriptionLabel.bottomAnchor.constraint(equalTo: welcomeView.bottomAnchor, constant: -20)
        ])
        
        // Step 1 Constraints
        NSLayoutConstraint.activate([
            step1View.topAnchor.constraint(equalTo: welcomeView.bottomAnchor, constant: 40),
            step1View.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            step1View.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            step1TitleLabel.topAnchor.constraint(equalTo: step1View.topAnchor),
            step1TitleLabel.leadingAnchor.constraint(equalTo: step1View.leadingAnchor),
            step1TitleLabel.trailingAnchor.constraint(equalTo: step1View.trailingAnchor)
        ])
        
        // Step 2 Constraints
        NSLayoutConstraint.activate([
            step2View.topAnchor.constraint(equalTo: step1View.bottomAnchor, constant: 30),
            step2View.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            step2View.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            step2TitleLabel.topAnchor.constraint(equalTo: step2View.topAnchor),
            step2TitleLabel.leadingAnchor.constraint(equalTo: step2View.leadingAnchor),
            step2TitleLabel.trailingAnchor.constraint(equalTo: step2View.trailingAnchor)
        ])
        
        // Content bottom constraint
        NSLayoutConstraint.activate([
            step2View.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // Done Button Constraints
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    // MARK: - Actions
    
    @objc private func helpButtonTapped() {
        // Show help information
        let alert = UIAlertController(title: "Help", message: "This guide will help you set up the Fusion ENS keyboard to resolve ENS names seamlessly across iOS.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    private func transitionToMainApp() {
        // Create the main tab bar controller
        let mainTabBarController = MainTabBarController()
        
        // Transition to main app
        if let windowScene = view.window?.windowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = mainTabBarController
            window.makeKeyAndVisible()
            
            // Animate the transition
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    private func transitionToMainAppWithTab(_ tabIndex: Int) {
        // Create the main tab bar controller
        let mainTabBarController = MainTabBarController()
        
        // Set the selected tab
        mainTabBarController.selectedIndex = tabIndex
        
        // Transition to main app
        if let windowScene = view.window?.windowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = mainTabBarController
            window.makeKeyAndVisible()
            
            // Animate the transition
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    @objc private func doneButtonTapped() {
        // Close the popover/modal
        dismiss(animated: true, completion: nil)
    }
}
