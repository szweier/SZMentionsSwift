//
//  UITextView.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 12/4/18.
//  Copyright © 2018 Steven Zweier. All rights reserved.
//

import UIKit

internal extension UITextView {
    var mutableAttributedString: NSMutableAttributedString? {
        return attributedText.mutableCopy() as? NSMutableAttributedString
    }

    /**
     @brief Reset typingAttributes for textView
     @param defaultAttributes: Attributes to reset to
     */
    func resetTypingAttributes(to defaultAttributes: [AttributeContainer]) {
        var attributes = [NSAttributedString.Key: Any]()
        for attribute in defaultAttributes {
            attributes[attribute.name] = attribute.value
        }
        typingAttributes = attributes
    }

    /**
     @brief Resets the empty text view
     @param textView: the text view to reset
     */
    func reset(to defaultAttributes: [AttributeContainer]) {
        resetTypingAttributes(to: defaultAttributes)
        text = " "
        apply(defaultAttributes, range: NSRange(location: 0, length: 1))
        text = ""
    }

    /**
     @brief Applies attributes to a given string and range
     @param attributes: the attributes to apply
     @param range: the range to apply the attributes to
     */
    func apply(_ attributes: [AttributeContainer], range: NSRange) {
        let keysAndValues = attributes.compactMap { ($0.name, $0.value) }
        let newMutableAttributedString = mutableAttributedString
        newMutableAttributedString?.addAttributes(Dictionary(uniqueKeysWithValues: keysAndValues), range: range)
        attributedText = newMutableAttributedString
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
            assert(NSMaxRange(range) <= attributedText.string.utf16.count,
                   "Mention range is out of bounds for the text length")

            apply(attributes(createMention), range: range)
        }
    }

    func replace(charactersIn range: NSRange, with text: String) {
        let newMutableAttributedString = mutableAttributedString
        newMutableAttributedString?.mutableString.replaceCharacters(in: range, with: text)
        attributedText = newMutableAttributedString
    }
}
