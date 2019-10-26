@testable import SZMentionsSwift
import XCTest

private final class AttributeContainerTests: XCTestCase {
    func test_shouldBeGeneratedFromAnArrayOfAttributeContainers() {
        let actual = [
            Attribute(name: .backgroundColor, value: UIColor.red) as AttributeContainer,
            Attribute(name: .foregroundColor, value: UIColor.blue) as AttributeContainer,
        ].dictionary as! [NSAttributedString.Key: UIColor]
        let expected: [NSAttributedString.Key: UIColor] = [NSAttributedString.Key.backgroundColor: UIColor.red,
                                                           NSAttributedString.Key.foregroundColor: UIColor.blue]

        XCTAssertEqual(actual, expected)
    }
}
