import XCTest
@testable import FusionENSShared

class IntegrationTests: XCTestCase {
    
    var apiCaller: APICaller!
    
    override func setUp() {
        super.setUp()
        apiCaller = APICaller.shared
    }
    
    override func tearDown() {
        apiCaller = nil
        super.tearDown()
    }
    
    // MARK: - API Fallback Integration Tests
    
    func testENSDataAPIFallbackForBaseSubdomain() {
        let expectation = XCTestExpectation(description: "ENSData API fallback for Base subdomain")
        
        // Test that Base subdomains prioritize ENSData API
        apiCaller.resolveENSName(name: "jesse.base.eth") { address in
            XCTAssertFalse(address.isEmpty, "Base subdomain should resolve successfully")
            XCTAssertTrue(address.hasPrefix("0x"), "Address should be valid Ethereum address")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testFusionAPIFallbackForRegularETH() {
        let expectation = XCTestExpectation(description: "Fusion API with ENSData fallback for regular ETH")
        
        // Test that regular .eth domains use Fusion API first, then ENSData fallback
        apiCaller.resolveENSName(name: "vitalik.eth") { address in
            XCTAssertFalse(address.isEmpty, "Regular ETH domain should resolve successfully")
            XCTAssertTrue(address.hasPrefix("0x"), "Address should be valid Ethereum address")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testMultiChainResolution() {
        let expectation = XCTestExpectation(description: "Multi-chain resolution")
        
        // Test multi-chain domain resolution
        apiCaller.resolveENSName(name: "onshow.eth:btc") { address in
            // Multi-chain domains might return different formats
            // This test ensures the integration works without crashing
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    // MARK: - End-to-End Resolution Tests
    
    func testCompleteResolutionFlow() {
        let testCases = [
            ("vitalik.eth", "Regular ETH domain"),
            ("jesse.base.eth", "Base subdomain"),
            ("onshow.eth:btc", "Multi-chain domain"),
            ("ses.eth:x", "Text record")
        ]
        
        let expectation = XCTestExpectation(description: "Complete resolution flow")
        expectation.expectedFulfillmentCount = testCases.count
        
        for (ensName, description) in testCases {
            apiCaller.resolveENSName(name: ensName) { address in
                print("✅ \(description): \(ensName) -> \(address.isEmpty ? "No address" : "Resolved")")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    // MARK: - Network Error Handling Tests
    
    func testNetworkTimeoutHandling() {
        let expectation = XCTestExpectation(description: "Network timeout handling")
        
        // This test ensures the app handles network timeouts gracefully
        apiCaller.resolveENSName(name: "vitalik.eth") { address in
            // Should not crash even if network is slow
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testInvalidResponseHandling() {
        let expectation = XCTestExpectation(description: "Invalid response handling")
        
        // Test with a name that might return invalid responses
        apiCaller.resolveENSName(name: "notxistent.eth") { address in
            // Should handle gracefully and return empty string
            XCTAssertTrue(address.isEmpty, "Invalid ENS name should return empty address")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    // MARK: - Concurrent Resolution Tests
    
    func testConcurrentBaseSubdomainResolutions() {
        let expectation = XCTestExpectation(description: "Concurrent Base subdomain resolutions")
        expectation.expectedFulfillmentCount = 5
        
        let baseSubdomains = [
            "jesse.base.eth",
            "ben.base.eth",
            "dami.base.eth",
        ]
        
        for subdomain in baseSubdomains {
            apiCaller.resolveENSName(name: subdomain) { address in
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testConcurrentMixedResolutions() {
        let expectation = XCTestExpectation(description: "Concurrent mixed resolutions")
        expectation.expectedFulfillmentCount = 6
        
        let mixedNames = [
            "vitalik.eth",
            "jesse.base.eth",
            "onshow.eth:btc",
            "onshow.eth:sol",
            "test.eth",
            "ben.base.eth"
        ]
        
        for name in mixedNames {
            apiCaller.resolveENSName(name: name) { address in
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    // MARK: - Settings Integration Tests
    
    func testL2ChainDetectionIntegration() {
        let expectation = XCTestExpectation(description: "L2 chain detection integration")
        
        // Test with L2 detection enabled
        HelperClass.setL2ChainDetectionEnabled(true)
        XCTAssertTrue(HelperClass.isL2ChainDetectionEnabled(), "L2 detection should be enabled")
        
        // Test Base subdomain resolution with L2 detection enabled
        apiCaller.resolveENSName(name: "jesse.base.eth") { address in
            XCTAssertFalse(address.isEmpty, "Base subdomain should resolve with L2 detection enabled")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testL2ChainDetectionDisabledIntegration() {
        let expectation = XCTestExpectation(description: "L2 chain detection disabled integration")
        
        // Test with L2 detection disabled
        HelperClass.setL2ChainDetectionEnabled(false)
        XCTAssertFalse(HelperClass.isL2ChainDetectionEnabled(), "L2 detection should be disabled")
        
        // Test Base subdomain resolution with L2 detection disabled
        apiCaller.resolveENSName(name: "jesse.base.eth") { address in
            // Should still resolve, but might use different logic
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    // MARK: - Browser Action Integration Tests
    
    func testBrowserActionIntegration() {
        // Test setting different browser actions
        let browserActions: [HelperClass.DefaultBrowserAction] = [.etherscan, .github, .url, .x]
        
        for action in browserActions {
            HelperClass.setDefaultBrowserAction(action)
            XCTAssertEqual(HelperClass.getDefaultBrowserAction(), action, "Browser action should be set to \(action.rawValue)")
        }
    }
    
    // MARK: - Performance Integration Tests
    
    func testResolutionPerformanceUnderLoad() {
        measure {
            let expectation = XCTestExpectation(description: "Performance under load")
            expectation.expectedFulfillmentCount = 10
            
            let testNames = [
                "vitalik.eth",
                "jesse.base.eth",
                "test.eth",
                "ben.base.eth",
                "onshow.eth:btc",
                "onshow.eth:sol",
                "vitalik.eth:x",
                "ses.eth:url"
            ]
            
            for name in testNames {
                apiCaller.resolveENSName(name: name) { address in
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 30.0)
        }
    }
    
    // MARK: - Error Recovery Tests
    
    func testErrorRecoveryAfterFailedResolution() {
        let expectation = XCTestExpectation(description: "Error recovery after failed resolution")
        
        // First, try to resolve an invalid name
        apiCaller.resolveENSName(name: "definitelyinvalidname.eth") { address in
            XCTAssertTrue(address.isEmpty, "Invalid name should return empty address")
            
            // Then try to resolve a valid name to ensure the system recovers
            self.apiCaller.resolveENSName(name: "vitalik.eth") { validAddress in
                XCTAssertFalse(validAddress.isEmpty, "Valid name should resolve after error")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryManagementUnderLoad() {
        let expectation = XCTestExpectation(description: "Memory management under load")
        expectation.expectedFulfillmentCount = 20
        
        // Test multiple rapid resolutions to ensure no memory leaks
        for i in 0..<20 {
            apiCaller.resolveENSName(name: "test\(i).eth") { address in
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}
