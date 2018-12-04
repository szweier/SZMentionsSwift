import Nimble
import Quick
@testable import SZMentionsSwift

class MentionsArrayTests: QuickSpec {
    struct ExampleMention: CreateMention {
        var name: String = ""
        var range: NSRange = NSRange(location: 0, length: 0)
    }

    override func spec() {
        describe("Search") {
            let mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]

            it("Should NOT return mention being edited if positioned BEFORE the FIRST letter of the mention") {
                expect(mentions.mentionBeingEdited(at: NSRange(location: 0, length: 0))).to(beNil())
            }

            it("Should return mention being edited if positioned AFTER the FIRST letter of the mention") {
                expect(mentions.mentionBeingEdited(at: NSRange(location: 1, length: 0))).to(equal(mentions[0]))
            }

            it("Should return mention being edited if positioned BEFORE the LAST letter of the mention") {
                expect(mentions.mentionBeingEdited(at: NSRange(location: 9, length: 0))).to(equal(mentions[0]))
            }

            it("Should NOT return mention being edited if positioned AFTER the LAST letter of the mention") {
                expect(mentions.mentionBeingEdited(at: NSRange(location: 10, length: 0))).to(beNil())
            }
        }

        describe("Adjust") {
            it("Should properly adjust the location of mentions located after added text") {
                var mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention()),
                                           Mention(range: NSRange(location: 15, length: 10), object: ExampleMention())]

                let insertText = "Test "
                expect(mentions[0].range.location).to(equal(0))
                expect(mentions[1].range.location).to(equal(15))
                mentions.adjustMentions(forTextChangeAt: NSRange(location: 5, length: 0), text: insertText)
                expect(mentions[0].range.location).to(equal(0))
                expect(mentions[1].range.location).to(equal(15 + insertText.count))
            }
        }
    }
}
