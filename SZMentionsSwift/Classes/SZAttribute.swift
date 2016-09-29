//
//  SZAttribute.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit

open class SZAttribute: NSObject {
    /**
     @brief Name of the attribute to set on a string
     */
    var attributeName: String

    /**
     @brief Value of the attribute to set on a string
     */
    var attributeValue: NSObject

    /**
     @brief initializer for creating an attribute
     @param attributeName: the name of the attribute (example: NSForegroundColorAttributeName)
     @param attributeValue: the value for the given attribute (example: UIColor.redColor)
     */
    public init(attributeName: String, attributeValue: NSObject) {
        self.attributeName = attributeName
        self.attributeValue = attributeValue
    }
}
