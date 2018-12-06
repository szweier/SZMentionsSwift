//
//  NSAttributedString.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 12/4/18.
//  Copyright © 2018 Steven Zweier. All rights reserved.
//

import UIKit

extension NSAttributedString {
    internal var mutableAttributedText: NSMutableAttributedString {
        return mutableCopy() as! NSMutableAttributedString
    }
}

/**
 @brief Applies attributes to a given string and range
 @param attributes: the attributes to apply
 @param range: the range to apply the attributes to
 */
func apply(_ attributes: [AttributeContainer], range: NSRange) -> (inout NSAttributedString) -> Void {
    return { string in
        let attributedText = string.mutableAttributedText
        attributedText.addAttributes(attributes.dictionary, range: range)

        string = attributedText
    }
}

/**
 @brief Inserts existing mentions into the text view
 @param mentions: mentions to add along with the position to add them
 @param attributes: function to determine the attributes to apply to a specific mention
 */
func insert(_ mentions: [(CreateMention, NSRange)],
            with attributes: @escaping (CreateMention?) -> [AttributeContainer]) -> (inout NSAttributedString) -> Void {
    return { string in
        var attributedText = string
        mentions.forEach { createMention, range in
            assert(range.location != NSNotFound,
                   "Mention must have a range to insert into")
            assert(NSMaxRange(range) <= attributedText.string.utf16.count,
                   "Mention range is out of bounds for the text length")

            attributedText |> apply(attributes(createMention), range: range)
        }
        string = attributedText
    }
}

/**
 @brief Updates the text view by making adjustments to the characters within a given range
 @param range: The range of characters to replace
 @param text: The text to replace the characters with
 */
func replace(charactersIn range: NSRange, with text: String) -> (inout NSAttributedString) -> NSRange {
    return { string in
        let attributedText = string.mutableAttributedText
        attributedText.mutableString.replaceCharacters(in: range, with: text)
        string = attributedText

        return NSRange(location: range.location + text.utf16.count, length: 0)
    }
}

/**
 @brief Adds a mentions into the text view
 @param mention: The mention to add
 @param spaceAfterMention: Whether or not to add a space after the mention
 @param range: The position to add the mention to
 @param attributes: Function to determine the attributes to apply to a specific mention
 */
func add(_ mention: CreateMention,
         spaceAfterMention: Bool,
         at range: NSRange,
         with attributes: @escaping (CreateMention?) -> [AttributeContainer]) -> (inout NSAttributedString) -> NSRange {
    return { string in
        var attributedText = string
        _ = attributedText |> replace(charactersIn: range, with: mention.mentionName(with: spaceAfterMention))

        let adjustedRange = range.adjustLength(for: mention.name)
        attributedText |> insert([(mention, adjustedRange)], with: attributes)

        string = attributedText

        return NSRange(location: NSMaxRange(adjustedRange) + (spaceAfterMention ? 1 : 0),
                       length: 0)
    }
}
