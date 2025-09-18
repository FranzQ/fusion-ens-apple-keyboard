# FusionENSShared

A shared Swift package containing common utilities for the Fusion ENS keyboard extensions.

## Overview

This package provides shared functionality for both the SwiftUI and UIKit versions of the Fusion ENS keyboard, eliminating code duplication and ensuring consistency across both implementations.

## Components

### APICaller
- **Purpose**: Handles ENS name resolution to Ethereum addresses
- **Features**: 
  - Multi-chain support (.eth, .btc, .sol, .doge, etc.)
  - Text record support (.x, .url, .github, .bio)
  - Fallback between Fusion API and ENS Ideas API
  - Singleton pattern for shared usage

### HelperClass
- **Purpose**: Provides utility functions for ENS validation
- **Features**:
  - ENS format validation
  - Multi-chain domain validation
  - New format support (e.g., vitalik.eth:btc)

### URLS
- **Purpose**: Centralized URL configuration for API endpoints
- **Features**:
  - Fusion API endpoints
  - ENS Ideas API endpoints
  - Dynamic URL generation

## Usage

```swift
import FusionENSShared

// Resolve an ENS name
APICaller.shared.resolveENSName(name: "vitalik.eth") { address in
    print("Resolved address: \(address)")
}

// Validate ENS format
let isValid = HelperClass.isValidENS("vitalik.eth")
```

## Dependencies

- Alamofire 5.8.0+ for HTTP networking

## Supported Formats

- Standard ENS: `vitalik.eth`
- Multi-chain: `vitalik.btc`, `vitalik.sol`, `vitalik.doge`
- Text records: `vitalik.x`, `vitalik.url`, `vitalik.github`
- New format: `vitalik.eth:btc`

## API Endpoints

- **Fusion API**: `https://api.fusionens.com/resolve/`
- **ENS Ideas API**: `https://api.ensideas.com/ens/resolve/`
