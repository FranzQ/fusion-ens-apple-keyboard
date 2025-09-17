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
    
    private let keyboardSectionView = UIView()
    private let keyboardTitleLabel = UILabel()
    private let keyboardDescriptionLabel = UILabel()
    private let keyboardSegmentedControl = UISegmentedControl(items: ["UIKit (Default)", "SwiftUI (Modern)"])
    private let testKeyboardButton = UIButton(type: .system)
    private let testInputField = UITextField()
    private let testInputLabel = UILabel()
    private let keyboardDivider = UIView()
    
    private let aboutSectionView = UIView()
    private let aboutTitleLabel = UILabel()
    private let versionLabel = UILabel()
    private let websiteButton = UIButton(type: .system)
    private let supportButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let hapticFeedbackKey = "hapticFeedbackEnabled"
    private let keyboardTypeKey = "keyboardType"
    
    private var isHapticFeedbackEnabled: Bool {
        get {
            return UserDefaults(suiteName: "group.com.fusionens.keyboard")?.bool(forKey: hapticFeedbackKey) ?? true
        }
        set {
            UserDefaults(suiteName: "group.com.fusionens.keyboard")?.set(newValue, forKey: hapticFeedbackKey)
            UserDefaults(suiteName: "group.com.fusionens.keyboard")?.synchronize()
        }
    }
    
    private var keyboardType: KeyboardType {
        get {
            if let savedType = UserDefaults(suiteName: "group.com.fusionens.keyboard")?.string(forKey: keyboardTypeKey),
               let type = KeyboardType(rawValue: savedType) {
                return type
            }
            return .uikit // Default to UIKit
        }
        set {
            UserDefaults(suiteName: "group.com.fusionens.keyboard")?.set(newValue.rawValue, forKey: keyboardTypeKey)
            UserDefaults(suiteName: "group.com.fusionens.keyboard")?.synchronize()
        }
    }
    
    enum KeyboardType: String {
        case uikit = "UIKit"
        case swiftui = "SwiftUI"
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
        
        // Keyboard Section
        setupKeyboardSection()
        
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
    
    private func setupKeyboardSection() {
        contentView.addSubview(keyboardSectionView)
        
        // Keyboard Title
        keyboardTitleLabel.text = "Keyboard Type"
        keyboardTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        keyboardTitleLabel.textColor = .label
        keyboardSectionView.addSubview(keyboardTitleLabel)
        
        // Keyboard Description
        keyboardDescriptionLabel.text = "Choose between the traditional UIKit keyboard with full ENS features or the modern SwiftUI keyboard with a simplified interface"
        keyboardDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        keyboardDescriptionLabel.textColor = .secondaryLabel
        keyboardDescriptionLabel.numberOfLines = 0
        keyboardSectionView.addSubview(keyboardDescriptionLabel)
        
        // Keyboard Segmented Control
        keyboardSegmentedControl.addTarget(self, action: #selector(keyboardTypeChanged), for: .valueChanged)
        keyboardSectionView.addSubview(keyboardSegmentedControl)
        
        // Test Keyboard Button
        testKeyboardButton.setTitle("Test Keyboard Switching", for: .normal)
        testKeyboardButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        testKeyboardButton.setTitleColor(.systemBlue, for: .normal)
        testKeyboardButton.addTarget(self, action: #selector(testKeyboardTapped), for: .touchUpInside)
        keyboardSectionView.addSubview(testKeyboardButton)
        
        // Test Input Label
        testInputLabel.text = "Test Keyboard Input:"
        testInputLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        testInputLabel.textColor = .label
        keyboardSectionView.addSubview(testInputLabel)
        
        // Test Input Field
        testInputField.placeholder = "Tap here to test your keyboard..."
        testInputField.borderStyle = .roundedRect
        testInputField.font = UIFont.systemFont(ofSize: 16)
        testInputField.backgroundColor = .systemGray6
        testInputField.layer.cornerRadius = 8
        testInputField.layer.borderWidth = 1
        testInputField.layer.borderColor = UIColor.systemGray4.cgColor
        keyboardSectionView.addSubview(testInputField)
        
        // Divider
        keyboardDivider.backgroundColor = .separator
        keyboardSectionView.addSubview(keyboardDivider)
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
        
        // Keyboard Section
        keyboardSectionView.snp.makeConstraints { make in
            make.top.equalTo(hapticDivider.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        keyboardTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        keyboardDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(keyboardTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
        
        keyboardSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(keyboardDescriptionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
        }
        
        testKeyboardButton.snp.makeConstraints { make in
            make.top.equalTo(keyboardSegmentedControl.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
        }
        
        testInputLabel.snp.makeConstraints { make in
            make.top.equalTo(testKeyboardButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
        }
        
        testInputField.snp.makeConstraints { make in
            make.top.equalTo(testInputLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        keyboardDivider.snp.makeConstraints { make in
            make.top.equalTo(keyboardSectionView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        // About Section
        aboutSectionView.snp.makeConstraints { make in
            make.top.equalTo(keyboardDivider.snp.bottom).offset(20)
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
    
    @objc private func keyboardTypeChanged() {
        let selectedIndex = keyboardSegmentedControl.selectedSegmentIndex
        let newType: KeyboardType = selectedIndex == 0 ? .uikit : .swiftui
        keyboardType = newType
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Force UserDefaults synchronization
        UserDefaults(suiteName: "group.com.fusionens.keyboard")?.synchronize()
        
        // Post notification to inform keyboard extension of the change
        NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: nil)
        
        // Show alert to inform user about the change
        let alert = UIAlertController(
            title: "Keyboard Type Changed",
            message: "Your keyboard type has been updated to \(newType.rawValue). The change will take effect the next time you use the keyboard.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func testKeyboardTapped() {
        // Test switching between keyboard types
        let alert = UIAlertController(
            title: "Test Keyboard Switching",
            message: "This will test switching between UIKit and SwiftUI keyboards. Check the debug console for logs.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Test UIKit", style: .default) { _ in
            self.keyboardType = .uikit
            print("🧪 Test: Set keyboard type to UIKit")
            self.testUserDefaultsWriting()
        })
        
        alert.addAction(UIAlertAction(title: "Test SwiftUI", style: .default) { _ in
            self.keyboardType = .swiftui
            print("🧪 Test: Set keyboard type to SwiftUI")
            self.testUserDefaultsWriting()
        })
        
        alert.addAction(UIAlertAction(title: "Test UserDefaults", style: .default) { _ in
            self.testUserDefaultsWriting()
        })
        
        alert.addAction(UIAlertAction(title: "Test Auto Switch", style: .default) { _ in
            self.testAutoKeyboardSwitching()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func testUserDefaultsWriting() {
        print("🧪 Testing UserDefaults writing from main app...")
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard")
        
        // Test writing a value
        userDefaults?.set("SwiftUI", forKey: keyboardTypeKey)
        userDefaults?.synchronize()
        
        // Test reading it back
        let savedValue = userDefaults?.string(forKey: keyboardTypeKey)
        print("🧪 Written value: SwiftUI")
        print("🧪 Read back value: \(savedValue ?? "nil")")
        
        // Test writing UIKit
        userDefaults?.set("UIKit", forKey: keyboardTypeKey)
        userDefaults?.synchronize()
        
        let savedValue2 = userDefaults?.string(forKey: keyboardTypeKey)
        print("🧪 Written value: UIKit")
        print("🧪 Read back value: \(savedValue2 ?? "nil")")
        
        // Show alert with results
        let alert = UIAlertController(
            title: "UserDefaults Test Results",
            message: "SwiftUI: \(savedValue ?? "nil")\nUIKit: \(savedValue2 ?? "nil")",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func testAutoKeyboardSwitching() {
        print("🧪 Testing automatic keyboard switching...")
        
        // Show initial alert
        let initialAlert = UIAlertController(
            title: "Auto Switch Test",
            message: "This will automatically switch between UIKit and SwiftUI keyboards every 3 seconds. Check the debug console for logs.",
            preferredStyle: .alert
        )
        initialAlert.addAction(UIAlertAction(title: "Start Test", style: .default) { _ in
            self.performAutoSwitchTest()
        })
        initialAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(initialAlert, animated: true)
    }
    
    private func performAutoSwitchTest() {
        print("🧪 Starting automatic keyboard switching test...")
        
        // Switch to SwiftUI first
        keyboardType = .swiftui
        print("🧪 Switched to SwiftUI")
        
        // Wait 3 seconds, then switch to UIKit
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.keyboardType = .uikit
            print("🧪 Switched to UIKit")
            
            // Wait 3 seconds, then switch back to SwiftUI
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.keyboardType = .swiftui
                print("🧪 Switched back to SwiftUI")
                
                // Wait 3 seconds, then switch back to UIKit
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.keyboardType = .uikit
                    print("🧪 Final switch back to UIKit")
                    
                    // Show completion alert
                    let completionAlert = UIAlertController(
                        title: "Auto Switch Test Complete",
                        message: "The automatic keyboard switching test has completed. Check the debug console for detailed logs.",
                        preferredStyle: .alert
                    )
                    completionAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(completionAlert, animated: true)
                }
            }
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
        
        // Set the segmented control based on current keyboard type
        switch keyboardType {
        case .uikit:
            keyboardSegmentedControl.selectedSegmentIndex = 0
        case .swiftui:
            keyboardSegmentedControl.selectedSegmentIndex = 1
        }
    }
}
