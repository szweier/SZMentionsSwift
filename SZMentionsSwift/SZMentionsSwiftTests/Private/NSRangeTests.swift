import Nimble
import Quick
@testable import SZMentionsSwift

class NSRangeTests: QuickSpec {
    override func spec() {
        describe("Adjust offset") {
            it("Should add mention") {
                var range = NSRange(location: 0, length: 2)
                range = range.adjustLength(for: "Test")
                expect(range.location).to(equal(0))
                expect(range.length).to(equal(4))
            }
        }
    }
}
