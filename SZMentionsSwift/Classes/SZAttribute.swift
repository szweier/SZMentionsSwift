//
//  SZAttribute.swift
//  SZMentions_Swift
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit

public class SZAttribute: NSObject {
    /**
     @brief Name of the attribute to set on a string
     */
    var attributeName: String

    /**
     @brief Value of the attribute to set on a string
     */
    var attributeValue: NSObject

    public init(attributeName: String, attributeValue: NSObject) {
        self.attributeName = attributeName
        self.attributeValue = attributeValue
    }
}
