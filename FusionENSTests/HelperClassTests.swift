import XCTest
@testable import FusionENSShared

class HelperClassTests: XCTestCase {
    
    // MARK: - ENS Format Validation Tests
    
    func testCheckFormatValidENS() {
        XCTAssertTrue(HelperClass.checkFormat("vitalik.eth"), "Valid ENS name should pass format check")
        XCTAssertTrue(HelperClass.checkFormat("jesse.base.eth"), "Valid Base subdomain should pass format check")
        XCTAssertTrue(HelperClass.checkFormat("fred.uni.eth"), "Valid subdomain should pass format check")
    }
    
    func testCheckFormatInvalidENS() {
        XCTAssertFalse(HelperClass.checkFormat(""), "Empty string should fail format check")
        XCTAssertFalse(HelperClass.checkFormat("invalid"), "String without .eth should fail format check")
        XCTAssertFalse(HelperClass.checkFormat(".eth"), "String starting with dot should fail format check")
        XCTAssertFalse(HelperClass.checkFormat("ses."), "String ending with dot should fail format check")
        XCTAssertFalse(HelperClass.checkFormat("ses..eth"), "String with double dots should fail format check")
        XCTAssertFalse(HelperClass.checkFormat(" ses.eth "), "String with spaces should fail format check")
    }
    
    func testCheckFormatMultiChain() {
        XCTAssertTrue(HelperClass.checkFormat("onshow.eth:btc"), "Multi-chain ENS name should pass format check")
        XCTAssertTrue(HelperClass.checkFormat("onshow.eth:sol"), "Multi-chain ENS name should pass format check")
        XCTAssertTrue(HelperClass.checkFormat("onshow.eth:doge"), "Multi-chain ENS name should pass format check")
    }
    
    // MARK: - L2 Subdomain Detection Tests
    
    func testIsL2SubdomainBase() {
        XCTAssertTrue(HelperClass.isL2Subdomain("jesse.base.eth"), "Base subdomain should be detected as L2")
        XCTAssertTrue(HelperClass.isL2Subdomain("ben.base.eth"), "Base subdomain should be detected as L2")
    }
    
    func testIsL2SubdomainNotBase() {
        XCTAssertFalse(HelperClass.isL2Subdomain("vitalik.eth"), "Regular .eth should not be detected as L2")
        XCTAssertFalse(HelperClass.isL2Subdomain("fred.uni.eth"), "Non-Base subdomain should not be detected as L2")
        XCTAssertFalse(HelperClass.isL2Subdomain("invalid"), "Invalid ENS should not be detected as L2")
    }
    
    // MARK: - L2 Network Type Tests
    
    func testGetL2NetworkTypeBase() {
        let networkType = HelperClass.getL2NetworkType("jesse.base.eth")
        XCTAssertEqual(networkType, .base, "Base subdomain should return .base network type")
    }
    
    func testGetL2NetworkTypeNotBase() {
        let networkType = HelperClass.getL2NetworkType("vitalik.eth")
        XCTAssertNil(networkType, "Regular .eth should return nil network type")
        
        let networkType2 = HelperClass.getL2NetworkType("fred.uni.eth")
        XCTAssertNil(networkType2, "Non-Base subdomain should return nil network type")
    }
    
    // MARK: - L2 Explorer Resolution Tests
    
    func testResolveL2SubdomainToExplorer() {
        let explorerURL = HelperClass.resolveL2SubdomainToExplorer("jesse.base.eth", resolvedAddress: "0x2211d1D0020DAEA8039E46Cf1367962070d77DA9")
        XCTAssertEqual(explorerURL, "https://basescan.org/address/0x2211d1D0020DAEA8039E46Cf1367962070d77DA9", "Should return correct BaseScan URL")
    }
    
    func testResolveL2SubdomainToExplorerInvalid() {
        let explorerURL = HelperClass.resolveL2SubdomainToExplorer("vitalik.eth", resolvedAddress: "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045")
        XCTAssertEqual(explorerURL, "https://etherscan.io/address/0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045", "Should return Etherscan URL for non-L2 domains")
    }
    
