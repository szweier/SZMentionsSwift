import Nimble
import Quick
@testable import SZMentionsSwift

class VerifierTests: QuickSpec {
    override func spec() {
        describe("Attribute Handling") {
            let attribute = Attribute(name: NSAttributedStringKey.foregroundColor.rawValue, value: UIColor.red)
            let attribute2 = Attribute(name: NSAttributedStringKey.backgroundColor.rawValue, value: UIColor.black)

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
