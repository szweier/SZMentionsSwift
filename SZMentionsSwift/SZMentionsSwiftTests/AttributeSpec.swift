import Quick
import Nimble
@testable import SZMentionsSwift


class Attribute: QuickSpec {
    override func spec() {
        describe("Attribute Handling") {
            it("Should throw an exception if the attribute types don't match") {
                let attribute = SZAttribute(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.red)
                let attribute2 = SZAttribute(attributeName: NSBackgroundColorAttributeName, attributeValue: UIColor.black)

                let defaultAttributes = [attribute]
                let mentionAttributes = [attribute, attribute2]

                expect(SZVerifier.verifySetup(withDefaultTextAttributes: defaultAttributes, mentionTextAttributes: mentionAttributes)).to(throwAssertion())
            }

            it("Should not throw an exception if the attribute types match") {
                let attribute = SZAttribute(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.red)
                let attribute2 = SZAttribute(attributeName: NSBackgroundColorAttributeName, attributeValue: UIColor.black)

                let defaultAttributes = [attribute, attribute2]
                let mentionAttributes = [attribute2, attribute]

                expect(SZVerifier.verifySetup(withDefaultTextAttributes: defaultAttributes, mentionTextAttributes: mentionAttributes)).toNot(throwAssertion())
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
                let attributes: [SZAttribute] = SZDefaultAttributes.defaultTextAttributes()
                let attribute = attributes[0]
                expect(attributes.count).to(equal(1))
                expect(attribute.attributeName).to(equal(NSForegroundColorAttributeName))
                expect(attribute.attributeValue).to(equal(UIColor.black))
            }

            it("Should have the correct default mention text attributes") {
                let attributes: [SZAttribute] = SZDefaultAttributes.defaultMentionAttributes()
                let attribute = attributes[0]
                expect(attributes.count).to(equal(1))
                expect(attribute.attributeName).to(equal(NSForegroundColorAttributeName))
                expect(attribute.attributeValue).to(equal(UIColor.blue))
            }
        }
    }
}
