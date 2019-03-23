import Nimble
import Quick
@testable import SZMentionsSwift

class AddingMentions: QuickSpec {
    override func spec() {
        describe("Adding Mentions") {
            var textView: UITextView!
            var mentionsListener: MentionListener!

            beforeEach {
                textView = UITextView()
                mentionsListener = generateMentionsListener(spaceAfterMention: false, searchSpaces: false)
            }

            it("Should add mention with the correct range") {
                update(text: "Testing @t", type: .insert, on: mentionsListener)
                addMention(named: "Steven", on: mentionsListener)

                expect(mentionsListener.mentions.count).to(equal(1))
                expect(mentionsListener.mentions[0].range.location).to(equal(8))
                expect(mentionsListener.mentions[0].range.length).to(equal(6))
            }

            it("Should add two mentions with correct range") {
                update(text: "@t", type: .insert, on: mentionsListener)
                addMention(named: "Steven", on: mentionsListener)

                update(text: " Testing @t", type: .insert, on: mentionsListener)
                addMention(named: "Steven Zweier", on: mentionsListener)

                expect(mentionsListener.mentions[0].range.location).to(equal(0))
                expect(mentionsListener.mentions[0].range.length).to(equal(6))
                expect(mentionsListener.mentions[1].range.location).to(equal(15))
                expect(mentionsListener.mentions[1].range.length).to(equal(13))
            }

            it("Should add mention attributes to mention") {
                update(text: "Test @t", type: .insert, on: mentionsListener)
                addMention(named: "Steven", on: mentionsListener)
                update(text: ". ", type: .insert, on: mentionsListener)

                expect(textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor).to(equal(UIColor.black))
                expect(textView.attributedText.attribute(.foregroundColor, at: 10, effectiveRange: nil) as? UIColor).to(equal(UIColor.red))
                expect(textView.attributedText.attribute(.foregroundColor, at: 12, effectiveRange: nil) as? UIColor).to(equal(UIColor.black))
            }

            it("Should adjust the location of an existing mention correctly") {
                update(text: "Testing @t", type: .insert, on: mentionsListener)
                addMention(named: "Steven", on: mentionsListener)

                expect(mentionsListener.mentions[0].range.location).to(equal(8))

                update(text: "", type: .replace, at: NSRange(location: 0, length: 3), on: mentionsListener)

                expect(mentionsListener.mentions[0].range.location).to(equal(5))

                update(text: "", type: .replace, at: NSRange(location: 0, length: 5), on: mentionsListener)

                expect(mentionsListener.mentions[0].range.location).to(equal(0))
            }

            it("Should adjust the location of an existing mention correctly") {
                update(text: "@t", type: .insert, on: mentionsListener)
                addMention(named: "Steven", on: mentionsListener)

                expect(mentionsListener.mentions[0].range.location).to(equal(0))
                expect(mentionsListener.mentions[0].range.length).to(equal(6))

                type(text: "@t", at: NSRange(location: 0, length: 0), on: mentionsListener)
                addMention(named: "Steven Zweier", on: mentionsListener)

                expect(mentionsListener.mentions[1].range.location).to(equal(0))
                expect(mentionsListener.mentions[1].range.length).to(equal(13))
                expect(mentionsListener.mentions[0].range.location).to(equal(13))
            }

            it("Should remove the mention when editing the middle of a mention") {
                update(text: "Testing @t", type: .insert, on: mentionsListener)
                addMention(named: "Steven", on: mentionsListener)

                expect(mentionsListener.mentions.count).to(equal(1))

                update(text: "", type: .delete, at: NSRange(location: 11, length: 1), on: mentionsListener)

                expect(mentionsListener.mentions.isEmpty).to(beTruthy())
            }

            it("Should allow you to reset the mentionsListener and textView to the original state") {
                update(text: "@St", type: .insert, on: mentionsListener)
                addMention(named: "Steven", on: mentionsListener)

                expect(mentionsListener.mentions.count).to(equal(1))

                mentionsListener.reset()

                expect(mentionsListener.mentions.count).to(equal(0))
            }

            it("Should test mention location is adjusted properly when a mention is inserted behind a mention when space after mention is true") {
                mentionsListener = generateMentionsListener(spaceAfterMention: true, searchSpaces: false)

                update(text: "@t", type: .insert, on: mentionsListener)
                addMention(named: "Steven", on: mentionsListener)

                expect(mentionsListener.mentions[0].range.location).to(equal(0))
                expect(mentionsListener.mentions[0].range.length).to(equal(6))
                expect(textView.selectedRange.location).to(equal(7))

                update(text: "@t", type: .insert, at: NSRange(location: 0, length: 0), on: mentionsListener)
                addMention(named: "Steven Zweier", on: mentionsListener)

                expect(mentionsListener.mentions[1].range.location).to(equal(0))
                expect(mentionsListener.mentions[1].range.length).to(equal(13))
                expect(mentionsListener.mentions[0].range.location).to(equal(14))
                expect(textView.selectedRange.location).to(equal(14))
            }

            it("Should test editing after mention does not delete the mention") {
                update(text: "Testing @t", type: .insert, on: mentionsListener)
                addMention(named: "Steven", on: mentionsListener)

                update(text: " ", type: .insert, on: mentionsListener)

                expect(mentionsListener.mentions.count).to(equal(1))

                update(text: "", type: .delete, at: NSRange(location: 14, length: 1), on: mentionsListener)

                expect(mentionsListener.mentions.count).to(equal(1))
            }

            it("Should test that pasting text before a leading mention resets its attributes") {
                update(text: "@s", type: .insert, on: mentionsListener)
                addMention(named: "Steven", on: mentionsListener)

                update(text: "test", type: .insert, at: NSRange(location: 0, length: 0), on: mentionsListener)

                expect(textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor).to(equal(UIColor.black))
            }

            it("Should test that the correct mention range is replaced if multiple exist and that the selected range is correct") {
                update(text: " @st", type: .insert, on: mentionsListener)
                update(text: "@st", type: .insert, at: NSRange(location: 0, length: 0), on: mentionsListener)

                addMention(named: "Steven", on: mentionsListener)

                expect(mentionsListener.mentions[0].range.location).to(equal(0))
                expect(textView.selectedRange.location).to(equal(6))
            }

            it("Should test that the correct mention range is replaced if multiple exist and that the selected range is correct when space after mention is true") {
                mentionsListener = generateMentionsListener(spaceAfterMention: true, searchSpaces: false)
                update(text: " @st", type: .insert, on: mentionsListener)
                update(text: "@st", type: .insert, at: NSRange(location: 0, length: 0), on: mentionsListener)

                addMention(named: "Steven", on: mentionsListener)

                expect(mentionsListener.mentions[0].range.location).to(equal(0))
                expect(textView.selectedRange.location).to(equal(7))
            }

            it("Should test that adding text immediately after the mention changes back to default attributes") {
                update(text: "@s", type: .insert, on: mentionsListener)
                addMention(named: "Steven", on: mentionsListener)

                update(text: "test", type: .insert, on: mentionsListener)

                expect(textView.attributedText.attribute(.foregroundColor, at: textView.selectedRange.location - 1, effectiveRange: nil) as? UIColor).to(equal(UIColor.black))
            }

            it("Should test that the mention position is correct to start text on a new line") {
                update(text: "\n@t", type: .insert, on: mentionsListener)
                addMention(named: "Steven", on: mentionsListener)

                expect(mentionsListener.mentions[0].range.location).to(equal(1))
            }

            it("Should test that mention position is correct in the middle of new line text") {
                update(text: "Testing \nnew line @t", type: .insert, on: mentionsListener)
                addMention(named: "Steven", on: mentionsListener)

                expect(mentionsListener.mentions[0].range.location).to(equal(18))
            }

            it("Should accurately detect whether or not a mention is being edited") {
                update(text: "@s", type: .insert, on: mentionsListener)
                addMention(named: "Steven", on: mentionsListener)

                expect(mentionsListener.mentions |> mentionBeingEdited(at: NSRange(location: 0, length: 0))).to(beNil())

                update(text: "t", type: .insert, at: NSRange(location: 0, length: 0), on: mentionsListener)

                expect(mentionsListener.mentions |> mentionBeingEdited(at: NSRange(location: 1, length: 0))).to(beNil())
            }

            it("Should not crash when deleting two mentions at a time") {
                update(text: "@St", type: .insert, on: mentionsListener)
                addMention(named: "Steven Zweier", on: mentionsListener)
                update(text: " @Jo", type: .insert, on: mentionsListener)
                addMention(named: "John Smith", on: mentionsListener)
                update(text: "", type: .delete, at: NSRange(location: 0, length: textView.text.utf16.count), on: mentionsListener)

                expect(textView.text.isEmpty).to(beTruthy())
            }

            it("Should remove existing mention when pasting text within the mention") {
                update(text: "@St", type: .insert, on: mentionsListener)
                addMention(named: "Steven Zweier", on: mentionsListener)

                expect(mentionsListener.mentions.count).to(equal(1))
                expect(textView.attributedText.string).to(equal("Steven Zweier"))
                expect(textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor).to(equal(UIColor.red))
                expect(textView.attributedText.attribute(.foregroundColor, at: 12, effectiveRange: nil) as? UIColor).to(equal(UIColor.red))

                update(text: "Test", type: .insert, at: NSRange(location: 7, length: 0), on: mentionsListener)

                expect(textView.attributedText.string).to(equal("Steven TestZweier"))
                expect(textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor).to(equal(UIColor.black))
                expect(textView.attributedText.attribute(.foregroundColor, at: 16, effectiveRange: nil) as? UIColor).to(equal(UIColor.black))
                expect(mentionsListener.mentions.count).to(equal(0))
            }

            it("Should not add mention if range is nil") {
                expect(addMention(named: "John Smith", on: mentionsListener)).to(beFalsy())
            }

            it("Should properly delete text during mention creation") {
                update(text: "@ste", type: .insert, on: mentionsListener)
                ["", ""].forEach { update(text: $0, type: .delete, on: mentionsListener) }
                mentionsListener.cooldownTimerFired(Timer())
                update(text: "", type: .delete, on: mentionsListener)
                mentionsListener.cooldownTimerFired(Timer())

                expect(textView.text.utf16.count).to(equal(1))
            }

            it("Should properly add a space during mention creation") {
                update(text: "@ste ", type: .insert, on: mentionsListener)
                mentionsListener.cooldownTimerFired(Timer())

                expect(textView.text.utf16.count).to(equal(5))
            }

            it("Should test that text can be added and removed without crashes when search spaces is true.") {
                mentionsListener = generateMentionsListener(spaceAfterMention: false, searchSpaces: true)
                update(text: "@s", type: .insert, on: mentionsListener)
                update(text: "", type: .delete, on: mentionsListener)
                update(text: "", type: .delete, on: mentionsListener)
                expect(textView.text.isEmpty).to(beTruthy())
            }

            func generateMentionsListener(spaceAfterMention: Bool, searchSpaces: Bool) -> MentionListener {
                let attribute = Attribute(name: .foregroundColor, value: UIColor.red)
                let attribute2 = Attribute(name: .foregroundColor, value: UIColor.black)

                return MentionListener(mentionsTextView: textView,
                                       mentionTextAttributes: { _ in [attribute] },
                                       defaultTextAttributes: [attribute2],
                                       spaceAfterMention: spaceAfterMention,
                                       searchSpaces: searchSpaces,
                                       hideMentions: {},
                                       didHandleMentionOnReturn: { false },
                                       showMentionsListWithString: { _, _ in })
            }
        }
    }
}
