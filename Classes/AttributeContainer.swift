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
    var name: NSAttributedString.Key { get }

    /**
     @brief Value of the attribute to set on a string
     */
    var value: Any { get }
}

internal extension Array where Element == AttributeContainer {
    var dictionary: [NSAttributedString.Key: Any] {
        return Dictionary(uniqueKeysWithValues: compactMap { ($0.name, $0.value) })
    }
}
