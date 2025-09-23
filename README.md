# Fusion ENS iOS Keyboard

## 🎯 **What It Does**

A custom iOS keyboard that resolves ENS names (like `vitalik.eth`) to blockchain addresses. Type ENS names and get instant address resolution, send crypto, and manage contacts directly from your keyboard.

## ✨ **Key Features**

- **ENS Resolution**: Type `vitalik.eth` → get Ethereum address
- **Multi-Chain Support**: `vitalik.eth:btc` → Bitcoin address, `vitalik.eth:sol` → Solana address
- **Contact Management**: Save ENS names as contacts with avatars
- **Send Crypto**: Direct deeplinks to Trust Wallet, MetaMask, Coinbase Wallet
- **Payment Requests**: Generate QR codes for receiving crypto
- **Two Keyboards**: Basic (standard iOS) and Pro (custom UI with suggestions)

## 🛠️ **Technical Stack**

- **Swift 5.0+** with iOS 14.0+
- **KeyboardKit** for keyboard extensions
- **SnapKit** for Auto Layout
- **UserDefaults** with App Group sharing
- **URLSession** for ENS API calls

## 📱 **How It Works**

1. **Install** the app and enable keyboard in iOS Settings
2. **Switch** to Fusion ENS Keyboard in any text field
3. **Type** ENS names like `vitalik.eth` or `vitalik.eth:btc`
4. **Get** resolved addresses automatically inserted

## 🔗 **Supported Chains**

Bitcoin, Ethereum, Solana, Dogecoin, XRP, Litecoin, Cardano, Polkadot

## 🎯 **Problem Solved**

Instead of copying long addresses like `0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045`, just type `vitalik.eth` and get the address instantly.

## 🚀 **Use Cases**

- **Send crypto** to ENS names without copying addresses
- **Manage contacts** with ENS names and avatars
- **Create payment requests** with QR codes
- **Resolve addresses** in any iOS app
