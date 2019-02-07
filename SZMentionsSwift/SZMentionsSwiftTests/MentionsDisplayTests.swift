import Nimble
import Quick
@testable import SZMentionsSwift

class MentionsDisplay: QuickSpec {
    var hidingMentionsList = false
    var mentionsString = ""
    var triggerString = ""

    func hideMentions() { hidingMentionsList = true }
    func showMentions(mention: String, trigger: String) {
        hidingMentionsList = false
        mentionsString = mention
        triggerString = trigger
    }

    override func spec() {
        describe("Mentions Display") {
            var mentionsListener: MentionListener!
            let textView = UITextView()

            it("Should show the mentions list when typing a mention and hide when a space is added if search spaces is false") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: false, spaceAfterMention: false)
                textView.insertText("@t")

                expect(self.hidingMentionsList).to(beFalsy())
                expect(self.mentionsString).to(equal("t"))
                expect(self.triggerString).to(equal("@"))

                textView.insertText(" ")

                expect(self.hidingMentionsList).to(beTruthy())
            }

            it("Should show the mentions list when typing a mention and remain visible when a space is added if search spaces is true") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: true, spaceAfterMention: false)
                textView.insertText("@t")

                expect(self.hidingMentionsList).to(beFalsy())
                expect(self.mentionsString).to(equal("t"))
                expect(self.triggerString).to(equal("@"))

                textView.insertText(" ")

                expect(self.hidingMentionsList).to(beFalsy())
            }

            it("Should show the mentions list when typing a mention on a new line and hide when a space is added if search spaces is false") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: false, spaceAfterMention: false)
                textView.insertText("\n@t")

                expect(self.hidingMentionsList).to(beFalsy())
                expect(self.mentionsString).to(equal("t"))
                expect(self.triggerString).to(equal("@"))

                textView.insertText(" ")

                expect(self.hidingMentionsList).to(beTruthy())
            }

            it("Should show the mentions list when typing a mention on a new line and remain visible when a space is added if search spaces is true") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: true, spaceAfterMention: false)
                textView.insertText("\n@t")

                expect(self.hidingMentionsList).to(beFalsy())
                expect(self.mentionsString).to(equal("t"))
                expect(self.triggerString).to(equal("@"))

                textView.insertText(" ")

                expect(self.hidingMentionsList).to(beFalsy())
            }

            it("Should set cursor after added space when add a mention if spaces after mention is true") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: true, spaceAfterMention: true)

                textView.text = ""
                textView.insertText("@a")
                addMention(named: "@awesome", on: mentionsListener)

                expect("@awesome ".count).to(equal(textView.selectedRange.location))
            }

            func generateMentionsListener(searchSpacesInMentions: Bool, spaceAfterMention: Bool) -> MentionListener {
                return MentionListener(mentionsTextView: textView,
                                       spaceAfterMention: spaceAfterMention,
                                       searchSpaces: searchSpacesInMentions,
                                       hideMentions: hideMentions,
                                       didHandleMentionOnReturn: { true },
                                       showMentionsListWithString: showMentions)
            }
        }
    }
}
