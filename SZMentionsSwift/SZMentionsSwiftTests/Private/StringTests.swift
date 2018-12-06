import Nimble
import Quick
@testable import SZMentionsSwift

class StringExtensionTests: QuickSpec {
    override func spec() {
        describe("Search") {
            it("Should be able to search with multiple search items prioritizing the first element in the search array") {
                let stringToSearch = "This is a #test string to @search"
                let result = stringToSearch.range(of: ["@", "#"], options: .caseInsensitive)
                expect(result.range).to(equal(NSRange(location: 26, length: 1)))
                expect(result.foundString).to(equal("@"))
            }

            it("Should be able to search with multiple search items prioritizing the first element in the search array") {
                let stringToSearch = "This is a #test string to @search"
                let result = stringToSearch.range(of: ["#", "@"], options: .caseInsensitive)
                expect(result.range).to(equal(NSRange(location: 10, length: 1)))
                expect(result.foundString).to(equal("#"))
            }

            it("Should be able to search with multiple search items prioritizing the first element in the search array") {
                let stringToSearch = "This is a test string to @search"
                let result = stringToSearch.range(of: ["#", "@"], options: .caseInsensitive)
                expect(result.range).to(equal(NSRange(location: 25, length: 1)))
                expect(result.foundString).to(equal("@"))
            }

            it("Should return NSNotFound with empty string when given an empty input array") {
                let stringToSearch = "This is a test string to @search"
                let result = stringToSearch.range(of: [], options: .caseInsensitive)
                expect(result.range).to(equal(NSRange(location: NSNotFound, length: 0)))
                expect(result.foundString).to(equal(""))
            }

            it("Should properly search within a specified range") {
                let stringToSearch = "This is a test #string to @search"
                let result = stringToSearch.range(of: ["#", "@"], options: .caseInsensitive, range: NSRange(location: 17, length: 16))
                expect(result.range).to(equal(NSRange(location: 26, length: 1)))
                expect(result.foundString).to(equal("@"))
            }
        }
    }
}
