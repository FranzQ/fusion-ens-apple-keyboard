//
//  SettingsView.swift
//  FusionENSKeyboard
//
//  Created by Franz Quarshie on 05/09/2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var hapticFeedbackEnabled: Bool = true
    @State private var keyboardType: KeyboardType = .uikit
    private let hapticFeedbackKey = "hapticFeedbackEnabled"
    private let keyboardTypeKey = "keyboardType"
    
    enum KeyboardType: String, CaseIterable {
        case uikit = "UIKit"
        case swiftui = "SwiftUI"
        
        var displayName: String {
            switch self {
            case .uikit:
                return "UIKit (Default)"
            case .swiftui:
                return "SwiftUI (Modern)"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Keyboard Settings")) {
                    Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
                        .onChange(of: hapticFeedbackEnabled) { newValue in
                            saveHapticFeedbackSetting(newValue)
                        }
                    
                    Picker("Keyboard Type", selection: $keyboardType) {
                        ForEach(KeyboardType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .onChange(of: keyboardType) { newValue in
                        saveKeyboardTypeSetting(newValue)
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Fusion ENS")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Support")) {
                    if let websiteURL = URL(string: "https://fusionens.com") {
                        Link("Visit Website", destination: websiteURL)
                    }
                    if let supportURL = URL(string: "mailto:hello@fusionens.com") {
                        Link("Contact Support", destination: supportURL)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                loadHapticFeedbackSetting()
                loadKeyboardTypeSetting()
            }
        }
    }
    
    private func loadHapticFeedbackSetting() {
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        hapticFeedbackEnabled = userDefaults.bool(forKey: hapticFeedbackKey)
    }
    
    private func saveHapticFeedbackSetting(_ enabled: Bool) {
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        userDefaults.set(enabled, forKey: hapticFeedbackKey)
        userDefaults.synchronize()
    }
    
    private func loadKeyboardTypeSetting() {
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        if let savedType = userDefaults.string(forKey: keyboardTypeKey),
           let type = KeyboardType(rawValue: savedType) {
            keyboardType = type
        } else {
            keyboardType = .uikit // Default to UIKit
        }
    }
    
    private func saveKeyboardTypeSetting(_ type: KeyboardType) {
        let userDefaults = UserDefaults(suiteName: "group.com.fusionens.keyboard") ?? UserDefaults.standard
        userDefaults.set(type.rawValue, forKey: keyboardTypeKey)
        userDefaults.synchronize()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
