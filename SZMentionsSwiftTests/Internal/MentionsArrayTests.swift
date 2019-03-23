import Nimble
import Quick
@testable import SZMentionsSwift

class MentionsArrayTests: QuickSpec {
    override func spec() {
        describe("Search") {
            let mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]

            it("Should NOT return mention being edited if positioned BEFORE the FIRST letter of the mention") {
                expect(mentions |> mentionBeingEdited(at: NSRange(location: 0, length: 0))).to(beNil())
            }

            it("Should return mention being edited if positioned AFTER the FIRST letter of the mention") {
                expect(mentions |> mentionBeingEdited(at: NSRange(location: 1, length: 0))).to(equal(mentions[0]))
            }

            it("Should return mention being edited if positioned BEFORE the LAST letter of the mention") {
                expect(mentions |> mentionBeingEdited(at: NSRange(location: 9, length: 0))).to(equal(mentions[0]))
            }

            it("Should NOT return mention being edited if positioned AFTER the LAST letter of the mention") {
                expect(mentions |> mentionBeingEdited(at: NSRange(location: 10, length: 0))).to(beNil())
            }
        }

        describe("Adjust") {
            it("Should properly adjust the location of mentions located after added text") {
                var mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention()),
                                           Mention(range: NSRange(location: 15, length: 10), object: ExampleMention())]

                let insertText = "Test "
                expect(mentions[0].range.location).to(equal(0))
                expect(mentions[1].range.location).to(equal(15))
                mentions = mentions |> adjusted(forTextChangeAt: NSRange(location: 5, length: 0), text: insertText)
                expect(mentions[0].range.location).to(equal(0))
                expect(mentions[1].range.location).to(equal(15 + insertText.count))
            }
        }

        describe("Mention Being Edited") {
            it("Should return nil being edited if selection is before the first letter") {
                let mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]

                expect(mentions |> mentionBeingEdited(at: NSRange(location: 0, length: 0))).to(beNil())
            }

            it("Should return the mention being edited if selection is after the first letter") {
                let mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]

                expect(mentions |> mentionBeingEdited(at: NSRange(location: 1, length: 0))).toNot(beNil())
            }
            it("Should return nil being edited if selection is after the last letter") {
                let mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]

                expect(mentions |> mentionBeingEdited(at: NSRange(location: 10, length: 0))).to(beNil())
            }

            it("Should return the mention being edited if selection is before the last letter") {
                let mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]

                expect(mentions |> mentionBeingEdited(at: NSRange(location: 9, length: 0))).toNot(beNil())
            }

            it("Should return the mention being edited if selection intersects the mention at the beginning") {
                let mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]

                expect(mentions |> mentionBeingEdited(at: NSRange(location: 0, length: 3))).toNot(beNil())
            }

            it("Should return the mention being edited if selection intersects the mention at the end") {
                let mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]

                expect(mentions |> mentionBeingEdited(at: NSRange(location: 9, length: 3))).toNot(beNil())
            }
        }

        describe("Insert Mention") {
            it("Should return a new mentions array with a mention inserted") {
                var mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]
                let createMentionObject = ExampleMention(name: "Test Mention")
                mentions = mentions |> insert([(createMentionObject, NSRange(location: 15, length: 12))])
                expect(mentions.count).to(equal(2))
                expect(mentions[1]).to(equal(Mention(range: NSRange(location: 15, length: 12), object: createMentionObject)))
            }
        }

        describe("Remove Mention") {
            it("Should return an array with a single item removed") {
                var mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention()),
                                           Mention(range: NSRange(location: 13, length: 10), object: ExampleMention())]
                mentions = mentions |> remove([mentions[0]])
                expect(mentions.count).to(equal(1))
            }

            it("Should return an array with a multiple items removed") {
                var mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention()),
                                           Mention(range: NSRange(location: 13, length: 10), object: ExampleMention())]
                mentions = mentions |> remove([mentions[0], mentions[1]])
                expect(mentions.isEmpty).to(beTrue())
            }
        }

        describe("Add Mention") {
            it("Should return an array with a single item added") {
                var mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]
                let mentionToAdd = ExampleMention(name: "Added Mention")
                mentions = mentions |> SZMentionsSwift.add(mentionToAdd, spaceAfterMention: false, at: NSRange(location: 0, length: 0))
                expect(mentions.count).to(equal(2))
                expect(mentions[0]).to(equal(Mention(range: NSRange(location: 13, length: 10), object: ExampleMention())))
                expect(mentions[1]).to(equal(Mention(range: NSRange(location: 0, length: 13), object: mentionToAdd)))
            }
        }
    }
}
