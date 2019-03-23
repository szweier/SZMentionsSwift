import Nimble
import Quick
@testable import SZMentionsSwift

class VerifierTests: QuickSpec {
    override func spec() {
        describe("Attributes Match") {
            let attribute = Attribute(name: .foregroundColor, value: UIColor.red)
            let attribute2 = Attribute(name: .backgroundColor, value: UIColor.black)

            it("Should throw an exception if the attribute types don't match") {
                expect(Verifier.verifySetup(withDefaultTextAttributes: [attribute],
                                            mentionTextAttributes: [attribute, attribute2])).to(throwAssertion())
            }

            it("Should not throw an exception if the attribute types match") {
                expect(Verifier.verifySetup(withDefaultTextAttributes: [attribute, attribute2],
                                            mentionTextAttributes: [attribute2, attribute])).toNot(throwAssertion())
            }
        }
    }
}
