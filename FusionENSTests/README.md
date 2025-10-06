# Fusion ENS Keyboard Tests

This directory contains comprehensive tests for the Fusion ENS Keyboard app, covering unit tests, integration tests, and UI tests.

## Test Structure

### Unit Tests

#### `APICallerTests.swift`
Tests the core ENS resolution functionality:
- ✅ Regular .eth domain resolution
- ✅ Base subdomain (.base.eth) resolution
- ✅ Multi-chain domain resolution (.eth:btc, .eth:sol, etc.)
- ✅ Text record resolution (.eth:x, .eth:url, etc.)
- ✅ Invalid ENS name handling
- ✅ API fallback logic (Fusion API → ENSData API)
- ✅ Performance testing
- ✅ Concurrent resolution testing

#### `HelperClassTests.swift`
Tests utility functions and validation:
- ✅ ENS format validation
- ✅ L2 subdomain detection
- ✅ L2 network type detection
- ✅ Explorer URL generation
- ✅ UserDefaults settings management
- ✅ URL conversion utilities
- ✅ Edge cases and special characters
- ✅ Performance testing

### Integration Tests

#### `IntegrationTests.swift`
Tests end-to-end functionality:
- ✅ API fallback integration
- ✅ Complete resolution flow
- ✅ Network error handling
- ✅ Concurrent resolution testing
- ✅ Settings integration
- ✅ Browser action integration
- ✅ Performance under load
- ✅ Error recovery
- ✅ Memory management

### UI Tests

#### `KeyboardUITests.swift`
Tests user interface functionality:
- ✅ App launch and navigation
- ✅ Settings screen functionality
- ✅ Base Chain Detection toggle
- ✅ Default Browser Action picker
- ✅ Contacts management
- ✅ ENS Names management
- ✅ Payment Request functionality
- ✅ Keyboard Guide
- ✅ Accessibility
- ✅ Performance testing
- ✅ Error handling

## Running Tests

### Prerequisites
1. Open the project in Xcode
2. Add the test files to your project:
   - Create a new test target (if not already present)
   - Add the test files to the target
   - Ensure proper imports and dependencies

### Running Unit Tests
```bash
# Run all unit tests
xcodebuild test -scheme "Fusion ENS" -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test class
xcodebuild test -scheme "Fusion ENS" -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FusionENSTests/APICallerTests
```

### Running UI Tests
```bash
# Run UI tests
xcodebuild test -scheme "Fusion ENS" -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FusionENSTests/KeyboardUITests
```

### Running Integration Tests
```bash
# Run integration tests
xcodebuild test -scheme "Fusion ENS" -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FusionENSTests/IntegrationTests
```

## Test Configuration

### Test Targets
- **Unit Tests**: Test individual components in isolation
- **Integration Tests**: Test component interactions and API calls
- **UI Tests**: Test user interface and user flows

### Test Data
- Uses real ENS names for testing (vitalik.eth, jesse.base.eth)
- Tests both valid and invalid inputs
- Includes edge cases and error scenarios

### Network Testing
- Tests require internet connection for API calls
- Includes timeout and error handling tests
- Tests API fallback mechanisms

## Coverage Areas

### Critical Functionality
- ✅ ENS name resolution
- ✅ Base chain detection
- ✅ API fallback logic
- ✅ User settings persistence
- ✅ Keyboard functionality
- ✅ Contact management
- ✅ Payment requests

### Edge Cases
- ✅ Invalid ENS names
- ✅ Network timeouts
- ✅ API failures
- ✅ Special characters in ENS names
- ✅ Very long ENS names
- ✅ Unicode characters
- ✅ Concurrent requests

### Performance
- ✅ Resolution speed
- ✅ Memory usage
- ✅ Concurrent load handling
- ✅ UI responsiveness

## Adding New Tests

### Unit Tests
1. Create test methods with `test` prefix
2. Use `XCTAssert` for assertions
3. Test both success and failure cases
4. Include performance tests where appropriate

### Integration Tests
1. Test complete user flows
2. Test API interactions
3. Test error recovery
4. Test concurrent operations

### UI Tests
1. Use `XCUIApplication` for app interaction
2. Test user interface elements
3. Test navigation flows
4. Test accessibility

## Best Practices

### Test Organization
- Group related tests in the same class
- Use descriptive test method names
- Include setup and teardown methods
- Use expectations for asynchronous operations

### Assertions
- Use specific assertions (XCTAssertEqual, XCTAssertTrue, etc.)
- Include descriptive failure messages
- Test both positive and negative cases

### Performance
- Use `measure` blocks for performance tests
- Set appropriate timeouts for network operations
- Test under various load conditions

### Maintenance
- Update tests when functionality changes
- Remove obsolete tests
- Keep tests independent and isolated
- Use meaningful test data

## Troubleshooting

### Common Issues
1. **Import Errors**: Ensure proper `@testable import` statements
2. **Network Timeouts**: Increase timeout values for slow networks
3. **UI Test Failures**: Check element identifiers and accessibility labels
4. **Build Errors**: Ensure test target includes necessary dependencies

### Debug Tips
1. Use `print()` statements for debugging (remove before committing)
2. Check console output for detailed error messages
3. Use Xcode's test navigator for detailed test results
4. Run tests individually to isolate issues

## Continuous Integration

### GitHub Actions (Recommended)
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Tests
        run: xcodebuild test -scheme "Fusion ENS" -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Local CI
```bash
#!/bin/bash
# Run all tests locally
xcodebuild test -scheme "Fusion ENS" -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Metrics

### Coverage Goals
- **Unit Tests**: 80%+ code coverage
- **Integration Tests**: 90%+ critical path coverage
- **UI Tests**: 70%+ user flow coverage

### Performance Targets
- **ENS Resolution**: < 3 seconds
- **UI Response**: < 1 second
- **Memory Usage**: < 100MB under load
- **Concurrent Requests**: Handle 10+ simultaneous requests

## Contributing

When adding new features:
1. Write tests first (TDD approach)
2. Ensure all tests pass
3. Update test documentation
4. Add performance tests for critical paths
5. Include edge case testing

## Support

For test-related issues:
1. Check this README first
2. Review test logs and console output
3. Verify test environment setup
4. Check network connectivity for integration tests
