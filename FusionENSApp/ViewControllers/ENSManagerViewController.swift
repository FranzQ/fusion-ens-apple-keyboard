//
//  ENSManagerViewController.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 12/09/2025.
//

import UIKit
import SnapKit

class ENSManagerViewController: UIViewController, UISearchResultsUpdating {
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let addButton = UIButton(type: .system)
    private let emptyStateView = UIView()
    private let emptyStateLabel = UILabel()
    private let getENSButton = UIButton(type: .system)
    
    // MARK: - Data
    private var ensNames: [ENSName] = []
    private var filteredENSNames: [ENSName] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadENSNames()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Clear avatar caches to free memory
        ENSNameTableViewCell.clearAvatarCache()
        ContactTableViewCell.clearAvatarCache()
        
        // Hide bottom navigation if we're in a tab bar controller
        if tabBarController != nil {
            // Note: ENSManagerViewController doesn't have a bottomNavView, it uses the native tab bar
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Only reload if we don't have any ENS names loaded
        if ensNames.isEmpty {
            loadENSNames()
        } else {
            // Just update the display without reloading data
            updateEmptyState()
            tableView.reloadData()
        }
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
        searchController.searchBar.placeholder = "Search..."
        searchController.searchBar.barTintColor = ColorTheme.secondaryBackground
        searchController.searchBar.searchTextField.backgroundColor = ColorTheme.searchBarBackground
        searchController.searchBar.searchTextField.textColor = ColorTheme.primaryText
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
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
        
        // Empty State View
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        emptyStateView.isUserInteractionEnabled = true
        view.addSubview(emptyStateView)
        
        emptyStateLabel.text = "No ENS names yet\nTap '+ Add ENS Name' to get started"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emptyStateLabel.textColor = ColorTheme.secondaryText
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(emptyStateLabel)
        
        // Get ENS Button
        getENSButton.setTitle("Don't have an ENS name? Tap here to get one", for: .normal)
        getENSButton.setTitleColor(.systemBlue, for: .normal)
        getENSButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        getENSButton.titleLabel?.textAlignment = .center
        getENSButton.titleLabel?.numberOfLines = 0
        getENSButton.backgroundColor = UIColor.clear
        getENSButton.translatesAutoresizingMaskIntoConstraints = false
        getENSButton.isUserInteractionEnabled = true
        getENSButton.addTarget(self, action: #selector(getENSButtonTapped), for: .touchUpInside)
        view.addSubview(getENSButton) // Add directly to main view instead of emptyStateView
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
        
        // Empty State View
        emptyStateView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
        }
        
        getENSButton.snp.makeConstraints { make in
            make.top.equalTo(emptyStateLabel.snp.bottom).offset(16)
            make.centerX.equalTo(view)
            make.leading.trailing.equalTo(view).inset(40)
            make.height.equalTo(60) // Make button taller for easier tapping
        }
    }
    
    // MARK: - Data Management
    private func loadENSNames() {
        // Use shared UserDefaults to enable keyboard suggestions
        // Add fallback to standard UserDefaults if App Group fails
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        
        if let data = userDefaults.data(forKey: "savedENSNamesData"),
           let savedNames = try? JSONDecoder().decode([ENSName].self, from: data) {
            ensNames = savedNames
        } else {
            // Start with empty array - no sample data
            ensNames = []
        }
        filteredENSNames = ensNames
        
        // Load full names for ENS names that don't have them
        loadFullNamesForENSNames()
        
        updateTableView()
    }
    
    private func updateEmptyState() {
        let hasENSNames = !filteredENSNames.isEmpty
        emptyStateView.isHidden = hasENSNames
        tableView.isHidden = !hasENSNames
        getENSButton.isHidden = hasENSNames // Hide button when there are ENS names
    }
    
    private func updateTableView() {
        updateEmptyState()
        tableView.reloadData()
    }
    
    private func updateTableViewEfficiently() {
        updateEmptyState()
        // Only reload if we have data to show
        if !filteredENSNames.isEmpty {
            tableView.reloadData()
        }
    }
    
