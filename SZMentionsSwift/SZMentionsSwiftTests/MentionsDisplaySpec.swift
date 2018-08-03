import Quick
import Nimble
@testable import SZMentionsSwift

class MentionsDisplay: QuickSpec {

    override func spec() {
        describe("Mentions Display") {
            var testDelegate: TestMentionDelegate!
            var mentionsListener: SZMentionsListener!
            let textView = UITextView()

            beforeEach {
                testDelegate = TestMentionDelegate()
                mentionsListener = SZMentionsListener(mentionTextView: textView,
                                                      mentionsManager: testDelegate,
                                                      textViewDelegate: testDelegate)
            }

            it("Should show the mentions list when typing a mention and hide when a space is added if search spaces is false") {
                textView.insertText("@t")
                expect(testDelegate.hidingMentionsList).to(beFalsy())
                expect(testDelegate.mentionsString).to(equal("t"))
                expect(testDelegate.trigger).to(equal("@"))
                textView.insertText(" ")
                expect(testDelegate.hidingMentionsList).to(beTruthy())
            }

            it("Should show the mentions list when typing a mention and remain visible when a space is added if search spaces is true") {
                mentionsListener.searchSpacesInMentions = true
                textView.insertText("@t")
                expect(testDelegate.hidingMentionsList).to(beFalsy())
                expect(testDelegate.mentionsString).to(equal("t"))
                expect(testDelegate.trigger).to(equal("@"))
                textView.insertText(" ")
                expect(testDelegate.hidingMentionsList).to(beFalsy())
            }

            it("Should show the mentions list when typing a mention on a new line and hide when a space is added if search spaces is false") {
                textView.insertText("\n@t")
                expect(testDelegate.hidingMentionsList).to(beFalsy())
                expect(testDelegate.mentionsString).to(equal("t"))
                expect(testDelegate.trigger).to(equal("@"))
                textView.insertText(" ")
                expect(testDelegate.hidingMentionsList).to(beTruthy())
            }

            it("Should show the mentions list when typing a mention on a new line and remain visible when a space is added if search spaces is true") {
                mentionsListener.searchSpacesInMentions = true
                textView.insertText("\n@t")
                expect(testDelegate.hidingMentionsList).to(beFalsy())
                expect(testDelegate.mentionsString).to(equal("t"))
                expect(testDelegate.trigger).to(equal("@"))
                textView.insertText(" ")
                expect(testDelegate.hidingMentionsList).to(beFalsy())
            }
        }
    }
}
