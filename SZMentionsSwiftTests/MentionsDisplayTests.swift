@testable import SZMentionsSwift
import XCTest

private final class MentionsDisplay: XCTestCase {
    var hidingMentionsList: Bool!
    var mentionsString: String!
    var triggerString: String!
    var mentionsListener: MentionListener!
    var textView: UITextView!

    func hideMentions() { hidingMentionsList = true }
    func showMentions(mention: String, trigger: String) {
        hidingMentionsList = false
        mentionsString = mention
        triggerString = trigger
    }

    override func setUp() {
        super.setUp()
        textView = UITextView()
    }

    override func tearDown() {
        super.tearDown()
        textView = nil
        mentionsListener = nil
        triggerString = nil
        mentionsString = nil
        hidingMentionsList = nil
    }

    func test_shouldShowTheMentionsListWhenTypingAMentionAndHideWhenASpaceIsAdded_whenSearchSpacesIsFalse() {
        mentionsListener = generateMentionsListener(searchSpacesInMentions: false, spaceAfterMention: false)
        textView.insertText("@t")

        XCTAssertFalse(hidingMentionsList)
        XCTAssertEqual(mentionsString, "t")
        XCTAssertEqual(triggerString, "@")

        textView.insertText(" ")

        XCTAssertTrue(hidingMentionsList)
    }

    func test_shouldShowTheMentionsListWhenTypingAMentionAndRemainVisibleWhenASpaceIsAdded_whenSearchSpacesIsTrue() {
        mentionsListener = generateMentionsListener(searchSpacesInMentions: true, spaceAfterMention: false)
        textView.insertText("@t")

        XCTAssertFalse(hidingMentionsList)
        XCTAssertEqual(mentionsString, "t")
        XCTAssertEqual(triggerString, "@")

        textView.insertText(" ")

        XCTAssertFalse(hidingMentionsList)
    }

    func test_shouldShowTheMentionsListWhenTypingAMentionOnANewLineAndHideWhenASpaceIsAdded_whenSearchSpacesIsFalse() {
        mentionsListener = generateMentionsListener(searchSpacesInMentions: false, spaceAfterMention: false)
        textView.insertText("\n@t")

        XCTAssertFalse(hidingMentionsList)
        XCTAssertEqual(mentionsString, "t")
        XCTAssertEqual(triggerString, "@")

        textView.insertText(" ")

        XCTAssertTrue(hidingMentionsList)
    }

    func test_shouldShowTheMentionsListWhenTypingAMentionOnANewLineAndRemainVisibleWhenASpaceIsAdded_whenSearchSpacesIsTrue() {
        mentionsListener = generateMentionsListener(searchSpacesInMentions: true, spaceAfterMention: false)
        textView.insertText("\n@t")

        XCTAssertFalse(hidingMentionsList)
        XCTAssertEqual(mentionsString, "t")
        XCTAssertEqual(triggerString, "@")

        textView.insertText(" ")

        XCTAssertFalse(hidingMentionsList)
    }

    func test_shouldSetCursorAfterAddedSpaceWhenAddAMention_whenSpacesAfterMentionIsTrue() {
        mentionsListener = generateMentionsListener(searchSpacesInMentions: true, spaceAfterMention: true)

        textView.text = ""
        textView.insertText("@a")
        addMention(named: "@awesome", on: mentionsListener)

        XCTAssertEqual("@awesome ".count, textView.selectedRange.location)
    }

    func generateMentionsListener(searchSpacesInMentions: Bool, spaceAfterMention: Bool) -> MentionListener {
        return MentionListener(mentionsTextView: textView,
                               spaceAfterMention: spaceAfterMention,
                               searchSpaces: searchSpacesInMentions,
                               hideMentions: hideMentions,
                               didHandleMentionOnReturn: { true },
                               showMentionsListWithString: showMentions)
    }
}
