//
//  ENSManagerViewController.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 12/09/2025.
//

import UIKit
import SnapKit

class ENSManagerViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let addButton = UIButton(type: .system)
    
    // MARK: - Data
    private var ensNames: [ENSName] = []
    private var filteredENSNames: [ENSName] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadENSNames()
        
        // Hide bottom navigation if we're in a tab bar controller
        if tabBarController != nil {
            // Note: ENSManagerViewController doesn't have a bottomNavView, it uses the native tab bar
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadENSNames()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = ColorTheme.primaryBackground
        
        // Navigation Bar
        navigationItem.title = "My ENS Names"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: ColorTheme.primaryText]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: ColorTheme.primaryText]
        navigationController?.navigationBar.barTintColor = ColorTheme.navigationBarBackground
        navigationController?.navigationBar.tintColor = ColorTheme.navigationBarTint
        
        // Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search ENS names..."
        searchController.searchBar.barTintColor = ColorTheme.secondaryBackground
        searchController.searchBar.searchTextField.backgroundColor = ColorTheme.searchBarBackground
        searchController.searchBar.searchTextField.textColor = ColorTheme.primaryText
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = ColorTheme.primaryBackground
        tableView.separatorStyle = .none
        tableView.register(ENSNameTableViewCell.self, forCellReuseIdentifier: "ENSNameCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Add Button
        addButton.setTitle("+ Add ENS Name", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = ColorTheme.accent
        addButton.layer.cornerRadius = 8
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(addButton.snp.top).offset(-16)
        }
        
        addButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    // MARK: - Data Management
    private func loadENSNames() {
        if let data = UserDefaults.standard.data(forKey: "SavedENSNames"),
           let savedNames = try? JSONDecoder().decode([ENSName].self, from: data) {
            ensNames = savedNames
        } else {
            // Start with empty array - no sample data
            ensNames = []
        }
        filteredENSNames = ensNames
        tableView.reloadData()
    }
    
    private func saveENSNames() {
        if let data = try? JSONEncoder().encode(ensNames) {
            UserDefaults.standard.set(data, forKey: "SavedENSNames")
        }
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let vc = AddENSNameViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
    private func showDeleteConfirmation(for ensName: ENSName, at indexPath: IndexPath) {
        // First confirmation alert
        let firstAlert = UIAlertController(
            title: "Delete ENS Name",
            message: "Are you sure you want to delete '\(ensName.name)'?",
            preferredStyle: .alert
        )
        
        firstAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        firstAlert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            // Second confirmation alert
            self?.showSecondDeleteConfirmation(for: ensName, at: indexPath)
        })
        
        present(firstAlert, animated: true)
    }
    
    private func showSecondDeleteConfirmation(for ensName: ENSName, at indexPath: IndexPath) {
        // Second confirmation alert
        let secondAlert = UIAlertController(
            title: "Final Confirmation",
            message: "This action cannot be undone. Are you absolutely sure you want to delete '\(ensName.name)'?",
            preferredStyle: .alert
        )
        
        secondAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        secondAlert.addAction(UIAlertAction(title: "Delete Forever", style: .destructive) { [weak self] _ in
            self?.deleteENSName(ensName, at: indexPath)
        })
        
        present(secondAlert, animated: true)
    }
    
    private func deleteENSName(_ ensName: ENSName, at indexPath: IndexPath) {
        // Remove from the main array
        if let index = ensNames.firstIndex(where: { $0.name == ensName.name }) {
            ensNames.remove(at: index)
        }
        
        // Remove from filtered array
        filteredENSNames.remove(at: indexPath.row)
        
        // Save the updated array
        saveENSNames()
        
        // Update the table view
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        // Show success message
        let successAlert = UIAlertController(
            title: "Deleted",
            message: "'\(ensName.name)' has been deleted successfully.",
            preferredStyle: .alert
        )
        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(successAlert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ENSManagerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredENSNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ENSNameCell", for: indexPath) as! ENSNameTableViewCell
        cell.configure(with: filteredENSNames[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ENSManagerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let ensName = filteredENSNames[indexPath.row]
        
        // Navigate to payment request
        let paymentVC = PaymentRequestViewController(ensName: ensName)
        let navController = UINavigationController(rootViewController: paymentVC)
        navController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        navController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        present(navController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let ensName = filteredENSNames[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(
                title: "Delete ENS Name",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.showDeleteConfirmation(for: ensName, at: indexPath)
            }
            
            return UIMenu(title: ensName.name, children: [deleteAction])
        }
    }
}

// MARK: - UISearchResultsUpdating
extension ENSManagerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        if searchText.isEmpty {
            filteredENSNames = ensNames
        } else {
            filteredENSNames = ensNames.filter { ensName in
                ensName.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        tableView.reloadData()
    }
}

// MARK: - AddENSNameDelegate
extension ENSManagerViewController: AddENSNameDelegate {
    func didAddENSName(_ ensName: ENSName) {
        ensNames.append(ensName)
        filteredENSNames = ensNames
        saveENSNames()
        tableView.reloadData()
    }
}

// MARK: - ENSName Model
struct ENSName: Codable {
    let name: String
    let address: String
    let dateAdded: Date
}