//
//  Attribute.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 9/21/17.
//  Copyright © 2017 Steven Zweier. All rights reserved.
//

import Foundation

internal struct Attribute: AttributeContainer {
    /**
     @brief Name of the attribute to set on a string
     */
    var name: NSAttributedString.Key

    /**
     @brief Value of the attribute to set on a string
     */
    var value: Any
}
