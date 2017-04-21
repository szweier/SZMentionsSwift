import Quick
import Nimble
@testable import SZMentionsSwift


class MentionsDisplay: QuickSpec {

    override func spec() {
        describe("Mentions Display") {
            var testDelegate: TestMentionDelegate!
            let textView = UITextView()
            var mentionsListener: SZMentionsListener!

            beforeEach {
                let attribute = SZAttribute(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.red)
                let attribute2 = SZAttribute(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.black)

                testDelegate = TestMentionDelegate()
                mentionsListener = SZMentionsListener(mentionTextView: textView,
                                                      mentionsManager: testDelegate,
                                                      textViewDelegate: testDelegate,
                                                      mentionTextAttributes: [attribute],
                                                      defaultTextAttributes: [attribute2],
                                                      spaceAfterMention: false,
                                                      addMentionOnReturnKey: true,
                                                      searchSpaces: false)
            }

            it("Should show and hide the mentions list") {
                textView.insertText("@t")
                expect(testDelegate.hidingMentionsList).to(beFalsy())
                textView.insertText(" ")
                expect(testDelegate.hidingMentionsList).to(beTruthy())
            }

            it("Should show mentions on a new line and then hide on adding spaces") {
                textView.insertText("\n@t")
                expect(testDelegate.hidingMentionsList).to(beFalsy())
                textView.insertText(" ")
                expect(testDelegate.hidingMentionsList).to(beTruthy())
            }

            it("Should show mentions on a new line and continue to show it when search spaces is true") {
                mentionsListener.searchSpacesInMentions = true
                textView.insertText("\n@t")
                expect(testDelegate.hidingMentionsList).to(beFalsy())
                textView.insertText(" ")
                expect(testDelegate.hidingMentionsList).to(beFalsy())
            }

            it("Should not hide the mentions list when adding a space is spaces are allowed in search") {
                mentionsListener.searchSpacesInMentions = true
                textView.insertText("@t")
                expect(testDelegate.hidingMentionsList).to(beFalsy())
                textView.insertText(" ")
                expect(testDelegate.hidingMentionsList).to(beFalsy())
            }
        }
    }
}
