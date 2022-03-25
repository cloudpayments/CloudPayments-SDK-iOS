    import XCTest
    @testable import sdk

    final class sdkTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            XCTAssertEqual(sdk().text, "Hello, World!")
        }
    }
