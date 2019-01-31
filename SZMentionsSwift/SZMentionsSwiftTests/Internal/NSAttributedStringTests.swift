import Nimble
import Quick
@testable import SZMentionsSwift

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
                (attributedText, _) = attributedText
                    |> apply(mentionAttributes, range: NSRange(location: 0, length: attributedText.length))

                expect(attributedText.backgroundColor(at: 0)) == .red
                expect(attributedText.foregroundColor(at: 0)) == .blue
            }

            it("Should insert existing mentions") {
                var attributedText = NSAttributedString(string: "Test Steven Zweier")
                (attributedText, _) = attributedText
                    |> apply(mentionAttributesClosure(ExampleMention(name: "Steven Zweier")), range: NSRange(location: 5, length: 13))

                expect(attributedText.backgroundColor(at: 5)) == .red
                expect(attributedText.foregroundColor(at: 5)) == .blue
            }

            it("Should throw assertion if range location is NSNotFound") {
                var attributedText = NSAttributedString(string: "Test Steven Zweier")
                expect(
                    (attributedText, _) = attributedText
                        |> apply(mentionAttributesClosure(ExampleMention(name: "Steven Zweier")), range: NSRange(location: NSNotFound, length: 13))
                ).to(throwAssertion())
            }

            it("Should throw assertion if range location is out of bounds") {
                var attributedText = NSAttributedString(string: "Test Steven Zweier")

                expect {
                    (attributedText, _) = attributedText
                        |> apply(mentionAttributesClosure(ExampleMention(name: "Steven Zweier")), range: NSRange(location: 30, length: 13))
                }.to(throwAssertion())
            }

            it("Should add mention") {
                var attributedText = NSAttributedString(string: "Test @ste")
                (attributedText, _) = attributedText |> SZMentionsSwift.add(ExampleMention(name: "Steven Zweier"),
                                                                            spaceAfterMention: false,
                                                                            at: NSRange(location: 5, length: 4),
                                                                            with: mentionAttributesClosure)

                expect(attributedText.backgroundColor(at: 2)).to(beNil())
                expect(attributedText.foregroundColor(at: 2)).to(beNil())
                expect(attributedText.backgroundColor(at: 5)) == .red
                expect(attributedText.foregroundColor(at: 5)) == .blue
                expect(attributedText.backgroundColor(at: 17)) == .red
                expect(attributedText.foregroundColor(at: 17)) == .blue
            }
        }

        describe("Text View Typing Attributes") {
            it("Should reset") {
                let textView = UITextView()
                textView.attributedText = NSAttributedString(string:
                    "Test string, test string, test string, test string, test string, test string, test string, test string, test string.")
                let (text, _) = textView.attributedText
                    |> apply(mentionAttributes, range: NSRange(location: 0, length: textView.attributedText.length))
                textView.attributedText = text

                expect(textView.typingAttributes[.backgroundColor] as? UIColor) == .red
                expect(textView.typingAttributes[.foregroundColor] as? UIColor) == .blue

                textView.typingAttributes = (defaultAttributes as [AttributeContainer]).dictionary

                expect(textView.typingAttributes[.backgroundColor] as? UIColor).to(beNil())
                expect(textView.typingAttributes[.foregroundColor] as? UIColor) == .black
            }
        }
    }
}
