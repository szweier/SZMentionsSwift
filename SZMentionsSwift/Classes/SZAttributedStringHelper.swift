//
//  SZAttributedStringHelper.swift
//  SZMentionsSwift
//
//  Created by Steve Zweier on 2/1/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import Foundation

class SZAttributedStringHelper {
    class func apply(attributes: [SZAttribute], range: NSRange, mutableAttributedString: NSMutableAttributedString) {
        for attribute in attributes {
            mutableAttributedString.addAttribute(
                attribute.attributeName,
                value: attribute.attributeValue,
                range: range)
        }
    }
}