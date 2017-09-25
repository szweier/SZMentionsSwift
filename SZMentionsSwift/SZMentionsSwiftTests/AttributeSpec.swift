import Quick
import Nimble
@testable import SZMentionsSwift


class Attribute: QuickSpec {
    override func spec() {
        describe("Attribute Handling") {
            #if swift(>=4.0)
                let attribute = SZAttribute(attributeName: NSAttributedStringKey.foregroundColor.rawValue, attributeValue: UIColor.red)
                let attribute2 = SZAttribute(attributeName: NSAttributedStringKey.backgroundColor.rawValue, attributeValue: UIColor.black)
            #else
                let attribute = SZAttribute(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.red)
                let attribute2 = SZAttribute(attributeName: NSBackgroundColorAttributeName, attributeValue: UIColor.black)
            #endif

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
