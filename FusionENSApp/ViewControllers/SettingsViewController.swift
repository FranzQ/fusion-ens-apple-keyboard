//
//  SettingsViewController.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 12/09/2025.
//

import UIKit
import SnapKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let hapticSectionView = UIView()
    private let hapticTitleLabel = UILabel()
    private let hapticDescriptionLabel = UILabel()
    private let hapticToggle = UISwitch()
    private let hapticDivider = UIView()
    
    private let aboutSectionView = UIView()
    private let aboutTitleLabel = UILabel()
    private let versionLabel = UILabel()
    private let websiteButton = UIButton(type: .system)
    private let supportButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let hapticFeedbackKey = "hapticFeedbackEnabled"
    private var isHapticFeedbackEnabled: Bool {
        get {
            return UserDefaults(suiteName: "group.com.fusionens.keyboard")?.bool(forKey: hapticFeedbackKey) ?? true
        }
        set {
            UserDefaults(suiteName: "group.com.fusionens.keyboard")?.set(newValue, forKey: hapticFeedbackKey)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadSettings()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Navigation Bar
        setupNavigationBar()
        
        // Scroll View
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Title
        titleLabel.text = "Settings"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        // Haptic Section
        setupHapticSection()
        
        // About Section
        setupAboutSection()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Settings"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }
    
    private func setupHapticSection() {
        contentView.addSubview(hapticSectionView)
        
        // Haptic Title
        hapticTitleLabel.text = "Haptic Feedback"
        hapticTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        hapticTitleLabel.textColor = .label
        hapticSectionView.addSubview(hapticTitleLabel)
        
        // Haptic Description
        hapticDescriptionLabel.text = "Feel vibrations when ENS names are resolved successfully or when errors occur"
        hapticDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        hapticDescriptionLabel.textColor = .secondaryLabel
        hapticDescriptionLabel.numberOfLines = 0
        hapticSectionView.addSubview(hapticDescriptionLabel)
        
        // Haptic Toggle
        hapticToggle.addTarget(self, action: #selector(hapticToggleChanged), for: .valueChanged)
        hapticSectionView.addSubview(hapticToggle)
        
        // Divider
        hapticDivider.backgroundColor = .separator
        hapticSectionView.addSubview(hapticDivider)
    }
    
    private func setupAboutSection() {
        contentView.addSubview(aboutSectionView)
        
        // About Title
        aboutTitleLabel.text = "About"
        aboutTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        aboutTitleLabel.textColor = .label
        aboutSectionView.addSubview(aboutTitleLabel)
        
        // Version
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        versionLabel.text = "Version \(version)"
        versionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        versionLabel.textColor = .secondaryLabel
        aboutSectionView.addSubview(versionLabel)
        
        // Website Button
        websiteButton.setTitle("Visit Website", for: .normal)
        websiteButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        websiteButton.setTitleColor(.systemBlue, for: .normal)
        websiteButton.addTarget(self, action: #selector(websiteTapped), for: .touchUpInside)
        aboutSectionView.addSubview(websiteButton)
        
        // Support Button
        supportButton.setTitle("Contact Support", for: .normal)
        supportButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        supportButton.setTitleColor(.systemBlue, for: .normal)
        supportButton.addTarget(self, action: #selector(supportTapped), for: .touchUpInside)
        aboutSectionView.addSubview(supportButton)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Haptic Section
        hapticSectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        hapticTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        hapticToggle.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.centerY.equalTo(hapticTitleLabel)
        }
        
        hapticDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(hapticTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        
        hapticDivider.snp.makeConstraints { make in
            make.top.equalTo(hapticSectionView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        // About Section
        aboutSectionView.snp.makeConstraints { make in
            make.top.equalTo(hapticDivider.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        aboutTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        versionLabel.snp.makeConstraints { make in
            make.top.equalTo(aboutTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
        
        websiteButton.snp.makeConstraints { make in
            make.top.equalTo(versionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        supportButton.snp.makeConstraints { make in
            make.top.equalTo(websiteButton.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    @objc private func doneTapped() {
        dismiss(animated: true)
    }
    
    @objc private func hapticToggleChanged() {
        isHapticFeedbackEnabled = hapticToggle.isOn
        
        // Provide immediate feedback
        if hapticToggle.isOn {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    @objc private func websiteTapped() {
        if let url = URL(string: "https://fusionens.com") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func supportTapped() {
        if let url = URL(string: "mailto:hello@fusionens.com") {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Helper Methods
    private func loadSettings() {
        hapticToggle.isOn = isHapticFeedbackEnabled
    }
}
