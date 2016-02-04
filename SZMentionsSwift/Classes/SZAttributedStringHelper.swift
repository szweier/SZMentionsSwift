//
//  SZAttributedStringHelper.swift
//  SZMentionsSwift
//
//  Created by Steve Zweier on 2/1/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import Foundation

class SZAttributedStringHelper {
    /** 
     @brief Applies attributes to a given string and range
     @param attributes: the attributes to apply
     @param range: the range to apply the attributes to
     @param mutableAttributedString: the string to apply the attributes to
     */
    class func apply(attributes: [SZAttribute], range: NSRange,
        mutableAttributedString: NSMutableAttributedString) {
        for attribute in attributes {
            mutableAttributedString.addAttribute(
                attribute.attributeName,
                value: attribute.attributeValue,
                range: range)
        }
    }
}