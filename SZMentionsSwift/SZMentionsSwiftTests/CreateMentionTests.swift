import Nimble
import Quick
@testable import SZMentionsSwift

class CreateMentionTests: QuickSpec {
    override func spec() {
        describe("Name helper") {
            it("Should return a name without a space if spaceAfterMention is false") {
                let mention = ExampleMention(name: "Steven Zweier")

                expect(mention.mentionName(with: false)).to(equal("Steven Zweier"))
            }

            it("Should return a name with a space if spaceAfterMention is true") {
                let mention = ExampleMention(name: "Steven Zweier")

                expect(mention.mentionName(with: true)).to(equal("Steven Zweier "))
            }
        }
    }
}
