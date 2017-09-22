//
//  SZAttribute.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 9/21/17.
//  Copyright © 2017 Steven Zweier. All rights reserved.
//

import Foundation

public class SZAttribute: AttributeContainer {
    /**
     @brief Name of the attribute to set on a string
     */
    public var attributeName: String
    
    /**
     @brief Value of the attribute to set on a string
     */
    public var attributeValue: NSObject
    
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
