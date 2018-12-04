import Nimble
import Quick
@testable import SZMentionsSwift

class Delegates: QuickSpec {
    class TextViewDelegate: NSObject, UITextViewDelegate {
        var shouldBeginEditing: Bool = false
        var shouldEndEditing: Bool = false
        var shouldInteractWithTextAttachment: Bool = false
        var triggeredDelegateMethod: Bool = false

        func textView(_: UITextView, shouldInteractWith _: NSTextAttachment,
                      in _: NSRange) -> Bool {
            return shouldInteractWithTextAttachment
        }

        func textView(_: UITextView, shouldInteractWith _: URL, in _: NSRange) -> Bool {
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

    override func spec() {
        describe("Delegate Methods") {
            var textViewDelegate: TextViewDelegate!
            var mentionsListener: MentionListener!
            let textView = UITextView()

            beforeEach {
                let attribute = Attribute(name: .foregroundColor, value: UIColor.red)
                let attribute2 = Attribute(name: .foregroundColor, value: UIColor.black)

                hidingMentionsList = false
                textViewDelegate = TextViewDelegate()
                mentionsListener = MentionListener(mentionTextView: textView,
                                                   delegate: textViewDelegate,
                                                   attributesForMention: { _ in [attribute] },
                                                   defaultTextAttributes: [attribute2],
                                                   hideMentions: hideMentions,
                                                   didHandleMentionOnReturn: didHandleMention,
                                                   showMentionsListWithString: showMentions)
            }

            it("Should return false for textView(shouldInteractWith:in) for a text attachment when overridden") {
                expect(mentionsListener.textView(textView, shouldInteractWith: NSTextAttachment(), in: NSRange(location: 0, length: 0))).to(beFalsy())
            }

            it("Should return true for textView(shouldInteractWith:in) for a text attachment when not overridden") {
                mentionsListener.delegate = nil
                expect(mentionsListener.textView(textView, shouldInteractWith: NSTextAttachment(), in: NSRange(location: 0, length: 0))).to(beTruthy())
            }

            it("Should return false for textView(shouldInteractWith:in) for a URL when overridden") {
                expect(mentionsListener.textView(textView, shouldInteractWith: URL(string: "http://test.com")!, in: NSRange(location: 0, length: 0))).to(beFalsy())
            }

            it("Should return true for textView(shouldInteractWith:in) for a URL when not overridden") {
                mentionsListener.delegate = nil
                expect(mentionsListener.textView(textView, shouldInteractWith: URL(string: "http://test.com")!, in: NSRange(location: 0, length: 0))).to(beTruthy())
            }

            it("Should return false for textViewShouldBeginEditing when overridden") {
                expect(mentionsListener.textViewShouldBeginEditing(textView)).to(beFalsy())
            }

            it("Should return true for textViewShouldBeginEditing when not overridden") {
                mentionsListener.delegate = nil
                expect(mentionsListener.textViewShouldBeginEditing(textView)).to(beTruthy())
            }

            it("Should return false for textViewShouldEndEditing when not overridden") {
                expect(mentionsListener.textViewShouldEndEditing(textView)).to(beFalsy())
            }

            it("Should return true for textViewShouldEndEditing when not overridden") {
                mentionsListener.delegate = nil
                expect(mentionsListener.textViewShouldEndEditing(textView)).to(beTruthy())
            }

            it("Should return the delegate response for textViewDidBeginEditing") {
                expect(textViewDelegate.triggeredDelegateMethod).to(beFalsy())
                mentionsListener.textViewDidBeginEditing(textView)
                expect(textViewDelegate.triggeredDelegateMethod).to(beTruthy())
            }

            it("Should return the delegate response for textViewDidEndEditing") {
                expect(textViewDelegate.triggeredDelegateMethod).to(beFalsy())
                mentionsListener.textViewDidEndEditing(textView)
                expect(textViewDelegate.triggeredDelegateMethod).to(beTruthy())
            }

            it("Should call delegate method to determine if adding mention on return should be enabled") {
                expect(shouldAddMentionOnReturnKeyCalled).to(beFalsy())

                textView.insertText("@t")
                expect(hidingMentionsList).to(beFalsy())

                if mentionsListener.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "\n") {
                    textView.insertText("\n")
                }

                expect(shouldAddMentionOnReturnKeyCalled).to(beTruthy())
                expect(hidingMentionsList).to(beTruthy())
            }

            it("Should allow for mentions to be added in advance") {
                textView.text = "Testing Steven Zweier and Tiffany get mentioned correctly"

                let mention = (ExampleMention(name: "Steve") as CreateMention,
                               NSRange(location: 8, length: 13))
                let mention2 = (ExampleMention(name: "Tiff") as CreateMention,
                                NSRange(location: 26, length: 7))

                let insertMentions = [mention, mention2]

                mentionsListener.insertExistingMentions(insertMentions)

                expect(mentionsListener.mentions.count).to(equal(2))

                expect((textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                expect((textView.attributedText.attribute(.foregroundColor, at: 9, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.red))
                expect((textView.attributedText.attribute(.foregroundColor, at: 21, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                expect((textView.attributedText.attribute(.foregroundColor, at: 27, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.red))
                expect((textView.attributedText.attribute(.foregroundColor, at: 33, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
            }

            it("Should allow for mentions to be added in advance") {
                textView.text = "test 🦅 Asim test"

                let mention = (ExampleMention(name: "Asim") as CreateMention,
                               NSRange(location: 8, length: 4))

                let insertMentions: [(CreateMention, NSRange)] = [mention]

                mentionsListener.insertExistingMentions(insertMentions)

                expect(mentionsListener.mentions.count).to(equal(1))

                expect((textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                expect((textView.attributedText.attribute(.foregroundColor, at: 9, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.red))
                expect((textView.attributedText.attribute(.foregroundColor, at: 12, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
            }

            it("Should throw an assertion if the mention range is beyond the text length") {
                textView.text = "Testing Steven Zweier"

                let mention = (ExampleMention(name: "Steve") as CreateMention,
                               NSRange(location: 8, length: 13))
                let mention2 = (ExampleMention(name: "Tiff") as CreateMention,
                                NSRange(location: 26, length: 7))

                let insertMentions: [(CreateMention, NSRange)] = [mention, mention2]

                expect(mentionsListener.insertExistingMentions(insertMentions)).to(throwAssertion())
            }
        }
    }
}
