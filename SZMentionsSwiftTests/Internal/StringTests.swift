@testable import SZMentionsSwift
import XCTest

private final class StringExtensionTests: XCTestCase {
    func test_shouldBeAbleToSearchWithMultipleSearchItemsPrioritizingTheFirstElementInTheSearchArray() {
        let stringToSearch = "This is a #test string to @search"
        let result = stringToSearch.range(of: ["@", "#"], options: .caseInsensitive)
        XCTAssertEqual(result.range, NSRange(location: 26, length: 1))
        XCTAssertEqual(result.foundString, "@")
    }

    func test_shouldBeAbleToSearchWithMultipleSearchItemsPrioritizingTheFirstElementInTheSearchArray2() {
        let stringToSearch = "This is a #test string to @search"
        let result = stringToSearch.range(of: ["#", "@"], options: .caseInsensitive)
        XCTAssertEqual(result.range, NSRange(location: 10, length: 1))
        XCTAssertEqual(result.foundString, "#")
    }

    func test_shouldBeAbleToSearchWithMultipleSearchItemsPrioritizingTheFirstElementInTheSearchArray_whenOnlyOneExists() {
        let stringToSearch = "This is a test string to @search"
        let result = stringToSearch.range(of: ["#", "@"], options: .caseInsensitive)
        XCTAssertEqual(result.range, NSRange(location: 25, length: 1))
        XCTAssertEqual(result.foundString, "@")
    }

    func test_shouldReturnNSNotFoundWithEmptyString_whenGivenAnEmptyInputArray() {
        let stringToSearch = "This is a test string to @search"
        let result = stringToSearch.range(of: [], options: .caseInsensitive)
        XCTAssertEqual(result.range, NSRange(location: NSNotFound, length: 0))
        XCTAssertEqual(result.foundString, "")
    }

    func test_shouldProperlySearchWithinASpecifiedRange() {
        let stringToSearch = "This is a test #string to @search"
        let result = stringToSearch.range(of: ["#", "@"], options: .caseInsensitive, range: NSRange(location: 17, length: 16))
        XCTAssertEqual(result.range, NSRange(location: 26, length: 1))
        XCTAssertEqual(result.foundString, "@")
    }

    func test_shouldReturnTrueForIsMentionEnabledAt_whenTheTriggerIsPreceededByASpace() {
        let stringToSearch = "This is @search"
        XCTAssertTrue(stringToSearch.isMentionEnabledAt(8).0)
    }

    func test_shouldReturnTrueForIsMentionEnabledAt_whenTheTriggerIsPreceededByANewLine() {
        let stringToSearch = "This is\n@search"
        XCTAssertTrue(stringToSearch.isMentionEnabledAt(8).0)
    }

    func test_shouldReturnTrueForIsMentionEnabledAt_whenTheTriggerIsNotPreceededByANewLineNorASpace() {
        let stringToSearch = "This is@search"
        XCTAssertFalse(stringToSearch.isMentionEnabledAt(7).0)
    }
}
