import Nimble
import Quick
@testable import SZMentionsSwift

class OperatorsTests: QuickSpec {
    override func spec() {
        describe("ForwardApplicator") {
            it("Should run the given function on the input") {
                func addOne(_ x: Int) -> Int {
                    return x + 1
                }
                expect(2 |> addOne).to(equal(3))
            }

            it("Should run the given function on the inout input") {
                func addOne(_ x: inout Int) {
                    x = x + 1
                }
                var val = 2
                val |> addOne
                expect(val).to(equal(3))
            }

            it("Should run the given function on the inout input and return a value") {
                func addOne(_ x: inout Int) -> Bool {
                    x = x + 1
                    return true
                }
                var val = 2
                let didSucceed = val |> addOne
                expect(val).to(equal(3))
                expect(didSucceed).to(beTrue())
            }
        }
    }
}
