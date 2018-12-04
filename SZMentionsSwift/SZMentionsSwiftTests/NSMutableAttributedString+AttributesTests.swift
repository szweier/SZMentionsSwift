import Nimble
import Quick
@testable import SZMentionsSwift

class NSMutableAttributedStringAttributesTests: QuickSpec {
    override func spec() {
        describe("Search") {
            it("Should NOT return mention being edited if positioned BEFORE the FIRST letter of the mention") {
                let attributedString = NSMutableAttributedString(string:
                    "Test string, test string, test string, test string, test string, test string, test string, test string, test string.")
                let attributes = [
                    Attribute(name: NSAttributedStringKey.backgroundColor.rawValue, value: UIColor.red),
                    Attribute(name: NSAttributedStringKey.foregroundColor.rawValue, value: UIColor.blue),
                ]
                attributedString.apply(attributes, range: NSRange(location: 0, length: attributedString.length))
                expect(attributedString.attributes(at: 0, effectiveRange: nil)[.backgroundColor] as? UIColor).to(equal(UIColor.red))
                expect(attributedString.attributes(at: 0, effectiveRange: nil)[.foregroundColor] as? UIColor).to(equal(UIColor.blue))
            }
        }
    }
}
