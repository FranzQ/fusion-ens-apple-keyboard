//
//  ViewController.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 05/09/2025.
//

import UIKit

class GettingStartedVC: UIViewController {
    
    var titleLabel = UILabel()
    var subtitleLabel = UILabel()
    var getStartedButton = UIButton(type: .system)
    var manageENSButton = UIButton(type: .system)
    var settingsButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    func setupUI() {
        // Title
        titleLabel.text = "Fusion ENS"
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        // Subtitle
        subtitleLabel.text = "ENS Resolution Keyboard"
        subtitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        view.addSubview(subtitleLabel)
        
        // Get Started Button
        getStartedButton.setTitle("Setup Keyboard", for: .normal)
        getStartedButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        getStartedButton.backgroundColor = .systemBlue
        getStartedButton.setTitleColor(.white, for: .normal)
        getStartedButton.layer.cornerRadius = 12
        getStartedButton.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
        view.addSubview(getStartedButton)
        
        // Manage ENS Button
        manageENSButton.setTitle("Manage ENS Names", for: .normal)
        manageENSButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        manageENSButton.backgroundColor = .systemGreen
        manageENSButton.setTitleColor(.white, for: .normal)
        manageENSButton.layer.cornerRadius = 12
        manageENSButton.addTarget(self, action: #selector(manageENSTapped), for: .touchUpInside)
        view.addSubview(manageENSButton)
        
        // Settings Button
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        settingsButton.backgroundColor = .systemGray
        settingsButton.setTitleColor(.white, for: .normal)
        settingsButton.layer.cornerRadius = 12
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        view.addSubview(settingsButton)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        getStartedButton.translatesAutoresizingMaskIntoConstraints = false
        manageENSButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            
            getStartedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartedButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 60),
            getStartedButton.widthAnchor.constraint(equalToConstant: 200),
            getStartedButton.heightAnchor.constraint(equalToConstant: 50),
            
            manageENSButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            manageENSButton.topAnchor.constraint(equalTo: getStartedButton.bottomAnchor, constant: 20),
            manageENSButton.widthAnchor.constraint(equalToConstant: 200),
            manageENSButton.heightAnchor.constraint(equalToConstant: 50),
            
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.topAnchor.constraint(equalTo: manageENSButton.bottomAnchor, constant: 20),
            settingsButton.widthAnchor.constraint(equalToConstant: 200),
            settingsButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func getStartedTapped() {
        let vc = GettingStartedVC_Page2()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
    
    @objc func manageENSTapped() {
        let vc = ENSManagerViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
    
    @objc func settingsTapped() {
        let vc = SettingsViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
}

