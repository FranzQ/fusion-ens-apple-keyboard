import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    private func setupTabBar() {
        // Dynamic theme for tab bar
        tabBar.backgroundColor = ColorTheme.tabBarBackground
        tabBar.barTintColor = ColorTheme.tabBarBackground
        tabBar.tintColor = ColorTheme.tabBarTint
        tabBar.unselectedItemTintColor = ColorTheme.tabBarUnselectedTint
        tabBar.isTranslucent = false
        
        // Add subtle border
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = ColorTheme.border.cgColor
    }
    
    private func setupViewControllers() {
        // My ENS Names
        let ensManagerVC = ENSManagerViewController()
        let ensNavController = UINavigationController(rootViewController: ensManagerVC)
        ensNavController.tabBarItem = UITabBarItem(
            title: "My ENS",
            image: UIImage(systemName: "person.circle"),
            selectedImage: UIImage(systemName: "person.circle.fill")
        )
        
        // Contacts
        let contactsVC = ContactsViewController()
        let contactsNavController = UINavigationController(rootViewController: contactsVC)
        contactsNavController.tabBarItem = UITabBarItem(
            title: "Contacts",
            image: UIImage(systemName: "person.2"),
            selectedImage: UIImage(systemName: "person.2.fill")
        )
        
        // Keyboard Guide
        let keyboardGuideVC = KeyboardGuideViewController()
        let keyboardNavController = UINavigationController(rootViewController: keyboardGuideVC)
        keyboardNavController.tabBarItem = UITabBarItem(
            title: "Keyboard",
            image: UIImage(systemName: "keyboard"),
            selectedImage: UIImage(systemName: "keyboard.fill")
        )
        
        // Settings
        let settingsVC = SettingsViewController()
        let settingsNavController = UINavigationController(rootViewController: settingsVC)
        settingsNavController.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        
        // Set view controllers
        viewControllers = [ensNavController, contactsNavController, keyboardNavController, settingsNavController]
        
        // Set initial selection
        selectedIndex = 0
    }
}
