import XCTest
@testable import NOAAKit

final class NOAAKitTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(NOAAKit().text, "Hello, World!")
    }
}
