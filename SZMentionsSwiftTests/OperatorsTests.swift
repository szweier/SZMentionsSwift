@testable import SZMentionsSwift
import XCTest

private final class OperatorTests: XCTestCase {
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

    func test_shouldBeAbleToCallAFunctionUsingForwardApplicator() {
        XCTAssertEqual(2 |> addOne, 3)
    }

    func test_shouldBeAbleToCallAFunctionUsingForwardApplicatorAndForwardComposition() {
        XCTAssertEqual(2 |> addOne >>> double, 6)
    }

    func test_shouldBeAbleToCallAFunctionUsingFishOperatorAndFailEarly() {
        XCTAssertEqual(2 |> addOneOptional >=> double, 6)
    }

    func test_shouldBeAbleToCallAFunctionUsingFishOperatorAndSucceed() {
        XCTAssertNil(1 |> addOneOptional >=> double)
    }
}
