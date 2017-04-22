import Quick
import Nimble
@testable import SZMentionsSwift


class Attribute: QuickSpec {
    override func spec() {
        describe("Attribute Handling") {
            let attribute = SZAttribute(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.red)
            let attribute2 = SZAttribute(attributeName: NSBackgroundColorAttributeName, attributeValue: UIColor.black)

            it("Should throw an exception if the attribute types don't match") {
                expect(SZVerifier.verifySetup(withDefaultTextAttributes: [attribute],
                                              mentionTextAttributes: [attribute, attribute2])).to(throwAssertion())
            }

            it("Should not throw an exception if the attribute types match") {
                expect(SZVerifier.verifySetup(withDefaultTextAttributes: [attribute, attribute2],
                                              mentionTextAttributes: [attribute2, attribute])).toNot(throwAssertion())
            }

            it("Should have the correct default color") {
                let attribute: SZAttribute = SZDefaultAttributes.defaultColor
                expect(attribute.attributeName).to(equal(NSForegroundColorAttributeName))
                expect(attribute.attributeValue).to(equal(UIColor.black))
            }

            it("Should have the correct mention color") {
                let attribute: SZAttribute = SZDefaultAttributes.mentionColor
                expect(attribute.attributeName).to(equal(NSForegroundColorAttributeName))
                expect(attribute.attributeValue).to(equal(UIColor.blue))
            }

            it("Should have the correct default text attributes") {
                let attributes: [SZAttribute] = SZDefaultAttributes.defaultTextAttributes
                let attribute = attributes[0]
                expect(attributes.count).to(equal(1))
                expect(attribute.attributeName).to(equal(NSForegroundColorAttributeName))
                expect(attribute.attributeValue).to(equal(UIColor.black))
            }

            it("Should have the correct default mention text attributes") {
                let attributes: [SZAttribute] = SZDefaultAttributes.defaultMentionAttributes
                let attribute = attributes[0]
                expect(attributes.count).to(equal(1))
                expect(attribute.attributeName).to(equal(NSForegroundColorAttributeName))
                expect(attribute.attributeValue).to(equal(UIColor.blue))
            }
        }
    }
}