    private func updateSpecificRow(at index: Int) {
        guard index < filteredENSNames.count else { return }
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    private func loadFullNamesForENSNames() {
        for (index, ensName) in ensNames.enumerated() {
            // Only load if fullName is nil AND we haven't already tried to load it
            if ensName.fullName == nil && !ensName.name.isEmpty {
                loadFullName(for: ensName, at: index)
            }
        }
    }
    
    private func loadFullName(for ensName: ENSName, at index: Int) {
        let baseDomain = extractBaseDomain(from: ensName.name)
        let fusionServerURL = "https://api.fusionens.com/resolve/\(baseDomain):name?network=mainnet&source=ios-app"
        
        guard let url = URL(string: fusionServerURL) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let success = json?["success"] as? Bool,
                      success,
                      let dataDict = json?["data"] as? [String: Any],
                      let fullName = dataDict["address"] as? String,
                      !fullName.isEmpty else {
                    return
                }
                
                // Clean HTML tags if present
                let cleanName = self.cleanHTMLTags(from: fullName)
                
                DispatchQueue.main.async {
                    if !cleanName.isEmpty && index < self.ensNames.count {
                        self.ensNames[index].fullName = cleanName
                        self.saveENSNames()
                        // Update only the specific row instead of reloading entire table
                        self.updateSpecificRow(at: index)
                    }
                }
            } catch {
                // JSON parsing failed, continue without error
                return
            }
        }.resume()
    }
    
    private func extractBaseDomain(from ensName: String) -> String {
        // Handle new format like vitalik.eth:btc
        if ensName.contains(":") {
            let parts = ensName.components(separatedBy: ":")
            if parts.count == 2 {
                return parts[0]
            }
        }
        
        // Handle shortcut format like vitalik:btc
        if ensName.contains(":") && !ensName.contains(".eth") {
            let parts = ensName.components(separatedBy: ":")
            if parts.count == 2 {
                return parts[0] + ".eth"
            }
        }
        
        // Return as is for standard .eth domains
        return ensName
    }
    
    private func cleanHTMLTags(from htmlString: String) -> String {
        // Remove HTML tags and decode HTML entities
        let cleanString = htmlString
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If the result is empty or contains only HTML artifacts, return empty string
        if cleanString.isEmpty || cleanString.contains("DOCTYPE") || cleanString.contains("html") {
            return ""
        }
        
        return cleanString
    }
    
    private func saveENSNames() {
        // Add fallback to standard UserDefaults if App Group fails
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        
        // Save full ENS name objects for the main app
        if let data = try? JSONEncoder().encode(ensNames) {
            userDefaults.set(data, forKey: "savedENSNamesData")
            userDefaults.synchronize()
        }
        
        // Also save ENS names as strings for keyboard suggestions (separate from contacts)
        let ensNameStrings = ensNames.map { $0.name }
        userDefaults.set(ensNameStrings, forKey: "myENSNames")
        userDefaults.synchronize()
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let vc = AddENSNameViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
    @objc private func getENSButtonTapped() {
        // Open app.ens.domains to get an ENS name
        let ensURL = "https://app.ens.domains"
        if let url = URL(string: ensURL) {
            UIApplication.shared.open(url) { success in
                if !success {
                    // Fallback: show alert if URL can't be opened
                    DispatchQueue.main.async {
                        let fallbackAlert = UIAlertController(title: "Cannot Open Browser", message: "Please visit \(ensURL) in your browser to get an ENS name.", preferredStyle: .alert)
                        fallbackAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(fallbackAlert, animated: true)
                    }
                }
            }
        }
    }
    
    private func showDeleteConfirmation(for ensName: ENSName, at indexPath: IndexPath) {
        // First confirmation alert
        let firstAlert = UIAlertController(
            title: "Remove ENS Name",
            message: "Are you sure you want to remove it from your list of ENS names? '\(ensName.name)'?",
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
            title: "Are you sure?",
            message: "This action cannot be undone. '\(ensName.name)'?",
            preferredStyle: .alert
        )
        
        secondAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        secondAlert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ENSNameCell", for: indexPath) as? ENSNameTableViewCell else {
            // Fallback to basic cell if casting fails
            let fallbackCell = UITableViewCell(style: .subtitle, reuseIdentifier: "FallbackCell")
            fallbackCell.textLabel?.text = filteredENSNames[indexPath.row].name
            fallbackCell.detailTextLabel?.text = filteredENSNames[indexPath.row].address
            return fallbackCell
        }
        cell.delegate = self
        cell.configure(with: filteredENSNames[indexPath.row])
        return cell
    }
}


