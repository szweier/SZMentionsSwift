//
//  Verifier.swift
//  SZMentionsSwift
//
//  Created by Steve Zweier on 2/1/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

internal class Verifier {
    static let attributeConsistencyError = "Default and mention attributes must contain the same attribute names: If default attributes specify NSForegroundColorAttributeName mention attributes must specify that same name as well. (Values do not need to match)"

    static func verifySetup(withDefaultTextAttributes defaultTextAttributes: [AttributeContainer],
                            mentionTextAttributes: [AttributeContainer]) {
        let sortedMentionAttributes = mentionTextAttributes.sorted(by: { $0.name.rawValue > $1.name.rawValue })
        let sortedAttributes = defaultTextAttributes.sorted(by: { $0.name.rawValue > $1.name.rawValue })
        let attributesMatch = sortedMentionAttributes.elementsEqual(sortedAttributes) {
            (mentionAttribute, defaultAttribute) -> Bool in
            mentionAttribute.name == defaultAttribute.name
        }
        assert(attributesMatch, attributeConsistencyError)
    }
}
