@testable import chordeditor
import XCTest

/// A test case to validate our logic inside the `UsersViewModel`.
final class SourceColorizerTests: XCTestCase {
    /// It should correctly reflect whether it has users.
    func testHasUsers() {
        let colorizer = SourceColorizer()
        colorizer.colorize(string: """
                                                                                                                                                                                                        # Überschrift

                                                                                                                                                                                                        [Am]Das ist mein [D]Test
""")
    }
}
