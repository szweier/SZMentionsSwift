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
    
    struct UsernameMention: CreateMention {
        public var name: String
        public var range: NSRange
        
        public init(name: String, range: NSRange) {
            self.name = name
            self.range = range
        }
    }
    
    override func spec() {
        describe("Mentions Display") {
            var mentionsListener: MentionListener!
            let textView = UITextView()
            
            it("Should show the mentions list when typing a mention and hide when a space is added if search spaces is false") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: false)
                textView.insertText("@t")
                
                expect(self.hidingMentionsList).to(beFalsy())
                expect(self.mentionsString).to(equal("t"))
                expect(self.triggerString).to(equal("@"))
                
                textView.insertText(" ")
                
                expect(self.hidingMentionsList).to(beTruthy())
            }
            
            it("Should show the mentions list when typing a mention and remain visible when a space is added if search spaces is true") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: true)
                textView.insertText("@t")
                
                expect(self.hidingMentionsList).to(beFalsy())
                expect(self.mentionsString).to(equal("t"))
                expect(self.triggerString).to(equal("@"))
                
                textView.insertText(" ")
                
                expect(self.hidingMentionsList).to(beFalsy())
            }
            
            it("Should show the mentions list when typing a mention on a new line and hide when a space is added if search spaces is false") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: false)
                textView.insertText("\n@t")
                
                expect(self.hidingMentionsList).to(beFalsy())
                expect(self.mentionsString).to(equal("t"))
                expect(self.triggerString).to(equal("@"))
                
                textView.insertText(" ")
                
                expect(self.hidingMentionsList).to(beTruthy())
            }
            
            it("Should show the mentions list when typing a mention on a new line and remain visible when a space is added if search spaces is true") {
                mentionsListener = generateMentionsListener(searchSpacesInMentions: true)
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
                let mention = UsernameMention(name: "@awesome", range: NSRange(location: 0, length: 0))
                mentionsListener.addMention(mention)
                
                var cursorPosition = 0
                if let selectedRange = textView.selectedTextRange {
                    cursorPosition = textView.offset(from: textView.beginningOfDocument,
                                                     to: selectedRange.start)
                }
                
                expect(textView.text.count).to(equal(cursorPosition))
            }
            
            func generateMentionsListener(searchSpacesInMentions: Bool,
                                          spaceAfterMention: Bool = false) -> MentionListener {
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
