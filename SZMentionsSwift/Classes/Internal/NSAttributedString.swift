//
//  NSAttributedString.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 12/4/18.
//  Copyright © 2018 Steven Zweier. All rights reserved.
//

import UIKit

internal extension NSAttributedString {
    var mutableAttributedText: NSMutableAttributedString {
        return mutableCopy() as! NSMutableAttributedString
    }
}

/**
 @brief Applies attributes to a given string and range
 @param attributes: the attributes to apply
 @param range: the range to apply the attributes to
 */
internal func apply(_ attributes: [AttributeContainer], range: NSRange) -> (NSAttributedString) -> NSAttributedString {
    return { string in
        let attributedText = string.mutableAttributedText
        attributedText.addAttributes(attributes.dictionary, range: range)

        return attributedText
    }
}

/**
 @brief Inserts existing mentions into the text view
 @param mentions: mentions to add along with the position to add them
 @param attributes: function to determine the attributes to apply to a specific mention
 */
internal func insert(_ mentions: [(CreateMention, NSRange)],
                     with attributes: @escaping (CreateMention?) -> [AttributeContainer]) -> (NSAttributedString) -> NSAttributedString {
    return { string in
        var attributedText = string
        mentions.forEach { createMention, range in
            assert(range.location != NSNotFound,
                   "Mention must have a range to insert into")
            assert(NSMaxRange(range) <= attributedText.string.utf16.count,
                   "Mention range is out of bounds for the text length")

            attributedText = attributedText |> apply(attributes(createMention), range: range)
        }

        return attributedText
    }
}

/**
 @brief Updates the text view by making adjustments to the characters within a given range
 @param range: The range of characters to replace
 @param text: The text to replace the characters with
 */
internal func replace(charactersIn range: NSRange, with text: String) -> (NSAttributedString) -> NSAttributedString {
    return { string in
        let attributedText = string.mutableAttributedText
        attributedText.mutableString.replaceCharacters(in: range, with: text)

        return attributedText
    }
}

/**
 @brief Adds a mentions into the text view
 @param mention: The mention to add
 @param spaceAfterMention: Whether or not to add a space after the mention
 @param range: The position to add the mention to
 @param attributes: Function to determine the attributes to apply to a specific mention
 */
internal func add(_ mention: CreateMention,
                  spaceAfterMention: Bool,
                  at range: NSRange,
                  with attributes: @escaping (CreateMention?) -> [AttributeContainer]) -> (NSAttributedString) -> NSAttributedString {
    return { string in
        var attributedText = string
        let adjustedRange = range.adjustLength(for: mention.name)
        attributedText = attributedText
            |> replace(charactersIn: range, with: mention.mentionName(with: spaceAfterMention))
            >>> insert([(mention, adjustedRange)], with: attributes)

        return attributedText
    }
}