    // MARK: - L2 Chain Detection Settings Tests
    
    func testL2ChainDetectionEnabledDefault() {
        // Reset to default state
        HelperClass.setL2ChainDetectionEnabled(false)
        XCTAssertFalse(HelperClass.isL2ChainDetectionEnabled(), "L2 chain detection should be disabled by default")
    }
    
    func testL2ChainDetectionEnabledToggle() {
        // Test enabling
        HelperClass.setL2ChainDetectionEnabled(true)
        XCTAssertTrue(HelperClass.isL2ChainDetectionEnabled(), "L2 chain detection should be enabled after setting to true")
        
        // Test disabling
        HelperClass.setL2ChainDetectionEnabled(false)
        XCTAssertFalse(HelperClass.isL2ChainDetectionEnabled(), "L2 chain detection should be disabled after setting to false")
    }
    
    // MARK: - Default Browser Action Tests
    
    func testDefaultBrowserActionDefault() {
        // Reset to default
        HelperClass.setDefaultBrowserAction(.etherscan)
        XCTAssertEqual(HelperClass.getDefaultBrowserAction(), .etherscan, "Default browser action should be etherscan")
    }
    
    func testDefaultBrowserActionSet() {
        HelperClass.setDefaultBrowserAction(.github)
        XCTAssertEqual(HelperClass.getDefaultBrowserAction(), .github, "Should be able to set browser action to github")
        
        HelperClass.setDefaultBrowserAction(.url)
        XCTAssertEqual(HelperClass.getDefaultBrowserAction(), .url, "Should be able to set browser action to url")
        
        HelperClass.setDefaultBrowserAction(.x)
        XCTAssertEqual(HelperClass.getDefaultBrowserAction(), .x, "Should be able to set browser action to x")
    }
    
    // MARK: - Text Record URL Conversion Tests
    
    func testConvertTextRecordToURL() {
        let url = HelperClass.convertTextRecordToURL(recordType: "url", value: "https://example.com")
        XCTAssertEqual(url, "https://example.com", "Should return the URL value for url record type")
    }
    
    func testConvertTextRecordToURLX() {
        let url = HelperClass.convertTextRecordToURL(recordType: "x", value: "twitter_handle")
        XCTAssertEqual(url, "https://x.com/twitter_handle", "Should return formatted X URL")
    }
    
    func testConvertTextRecordToURLGitHub() {
        let url = HelperClass.convertTextRecordToURL(recordType: "github", value: "username")
        XCTAssertEqual(url, "https://github.com/username", "Should return formatted GitHub URL")
    }
    
    // MARK: - Edge Cases Tests
    
    func testVeryLongENSName() {
        let longName = String(repeating: "a", count: 100) + ".eth"
        XCTAssertTrue(HelperClass.checkFormat(longName), "Very long ENS name should pass format check")
    }
    
    func testSpecialCharactersInENS() {
        XCTAssertTrue(HelperClass.checkFormat("apu-pond.eth"), "ENS with hyphens should pass format check")
        XCTAssertTrue(HelperClass.checkFormat("shibtoshi001.eth"), "ENS with numbers should pass format check")
    }
    
    func testUnicodeCharactersInENS() {
        XCTAssertTrue(HelperClass.checkFormat("1️⃣1️⃣1️⃣.eth"), "ENS with Unicode characters should pass format check")
    }
    
    // MARK: - Performance Tests
    
    func testFormatCheckPerformance() {
        let testNames = [
            "vitalik.eth",
            "jesse.base.eth",
            "fred.uni.eth",
            "shibtoshi001.eth",
        ]
        
        measure {
            for name in testNames {
                _ = HelperClass.checkFormat(name)
            }
        }
    }
    
    func testL2DetectionPerformance() {
        let testNames = [
            "jesse.base.eth",
            "vitalik.eth",
            "fred.uni.eth"
        ]
        
        measure {
            for name in testNames {
                _ = HelperClass.isL2Subdomain(name)
                _ = HelperClass.getL2NetworkType(name)
            }
        }
    }
}
