//
//  KeyboardGuideViewController.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 24/09/2025.
//

import UIKit
import AVKit
import AVFoundation

class KeyboardGuideViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // MARK: - Video Player Management
    private var videoPlayer: AVPlayer?
    private var videoPlayerViewController: AVPlayerViewController?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    deinit {
        // Clean up video player to prevent memory leaks
        videoPlayer?.pause()
        videoPlayer = nil
        videoPlayerViewController = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = ColorTheme.primaryBackground
        
        // Navigation bar setup
        title = "Keyboard"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: ColorTheme.primaryText]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: ColorTheme.primaryText]
        navigationController?.navigationBar.barTintColor = ColorTheme.navigationBarBackground
        navigationController?.navigationBar.tintColor = ColorTheme.navigationBarTint
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add header section
        addHeaderSection()
        
        // Add content sections
        addBasicKeyboardSection()
        addProKeyboardSection()
        addDidYouKnowSection()
        addGeneralTipsSection()
        addTroubleshootingSection()
        
        // Set final bottom constraint
        if let lastView = lastView {
            contentView.bottomAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 40).isActive = true
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    // MARK: - Content Sections
    
    private func addHeaderSection() {
        let headerContainer = UIView()
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.backgroundColor = ColorTheme.cardBackground
        headerContainer.layer.cornerRadius = 16
        headerContainer.layer.shadowColor = UIColor.black.cgColor
        headerContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerContainer.layer.shadowRadius = 8
        headerContainer.layer.shadowOpacity = 0.1
        
        // Icon
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: "keyboard.fill")
        iconView.tintColor = ColorTheme.accent
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Fusion ENS Keyboard"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = ColorTheme.primaryText
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Choose your keyboard experience"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = ColorTheme.secondaryText
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Description
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Two powerful keyboard modes designed for different use cases. Switch between Basic and Pro to match your workflow."
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = ColorTheme.secondaryText
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerContainer.addSubview(iconView)
        headerContainer.addSubview(titleLabel)
        headerContainer.addSubview(subtitleLabel)
        headerContainer.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 24),
            iconView.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalToConstant: 48),
            
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -24)
        ])
        
        addSectionToContentView(headerContainer)
    }
    
    private func addBasicKeyboardSection() {
        let section = createEnhancedSection(
            title: "Basic Keyboard",
            subtitle: "Minimal & Clean",
            description: "Perfect for everyday ENS resolution with a clean, distraction-free interface.",
            icon: "keyboard",
            accentColor: UIColor.systemBlue,
            features: [
                ("🔍", "ENS Resolution", "Type and highlight any ENS name to auto-resolve"),
                ("🌐", "Browser Integration", "Works seamlessly in search bars and address fields"),
                ("⚡", "Lightning Fast", "Instant resolution with minimal battery impact")
            ],
            howToUse: [
                "Select 'Basic — Fusion ENS' from your keyboards",
                "Type any ENS name and highlight it to resolve"
            ],
            hasVideo: true,
            videoName: "Basic Keyboard"
        )
        
        addSectionToContentView(section)
    }
    
    private func addProKeyboardSection() {
        let section = createEnhancedSection(
            title: "Pro Keyboard",
            subtitle: "Advanced & Powerful",
            description: "Full-featured keyboard with crypto tickers, subdomains, and advanced ENS tools for power users.",
            icon: "keyboard.badge.ellipsis",
            accentColor: UIColor.systemGreen,
            features: [
                ("💰", "Crypto Tickers", "Long-press :btc"),
                ("🏷️", "ENS Subdomains", "Long-press .eth for popular subdomain suggestions"),
                ("⚡", "Spacebar Resolution", "Long-press spacebar to resolve after typing ENS names"),
                ("🚀", "Browser Magic", "Press Enter to instantly open ENS name links")
            ],
            howToUse: [
                "Select 'Pro — Fusion ENS' from your keyboards",
                "Use long-press gestures for advanced features",
            ],
            hasVideo: true,
            videoName: "Pro Keyboard"
        )
        
        addSectionToContentView(section)
    }
    
    private func addDidYouKnowSection() {
        let section = createEnhancedSection(
            title: "Did You Know?",
            subtitle: "Pro Tip",
            description: "You can use your favorite non-ENS keyboard to continue typing, then when you want to resolve an ENS name, just highlight it and switch to any Fusion ENS keyboard - it will automatically resolve!",
            icon: "lightbulb.circle.fill",
            accentColor: UIColor.systemBlue,
            features: [
                ("⌨️", "Use Any Keyboard", "Continue typing with your preferred keyboard"),
                ("📝", "Highlight ENS Names", "Select the ENS name you want to resolve"),
                ("🔄", "Switch & Resolve", "Switch to Fusion ENS keyboard for instant resolution"),
                ("↩️", "Switch Back", "Return to your favorite keyboard to continue typing")
            ],
            howToUse: [],
            hasVideo: false,
            videoName: nil,
            showFeaturesHeading: false
        )
        
        addSectionToContentView(section)
    }
    
    private func addGeneralTipsSection() {
        let section = createEnhancedSection(
            title: "General Tips",
            subtitle: "Pro Tips & Tricks",
            description: "Get the most out of your Fusion ENS keyboard experience.",
            icon: "lightbulb.fill",
            accentColor: UIColor.systemOrange,
            features: [
                ("🏷️", "Subdomain Support", "Works with any subdomain (e.g., jessie.base.eth)"),
                ("🔤", "Case Insensitive", "Type ENS names in any case - it just works"),
                ("📳", "Haptic Feedback", "Feel the response on long-presses for special keys"),
                ("🌐", "Universal Compatibility", "Works in any app that supports custom keyboards")
            ],
            howToUse: [],
            hasVideo: false,
            videoName: nil,
            showFeaturesHeading: false
        )
        
        addSectionToContentView(section)
    }
    
    private func addTroubleshootingSection() {
        let section = createEnhancedSection(
            title: "Troubleshooting",
            subtitle: "Need Help?",
            description: "Common issues and solutions to keep your keyboard running smoothly.",
            icon: "wrench.and.screwdriver.fill",
            accentColor: UIColor.systemRed,
            features: [
                ("🔌", "Connection Issues", "Check your internet connection for ENS resolution"),
                ("✅", "ENS Validity", "Ensure the ENS name exists and is properly configured"),
                ("📳", "Haptic Settings", "Verify haptic feedback is enabled in device settings"),
                ("🏷️", "Subdomain Rules", "Parent domain must allow subdomain creation")
            ],
            howToUse: [],
            hasVideo: false,
            videoName: nil,
            showFeaturesHeading: false
        )
        
        addSectionToContentView(section)
    }
    
    
    // MARK: - Helper Methods
    private var lastView: UIView?
    
    private func createEnhancedSection(
        title: String,
        subtitle: String,
        description: String,
        icon: String,
        accentColor: UIColor,
        features: [(String, String, String)],
        howToUse: [String],
        hasVideo: Bool,
        videoName: String?,
        showFeaturesHeading: Bool = true
    ) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = ColorTheme.cardBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.1
        
        // Header with icon and title
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = accentColor.withAlphaComponent(0.1)
        headerView.layer.cornerRadius = 12
        headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Icon
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = accentColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = ColorTheme.primaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = accentColor
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(iconView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        // Description
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = ColorTheme.secondaryText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(headerView)
        containerView.addSubview(descriptionLabel)
        
        var lastView: UIView = descriptionLabel
        
        // Features section
        if !features.isEmpty {
            var featuresTitle: UILabel?
            
            if showFeaturesHeading {
                featuresTitle = UILabel()
                featuresTitle!.text = "Features"
                featuresTitle!.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                featuresTitle!.textColor = ColorTheme.primaryText
                featuresTitle!.translatesAutoresizingMaskIntoConstraints = false
                
                containerView.addSubview(featuresTitle!)
            }
            
            for (emoji, featureTitle, featureDesc) in features {
                let featureView = createFeatureRow(emoji: emoji, title: featureTitle, description: featureDesc)
                containerView.addSubview(featureView)
                
                NSLayoutConstraint.activate([
                    featureView.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 12),
                    featureView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
                    featureView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
                ])
                
                lastView = featureView
            }
            
            if let featuresTitle = featuresTitle {
                NSLayoutConstraint.activate([
                    featuresTitle.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 20),
                    featuresTitle.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
                    featuresTitle.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
                ])
                
                lastView = featuresTitle
            }
        }
        
        // How to Use section
        if !howToUse.isEmpty {
            for (index, step) in howToUse.enumerated() {
                let stepView = createStepRow(step: step, index: index + 1)
                containerView.addSubview(stepView)
                
                NSLayoutConstraint.activate([
                    stepView.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 12),
                    stepView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
                    stepView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
                ])
                
                lastView = stepView
            }
        }
        
        // Video section
        if hasVideo, let videoName = videoName {
            let videoContainer = createVideoContainer(for: videoName)
            containerView.addSubview(videoContainer)
            
            NSLayoutConstraint.activate([
                videoContainer.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 20),
                videoContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                videoContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
            ])
            
            lastView = videoContainer
        }
        
        // Layout constraints
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            iconView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            lastView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
        
        return containerView
    }
    
    private func createFeatureRow(emoji: String, title: String, description: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = ColorTheme.searchBarBackground
        containerView.layer.cornerRadius = 8
        
        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = UIFont.systemFont(ofSize: 20)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = ColorTheme.primaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = ColorTheme.secondaryText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(emojiLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            emojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        return containerView
    }
    
    private func createStepRow(step: String, index: Int) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stepNumberView = UIView()
        stepNumberView.backgroundColor = ColorTheme.accent
        stepNumberView.layer.cornerRadius = 12
        stepNumberView.translatesAutoresizingMaskIntoConstraints = false
        
        let stepNumberLabel = UILabel()
        stepNumberLabel.text = "\(index)"
        stepNumberLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        stepNumberLabel.textColor = .white
        stepNumberLabel.textAlignment = .center
        stepNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stepLabel = UILabel()
        stepLabel.text = step
        stepLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        stepLabel.textColor = ColorTheme.primaryText
        stepLabel.numberOfLines = 0
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stepNumberView.addSubview(stepNumberLabel)
        containerView.addSubview(stepNumberView)
        containerView.addSubview(stepLabel)
        
        NSLayoutConstraint.activate([
            stepNumberView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stepNumberView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stepNumberView.widthAnchor.constraint(equalToConstant: 24),
            stepNumberView.heightAnchor.constraint(equalToConstant: 24),
            
            stepNumberLabel.centerXAnchor.constraint(equalTo: stepNumberView.centerXAnchor),
            stepNumberLabel.centerYAnchor.constraint(equalTo: stepNumberView.centerYAnchor),
            
            stepLabel.leadingAnchor.constraint(equalTo: stepNumberView.trailingAnchor, constant: 12),
            stepLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            stepLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stepLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func createSection(title: String, description: String, features: [String], howToUse: [String], visuals: [String]) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = ColorTheme.primaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Description
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = ColorTheme.secondaryText
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        
        var lastView: UIView = descriptionLabel
        
        // Features
        if !features.isEmpty {
            let featuresSection = createSubsection(title: "Features", items: features)
            containerView.addSubview(featuresSection)
            featuresSection.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 16).isActive = true
            featuresSection.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            featuresSection.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            lastView = featuresSection
        }
        
        // How to Use
        if !howToUse.isEmpty {
            let howToUseSection = createSubsection(title: "How to Use", items: howToUse)
            containerView.addSubview(howToUseSection)
            howToUseSection.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 16).isActive = true
            howToUseSection.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            howToUseSection.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            lastView = howToUseSection
            
            // Add video directly after "How to Use" for Basic and Pro Keyboard
            if title == "Basic Keyboard" {
                let videoContainer = createVideoContainer(for: "Basic Keyboard")
                containerView.addSubview(videoContainer)
                videoContainer.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 16).isActive = true
                videoContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
                videoContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
                lastView = videoContainer
            } else if title == "Pro Keyboard" {
                let videoContainer = createVideoContainer(for: "Pro Keyboard")
                containerView.addSubview(videoContainer)
                videoContainer.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 16).isActive = true
                videoContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
                videoContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
                lastView = videoContainer
            }
        }
        
        // Visuals (only for other sections, not Basic or Pro Keyboard as videos are handled above)
        if !visuals.isEmpty && title != "Basic Keyboard" && title != "Pro Keyboard" {
            let visualsSection = createVisualsSection(title: "Visuals", items: visuals)
            containerView.addSubview(visualsSection)
            visualsSection.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 16).isActive = true
            visualsSection.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            visualsSection.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            lastView = visualsSection
        }
        
        // Container constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            containerView.bottomAnchor.constraint(equalTo: lastView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func createSimpleSection(title: String, content: [String]) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = ColorTheme.primaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        
        var lastView: UIView = titleLabel
        
        // Content items
        for (index, item) in content.enumerated() {
            let itemLabel = UILabel()
            itemLabel.text = "• \(item)"
            itemLabel.font = UIFont.systemFont(ofSize: 16)
            itemLabel.textColor = ColorTheme.secondaryText
            itemLabel.numberOfLines = 0
            itemLabel.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(itemLabel)
            
            NSLayoutConstraint.activate([
                itemLabel.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: index == 0 ? 8 : 4),
                itemLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                itemLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
            
            lastView = itemLabel
        }
        
        // Container constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            containerView.bottomAnchor.constraint(equalTo: lastView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func createSubsection(title: String, items: [String]) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Subsection title
        let subsectionTitle = UILabel()
        subsectionTitle.text = title
        subsectionTitle.font = UIFont.boldSystemFont(ofSize: 16)
        subsectionTitle.textColor = ColorTheme.primaryText
        subsectionTitle.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(subsectionTitle)
        
        var lastView: UIView = subsectionTitle
        
        // Items
        for (index, item) in items.enumerated() {
            let itemLabel = UILabel()
            itemLabel.text = "• \(item)"
            itemLabel.font = UIFont.systemFont(ofSize: 14)
            itemLabel.textColor = ColorTheme.secondaryText
            itemLabel.numberOfLines = 0
            itemLabel.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(itemLabel)
            
            NSLayoutConstraint.activate([
                itemLabel.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: index == 0 ? 8 : 4),
                itemLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                itemLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
            
            lastView = itemLabel
        }
        
        // Container constraints
        NSLayoutConstraint.activate([
            subsectionTitle.topAnchor.constraint(equalTo: containerView.topAnchor),
            subsectionTitle.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            subsectionTitle.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            containerView.bottomAnchor.constraint(equalTo: lastView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func createVisualsSection(title: String, items: [String]) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Subsection title
        let subsectionTitle = UILabel()
        subsectionTitle.text = title
        subsectionTitle.font = UIFont.boldSystemFont(ofSize: 16)
        subsectionTitle.textColor = ColorTheme.primaryText
        subsectionTitle.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(subsectionTitle)
        
        var lastView: UIView = subsectionTitle
        
        // If items is empty but this is the Basic Keyboard section, show video directly
        if items.isEmpty && title == "Visuals" {
            // Add video player for Basic Keyboard demo
            let mediaContainer = UIView()
            mediaContainer.backgroundColor = ColorTheme.cardBackground
            mediaContainer.layer.cornerRadius = 8
            mediaContainer.layer.borderWidth = 1
            mediaContainer.layer.borderColor = ColorTheme.border.cgColor
            mediaContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let videoPlayerView = createVideoPlayerView(for: "Basic Keyboard")
            mediaContainer.addSubview(videoPlayerView)
            
            NSLayoutConstraint.activate([
                videoPlayerView.topAnchor.constraint(equalTo: mediaContainer.topAnchor),
                videoPlayerView.leadingAnchor.constraint(equalTo: mediaContainer.leadingAnchor),
                videoPlayerView.trailingAnchor.constraint(equalTo: mediaContainer.trailingAnchor),
                videoPlayerView.bottomAnchor.constraint(equalTo: mediaContainer.bottomAnchor)
            ])
            
            containerView.addSubview(mediaContainer)
            
            NSLayoutConstraint.activate([
                mediaContainer.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 8),
                mediaContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                mediaContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                mediaContainer.heightAnchor.constraint(equalToConstant: 400) // Reduced height for better fit
            ])
            
            lastView = mediaContainer
        } else {
            // Visual items with placeholders
            for (index, item) in items.enumerated() {
            // Description label
            let itemLabel = UILabel()
            itemLabel.text = "• \(item)"
            itemLabel.font = UIFont.systemFont(ofSize: 14)
            itemLabel.textColor = ColorTheme.secondaryText
            itemLabel.numberOfLines = 0
            itemLabel.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(itemLabel)
            
            // Media container
            let mediaContainer = UIView()
            mediaContainer.backgroundColor = ColorTheme.cardBackground
            mediaContainer.layer.cornerRadius = 8
            mediaContainer.layer.borderWidth = 1
            mediaContainer.layer.borderColor = ColorTheme.border.cgColor
            mediaContainer.translatesAutoresizingMaskIntoConstraints = false
            
            if item == "Video: Basic Keyboard Demo" {
                // Add video player for Basic Keyboard demo
                let videoPlayerView = createVideoPlayerView(for: "Basic Keyboard")
                mediaContainer.addSubview(videoPlayerView)
                
                NSLayoutConstraint.activate([
                    videoPlayerView.topAnchor.constraint(equalTo: mediaContainer.topAnchor),
                    videoPlayerView.leadingAnchor.constraint(equalTo: mediaContainer.leadingAnchor),
                    videoPlayerView.trailingAnchor.constraint(equalTo: mediaContainer.trailingAnchor),
                    videoPlayerView.bottomAnchor.constraint(equalTo: mediaContainer.bottomAnchor)
                ])
            } else {
                // Placeholder label for other items
                let placeholderLabel = UILabel()
                placeholderLabel.text = item.contains("GIF") ? "🎬 GIF Placeholder" : "📱 Image Placeholder"
                placeholderLabel.font = UIFont.systemFont(ofSize: 12)
                placeholderLabel.textColor = ColorTheme.placeholderText
                placeholderLabel.textAlignment = .center
                placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
                
                mediaContainer.addSubview(placeholderLabel)
                
                NSLayoutConstraint.activate([
                    placeholderLabel.centerXAnchor.constraint(equalTo: mediaContainer.centerXAnchor),
                    placeholderLabel.centerYAnchor.constraint(equalTo: mediaContainer.centerYAnchor)
                ])
            }
            
            containerView.addSubview(mediaContainer)
            
            NSLayoutConstraint.activate([
                itemLabel.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: index == 0 ? 8 : 16),
                itemLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                itemLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                
                mediaContainer.topAnchor.constraint(equalTo: itemLabel.bottomAnchor, constant: 8),
                mediaContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                mediaContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                mediaContainer.heightAnchor.constraint(equalToConstant: 400) // Reduced height for better fit
            ])
            
            lastView = mediaContainer
            }
        }
        
        // Container constraints
        NSLayoutConstraint.activate([
            subsectionTitle.topAnchor.constraint(equalTo: containerView.topAnchor),
            subsectionTitle.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            subsectionTitle.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            containerView.bottomAnchor.constraint(equalTo: lastView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func createVideoContainer(for videoName: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Media container
        let mediaContainer = UIView()
        mediaContainer.backgroundColor = ColorTheme.cardBackground
        mediaContainer.layer.cornerRadius = 8
        mediaContainer.layer.borderWidth = 1
        mediaContainer.layer.borderColor = ColorTheme.border.cgColor
        mediaContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Add video player
        let videoPlayerView = createVideoPlayerView(for: videoName)
        mediaContainer.addSubview(videoPlayerView)
        
        NSLayoutConstraint.activate([
            videoPlayerView.topAnchor.constraint(equalTo: mediaContainer.topAnchor),
            videoPlayerView.leadingAnchor.constraint(equalTo: mediaContainer.leadingAnchor),
            videoPlayerView.trailingAnchor.constraint(equalTo: mediaContainer.trailingAnchor),
            videoPlayerView.bottomAnchor.constraint(equalTo: mediaContainer.bottomAnchor)
        ])
        
        containerView.addSubview(mediaContainer)
        
        NSLayoutConstraint.activate([
            mediaContainer.topAnchor.constraint(equalTo: containerView.topAnchor),
            mediaContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            mediaContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            mediaContainer.heightAnchor.constraint(equalToConstant: 800), // Increased height for better visibility
            mediaContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func createVideoPlayerView(for videoName: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create AVPlayerViewController
        let playerViewController = AVPlayerViewController()
        
        // Get the video file path
        guard let videoPath = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            // Fallback if video not found
            let fallbackLabel = UILabel()
            fallbackLabel.text = "📹 Video not found: \(videoName).mp4"
            fallbackLabel.font = UIFont.systemFont(ofSize: 12)
            fallbackLabel.textColor = ColorTheme.placeholderText
            fallbackLabel.textAlignment = .center
            fallbackLabel.numberOfLines = 0
            fallbackLabel.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(fallbackLabel)
            
            NSLayoutConstraint.activate([
                fallbackLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                fallbackLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                fallbackLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 16),
                fallbackLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16)
            ])
            
            return containerView
        }
        
        let videoURL = URL(fileURLWithPath: videoPath)
        let player = AVPlayer(url: videoURL)
        playerViewController.player = player
        
        // Store references for cleanup
        self.videoPlayer = player
        self.videoPlayerViewController = playerViewController
        
        // Add as child view controller
        addChild(playerViewController)
        containerView.addSubview(playerViewController.view)
        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        playerViewController.didMove(toParent: self)
        
        // Configure player for performance and vertical video
        playerViewController.showsPlaybackControls = false
        playerViewController.videoGravity = .resizeAspect // Scale to fit within the container
        
        // Set clear background to avoid black space
        playerViewController.view.backgroundColor = UIColor.clear
        containerView.backgroundColor = UIColor.clear
        
        // Performance optimizations
        playerViewController.allowsPictureInPicturePlayback = false
        playerViewController.entersFullScreenWhenPlaybackBegins = false
        playerViewController.exitsFullScreenWhenPlaybackEnds = false
        
        // Audio session configuration - don't interfere with background music
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            // If audio session configuration fails, continue without it
        }
        
        // Mute the player to ensure no audio interference
        player.isMuted = true
        
        // Set up looping with weak reference to prevent retain cycles
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }
        
        // Start playing automatically
        player.play()
        
        NSLayoutConstraint.activate([
            playerViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            playerViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            // Ensure video fills the container properly
            playerViewController.view.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            playerViewController.view.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        return containerView
    }
    
    private func addSectionToContentView(_ section: UIView) {
        contentView.addSubview(section)
        
        NSLayoutConstraint.activate([
            section.topAnchor.constraint(equalTo: lastView?.bottomAnchor ?? contentView.topAnchor, constant: 24),
            section.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            section.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        lastView = section
    }
}
