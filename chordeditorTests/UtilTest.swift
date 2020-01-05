@testable import chordeditor
import XCTest

class UtilTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSubstringFromLength() {
        XCTAssertEqual("w", substring("Hello world", from: 6, length: 1))
        XCTAssertEqual("lo wor", substring("Hello world", from: 3, length: 6))
        XCTAssertEqual("🙂", substring("I feel 🙂😡", from: 7, length: 1))
        XCTAssertEqual("", substring("Out of bounds", from: 17, length: 1))
    }

    func testSubstringRange() {
        XCTAssertEqual("w", substring("Hello world", range: NSMakeRange(6, 1)))
        XCTAssertEqual("lo wor", substring("Hello world", range: NSMakeRange(3, 6)))
        XCTAssertEqual("🙂", substring("I feel 🙂😡", range: NSMakeRange(7, 1)))
        XCTAssertEqual("", substring("Out of bounds", range: NSMakeRange(17, 1)))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
