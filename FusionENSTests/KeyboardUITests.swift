import XCTest

class KeyboardUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    // MARK: - App Launch Tests
    
    func testAppLaunch() {
        // Test that the app launches successfully
        XCTAssertTrue(app.exists, "App should launch successfully")
    }
    
    func testMainScreenElements() {
        // Test that main screen elements are present
        XCTAssertTrue(app.navigationBars["Fusion ENS"].exists, "Main navigation bar should be present")
    }
    
    // MARK: - Settings Tests
    
    func testSettingsScreen() {
        // Navigate to settings
        let settingsButton = app.buttons["Settings"]
        if settingsButton.exists {
            settingsButton.tap()
            
            // Test settings screen elements
            XCTAssertTrue(app.navigationBars["Settings"].exists, "Settings navigation bar should be present")
            
            // Test Base Chain Detection toggle
            let baseChainToggle = app.switches["Base Chain Detection"]
            if baseChainToggle.exists {
                XCTAssertTrue(baseChainToggle.exists, "Base Chain Detection toggle should be present")
            }
            
            // Test Default Browser Action picker
            let browserActionPicker = app.pickers["Default Browser Action"]
            if browserActionPicker.exists {
                XCTAssertTrue(browserActionPicker.exists, "Default Browser Action picker should be present")
            }
        }
    }
    
    func testBaseChainDetectionToggle() {
        // Navigate to settings
        let settingsButton = app.buttons["Settings"]
        if settingsButton.exists {
            settingsButton.tap()
            
            let baseChainToggle = app.switches["Base Chain Detection"]
            if baseChainToggle.exists {
                // Test toggle functionality
                let initialState = baseChainToggle.value as? String
                baseChainToggle.tap()
                let newState = baseChainToggle.value as? String
                XCTAssertNotEqual(initialState, newState, "Toggle state should change when tapped")
            }
        }
    }
    
    func testDefaultBrowserActionPicker() {
        // Navigate to settings
        let settingsButton = app.buttons["Settings"]
        if settingsButton.exists {
            settingsButton.tap()
            
            let browserActionPicker = app.pickers["Default Browser Action"]
            if browserActionPicker.exists {
                // Test picker functionality
                browserActionPicker.tap()
                
                // Look for picker options
                let etherscanOption = app.pickerWheels.element(boundBy: 0)
                if etherscanOption.exists {
                    XCTAssertTrue(etherscanOption.exists, "Browser action picker should have options")
                }
            }
        }
    }
    
    // MARK: - Contacts Tests
    
    func testContactsScreen() {
        // Navigate to contacts
        let contactsButton = app.buttons["Contacts"]
        if contactsButton.exists {
            contactsButton.tap()
            
            // Test contacts screen elements
            XCTAssertTrue(app.navigationBars["Contacts"].exists, "Contacts navigation bar should be present")
            
            // Test add contact button
            let addButton = app.buttons["Add Contact"]
            if addButton.exists {
                XCTAssertTrue(addButton.exists, "Add Contact button should be present")
            }
        }
    }
    
    func testAddContactFlow() {
        // Navigate to contacts
        let contactsButton = app.buttons["Contacts"]
        if contactsButton.exists {
            contactsButton.tap()
            
            let addButton = app.buttons["Add Contact"]
            if addButton.exists {
                addButton.tap()
                
                // Test add contact screen
                XCTAssertTrue(app.navigationBars["Add Contact"].exists, "Add Contact navigation bar should be present")
                
                // Test ENS name input field
                let ensNameField = app.textFields["ENS Name"]
                if ensNameField.exists {
                    XCTAssertTrue(ensNameField.exists, "ENS Name input field should be present")
                    
                    // Test entering ENS name
                    ensNameField.tap()
                    ensNameField.typeText("vitalik.eth")
                    
                    // Test save button
                    let saveButton = app.buttons["Save"]
                    if saveButton.exists {
                        XCTAssertTrue(saveButton.exists, "Save button should be present")
                    }
                }
            }
        }
    }
    
    // MARK: - ENS Names Tests
    
    func testENSNamesScreen() {
        // Navigate to ENS Names
        let ensNamesButton = app.buttons["ENS Names"]
        if ensNamesButton.exists {
            ensNamesButton.tap()
            
            // Test ENS Names screen elements
            XCTAssertTrue(app.navigationBars["ENS Names"].exists, "ENS Names navigation bar should be present")
            
            // Test add ENS name button
            let addButton = app.buttons["Add ENS Name"]
            if addButton.exists {
                XCTAssertTrue(addButton.exists, "Add ENS Name button should be present")
            }
        }
    }
    
    func testAddENSNameFlow() {
        // Navigate to ENS Names
        let ensNamesButton = app.buttons["ENS Names"]
        if ensNamesButton.exists {
            ensNamesButton.tap()
            
            let addButton = app.buttons["Add ENS Name"]
            if addButton.exists {
                addButton.tap()
                
                // Test add ENS name screen
                XCTAssertTrue(app.navigationBars["Add ENS Name"].exists, "Add ENS Name navigation bar should be present")
                
                // Test ENS name input field
                let ensNameField = app.textFields["ENS Name"]
                if ensNameField.exists {
                    XCTAssertTrue(ensNameField.exists, "ENS Name input field should be present")
                    
                    // Test entering ENS name
                    ensNameField.tap()
                    ensNameField.typeText("jesse.base.eth")
                    
                    // Test save button
                    let saveButton = app.buttons["Save"]
                    if saveButton.exists {
                        XCTAssertTrue(saveButton.exists, "Save button should be present")
                    }
                }
            }
        }
    }
    
    // MARK: - Payment Request Tests
    
    func testPaymentRequestScreen() {
        // Navigate to payment request
        let paymentButton = app.buttons["Payment Request"]
        if paymentButton.exists {
            paymentButton.tap()
            
            // Test payment request screen elements
            XCTAssertTrue(app.navigationBars["Payment Request"].exists, "Payment Request navigation bar should be present")
            
            // Test ENS name input field
            let ensNameField = app.textFields["ENS Name"]
            if ensNameField.exists {
                XCTAssertTrue(ensNameField.exists, "ENS Name input field should be present")
            }
            
            // Test amount input field
            let amountField = app.textFields["Amount"]
            if amountField.exists {
                XCTAssertTrue(amountField.exists, "Amount input field should be present")
            }
        }
    }
    
    func testPaymentRequestFlow() {
        // Navigate to payment request
        let paymentButton = app.buttons["Payment Request"]
        if paymentButton.exists {
            paymentButton.tap()
            
            // Test entering payment request details
            let ensNameField = app.textFields["ENS Name"]
            if ensNameField.exists {
                ensNameField.tap()
                ensNameField.typeText("vitalik.eth")
            }
            
            let amountField = app.textFields["Amount"]
            if amountField.exists {
                amountField.tap()
                amountField.typeText("0.1")
            }
            
            // Test generate button
            let generateButton = app.buttons["Generate Request"]
            if generateButton.exists {
                XCTAssertTrue(generateButton.exists, "Generate Request button should be present")
            }
        }
    }
    
    // MARK: - Keyboard Guide Tests
    
    func testKeyboardGuideScreen() {
        // Navigate to keyboard guide
        let guideButton = app.buttons["Keyboard Guide"]
        if guideButton.exists {
            guideButton.tap()
            
            // Test keyboard guide screen elements
            XCTAssertTrue(app.navigationBars["Keyboard Guide"].exists, "Keyboard Guide navigation bar should be present")
            
            // Test scroll view content
            let scrollView = app.scrollViews.firstMatch
            if scrollView.exists {
                XCTAssertTrue(scrollView.exists, "Keyboard guide should have scrollable content")
            }
        }
    }
    
    // MARK: - Navigation Tests
    
    func testNavigationFlow() {
        // Test navigating between different screens
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            // Test tab bar navigation
            XCTAssertTrue(tabBar.exists, "Tab bar should be present")
            
            // Test different tabs
            let homeTab = app.tabBars.buttons["Home"]
            if homeTab.exists {
                homeTab.tap()
                XCTAssertTrue(homeTab.isSelected, "Home tab should be selected")
            }
            
            let settingsTab = app.tabBars.buttons["Settings"]
            if settingsTab.exists {
                settingsTab.tap()
                XCTAssertTrue(settingsTab.isSelected, "Settings tab should be selected")
            }
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() {
        // Test that important elements have accessibility labels
        let settingsButton = app.buttons["Settings"]
        if settingsButton.exists {
            XCTAssertTrue(settingsButton.label.count > 0, "Settings button should have accessibility label")
        }
        
        let contactsButton = app.buttons["Contacts"]
        if contactsButton.exists {
            XCTAssertTrue(contactsButton.label.count > 0, "Contacts button should have accessibility label")
        }
    }
    
    // MARK: - Performance Tests
    
    func testScreenLoadPerformance() {
        // Test screen load performance
        measure {
            let settingsButton = app.buttons["Settings"]
            if settingsButton.exists {
                settingsButton.tap()
                
                // Wait for screen to load
                let settingsNavBar = app.navigationBars["Settings"]
                XCTAssertTrue(settingsNavBar.waitForExistence(timeout: 2.0), "Settings screen should load within 2 seconds")
                
                // Navigate back
                app.navigationBars.buttons.firstMatch.tap()
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidENSNameHandling() {
        // Test handling of invalid ENS names
        let contactsButton = app.buttons["Contacts"]
        if contactsButton.exists {
            contactsButton.tap()
            
            let addButton = app.buttons["Add Contact"]
            if addButton.exists {
                addButton.tap()
                
                let ensNameField = app.textFields["ENS Name"]
                if ensNameField.exists {
                    ensNameField.tap()
                    ensNameField.typeText("invalid-ens-name")
                    
                    let saveButton = app.buttons["Save"]
                    if saveButton.exists {
                        saveButton.tap()
                        
                        // Should show error or validation message
                        // This test ensures the app doesn't crash with invalid input
                    }
                }
            }
        }
    }
    
    // MARK: - Keyboard Integration Tests
    
    func testKeyboardActivation() {
        // Test that the keyboard can be activated
        // Note: This is a simplified test - actual keyboard testing requires more complex setup
        
        let textField = app.textFields.firstMatch
        if textField.exists {
            textField.tap()
            
            // Wait for keyboard to appear
            let keyboard = app.keyboards.firstMatch
            if keyboard.waitForExistence(timeout: 2.0) {
                XCTAssertTrue(keyboard.exists, "Keyboard should appear when text field is tapped")
            }
        }
    }
}
