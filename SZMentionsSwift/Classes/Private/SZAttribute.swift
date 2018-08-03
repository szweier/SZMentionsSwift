//
//  SZAttribute.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 9/21/17.
//  Copyright © 2017 Steven Zweier. All rights reserved.
//

import Foundation

public struct SZAttribute: AttributeContainer {
    /**
     @brief Name of the attribute to set on a string
     */
    public var attributeName: String
    
    /**
     @brief Value of the attribute to set on a string
     */
    public var attributeValue: NSObject
}
