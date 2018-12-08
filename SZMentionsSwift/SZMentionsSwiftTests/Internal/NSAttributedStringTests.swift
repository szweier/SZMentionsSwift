import Nimble
import Quick
@testable import SZMentionsSwift

class NSAttributedStringTests: QuickSpec {
    override func spec() {
        let mentionAttributes = [
            Attribute(name: .backgroundColor, value: UIColor.red),
            Attribute(name: .foregroundColor, value: UIColor.blue),
        ]
        let defaultAttributes = [Attribute(name: .foregroundColor, value: UIColor.black)]

        describe("Attributes") {
            let mentionAttributesClosure: (CreateMention?) -> [AttributeContainer] = { _ in mentionAttributes }

            it("Should apply attributes passed to apply function") {
                var attributedText = NSAttributedString(string:
                    "Test string, test string, test string, test string, test string, test string, test string, test string, test string.")
                attributedText = attributedText
                    |> apply(mentionAttributes, range: NSRange(location: 0, length: attributedText.length))

                expect(attributedText.attributes(at: 0, effectiveRange: nil)[.backgroundColor] as? UIColor).to(equal(UIColor.red))
                expect(attributedText.attributes(at: 0, effectiveRange: nil)[.foregroundColor] as? UIColor).to(equal(UIColor.blue))
            }

            it("Should insert existing mentions") {
                var attributedText = NSAttributedString(string: "Test Steven Zweier")
                attributedText = attributedText
                    |> insert([(ExampleMention(name: "Steven Zweier"), NSRange(location: 5, length: 13))],
                              with: mentionAttributesClosure)

                expect(attributedText.attributes(at: 5, effectiveRange: nil)[.backgroundColor] as? UIColor).to(equal(UIColor.red))
                expect(attributedText.attributes(at: 5, effectiveRange: nil)[.foregroundColor] as? UIColor).to(equal(UIColor.blue))
            }

            pending("Should throw assertion if range location is NSNotFound") {
                var attributedText = NSAttributedString(string: "Test Steven Zweier")
                expect(
                    attributedText = attributedText
                        |> insert([(ExampleMention(name: "Steven Zweier"), NSRange(location: NSNotFound, length: 13))],
                                  with: mentionAttributesClosure)
                ).to(throwAssertion())
            }

            pending("Should throw assertion if range location is out of bounds") {
                var attributedText = NSAttributedString(string: "Test Steven Zweier")

                expect {
                    attributedText = attributedText
                        |> insert([(ExampleMention(name: "Steven Zweier"), NSRange(location: 30, length: 13))],
                                  with: mentionAttributesClosure)
                }.to(throwAssertion())
            }

            it("Should add mention") {
                var attributedText = NSAttributedString(string: "Test @ste")
                attributedText = attributedText |> SZMentionsSwift.add(ExampleMention(name: "Steven Zweier"),
                                                                       spaceAfterMention: false,
                                                                       at: NSRange(location: 5, length: 4),
                                                                       with: mentionAttributesClosure)

                expect(attributedText.attributes(at: 2, effectiveRange: nil)[.backgroundColor] as? UIColor).to(beNil())
                expect(attributedText.attributes(at: 2, effectiveRange: nil)[.foregroundColor] as? UIColor).to(beNil())
                expect(attributedText.attributes(at: 5, effectiveRange: nil)[.backgroundColor] as? UIColor).to(equal(UIColor.red))
                expect(attributedText.attributes(at: 5, effectiveRange: nil)[.foregroundColor] as? UIColor).to(equal(UIColor.blue))
                expect(attributedText.attributes(at: 17, effectiveRange: nil)[.backgroundColor] as? UIColor).to(equal(UIColor.red))
                expect(attributedText.attributes(at: 17, effectiveRange: nil)[.foregroundColor] as? UIColor).to(equal(UIColor.blue))
            }
        }

        describe("Text View Typing Attributes") {
            it("Should reset") {
                let textView = UITextView()
                textView.attributedText = NSAttributedString(string:
                    "Test string, test string, test string, test string, test string, test string, test string, test string, test string.")
                textView.attributedText = textView.attributedText
                    |> apply(mentionAttributes, range: NSRange(location: 0, length: textView.attributedText.length))

                expect(textView.typingAttributes[.backgroundColor] as? UIColor).to(equal(UIColor.red))
                expect(textView.typingAttributes[.foregroundColor] as? UIColor).to(equal(UIColor.blue))

                textView.typingAttributes = (defaultAttributes as [AttributeContainer]).dictionary

                expect(textView.typingAttributes[.backgroundColor] as? UIColor).to(beNil())
                expect(textView.typingAttributes[.foregroundColor] as? UIColor).to(equal(UIColor.black))
            }
        }
    }
}
