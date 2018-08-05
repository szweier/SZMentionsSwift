import Nimble
import Quick
@testable import SZMentionsSwift

class MentionsDisplay: QuickSpec {
    override func spec() {
        describe("Mentions Display") {
            var mentionsListener: MentionListener!
            let textView = UITextView()

            it("Should show the mentions list when typing a mention and hide when a space is added if search spaces is false") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: false)
                textView.insertText("@t")
                expect(hidingMentionsList).to(beFalsy())
                expect(mentionsString).to(equal("t"))
                expect(triggerString).to(equal("@"))
                textView.insertText(" ")
                expect(hidingMentionsList).to(beTruthy())
            }

            it("Should show the mentions list when typing a mention and remain visible when a space is added if search spaces is true") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: true)
                textView.insertText("@t")
                expect(hidingMentionsList).to(beFalsy())
                expect(mentionsString).to(equal("t"))
                expect(triggerString).to(equal("@"))
                textView.insertText(" ")
                expect(hidingMentionsList).to(beFalsy())
            }

            it("Should show the mentions list when typing a mention on a new line and hide when a space is added if search spaces is false") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: false)
                textView.insertText("\n@t")
                expect(hidingMentionsList).to(beFalsy())
                expect(mentionsString).to(equal("t"))
                expect(triggerString).to(equal("@"))
                textView.insertText(" ")
                expect(hidingMentionsList).to(beTruthy())
            }

            it("Should show the mentions list when typing a mention on a new line and remain visible when a space is added if search spaces is true") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: true)
                textView.insertText("\n@t")
                expect(hidingMentionsList).to(beFalsy())
                expect(mentionsString).to(equal("t"))
                expect(triggerString).to(equal("@"))
                textView.insertText(" ")
                expect(hidingMentionsList).to(beFalsy())
            }

            func generateMentionsListener(searchSpacesInMentions: Bool) -> MentionListener {
                return MentionListener(mentionTextView: textView,
                                       searchSpaces: searchSpacesInMentions,
                                       hideMentions: hideMentions,
                                       didHandleMentionOnReturn: didHandleMention,
                                       showMentionsListWithString: showMentions)
            }
        }
    }
}
