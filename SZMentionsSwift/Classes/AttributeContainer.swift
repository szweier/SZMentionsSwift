//
//  AttributeContainer.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit

public protocol AttributeContainer {
    /**
     @brief Name of the attribute to set on a string
     */
    var attributeName: String { get }
    
    /**
     @brief Value of the attribute to set on a string
     */
    var attributeValue: NSObject { get }
}
