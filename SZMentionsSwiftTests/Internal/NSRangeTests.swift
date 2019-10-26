@testable import SZMentionsSwift
import XCTest

private final class NSRangeTests: XCTestCase {
    func test_shouldAddMention() {
        var range = NSRange(location: 0, length: 2)
        range = range.adjustLength(for: "Test")
        XCTAssertEqual(range.location, 0)
        XCTAssertEqual(range.length, 4)
    }
}
