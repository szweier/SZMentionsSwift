@testable import SZMentionsSwift
import XCTest

private final class TextViewDelegate: NSObject, UITextViewDelegate {
    var shouldBeginEditing = false
    var shouldEndEditing = false
    var shouldInteractWithTextAttachment = false
    var triggeredDelegateMethod = false
    var textViewDidChange = false

    func textViewDidChange(_: UITextView) {
        textViewDidChange = true
    }

    func textView(_: UITextView, shouldInteractWith _: NSTextAttachment, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
        return shouldInteractWithTextAttachment
    }

    func textView(_: UITextView, shouldInteractWith _: URL, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
        return shouldInteractWithTextAttachment
    }

    func textViewShouldBeginEditing(_: UITextView) -> Bool {
        return shouldBeginEditing
    }

    func textViewShouldEndEditing(_: UITextView) -> Bool {
        return shouldEndEditing
    }

    func textViewDidEndEditing(_: UITextView) {
        triggeredDelegateMethod = true
    }

    func textViewDidBeginEditing(_: UITextView) {
        triggeredDelegateMethod = true
    }
}

private final class Delegates: XCTestCase {
    private var shouldAddMentionOnReturnKeyCalled: Bool!
    private var hidingMentionsList: Bool!
    private var textViewDelegate: TextViewDelegate!
    private var mentionsListener: MentionListener!
    private var textView: UITextView!

    private func hideMentions() { hidingMentionsList = true }
    private func showMentions(_: String, _: String) {
        hidingMentionsList = false
    }

    private func didHandleMention() -> Bool {
        shouldAddMentionOnReturnKeyCalled = true
        return true
    }

    override func setUp() {
        super.setUp()
        let attribute = Attribute(name: .foregroundColor, value: UIColor.red)
        let attribute2 = Attribute(name: .foregroundColor, value: UIColor.black)
        textView = UITextView()
        hidingMentionsList = false
        textViewDelegate = TextViewDelegate()
        mentionsListener = MentionListener(mentionsTextView: textView,
                                           delegate: textViewDelegate,
                                           mentionTextAttributes: { _ in [attribute] },
                                           defaultTextAttributes: [attribute2],
                                           hideMentions: hideMentions,
                                           didHandleMentionOnReturn: didHandleMention,
                                           showMentionsListWithString: showMentions)
        shouldAddMentionOnReturnKeyCalled = false
        hidingMentionsList = false
    }

    override func tearDown() {
        hidingMentionsList = nil
        shouldAddMentionOnReturnKeyCalled = nil
        textViewDelegate = nil
        mentionsListener = nil
        textView = nil
        super.tearDown()
    }

    func test_shouldReturnFalseForTextViewShouldInteractWithInForATextAttachment_whenOverridden() {
        XCTAssertFalse(mentionsListener.textView(textView, shouldInteractWith: NSTextAttachment(), in: NSRange(location: 0, length: 0), interaction: .invokeDefaultAction))
    }

    func test_shouldReturnTrueForTextViewShouldInteractWithInForATextAttachment_whenNotOverridden() {
        mentionsListener.delegate = nil

        XCTAssertTrue(mentionsListener.textView(textView, shouldInteractWith: NSTextAttachment(), in: NSRange(location: 0, length: 0), interaction: .invokeDefaultAction))
    }

    func test_shouldReturnFalseForTextViewShouldInteractWithInForAURL_whenOverridden() {
        XCTAssertFalse(mentionsListener.textView(textView, shouldInteractWith: URL(string: "http://test.com")!, in: NSRange(location: 0, length: 0), interaction: .invokeDefaultAction))
    }

    func test_shouldReturnTrueForTextViewShouldInteractWithInForAURL_whenNotOverridden() {
        mentionsListener.delegate = nil

        XCTAssertTrue(mentionsListener.textView(textView, shouldInteractWith: URL(string: "http://test.com")!, in: NSRange(location: 0, length: 0), interaction: .invokeDefaultAction))
    }

    func test_shouldReturnFalseForTextViewShouldBeginEditing_whenOverridden() {
        XCTAssertFalse(mentionsListener.textViewShouldBeginEditing(textView))
    }

    func test_shouldReturnTrueForTextViewShouldBeginEditing_whenNotOverridden() {
        mentionsListener.delegate = nil

        XCTAssertTrue(mentionsListener.textViewShouldBeginEditing(textView))
    }

    func test_shouldReturnFalseForTextViewShouldEndEditing_whenNotOverridden() {
        XCTAssertFalse(mentionsListener.textViewShouldEndEditing(textView))
    }

    func test_shouldReturnTrueForTextViewShouldEndEditing_whenNotOverridden() {
        mentionsListener.delegate = nil

        XCTAssertTrue(mentionsListener.textViewShouldEndEditing(textView))
    }

    func test_shouldReturnTheDelegateResponseForTextViewDidBeginEditing() {
        mentionsListener.textViewDidBeginEditing(textView)

        XCTAssertTrue(textViewDelegate.triggeredDelegateMethod)
    }

    func test_shouldReturnTheDelegateResponseForTextViewDidEndEditing() {
        mentionsListener.textViewDidEndEditing(textView)

        XCTAssertTrue(textViewDelegate.triggeredDelegateMethod)
    }

    func test_shouldCallDelegateMethodToDetermineIfAddingMentionOnReturn_shouldBeEnabled() {
        XCTAssertFalse(shouldAddMentionOnReturnKeyCalled)

        type(text: "@t", on: mentionsListener)

        XCTAssertFalse(hidingMentionsList)

        update(text: "\n", type: .insert, on: mentionsListener)

        XCTAssertTrue(shouldAddMentionOnReturnKeyCalled)
    }

    func test_shouldAllowForMentionsToBeAddedInAdvance() {
        textView.text = "Testing Steven Zweier and Tiffany get mentioned correctly"
        let mention = (ExampleMention(name: "Steve") as CreateMention,
                       NSRange(location: 8, length: 13))
        let mention2 = (ExampleMention(name: "Tiff") as CreateMention,
                        NSRange(location: 26, length: 7))
        let insertMentions = [mention, mention2]
        mentionsListener.insertExistingMentions(insertMentions)

        XCTAssertEqual(mentionsListener.mentions.count, 2)
        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor, UIColor.black)
        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 9, effectiveRange: nil) as? UIColor, UIColor.red)
        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 21, effectiveRange: nil) as? UIColor, UIColor.black)
        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 27, effectiveRange: nil) as? UIColor, UIColor.red)
        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 33, effectiveRange: nil) as? UIColor, UIColor.black)
    }

    func test_shouldAllowForMentionsToBeAddedInAdvance_withEmoji() {
        textView.text = "test 🦅 Asim test"
        let mention = (ExampleMention(name: "Asim") as CreateMention,
                       NSRange(location: 8, length: 4))
        let insertMentions: [(CreateMention, NSRange)] = [mention]
        mentionsListener.insertExistingMentions(insertMentions)

        XCTAssertEqual(mentionsListener.mentions.count, 1)
        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor, UIColor.black)
        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 9, effectiveRange: nil) as? UIColor, UIColor.red)
        XCTAssertEqual(textView.attributedText.attribute(.foregroundColor, at: 12, effectiveRange: nil) as? UIColor, UIColor.black)
    }

    func test_shouldCallTextViewDidChange_whenInsertingAnyTextWithAUTF16CountGreaterThan1() {
        XCTAssertFalse(textViewDelegate.textViewDidChange)
        update(text: "🤪", type: .insert, on: mentionsListener)
        XCTAssertTrue(textViewDelegate.textViewDidChange)
    }
}
