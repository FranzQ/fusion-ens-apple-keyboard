//
//  ColorTheme.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 12/09/2025.
//

import UIKit

struct ColorTheme {
    
    // MARK: - Background Colors
    static var primaryBackground: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0) // Dark background
            case .light:
                return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0) // Light background
            default:
                return UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
            }
        }
    }
    
    static var secondaryBackground: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0) // Dark secondary
            case .light:
                return UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Light secondary
            default:
                return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            }
        }
    }
    
    static var cardBackground: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0) // Dark card
            case .light:
                return UIColor.white // Light card
            default:
                return UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
            }
        }
    }
    
    static var searchBarBackground: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0) // Dark search
            case .light:
                return UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) // Light search
            default:
                return UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
            }
        }
    }
    
    // MARK: - Text Colors
    static var primaryText: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.white // Dark mode text
            case .light:
                return UIColor.black // Light mode text
            default:
                return UIColor.white
            }
        }
    }
    
    static var secondaryText: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) // Dark secondary text
            case .light:
                return UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0) // Light secondary text
            default:
                return UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            }
        }
    }
    
    static var placeholderText: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0) // Dark placeholder
            case .light:
                return UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) // Light placeholder
            default:
                return UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            }
        }
    }
    
    // MARK: - Accent Colors
    static var accent: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0) // Blue accent
            case .light:
                return UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0) // Slightly darker blue for light mode
            default:
                return UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    static var accentSecondary: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Dark accent secondary
            case .light:
                return UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0) // Light accent secondary
            default:
                return UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
            }
        }
    }
    
    // MARK: - Border Colors
    static var border: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Dark border
            case .light:
                return UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) // Light border
            default:
                return UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
            }
        }
    }
    
    // MARK: - Tab Bar Colors
    static var tabBarBackground: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0) // Dark tab bar
            case .light:
                return UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Light tab bar
            default:
                return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            }
        }
    }
    
    static var tabBarTint: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0) // Blue tint
            case .light:
                return UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0) // Slightly darker blue
            default:
                return UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    static var tabBarUnselectedTint: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) // Dark unselected
            case .light:
                return UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0) // Light unselected
            default:
                return UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            }
        }
    }
    
    // MARK: - Navigation Bar Colors
    static var navigationBarBackground: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0) // Dark nav bar
            case .light:
                return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0) // Light nav bar
            default:
                return UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
            }
        }
    }
    
    static var navigationBarTint: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.white // White tint for dark mode
            case .light:
                return UIColor.black // Black tint for light mode
            default:
                return UIColor.white
            }
        }
    }
}
