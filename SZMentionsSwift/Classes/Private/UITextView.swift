//
//  UITextView.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 12/4/18.
//  Copyright © 2018 Steven Zweier. All rights reserved.
//

import UIKit

extension UITextView {
    internal var mutableAttributedString: NSMutableAttributedString? {
        return attributedText.mutableCopy() as? NSMutableAttributedString
    }

    /**
     @brief Reset typingAttributes for textView
     @param defaultAttributes: Attributes to reset to
     */
    internal func resetTypingAttributes(to defaultAttributes: [AttributeContainer]) {
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
    internal func reset(to defaultAttributes: [AttributeContainer]) {
        resetTypingAttributes(to: defaultAttributes)
        text = " "
        if let mutableAttributedString = mutableAttributedString {
            mutableAttributedString.apply(defaultAttributes, range: NSRange(location: 0, length: 1))
            attributedText = mutableAttributedString
        }
        text = ""
    }
}
