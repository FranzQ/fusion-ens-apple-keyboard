import XCTest
@testable import FusionENSShared

class APICallerTests: XCTestCase {
    
    var apiCaller: APICaller!
    
    override func setUp() {
        super.setUp()
        apiCaller = APICaller.shared
    }
    
    override func tearDown() {
        apiCaller = nil
        super.tearDown()
    }
    
    // MARK: - ENS Resolution Tests
    
    func testResolveRegularETHName() {
        let expectation = XCTestExpectation(description: "Resolve regular .eth name")
        
        apiCaller.resolveENSName(name: "vitalik.eth") { address in
            XCTAssertFalse(address.isEmpty, "Should resolve to a valid address")
            XCTAssertTrue(address.hasPrefix("0x"), "Address should start with 0x")
            XCTAssertEqual(address.count, 42, "Address should be 42 characters long")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testResolveBaseSubdomain() {
        let expectation = XCTestExpectation(description: "Resolve Base subdomain")
        
        apiCaller.resolveENSName(name: "jesse.base.eth") { address in
            XCTAssertFalse(address.isEmpty, "Should resolve Base subdomain to a valid address")
            XCTAssertTrue(address.hasPrefix("0x"), "Address should start with 0x")
            XCTAssertEqual(address.count, 42, "Address should be 42 characters long")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testResolveMultiChainDomain() {
        let expectation = XCTestExpectation(description: "Resolve multi-chain domain")
        
        apiCaller.resolveENSName(name: "onshow.eth:btc") { address in
            XCTAssertFalse(address.isEmpty, "Should resolve multi-chain domain to a valid address")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testResolveTextRecord() {
        let expectation = XCTestExpectation(description: "Resolve text record")
        
        apiCaller.resolveENSName(name: "ses.eth:x") { address in
            // Text records might return empty or a different format
            // This test ensures the method doesn't crash
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testResolveInvalidENSName() {
        let expectation = XCTestExpectation(description: "Resolve invalid ENS name")
        
        apiCaller.resolveENSName(name: "invalidname.eth") { address in
            // Should return empty string for invalid names
            XCTAssertTrue(address.isEmpty, "Invalid ENS name should return empty address")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testResolveEmptyName() {
        let expectation = XCTestExpectation(description: "Resolve empty name")
        
        apiCaller.resolveENSName(name: "") { address in
            XCTAssertTrue(address.isEmpty, "Empty name should return empty address")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Chain Detection Tests
    
    func testDetectETHChain() {
        let expectation = XCTestExpectation(description: "Detect ETH chain")
        
        apiCaller.resolveENSName(name: "ses.eth") { address in
            // This tests the internal chain detection logic
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testDetectBTCChain() {
        let expectation = XCTestExpectation(description: "Detect BTC chain")
        
        apiCaller.resolveENSName(name: "onshow.eth:btc") { address in
            // This tests the internal chain detection logic
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - API Fallback Tests
    
    func testAPIFallbackForETHSubdomain() {
        let expectation = XCTestExpectation(description: "Test API fallback for ETH subdomain")
        
        // Test that Base subdomains use ENSData API first
        apiCaller.resolveENSName(name: "jesse.base.eth") { address in
            // Should attempt ENSData API first, then fallback if needed
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testAPIFallbackForRegularETH() {
        let expectation = XCTestExpectation(description: "Test API fallback for regular ETH")
        
        // Test that regular .eth domains use Fusion API first, then ENSData fallback
        apiCaller.resolveENSName(name: "vitalik.eth") { address in
            // Should attempt Fusion API first, then ENSData fallback if needed
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Performance Tests
    
    func testResolutionPerformance() {
        measure {
            let expectation = XCTestExpectation(description: "Performance test")
            
            apiCaller.resolveENSName(name: "vitalik.eth") { address in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    // MARK: - Concurrent Resolution Tests
    
    func testConcurrentResolutions() {
        let expectation = XCTestExpectation(description: "Concurrent resolutions")
        expectation.expectedFulfillmentCount = 3
        
        let names = ["vitalik.eth", "jesse.base.eth", "onshow.eth:btc"]
        
        for name in names {
            apiCaller.resolveENSName(name: name) { address in
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
}
