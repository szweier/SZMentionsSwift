import Quick
import Nimble
@testable import SZMentionsSwift

class Delegates: QuickSpec {
    class TextViewDelegate: NSObject, UITextViewDelegate {
        var shouldBeginEditing: Bool = true
        var shouldEndEditing: Bool = true
        var triggeredDelegateMethod: Bool = false

        func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
            triggeredDelegateMethod = true
            return shouldBeginEditing
        }

        func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
            triggeredDelegateMethod = true
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
            var testDelegate: TestMentionDelegate!
            let textView = UITextView()
            var mentionsListener: SZMentionsListener!

            beforeEach {
                let attribute = SZAttribute(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.red)
                let attribute2 = SZAttribute(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.black)

                textViewDelegate = TextViewDelegate()
                testDelegate = TestMentionDelegate()
                mentionsListener = SZMentionsListener(mentionTextView: textView,
                                                      mentionsManager: testDelegate,
                                                      textViewDelegate: textViewDelegate,
                                                      mentionTextAttributes: [attribute],
                                                      defaultTextAttributes: [attribute2],
                                                      spaceAfterMention: false,
                                                      addMentionOnReturnKey: true,
                                                      searchSpaces: false)
            }

            it("Should return true for textView(shouldInteractWith:in) for a text attachment") {
                expect(mentionsListener.textView(textView, shouldInteractWith: NSTextAttachment(), in: NSMakeRange(0, 0))).to(beTruthy())
            }

            it("Should return true for textView(shouldInteractWith:in) for a URL") {
                expect(mentionsListener.textView(textView, shouldInteractWith: URL(string: "http://test.com")!, in: NSMakeRange(0, 0))).to(beTruthy())
            }

            it("Should return true for textViewShouldBeginEditing when not overridden") {
                expect(mentionsListener.textViewShouldBeginEditing(textView)).to(beTruthy())
            }

            it("Should return the delegate response for textViewShouldBeginEditing") {
                expect(mentionsListener.textViewShouldBeginEditing(textView)).to(beTruthy())
                textViewDelegate.shouldBeginEditing = false
                expect(!mentionsListener.textViewShouldBeginEditing(textView)).to(beTruthy())
            }

            it("Should return true for textViewShouldEndEditing when not overridden") {
                expect(mentionsListener.textViewShouldEndEditing(textView)).to(beTruthy())
            }

            it("Should return the delegate response for textViewShouldEndEditing") {
                expect(mentionsListener.textViewShouldEndEditing(textView)).to(beTruthy())
                textViewDelegate.shouldEndEditing = false
                expect(mentionsListener.textViewShouldEndEditing(textView)).to(beFalsy())
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
                mentionsListener.addMentionAfterReturnKey = true

                textView.insertText("@t")
                expect(testDelegate.hidingMentionsList).to(beFalsy())

                if mentionsListener.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "\n") {
                    textView.insertText("\n")
                }

                expect(testDelegate.shouldAddMentionOnReturnKeyCalled).to(beTruthy())
                expect(testDelegate.hidingMentionsList).to(beTruthy())
            }

            it("Should allow for mentions to be added in advance") {
                textView.text = "Testing Steven Zweier and Tiffany get mentioned correctly";

                let mention = SZExampleMention()
                mention.szMentionName = "Steve"
                mention.szMentionRange = NSMakeRange(8, 13)

                let mention2 = SZExampleMention()
                mention2.szMentionName = "Tiff"
                mention2.szMentionRange = NSMakeRange(26, 7)

                let insertMentions : Array<SZCreateMentionProtocol> = [mention, mention2]

                mentionsListener.insertExistingMentions(insertMentions)

                expect(mentionsListener.mentions.count).to(equal(2))
                expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 9, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.red))
                expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 21, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 27, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.red))
                expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 33, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
            }
        }
    }
}
