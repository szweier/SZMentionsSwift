import Quick
import Nimble
@testable import SZMentionsSwift

class MentionsDisplay: QuickSpec {
    
    override func spec() {
        describe("Mentions Display") {
            var mentionsListener: SZMentionsListener!
            let textView = UITextView()
            var shouldAddMentionOnReturnKeyCalled = false
            var hidingMentionsList = false
            
            beforeEach {
            }
            
            it("Should show the mentions list when typing a mention and hide when a space is added if search spaces is false") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: false)
                textView.insertText("@t")
                expect(hidingMentionsList).to(beFalsy())
                textView.insertText(" ")
                expect(hidingMentionsList).to(beTruthy())
            }
            
            it("Should show the mentions list when typing a mention and remain visible when a space is added if search spaces is true") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: true)
                textView.insertText("@t")
                expect(hidingMentionsList).to(beFalsy())
                textView.insertText(" ")
                expect(hidingMentionsList).to(beFalsy())
            }
            
            it("Should show the mentions list when typing a mention on a new line and hide when a space is added if search spaces is false") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: false)
                textView.insertText("\n@t")
                expect(hidingMentionsList).to(beFalsy())
                textView.insertText(" ")
                expect(hidingMentionsList).to(beTruthy())
            }
            
            it("Should show the mentions list when typing a mention on a new line and remain visible when a space is added if search spaces is true") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: true)
                textView.insertText("\n@t")
                expect(hidingMentionsList).to(beFalsy())
                textView.insertText(" ")
                expect(hidingMentionsList).to(beFalsy())
            }
            
            func generateMentionsListener(searchSpacesInMentions: Bool) -> SZMentionsListener {
                return SZMentionsListener(mentionTextView: textView,
                                          searchSpaces: searchSpacesInMentions,
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
        }
    }
}
