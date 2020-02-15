@testable import SZMentionsSwift
import XCTest

private final class AddingMentions: XCTestCase {
    var textView: UITextView!
    var mentionsListener: MentionListener!

    override func setUp() {
        super.setUp()
        textView = UITextView()
        mentionsListener = generateMentionsListener()
    }

    override func tearDown() {
        textView = nil
        mentionsListener = nil
        super.tearDown()
    }

    func test_shouldAddMentionWithTheCorrectRange() {
        update(text: "Testing @t", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions.count, 1)
        XCTAssertEqual(mentionsListener.mentions[0].range.location, 8)
        XCTAssertEqual(mentionsListener.mentions[0].range.length, 6)
    }

    func test_shouldAddTwoMentionsWithCorrectRange() {
        update(text: "@t", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        update(text: " Testing @t", type: .insert, on: mentionsListener)
        addMention(named: "Steven Zweier", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions[0].range.location, 0)
        XCTAssertEqual(mentionsListener.mentions[0].range.length, 6)
        XCTAssertEqual(mentionsListener.mentions[1].range.location, 15)
        XCTAssertEqual(mentionsListener.mentions[1].range.length, 13)
    }

    func test_shouldAddMentionAttributesToMention() {
        update(text: "Test @t", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)
        update(text: ". ", type: .insert, on: mentionsListener)

        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor, UIColor.black)
        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 10, effectiveRange: nil) as? UIColor, UIColor.red)
        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 12, effectiveRange: nil) as? UIColor, UIColor.black)
    }

    func test_shouldAdjustTheLocationOfAnExistingMentionCorrectly() {
        update(text: "Testing @t", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions[0].range.location, 8)

        update(text: "", type: .replace, at: NSRange(location: 0, length: 3), on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions[0].range.location, 5)

        update(text: "", type: .replace, at: NSRange(location: 0, length: 5), on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions[0].range.location, 0)
    }

    func test_shouldAdjustTheLocationOfAnExistingMentionCorrectly2() {
        update(text: "@t", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions[0].range.location, 0)
        XCTAssertEqual(mentionsListener.mentions[0].range.length, 6)

        type(text: "@t", at: NSRange(location: 0, length: 0), on: mentionsListener)
        addMention(named: "Steven Zweier", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions[1].range.location, 0)
        XCTAssertEqual(mentionsListener.mentions[1].range.length, 13)
        XCTAssertEqual(mentionsListener.mentions[0].range.location, 13)
    }

    func test_shouldRemoveTheMentionButRetainTheText_whenEditingTheMiddleOfAMention() {
        update(text: "Testing @t", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions.count, 1)
        XCTAssertEqual(mentionsListener.mentionsTextView.text, "Testing Steven")

        update(text: "", type: .delete, at: NSRange(location: 11, length: 1), on: mentionsListener)

        XCTAssertTrue(mentionsListener.mentions.isEmpty)
        XCTAssertEqual(mentionsListener.mentionsTextView.text, "Testing Steen")
    }

    func test_shouldRemoveMultipleMentionsAndTheTextWhenEditingTheMiddleOfAMention() {
        mentionsListener = generateMentionsListener(removeEntireMention: true)
        update(text: "Testing @t", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)
        update(text: " @j", type: .insert, on: mentionsListener)
        addMention(named: "Joe", on: mentionsListener)
        update(text: " and @g", type: .insert, on: mentionsListener)
        addMention(named: "George", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions.count, 3)
        XCTAssertEqual(mentionsListener.mentionsTextView.text, "Testing Steven Joe and George")

        update(text: "", type: .delete, at: NSRange(location: 11, length: 1), on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions.count, 2)
        XCTAssertEqual(mentionsListener.mentionsTextView.text, "Testing  Joe and George")

        update(text: "", type: .delete, at: NSRange(location: 10, length: 1), on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions.count, 1)
        XCTAssertEqual(mentionsListener.mentionsTextView.text, "Testing   and George")

        update(text: "", type: .delete, at: NSRange(location: 15, length: 1), on: mentionsListener)

        XCTAssertTrue(mentionsListener.mentions.isEmpty)
        XCTAssertEqual(mentionsListener.mentionsTextView.text, "Testing   and ")
    }

    func test_shouldRemoveTheMentionAndTheTextWhenEditingTheMiddleOfAMention() {
        mentionsListener = generateMentionsListener(removeEntireMention: true)
        update(text: "Testing @t", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions.count, 1)
        XCTAssertEqual(mentionsListener.mentionsTextView.text, "Testing Steven")

        update(text: "", type: .delete, at: NSRange(location: 11, length: 1), on: mentionsListener)

        XCTAssertTrue(mentionsListener.mentions.isEmpty)
        XCTAssertEqual(mentionsListener.mentionsTextView.text, "Testing ")
    }

    func test_shouldAllowYouToResetTheMentionsListenerAndTextViewToTheOriginalState() {
        update(text: "@St", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions.count, 1)

        mentionsListener.reset()

        XCTAssertEqual(mentionsListener.mentions.count, 0)
    }

    func test_shouldTestMentionLocationIsAdjustedProperlyWhenAMentionIsInsertedBehindAMention_whenSpaceAfterMentionisTrue() {
        mentionsListener = generateMentionsListener(spaceAfterMention: true)

        update(text: "@t", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions[0].range.location, 0)
        XCTAssertEqual(mentionsListener.mentions[0].range.length, 6)
        XCTAssertEqual(textView.selectedRange.location, 7)

        update(text: "@t", type: .insert, at: NSRange(location: 0, length: 0), on: mentionsListener)
        addMention(named: "Steven Zweier", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions[1].range.location, 0)
        XCTAssertEqual(mentionsListener.mentions[1].range.length, 13)
        XCTAssertEqual(mentionsListener.mentions[0].range.location, 14)
        XCTAssertEqual(textView.selectedRange.location, 14)
    }

    func test_shouldTestEditingAfterMentionDoesNotDeleteTheMention() {
        update(text: "Testing @t", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        update(text: " ", type: .insert, on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions.count, 1)

        update(text: "", type: .delete, at: NSRange(location: 14, length: 1), on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions.count, 1)
    }

    func test_shouldTestThatPastingTextBeforeALeadingMention_resetsItsAttributes() {
        update(text: "@s", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        update(text: "test", type: .insert, at: NSRange(location: 0, length: 0), on: mentionsListener)

        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor, UIColor.black)
    }

    func test_shouldTestThatPastingTextWithinAMentionResetsItsAttributesButRetainsTheText() {
        update(text: "@s", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        update(text: "test", type: .insert, at: NSRange(location: 1, length: 0), on: mentionsListener)

        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor, UIColor.black)
        XCTAssertEqual(textView.text, "Stestteven")
    }

    func test_shouldTestThatPastingTextWithinAMentionResetsItsAttributesAndRemovesTheText_whenRemoveEntireMentionIsTrue() {
        mentionsListener = generateMentionsListener(removeEntireMention: true)
        update(text: "@s", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        update(text: "test", type: .insert, at: NSRange(location: 1, length: 0), on: mentionsListener)

        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor, UIColor.black)
        XCTAssertEqual(textView.text, "test")
    }

    func test_shouldTestThatTheCorrectMentionRangeIsReplacedIfMultipleExistAndThatTheSelectedRange_isCorrect() {
        update(text: " @st", type: .insert, on: mentionsListener)
        update(text: "@st", type: .insert, at: NSRange(location: 0, length: 0), on: mentionsListener)

        addMention(named: "Steven", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions[0].range.location, 0)
        XCTAssertEqual(textView.selectedRange.location, 6)
    }

    func test_shouldTestThatTheCorrectMentionRangeIsReplacedIfMultipleExistAndThatTheSelectedRangeIsCorrect_whenSpaceAfterMentionIsTrue() {
        mentionsListener = generateMentionsListener(spaceAfterMention: true)
        update(text: " @st", type: .insert, on: mentionsListener)
        update(text: "@st", type: .insert, at: NSRange(location: 0, length: 0), on: mentionsListener)

        addMention(named: "Steven", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions[0].range.location, 0)
        XCTAssertEqual(textView.selectedRange.location, 7)
    }

    func test_shouldTestThatAddingTextImmediatelyAfterTheMentionChangesBackToDefaultAttributes() {
        update(text: "@s", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        update(text: "test", type: .insert, on: mentionsListener)

        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: textView.selectedRange.location - 1, effectiveRange: nil) as? UIColor, UIColor.black)
    }

    func test_shouldTestThatTheMentionPositionIsCorrectToStartTextOnANewLine() {
        update(text: "\n@t", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions[0].range.location, 1)
    }

    func test_shouldTestThatMentionPositionIsCorrectInTheMiddleOfNewLineText() {
        update(text: "Testing \nnew line @t", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions[0].range.location, 18)
    }

    func test_shouldAccuratelyDetectWhetherOrNotAMentionIsBeingEdited() {
        update(text: "@s", type: .insert, on: mentionsListener)
        addMention(named: "Steven", on: mentionsListener)

        XCTAssertNil(mentionsListener.mentions |> mentionBeingEdited(at: NSRange(location: 0, length: 0)))

        update(text: "t", type: .insert, at: NSRange(location: 0, length: 0), on: mentionsListener)

        XCTAssertNil(mentionsListener.mentions |> mentionBeingEdited(at: NSRange(location: 1, length: 0)))
    }

    func test_shouldNotCrashWhenDeletingTwoMentionsAtATime() {
        update(text: "@St", type: .insert, on: mentionsListener)
        addMention(named: "Steven Zweier", on: mentionsListener)
        update(text: " @Jo", type: .insert, on: mentionsListener)
        addMention(named: "John Smith", on: mentionsListener)
        update(text: "", type: .delete, at: NSRange(location: 0, length: textView.text.utf16.count), on: mentionsListener)

        XCTAssertTrue(textView.text.isEmpty)
    }

    func test_shouldRemoveExistingMentionWhenPastingTextWithinTheMention() {
        update(text: "@St", type: .insert, on: mentionsListener)
        addMention(named: "Steven Zweier", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions.count, 1)
        XCTAssertEqual(textView.attributedText.string, "Steven Zweier")
        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor, UIColor.red)
        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 12, effectiveRange: nil) as? UIColor, UIColor.red)

        update(text: "Test", type: .insert, at: NSRange(location: 7, length: 0), on: mentionsListener)

        XCTAssertEqual(textView.attributedText.string, "Steven TestZweier")
        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor, UIColor.black)
        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 16, effectiveRange: nil) as? UIColor, UIColor.black)
        XCTAssertEqual(mentionsListener.mentions.count, 0)
    }

    func test_shouldNotAddMentionIfRangeIsNil() {
        XCTAssertFalse(addMention(named: "John Smith", on: mentionsListener))
    }

    func test_shouldProperlyDeleteTextDuringMentionCreation() {
        update(text: "@ste", type: .insert, on: mentionsListener)
        ["", ""].forEach { update(text: $0, type: .delete, on: mentionsListener) }
        mentionsListener.cooldownTimerFired(Timer())
        update(text: "", type: .delete, on: mentionsListener)
        mentionsListener.cooldownTimerFired(Timer())

        XCTAssertEqual(textView.text.utf16.count, 1)
    }

    func test_shouldProperlyAddASpaceDuringMentionCreation() {
        update(text: "@ste ", type: .insert, on: mentionsListener)
        mentionsListener.cooldownTimerFired(Timer())

        XCTAssertEqual(textView.text.utf16.count, 5)
    }

    func test_shouldTestThatTextCanBeAddedAndRemovedWithoutCrashes_whenSearchSpacesIsTrue() {
        mentionsListener = generateMentionsListener(searchSpaces: true)
        update(text: "@s", type: .insert, on: mentionsListener)
        update(text: "", type: .delete, on: mentionsListener)
        update(text: "", type: .delete, on: mentionsListener)
        XCTAssertTrue(textView.text.isEmpty)
    }

    func test_shouldTestMentionWithEmojiCanBeSearchedProperly() {
        mentionsListener = generateMentionsListener(spaceAfterMention: true, searchSpaces: true)

        update(text: "@t", type: .insert, on: mentionsListener)
        addMention(named: "Steven😌", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions[0].range.location, 0)
        XCTAssertEqual(mentionsListener.mentions[0].range.length, 8)
        XCTAssertEqual(textView.selectedRange.location, 9)
    }

    func test_shouldTestMentionAfterEmojiDoesNotCrash() {
        mentionsListener = generateMentionsListener(spaceAfterMention: true, searchSpaces: true)

        update(text: "😌 @Ste", type: .insert, on: mentionsListener)
        addMention(named: "Steven😌", on: mentionsListener)

        XCTAssertEqual(mentionsListener.mentions[0].range.location, 3)
        XCTAssertEqual(mentionsListener.mentions[0].range.length, 8)
        XCTAssertEqual(textView.selectedRange.location, 12)
    }

    func generateMentionsListener(spaceAfterMention: Bool = false,
                                  searchSpaces: Bool = false,
                                  removeEntireMention: Bool = false) -> MentionListener {
        let attribute = Attribute(name: .foregroundColor, value: UIColor.red)
        let attribute2 = Attribute(name: .foregroundColor, value: UIColor.black)

        return MentionListener(mentionsTextView: textView,
                               mentionTextAttributes: { _ in [attribute] },
                               defaultTextAttributes: [attribute2],
                               spaceAfterMention: spaceAfterMention,
                               searchSpaces: searchSpaces,
                               removeEntireMention: removeEntireMention,
                               hideMentions: {},
                               didHandleMentionOnReturn: { false },
                               showMentionsListWithString: { _, _ in })
    }
}
