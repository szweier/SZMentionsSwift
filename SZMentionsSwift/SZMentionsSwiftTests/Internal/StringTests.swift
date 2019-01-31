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

            it("Should return true for isMentionEnabledAt when the trigger is preceeded by a space") {
                let stringToSearch = "This is @search"
                expect(stringToSearch.isMentionEnabledAt(8).0).to(beTrue())
            }

            it("Should return true for isMentionEnabledAt when the trigger is preceeded by a \n") {
                let stringToSearch = "This is\n@search"
                expect(stringToSearch.isMentionEnabledAt(8).0).to(beTrue())
            }

            it("Should return true for isMentionEnabledAt when the trigger is not preceeded by \n nor a space") {
                let stringToSearch = "This is@search"
                expect(stringToSearch.isMentionEnabledAt(7).0).to(beFalse())
            }
        }
    }
}
