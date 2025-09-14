//
//  SettingsView.swift
//  FusionENSKeyboard
//
//  Created by Franz Quarshie on 05/09/2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var hapticFeedbackEnabled: Bool = true
    private let hapticFeedbackKey = "hapticFeedbackEnabled"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Keyboard Settings")) {
                    Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
                        .onChange(of: hapticFeedbackEnabled) { newValue in
                            saveHapticFeedbackSetting(newValue)
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
                    Link("Visit Website", destination: URL(string: "https://fusionens.com")!)
                    Link("Contact Support", destination: URL(string: "mailto:hello@fusionens.com")!)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                loadHapticFeedbackSetting()
            }
        }
    }
    
    private func loadHapticFeedbackSetting() {
        hapticFeedbackEnabled = UserDefaults(suiteName: "group.com.fusionens.keyboard")?.bool(forKey: hapticFeedbackKey) ?? true
    }
    
    private func saveHapticFeedbackSetting(_ enabled: Bool) {
        UserDefaults(suiteName: "group.com.fusionens.keyboard")?.set(enabled, forKey: hapticFeedbackKey)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
