# Fusion ENS iOS Keyboard

## 🎯 **What We Built**

A custom iOS keyboard extension that provides ENS (Ethereum Name Service) resolution capabilities. Users can type ENS names and automatically resolve them to Ethereum addresses directly from their keyboard.

## ✨ **Key Features**

- **Custom iOS Keyboard**: Native keyboard extension that works in any iOS app
- **ENS Resolution**: Resolves ENS names (like `vitalik.eth`) to Ethereum addresses
- **Real-time Processing**: Resolves ENS names as you type or when text is selected
- **Standard QWERTY Layout**: Familiar keyboard layout with standard iOS functionality

## 🛠️ **Technical Implementation**

### **Architecture**
- **Main App**: `FusionENSApp` - iOS app that contains the keyboard extension
- **Keyboard Extension**: `FusionENSKeyboard` - The actual keyboard functionality
- **Swift**: Modern iOS development with Swift 5.0+
- **KeyboardKit**: Custom keyboard framework for iOS

### **Core Components**
- `KeyboardViewController.swift` - Main keyboard controller
- `FusionENSAutoCompleteProvider.swift` - ENS resolution logic
- `FusionENSKeyboardActionHandler.swift` - Keyboard input handling
- `FusionENSKeyboardAppearance.swift` - Keyboard styling
- `FusionENSKeyboardLayoutProvider.swift` - Keyboard layout configuration

### **Dependencies**
- **KeyboardKit**: Custom keyboard framework
- **Alamofire**: HTTP networking for ENS API calls
- **SnapKit**: Auto Layout DSL for UI constraints

## 📱 **How It Works**

1. **Install**: User installs the app and enables the keyboard in iOS Settings
2. **Activate**: User switches to Fusion ENS Keyboard in any text field
3. **Type**: User types ENS names like `vitalik.eth`
4. **Resolve**: Keyboard automatically resolves ENS names to Ethereum addresses
5. **Insert**: Resolved addresses are inserted into the text field

## 🎯 **Problem Solved**

- **Complex Addresses**: Ethereum addresses are long and hard to remember
- **User Friction**: Copy-pasting addresses between apps is error-prone
- **Poor UX**: Web3 interactions require switching between multiple tools

**Our Solution**: A keyboard that makes ENS names as easy to use as typing a name.

## 🚀 **Current Status**

- ✅ **Working Prototype**: Fully functional iOS keyboard extension
- ✅ **ENS Resolution**: Successfully resolves ENS names to addresses
- ✅ **iOS Integration**: Works in any app that supports custom keyboards
- ✅ **Code Signing**: Properly signed for device deployment

## 📊 **Technical Details**

- **Platform**: iOS 16.0+
- **Language**: Swift 5.0+
- **Architecture**: MVVM pattern
- **Networking**: HTTP requests to ENS resolver APIs
- **Caching**: Basic in-memory caching for resolved names
- **Bundle ID**: `com.fusionens.keyboard.app`

## 🔧 **Development Setup**

```bash
# Clone the repository
git clone <repository-url>
cd fusion-ens-apple-keyboard

# Open in Xcode
open FusionENSApp.xcodeproj

# Build and run
# Select your development team in Signing & Capabilities
# Choose target device and press ⌘+R
```

## 📱 **Installation for Users**

1. Install the app on iOS device
2. Go to **Settings > General > Keyboard > Keyboards**
3. Tap **"Add New Keyboard"**
4. Select **"Fusion ENS Keyboard"**
5. Enable **"Allow Full Access"** for ENS resolution


## 🏆 **Innovation**

- **First ENS Keyboard**: Pioneering iOS keyboard for ENS resolution
- **Native Integration**: Works system-wide without app switching
- **Real-time Resolution**: Instant ENS name to address conversion
- **Web3 Accessibility**: Makes blockchain addresses human-readable

---

**Fusion ENS Keyboard: Making Ethereum addresses as easy to use as typing a name.**