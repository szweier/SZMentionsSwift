internal class SZVerifier {
    static let attributeConsistencyError = "Default and mention attributes must contain the same attribute names: If default attributes specify NSForegroundColorAttributeName mention attributes must specify that same name as well. (Values do not need to match)"

    static func verifySetup(withDefaultTextAttributes defaultTextAttributes: [AttributeContainer],
                            mentionTextAttributes: [AttributeContainer]) {
        assert(attributesSetCorrectly(mentionTextAttributes,
                                      defaultAttributes: defaultTextAttributes), attributeConsistencyError)
    }

    /**
     @brief Checks that attributes have existing counterparts for mentions and default
     @param mentionAttributes: The attributes to apply to mention objects
     @param defaultAttributes: The attributes to apply to default text
     */
    private static func attributesSetCorrectly(_ mentionAttributes: [AttributeContainer],
                                defaultAttributes: [AttributeContainer]) -> Bool {
        let attributeNamesToLoop = (defaultAttributes.count >= mentionAttributes.count) ?
            defaultAttributes.map({$0.attributeName}) :
            mentionAttributes.map({$0.attributeName})

        let attributeNamesToCompare = (defaultAttributes.count < mentionAttributes.count) ?
            defaultAttributes.map({$0.attributeName}) :
            mentionAttributes.map({$0.attributeName})

        var attributeHasMatch = true

        for attributeName in attributeNamesToLoop {
            attributeHasMatch = attributeNamesToCompare.contains(attributeName)

            if !attributeHasMatch { break }
        }

        return attributeHasMatch
    }
}
