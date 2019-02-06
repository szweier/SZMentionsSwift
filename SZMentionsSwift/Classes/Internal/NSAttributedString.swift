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

 @return (NSAttributedString, NSRange): The updated string and the new selected range
 */
internal func apply(_ attributes: [AttributeContainer],
                    range: NSRange) -> (NSAttributedString)
    -> (NSAttributedString, NSRange) {
    return { string in
        assert(range.location != NSNotFound,
               "Mention must have a range to insert into")
        assert(NSMaxRange(range) <= string.string.utf16.count,
               "Mention range is out of bounds for the text length")
        let attributedText = string.mutableAttributedText
        attributedText.addAttributes(attributes.dictionary, range: range)

        return (attributedText, NSRange(location: NSMaxRange(range), length: 0))
    }
}

/**
 @brief Applies attributes to existing mentions into the text view
 @param attributes: function to determine the attributes to apply to a specific mention
 @param mentions: mentions to add along with the position to add them

 @return (NSAttributedString, NSRange): The updated string and the new selected range
 */
internal func apply(attributes: @escaping (CreateMention?) -> [AttributeContainer],
                    to mentions: [(CreateMention, NSRange)])
    -> (NSAttributedString) -> (NSAttributedString, NSRange) {
    return { string in
        var selectedRange: NSRange = NSRange(location: NSNotFound, length: 0)
        var attributedText = string
        mentions.forEach { createMention, range in
            (attributedText, selectedRange) = attributedText |> apply(attributes(createMention), range: range)
        }

        return (attributedText, selectedRange)
    }
}

/**
 @brief Updates the text view by making adjustments to the characters within a given range
 @param range: The range of characters to replace
 @param text: The text to replace the characters with

 @return (NSAttributedString, NSRange): The updated string and the new selected range
 */
internal func replace(charactersIn range: NSRange,
                      with text: String) -> (NSAttributedString) -> (NSAttributedString, NSRange) {
    return { string in
        let attributedText = string.mutableAttributedText
        attributedText.mutableString.replaceCharacters(in: range, with: text)
        let selectedRange = NSRange(location: range.location + text.utf16.count, length: 0)

        return (attributedText, selectedRange)
    }
}

/**
 @brief Adds a mentions into the text view
 @param mention: The mention to add
 @param spaceAfterMention: Whether or not to add a space after the mention
 @param range: The position to add the mention to
 @param attributes: Function to determine the attributes to apply to a specific mention

 @return (NSAttributedString, NSRange): The updated string and the new selected range
 */
internal func add(_ mention: CreateMention,
                  spaceAfterMention: Bool,
                  at range: NSRange,
                  with attributes: @escaping (CreateMention?) -> [AttributeContainer])
    -> (NSAttributedString) -> (NSAttributedString, NSRange) {
    return { string in
        var attributedText = string
        let adjustedRange = range.adjustLength(for: mention.name)
        var selectedRange: NSRange
        (attributedText, selectedRange) = attributedText
            |> replace(charactersIn: range, with: mention.mentionName(with: spaceAfterMention))
            >=> apply(attributes(mention), range: adjustedRange)

        return (attributedText, NSRange(location: selectedRange.location + (spaceAfterMention ? 1 : 0), length: selectedRange.length))
    }
}
