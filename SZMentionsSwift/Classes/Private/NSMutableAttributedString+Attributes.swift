//
//  SZAttributedStringHelper.swift
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
        attributes.forEach { attribute in
            addAttribute(NSAttributedStringKey(rawValue: attribute.name),
                         value: attribute.value,
                         range: range)
        }
    }
}
