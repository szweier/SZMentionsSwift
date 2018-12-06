import Nimble
import Quick
@testable import SZMentionsSwift

class UITextViewTests: QuickSpec {
    override func spec() {
        describe("Attributes") {
            var textView: UITextView!
            let mentionAttributes = [
                Attribute(name: .backgroundColor, value: UIColor.red),
                Attribute(name: .foregroundColor, value: UIColor.blue),
            ]
            let mentionAttributesClosure: (CreateMention?) -> [AttributeContainer] = { _ in mentionAttributes }
            let defaultAttributes = [Attribute(name: .foregroundColor, value: UIColor.black)]

            beforeEach {
                textView = UITextView()
            }

            it("Should apply attributes passed to apply function") {
                textView.attributedText = NSAttributedString(string:
                    "Test string, test string, test string, test string, test string, test string, test string, test string, test string.")
                textView.apply(mentionAttributes, range: NSRange(location: 0, length: textView.attributedText.length))

                expect(textView.attributedText.attributes(at: 0, effectiveRange: nil)[.backgroundColor] as? UIColor).to(equal(UIColor.red))
                expect(textView.attributedText.attributes(at: 0, effectiveRange: nil)[.foregroundColor] as? UIColor).to(equal(UIColor.blue))
            }

            it("Should reset typing attributes") {
                textView.attributedText = NSAttributedString(string:
                    "Test string, test string, test string, test string, test string, test string, test string, test string, test string.")
                textView.apply(mentionAttributes, range: NSRange(location: 0, length: textView.attributedText.length))

                expect(textView.typingAttributes[.backgroundColor] as? UIColor).to(equal(UIColor.red))
                expect(textView.typingAttributes[.foregroundColor] as? UIColor).to(equal(UIColor.blue))

                textView.resetTypingAttributes(to: defaultAttributes)

                expect(textView.typingAttributes[.backgroundColor] as? UIColor).to(beNil())
                expect(textView.typingAttributes[.foregroundColor] as? UIColor).to(equal(UIColor.black))
            }

            it("Should reset text view") {
                textView.text = " "
                textView.apply(mentionAttributes, range: NSRange(location: 0, length: textView.attributedText.length))
                textView.text = ""

                expect(textView.typingAttributes[.backgroundColor] as? UIColor).to(equal(UIColor.red))
                expect(textView.typingAttributes[.foregroundColor] as? UIColor).to(equal(UIColor.blue))

                textView.reset(to: defaultAttributes)

                expect(textView.typingAttributes[.backgroundColor] as? UIColor).to(beNil())
                expect(textView.typingAttributes[.foregroundColor] as? UIColor).to(equal(UIColor.black))
            }

            it("Should insert existing mentions") {
                textView.text = "Test Steven Zweier"
                textView.insert([(ExampleMention(name: "Steven Zweier"), NSRange(location: 5, length: 13))],
                                with: mentionAttributesClosure)

                expect(textView.attributedText.attributes(at: 5, effectiveRange: nil)[.backgroundColor] as? UIColor).to(equal(UIColor.red))
                expect(textView.attributedText.attributes(at: 5, effectiveRange: nil)[.foregroundColor] as? UIColor).to(equal(UIColor.blue))
            }

            it("Should throw assertion if range location is NSNotFound") {
                textView.text = "Test Steven Zweier"

                expect(textView.insert([(ExampleMention(name: "Steven Zweier"), NSRange(location: NSNotFound, length: 13))],
                                       with: mentionAttributesClosure)).to(throwAssertion())
            }

            it("Should throw assertion if range location is out of bounds") {
                textView.text = "Test Steven Zweier"

                expect(textView.insert([(ExampleMention(name: "Steven Zweier"), NSRange(location: 30, length: 13))],
                                       with: mentionAttributesClosure)).to(throwAssertion())
            }

            it("Should add mention") {
                textView.text = "Test @ste"
                textView.add(ExampleMention(name: "Steven Zweier"),
                             spaceAfterMention: false,
                             at: NSRange(location: 5, length: 4),
                             with: mentionAttributesClosure)

                expect(textView.attributedText.attributes(at: 2, effectiveRange: nil)[.backgroundColor] as? UIColor).to(beNil())
                expect(textView.attributedText.attributes(at: 2, effectiveRange: nil)[.foregroundColor] as? UIColor).to(beNil())
                expect(textView.attributedText.attributes(at: 5, effectiveRange: nil)[.backgroundColor] as? UIColor).to(equal(UIColor.red))
                expect(textView.attributedText.attributes(at: 5, effectiveRange: nil)[.foregroundColor] as? UIColor).to(equal(UIColor.blue))
                expect(textView.attributedText.attributes(at: 17, effectiveRange: nil)[.backgroundColor] as? UIColor).to(equal(UIColor.red))
                expect(textView.attributedText.attributes(at: 17, effectiveRange: nil)[.foregroundColor] as? UIColor).to(equal(UIColor.blue))
            }
        }
    }
}
