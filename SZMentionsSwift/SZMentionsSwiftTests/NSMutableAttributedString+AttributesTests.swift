import Nimble
import Quick
@testable import SZMentionsSwift

class UITextViewTests: QuickSpec {
    override func spec() {
        describe("Search") {
            it("Should NOT return mention being edited if positioned BEFORE the FIRST letter of the mention") {
                let textView = UITextView()
                textView.attributedText = NSAttributedString(string:
                    "Test string, test string, test string, test string, test string, test string, test string, test string, test string.")
                let attributes = [
                    Attribute(name: .backgroundColor, value: UIColor.red),
                    Attribute(name: .foregroundColor, value: UIColor.blue),
                ]
                textView.apply(attributes, range: NSRange(location: 0, length: textView.attributedText.length))
                expect(textView.attributedText.attributes(at: 0, effectiveRange: nil)[.backgroundColor] as? UIColor).to(equal(UIColor.red))
                expect(textView.attributedText.attributes(at: 0, effectiveRange: nil)[.foregroundColor] as? UIColor).to(equal(UIColor.blue))
            }
        }
    }
}
