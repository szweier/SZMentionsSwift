import Nimble
import Quick
@testable import SZMentionsSwift

class StringHelperTests: QuickSpec {
    override func spec() {
        describe("String Helper") {
            it("Should be able to search with multiple search items prioritizing the first element in the search array") {
                let stringToSearch = "This is a #test string to @search"
                let result = stringToSearch.range(of: ["@", "#"], options: NSString.CompareOptions.caseInsensitive)
                expect(result?.range).to(equal(NSRange(location: 26, length: 1)))
                expect(result?.foundString).to(equal("@"))
            }

            it("Should be able to search with multiple search items prioritizing the first element in the search array") {
                let stringToSearch = "This is a #test string to @search"
                let result = stringToSearch.range(of: ["#", "@"], options: NSString.CompareOptions.caseInsensitive)
                expect(result?.range).to(equal(NSRange(location: 10, length: 1)))
                expect(result?.foundString).to(equal("#"))
            }

            it("Should be able to search with multiple search items prioritizing the first element in the search array") {
                let stringToSearch = "This is a test string to @search"
                let result = stringToSearch.range(of: ["#", "@"], options: NSString.CompareOptions.caseInsensitive)
                expect(result?.range).to(equal(NSRange(location: 25, length: 1)))
                expect(result?.foundString).to(equal("@"))
            }
        }
    }
}
