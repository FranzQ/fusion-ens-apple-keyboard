//
//  KeyboardGuideViewController.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 24/09/2025.
//

import UIKit
import AVKit

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
        
        // Add content sections
        addBasicKeyboardSection()
        addProKeyboardSection()
        addGeneralTipsSection()
        addTroubleshootingSection()
        
        // Set final bottom constraint
        if let lastView = lastView {
            contentView.bottomAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 20).isActive = true
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
    
    private func addBasicKeyboardSection() {
        let section = createSection(
            title: "Basic Keyboard",
            description: "Minimal design with core ENS tools.",
            features: [
                "ENS Resolution: type and highlight vitalik.eth",
                "Browser detection: Resolves links in browser search or address bars",
            ],
            howToUse: [
                "Switch to Fusion ENS Basic in settings",
                "Type ENS name and highlight it → auto resolves",
            ],
            visuals: []
        )
        
        addSectionToContentView(section)
    }
    
    private func addProKeyboardSection() {
        let section = createSection(
            title: "Pro Keyboard",
            description: "Advanced ENS + crypto functions.",
            features: [
                "ENS Resolution: full ENS + subdomains",
                "Crypto Tickers: long-press :btc for :btc, :eth, :sol, :doge, :ada",
                "ENS Subdomains: long-press .eth for .base.eth, .uni.eth, .dao.eth, .ens.eth, .defi.eth",
                "Spacebar Resolution: long-press spacebar to resolve names in text",
                "Browser Integration: ENS names open in Etherscan on Enter"
            ],
            howToUse: [
                "Switch to Fusion ENS Pro in settings",
                "Use long-press gestures for advanced features",
                "Press Enter to open ENS names in Etherscan"
            ],
            visuals: [
                "Video: Pro Keyboard Demo"
            ]
        )
        
        addSectionToContentView(section)
    }
    
    private func addGeneralTipsSection() {
        let section = createSimpleSection(
            title: "General Tips",
            content: [
                "Subdomains supported (e.g. jessie.base.eth)",
                "Case insensitive",
                "Auto-append .eth",
                "Haptic feedback for Pro long-presses"
            ]
        )
        
        addSectionToContentView(section)
    }
    
    private func addTroubleshootingSection() {
        let section = createSimpleSection(
            title: "Troubleshooting",
            content: [
                "Check internet, ENS validity, or device haptics",
                "Parent domain must allow subdomains"
            ]
        )
        
        addSectionToContentView(section)
    }
    
    
    // MARK: - Helper Methods
    private var lastView: UIView?
    
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
