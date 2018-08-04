import Quick
import Nimble
@testable import SZMentionsSwift

class Delegates: QuickSpec {
    class TextViewDelegate: NSObject, UITextViewDelegate {
        var shouldBeginEditing: Bool = false
        var shouldEndEditing: Bool = false
        var shouldInteractWithTextAttachment: Bool = false
        var triggeredDelegateMethod: Bool = false

        func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment,
                      in characterRange: NSRange) -> Bool {
            return shouldInteractWithTextAttachment
        }

        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
            return shouldInteractWithTextAttachment
        }

        func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
            return shouldBeginEditing
        }

        func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
            return shouldEndEditing
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            triggeredDelegateMethod = true
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            triggeredDelegateMethod = true
        }
    }

    override func spec() {
        describe("Delegate Methods") {
            var textViewDelegate: TextViewDelegate!
            var mentionsListener: SZMentionsListener!
            let textView = UITextView()
            var shouldAddMentionOnReturnKeyCalled = false
            var hidingMentionsList = false

            beforeEach {
                #if swift(>=4.0)
                    let attribute = SZAttribute(name: NSAttributedStringKey.foregroundColor.rawValue, value: UIColor.red)
                    let attribute2 = SZAttribute(name: NSAttributedStringKey.foregroundColor.rawValue, value: UIColor.black)
                #else
                    let attribute = SZAttribute(name: NSForegroundColorAttributeName, value: UIColor.red)
                    let attribute2 = SZAttribute(name: NSForegroundColorAttributeName, value: UIColor.black)
                #endif

                hidingMentionsList = false
                textViewDelegate = TextViewDelegate()
                mentionsListener = SZMentionsListener(mentionTextView: textView,
                                                      textViewDelegate: textViewDelegate,
                                                      mentionTextAttributes: [attribute],
                                                      defaultTextAttributes: [attribute2],
                                                      hideMentions: {
                                                            hidingMentionsList = true
                },
                                                      didHandleMentionOnReturn: { () -> Bool in
                                                        shouldAddMentionOnReturnKeyCalled = true
                                                        return true
                },
                                                      showMentionsListWithString: { _ in
                                                        hidingMentionsList = false
                })
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
                textView.text = "Testing Steven Zweier and Tiffany get mentioned correctly";

                let mention = SZExampleMention()
                mention.name = "Steve"
                mention.range = NSRange(location: 8, length: 13)

                let mention2 = SZExampleMention()
                mention2.name = "Tiff"
                mention2.range = NSRange(location: 26, length: 7)

                let insertMentions : Array<CreateMention> = [mention, mention2]

                mentionsListener.insertExistingMentions(insertMentions)

                expect(mentionsListener.mentions.count).to(equal(2))

                #if swift(>=4.0)
                    expect((textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                    expect((textView.attributedText.attribute(.foregroundColor, at: 9, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.red))
                    expect((textView.attributedText.attribute(.foregroundColor, at: 21, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                    expect((textView.attributedText.attribute(.foregroundColor, at: 27, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.red))
                    expect((textView.attributedText.attribute(.foregroundColor, at: 33, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                #else
                    expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                    expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 9, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.red))
                    expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 21, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                    expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 27, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.red))
                    expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 33, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                #endif
            }

            it("Should throw an assertion if the mention range is beyond the text length") {
                textView.text = "Testing Steven Zweier"

                let mention = SZExampleMention()
                mention.name = "Steve"
                mention.range = NSRange(location: 8, length: 13)

                let mention2 = SZExampleMention()
                mention2.name = "Tiff"
                mention2.range = NSRange(location: 26, length: 7)

                let insertMentions : Array<CreateMention> = [mention, mention2]

                expect(mentionsListener.insertExistingMentions(insertMentions)).to(throwAssertion())
            }
        }
    }
}
