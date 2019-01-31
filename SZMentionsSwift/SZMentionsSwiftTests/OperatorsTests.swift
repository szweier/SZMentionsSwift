import Nimble
import Quick
@testable import SZMentionsSwift

class OperatorsTests: QuickSpec {
    override func spec() {
        func addOne(_ x: Int) -> Int {
            return x + 1
        }

        func addOneOptional(_ x: Int) -> Int? {
            guard x % 2 == 0 else { return nil }
            return x + 1
        }

        func double(_ x: Int) -> Int {
            return x * 2
        }

        describe("Operator") {
            it("Should be able to call a function using forward applicator") {
                expect(2 |> addOne).to(equal(3))
            }

            it("Should be able to call a function using forward applicator and forward composition") {
                expect(2 |> addOne >>> double).to(equal(6))
            }

            it("Should be able to call a function using fish operator and fail early") {
                expect(2 |> addOneOptional >=> double).to(equal(6))
            }

            it("Should be able to call a function using fish operator and succeed") {
                expect(1 |> addOneOptional >=> double).to(beNil())
            }
        }
    }
}
