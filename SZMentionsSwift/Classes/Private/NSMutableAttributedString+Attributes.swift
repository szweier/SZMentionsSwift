//
//  NSMutableAttributedString+Attributes.swift
//  SZMentionsSwift
//
//  Created by Steve Zweier on 2/1/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

internal extension NSMutableAttributedString {
    /**
     @brief Applies attributes to a given string and range
     @param attributes: the attributes to apply
     @param range: the range to apply the attributes to
     */
    func apply(_ attributes: [AttributeContainer], range: NSRange) {
        let keysAndValues = attributes.compactMap { ($0.name, $0.value) }
        addAttributes(Dictionary(uniqueKeysWithValues: keysAndValues), range: range)
    }

    /**
     @brief Applies mention attributes to specified ranges
     @param mentions: mentions to add along with the position to add them
     @param attributes: function to determine the attributes to apply to a specific mention
     */
    func insertMentions(_ mentions: [(CreateMention, NSRange)],
                        with attributes: (CreateMention?) -> [AttributeContainer]) {
        mentions.forEach { createMention, range in
            assert(range.location != NSNotFound, "Mention must have a range to insert into")
            assert(NSMaxRange(range) <= string.utf16.count,
                   "Mention range is out of bounds for the text length")

            apply(attributes(createMention), range: range)
        }
    }
}
