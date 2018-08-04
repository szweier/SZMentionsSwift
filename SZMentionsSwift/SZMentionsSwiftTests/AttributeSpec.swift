import Quick
import Nimble
@testable import SZMentionsSwift


class Attribute: QuickSpec {
    override func spec() {
        describe("Attribute Handling") {
            #if swift(>=4.0)
                let attribute = SZAttribute(name: NSAttributedStringKey.foregroundColor.rawValue, value: UIColor.red)
                let attribute2 = SZAttribute(name: NSAttributedStringKey.backgroundColor.rawValue, value: UIColor.black)
            #else
                let attribute = SZAttribute(name: NSForegroundColorAttributeName, value: UIColor.red)
                let attribute2 = SZAttribute(name: NSBackgroundColorAttributeName, value: UIColor.black)
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
