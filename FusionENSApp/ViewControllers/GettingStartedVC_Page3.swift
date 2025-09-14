//
//  GettingStartedVC_Page3.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 05/09/2025.
//

import UIKit

class GettingStartedVC_Page3: UIViewController {
    
    var titleLabel = UILabel()
    var subtitleLabel = UILabel()
    var openSettingsButton = UIButton(type: .system)
    var doneButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupNavigationBar()
    }
    
    func setupUI() {
        // Title
        titleLabel.text = "Enable Full Access"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        // Subtitle
        subtitleLabel.text = "Enable 'Allow Full Access' for Fusion ENS keyboard to enable ENS resolution functionality."
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        view.addSubview(subtitleLabel)
        
        // Open Settings Button
        openSettingsButton.setTitle("Open iOS Settings", for: .normal)
        openSettingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        openSettingsButton.backgroundColor = .systemGreen
        openSettingsButton.setTitleColor(.white, for: .normal)
        openSettingsButton.layer.cornerRadius = 12
        openSettingsButton.addTarget(self, action: #selector(openSettingsTapped), for: .touchUpInside)
        view.addSubview(openSettingsButton)
        
        // Done Button
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        doneButton.backgroundColor = .systemBlue
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 12
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        openSettingsButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            openSettingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openSettingsButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 60),
            openSettingsButton.widthAnchor.constraint(equalToConstant: 200),
            openSettingsButton.heightAnchor.constraint(equalToConstant: 50),
            
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.topAnchor.constraint(equalTo: openSettingsButton.bottomAnchor, constant: 20),
            doneButton.widthAnchor.constraint(equalToConstant: 200),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Enable Full Access"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc func openSettingsTapped() {
        // Open iOS Settings to Keyboard settings
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    @objc func doneTapped() {
        dismiss(animated: true)
    }
}
