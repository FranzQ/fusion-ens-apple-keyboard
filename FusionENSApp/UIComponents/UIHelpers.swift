//
//  UIHelpers.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 05/09/2025.
//

import UIKit

class UIHelpers {
    
    // MARK: - Colors
    let greenColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
    let greyColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
    
    // MARK: - Fonts
    var poppinsRegularFont: UIFont {
        UIFont(name: "Poppins-Regular", size: 16) ?? .systemFont(ofSize: 16, weight: .regular)
    }
    
    var poppinsBoldFont: UIFont {
        UIFont(name: "Poppins-Bold", size: 18) ?? .systemFont(ofSize: 18, weight: .bold)
    }
    
    init() {
        // Initialize any additional setup if needed
    }
}
