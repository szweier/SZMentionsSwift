import Quick
import Nimble
@testable import SZMentionsSwift


class Attribute: QuickSpec {
    override func spec() {
        describe("Attribute Handling") {
            let attribute = SZAttribute(attributeName: .foregroundColor, attributeValue: UIColor.red)
            let attribute2 = SZAttribute(attributeName: .backgroundColor, attributeValue: UIColor.black)

            it("Should throw an exception if the attribute types don't match") {
                expect(SZVerifier.verifySetup(withDefaultTextAttributes: [attribute],
                                              mentionTextAttributes: [attribute, attribute2])).to(throwAssertion())
            }

            it("Should not throw an exception if the attribute types match") {
                expect(SZVerifier.verifySetup(withDefaultTextAttributes: [attribute, attribute2],
                                              mentionTextAttributes: [attribute2, attribute])).toNot(throwAssertion())
            }
        }
    }
}
