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
        let keysAndValues = attributes.compactMap { (NSAttributedStringKey(rawValue: $0.name), $0.value) }
        addAttributes(Dictionary(uniqueKeysWithValues: keysAndValues), range: range)
    }
}
