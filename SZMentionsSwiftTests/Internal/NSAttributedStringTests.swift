@testable import SZMentionsSwift
import XCTest

private extension NSAttributedString {
    func attribute(_ attribute: NSAttributedString.Key, at location: Int) -> Any? {
        return attributes(at: location, effectiveRange: nil)[attribute]
    }

    func backgroundColor(at location: Int) -> UIColor? {
        return attribute(.backgroundColor, at: location) as? UIColor
    }

    func foregroundColor(at location: Int) -> UIColor? {
        return attribute(.foregroundColor, at: location) as? UIColor
    }
}

private final class NSAttributedStringTests: XCTestCase {
    var mentionAttributes: [Attribute]!
    var defaultAttributes: [Attribute]!
    var mentionAttributesClosure: ((CreateMention?) -> [AttributeContainer])!

    override func setUp() {
        super.setUp()
        mentionAttributes = [
            Attribute(name: .backgroundColor, value: UIColor.red),
            Attribute(name: .foregroundColor, value: UIColor.blue),
        ]
        defaultAttributes = [Attribute(name: .foregroundColor, value: UIColor.black)]
        mentionAttributesClosure = { _ in self.mentionAttributes }
    }

    override func tearDown() {
        super.tearDown()
        mentionAttributes = nil
        defaultAttributes = nil
        mentionAttributesClosure = nil
    }

    func test_shouldApplyAttributesPassedToApplyFunction() {
        var attributedText = NSAttributedString(string:
            "Test string, test string, test string, test string, test string, test string, test string, test string, test string.")
        (attributedText, _) = attributedText
            |> apply(mentionAttributes, range: NSRange(location: 0, length: attributedText.length))

        XCTAssertEqual(attributedText.backgroundColor(at: 0), .red)
        XCTAssertEqual(attributedText.foregroundColor(at: 0), .blue)
    }

    func test_shouldInsertExistingMentions() {
        var attributedText = NSAttributedString(string: "Test Steven Zweier")
        (attributedText, _) = attributedText
            |> apply(mentionAttributesClosure(ExampleMention(name: "Steven Zweier")), range: NSRange(location: 5, length: 13))

        XCTAssertEqual(attributedText.backgroundColor(at: 5), .red)
        XCTAssertEqual(attributedText.foregroundColor(at: 5), .blue)
    }

    func test_shouldAddMention() {
        var attributedText = NSAttributedString(string: "Test @ste")
        (attributedText, _) = attributedText |> SZMentionsSwift.add(ExampleMention(name: "Steven Zweier"),
                                                                    spaceAfterMention: false,
                                                                    at: NSRange(location: 5, length: 4),
                                                                    with: mentionAttributesClosure)

        XCTAssertNil(attributedText.backgroundColor(at: 2))
        XCTAssertNil(attributedText.foregroundColor(at: 2))
        XCTAssertEqual(attributedText.backgroundColor(at: 5), .red)
        XCTAssertEqual(attributedText.foregroundColor(at: 5), .blue)
        XCTAssertEqual(attributedText.backgroundColor(at: 17), .red)
        XCTAssertEqual(attributedText.foregroundColor(at: 17), .blue)
    }

    func test_textViewTypingAttributes_shouldReset() {
        let textView = UITextView()
        textView.attributedText = NSAttributedString(string:
            "Test string, test string, test string, test string, test string, test string, test string, test string, test string.")
        let (text, _) = textView.attributedText
            |> apply(mentionAttributes, range: NSRange(location: 0, length: textView.attributedText.length))
        textView.attributedText = text

        XCTAssertEqual(textView.typingAttributes[.backgroundColor] as? UIColor, .red)
        XCTAssertEqual(textView.typingAttributes[.foregroundColor] as? UIColor, .blue)

        textView.typingAttributes = (defaultAttributes as [AttributeContainer]).dictionary

        XCTAssertNil(textView.typingAttributes[.backgroundColor] as? UIColor)
        XCTAssertEqual(textView.typingAttributes[.foregroundColor] as? UIColor, .black)
    }
}
