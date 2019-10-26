@testable import SZMentionsSwift
import XCTest

private final class CreateMentionTests: XCTestCase {
    func test_shouldReturnANameWithoutASpace_whenSpaceAfterMentionIsFalse() {
        let mention = ExampleMention(name: "Steven Zweier")

        XCTAssertEqual(mention.mentionName(with: false), "Steven Zweier")
    }

    func test_shouldReturnANameWithASpace_whenSpaceAfterMentionIsTrue() {
        let mention = ExampleMention(name: "Steven Zweier")

        XCTAssertEqual(mention.mentionName(with: true), "Steven Zweier ")
    }
}