// MARK: - UITableViewDelegate
extension ENSManagerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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
                title: "Remove ENS Name",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.showDeleteConfirmation(for: ensName, at: indexPath)
            }
            
            return UIMenu(title: ensName.name, children: [deleteAction])
        }
    }
}




// MARK: - AddENSNameDelegate
extension ENSManagerViewController: AddENSNameDelegate {
    func didAddENSName(_ ensName: ENSName) {
        ensNames.append(ensName)
        filteredENSNames = ensNames
        saveENSNames()
        updateTableViewEfficiently()
    }
    
    func didUpdateENSName(_ ensName: ENSName) {
        // Find and update the existing ENS name
        if let index = ensNames.firstIndex(where: { $0.name == ensName.name }) {
            ensNames[index] = ensName
            filteredENSNames = ensNames
            saveENSNames()
            tableView.reloadData()
        } else {
        }
    }
    
    func didRemoveENSName(_ ensName: String) {
        // Remove the ENS name if it exists
        ensNames.removeAll { $0.name == ensName }
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
    var fullName: String?
    
    init(name: String, address: String, dateAdded: Date, fullName: String? = nil) {
        self.name = name
        self.address = address
        self.dateAdded = dateAdded
        self.fullName = fullName
    }
}


// MARK: - ENSNameTableViewCellDelegate
extension ENSManagerViewController: ENSNameTableViewCellDelegate {
    func didTapRefresh(for ensName: ENSName) {
        refreshENSName(ensName)
    }
    
    private func refreshENSName(_ ensName: ENSName) {
        // Find the index of the ENS name to update
        guard let index = ensNames.firstIndex(where: { $0.name == ensName.name }) else { return }
        
        // Show loading state by updating the address to "Resolving..."
        var loadingENSName = ensNames[index]
        loadingENSName = ENSName(name: ensName.name, address: "Resolving...", dateAdded: ensName.dateAdded, fullName: ensName.fullName)
        ensNames[index] = loadingENSName
        filteredENSNames = ensNames
        saveENSNames()
        tableView.reloadData()
        
        // Resolve the ENS name with timeout
        let timeoutTask = DispatchWorkItem { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Timeout reached - restore original state
                if let originalIndex = self.ensNames.firstIndex(where: { $0.name == ensName.name }) {
                    self.ensNames[originalIndex] = ensName
                    self.filteredENSNames = self.ensNames
                    self.saveENSNames()
                    self.tableView.reloadData()
                }
                
                let timeoutAlert = UIAlertController(
                    title: "Request Timeout",
                    message: "Resolution of '\(ensName.name)' timed out. Please try again.",
                    preferredStyle: .alert
                )
                timeoutAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(timeoutAlert, animated: true)
            }
        }
        
        // Set 10 second timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: timeoutTask)
        
