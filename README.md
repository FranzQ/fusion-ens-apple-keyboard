# Fusion ENS Keyboard

A custom iOS keyboard extension that provides seamless ENS (Ethereum Name Service) resolution capabilities, allowing users to type ENS names and automatically resolve them to Ethereum addresses.

## Features

- **ENS Resolution**: Automatically resolves ENS names (like `vitalik.eth`) to their corresponding Ethereum addresses
- **Custom Keyboard**: Native iOS keyboard extension with standard QWERTY layout
- **Real-time Processing**: Resolves ENS names as you type or when text is selected
- **User-friendly Interface**: Clean, iOS-native keyboard design with intuitive controls
- **Offline Support**: Basic keyboard functionality works without internet connection

## Requirements

- iOS 16.0 or later
- Xcode 14.0 or later
- Swift 5.0 or later

## Dependencies

- **KeyboardKit**: Custom keyboard framework for iOS
- **Alamofire**: HTTP networking library for ENS resolution API calls
- **SnapKit**: Auto Layout DSL for Swift

## Installation

### Development Setup

1. Clone the repository:
```bash
git clone https://github.com/fusionens/fusion-ens-keyboard-app.git
cd fusion-ens-keyboard-app
```

2. Open the project in Xcode:
```bash
open FusionENSApp.xcodeproj
```

3. Build and run the project on iOS Simulator or device

### Adding the Keyboard to iOS

1. Install the app on your iOS device
2. Go to **Settings** > **General** > **Keyboard** > **Keyboards** > **Add New Keyboard**
3. Select **Fusion ENS Keyboard** from the list
4. Enable **Allow Full Access** to enable ENS resolution functionality

## Usage

### Basic Usage

1. Open any app that supports text input
2. Long-press the globe icon on the keyboard to switch to Fusion ENS Keyboard
3. Type normally - ENS names will be automatically resolved when appropriate

### ENS Resolution

The keyboard automatically detects and resolves ENS names in the following scenarios:

- **Selected Text**: Select any ENS name and it will be resolved to the corresponding Ethereum address
- **Current Word**: As you type, the current word is checked for ENS format and resolved automatically
- **Manual Trigger**: The keyboard can be configured to resolve ENS names on demand

### Supported ENS Formats

- Standard ENS names: `vitalik.eth`, `ens.eth`
- Subdomains: `subdomain.ens.eth`
- Custom TLDs: `example.crypto`, `name.blockchain`

## Project Structure

```
FusionENSApp/
├── FusionENSApp/                 # Main iOS application
│   ├── ViewControllers/          # Onboarding and setup screens
│   ├── UIComponents/             # Custom UI components
│   ├── Assets.xcassets/          # App icons and images
│   └── Fonts/                    # Custom fonts
├── FusionENSKeyboard/            # Keyboard extension
│   ├── KeyboardViewController.swift    # Main keyboard controller
│   ├── FusionENSAutoCompleteProvider.swift    # Autocomplete functionality
│   ├── FusionENSKeyboardActionHandler.swift   # Key press handling
│   ├── FusionENSKeyboardAppearance.swift      # Keyboard styling
│   ├── FusionENSKeyboardLayoutProvider.swift  # Layout management
│   └── Utilties/                 # Helper classes and API calls
└── FusionENSApp.xcodeproj        # Xcode project file
```

## Configuration

### ENS Resolution API

The keyboard uses a configurable API endpoint for ENS resolution. Update the API URL in `URLS.swift`:

```swift
static let baseURL = "https://your-ens-api-endpoint.com"
```

### Keyboard Appearance

Customize the keyboard appearance in `FusionENSKeyboardAppearance.swift`:

```swift
var backgroundColor: UIColor = .systemBackground
var textColor: UIColor = .label
var buttonBackgroundColor: UIColor = .systemGray5
```

## Development

### Building the Project

```bash
# Build for iOS Simulator
xcodebuild -project FusionENSApp.xcodeproj -scheme FusionENSApp -destination 'platform=iOS Simulator,name=iPhone 16' build

# Build for device (requires valid provisioning profile)
xcodebuild -project FusionENSApp.xcodeproj -scheme FusionENSApp -destination 'generic/platform=iOS' build
```

### Testing

1. Run the app in iOS Simulator
2. Navigate to any text input field
3. Switch to the Fusion ENS Keyboard
4. Test ENS resolution by typing or selecting ENS names

### Debugging

- Check Xcode console for ENS resolution logs
- Monitor network requests for API calls
- Use iOS Simulator's keyboard switching to test functionality

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Style

- Follow Swift style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Ensure all code compiles without warnings

## Security Considerations

- The keyboard requires "Full Access" permission to enable ENS resolution
- ENS resolution involves network requests - ensure API endpoints are secure
- Consider implementing rate limiting for API calls
- Validate all ENS names before resolution attempts

## Troubleshooting

### Common Issues

**Keyboard not appearing:**
- Ensure the app is installed and the keyboard is enabled in Settings
- Check that "Allow Full Access" is enabled for ENS resolution

**ENS resolution not working:**
- Verify internet connection
- Check API endpoint configuration
- Review console logs for error messages

**Build errors:**
- Ensure all dependencies are properly resolved
- Check iOS deployment target compatibility
- Verify code signing settings

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:

- Create an issue on GitHub
- Contact the development team
- Check the documentation wiki

## Acknowledgments

- Built with [KeyboardKit](https://github.com/KeyboardKit/KeyboardKit) framework
- ENS resolution powered by Ethereum Name Service
- Inspired by the need for seamless Web3 integration in mobile keyboards

## Roadmap

- [ ] Support for additional blockchain domains (.crypto, .blockchain)
- [ ] Custom keyboard themes and layouts
- [ ] Offline ENS name caching
- [ ] Integration with popular Web3 wallets
- [ ] Multi-language support
- [ ] Advanced autocomplete suggestions