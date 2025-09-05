//
//  FusionENSButton.swift
//  FusionENSApp
//
//  Created by Franz Quarshie on 05/09/2025.
//

import Foundation
import UIKit

class FusionENSButton: UIButton {
    private let iconImageView = UIImageView()
    var uiHelpers = UIHelpers()
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        
        iconImageView.image = UIImage(named: "arrow-left")
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)
        
        // Set up Auto Layout constraints for icon
        NSLayoutConstraint.activate([
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 2),
            iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            iconImageView.widthAnchor.constraint(equalToConstant: 58),
            iconImageView.heightAnchor.constraint(equalToConstant: 54)
        ])
        
        // Customize the button appearance
        setTitleColor(.white, for: .normal)
        backgroundColor = uiHelpers.greenColor
        layer.cornerRadius = 8.0
        titleLabel?.font = UIFont(name: "Poppins-Regular", size: 16)
        
        // Set up Auto Layout constraints for title label
        titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel!.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel!.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30)
        ])
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
