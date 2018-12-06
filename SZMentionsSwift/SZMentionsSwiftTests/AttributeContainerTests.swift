import Nimble
import Quick
@testable import SZMentionsSwift

class AttributeContainerTests: QuickSpec {
    override func spec() {
        describe("Dictionary") {
            it("Should be generated from an array of AttributeContainers") {
                let actual = [
                    Attribute(name: .backgroundColor, value: UIColor.red) as AttributeContainer,
                    Attribute(name: .foregroundColor, value: UIColor.blue) as AttributeContainer,
                ].dictionary as! [NSAttributedString.Key: UIColor]
                let expected: [NSAttributedString.Key: UIColor] = [NSAttributedString.Key.backgroundColor: UIColor.red,
                                                                   NSAttributedString.Key.foregroundColor: UIColor.blue]

                expect(actual).to(equal(expected))
            }
        }
    }
}