        APICaller.shared.resolveENSName(name: ensName.name) { [weak self] resolvedAddress in
            // Cancel timeout task since we got a response
            timeoutTask.cancel()
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if !resolvedAddress.isEmpty {
                    // Update with resolved address
                    let updatedENSName = ENSName(name: ensName.name, address: resolvedAddress, dateAdded: ensName.dateAdded, fullName: ensName.fullName)
                    
                    // Load full name asynchronously
                    self.loadFullName(for: updatedENSName) { fullName in
                        DispatchQueue.main.async {
                            var finalENSName = updatedENSName
                            finalENSName.fullName = fullName
                            
                            // Update the ENS name in the array
                            if let finalIndex = self.ensNames.firstIndex(where: { $0.name == ensName.name }) {
                                self.ensNames[finalIndex] = finalENSName
                                self.filteredENSNames = self.ensNames
                                self.saveENSNames()
                                self.tableView.reloadData()
                            }
                        }
                    }
                } else {
                    // Resolution failed - restore original state and show error
                    if let originalIndex = self.ensNames.firstIndex(where: { $0.name == ensName.name }) {
                        // Restore the original ENS name (remove "Resolving..." state)
                        self.ensNames[originalIndex] = ensName
                        self.filteredENSNames = self.ensNames
                        self.saveENSNames()
                        self.tableView.reloadData()
                    }
                    
                    // Show error alert
                    let errorAlert = UIAlertController(
                        title: "Resolution Failed",
                        message: "Could not resolve '\(ensName.name)'. Please check your internet connection and try again.",
                        preferredStyle: .alert
                    )
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            }
        }
    }
    
    private func loadFullName(for ensName: ENSName, completion: @escaping (String?) -> Void) {
        let baseDomain = extractBaseDomain(from: ensName.name)
        let fusionServerURL = "https://api.fusionens.com/resolve/\(baseDomain):name?network=mainnet&source=ios-app"
        
        guard let url = URL(string: fusionServerURL) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let success = json?["success"] as? Bool,
                      success,
                      let dataDict = json?["data"] as? [String: Any],
                      let fullName = dataDict["address"] as? String,
                      !fullName.isEmpty else {
                    completion(nil)
                    return
                }
                
                // Clean HTML tags if present
                let cleanName = self.cleanHTMLTags(from: fullName)
                completion(cleanName.isEmpty ? nil : cleanName)
            } catch {
                completion(nil)
            }
        }.resume()
    }
    
    func didTapQRCode(for ensName: ENSName) {
        // Navigate to payment request
        let paymentVC = PaymentRequestViewController(ensName: ensName)
        let navController = UINavigationController(rootViewController: paymentVC)
        navController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        navController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        present(navController, animated: true)
    }
    
    func didTapSettings(for ensName: ENSName) {
        // This method is no longer used since we show context menu instead
    }
    
    func didTapDelete(for ensName: ENSName) {
        // Show remove confirmation alert
        let alert = UIAlertController(title: "Remove ENS Name", message: "Are you sure you want to remove \(ensName.name)? This action cannot be undone.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.deleteENSName(ensName)
        })
        
        present(alert, animated: true)
    }
    
    func didTapManage(for ensName: ENSName) {
        // Open app.ens.domains for the specific ENS name
        let ensURL = "https://app.ens.domains/name/\(ensName.name)"
        if let url = URL(string: ensURL) {
            UIApplication.shared.open(url)
        }
    }
    
    private func deleteENSName(_ ensName: ENSName) {
        
        // Find the index of the ENS name to delete
        guard let index = ensNames.firstIndex(where: { $0.name == ensName.name }) else { 
            return 
        }
        
        // Remove from the main array
        ensNames.remove(at: index)
        
        // Update filtered array
        filteredENSNames = ensNames
        
        // Save the updated array
        saveENSNames()
        
        // Update the table view
        updateTableView()
        
        // Show success message
        let successAlert = UIAlertController(
            title: "Deleted",
            message: "'\(ensName.name)' has been deleted successfully.",
            preferredStyle: .alert
        )
        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
        present(successAlert, animated: true)
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        
        if searchText.isEmpty {
            filteredENSNames = ensNames
        } else {
            filteredENSNames = ensNames.filter { ensName in
                ensName.name.lowercased().contains(searchText.lowercased()) ||
                (ensName.fullName?.lowercased().contains(searchText.lowercased()) ?? false) ||
                ensName.address.lowercased().contains(searchText.lowercased())
            }
        }
        
        updateTableView()
    }
}
