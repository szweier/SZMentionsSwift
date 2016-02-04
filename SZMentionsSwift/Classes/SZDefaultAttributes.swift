//
//  SZDefaultAttributes.swift
//  SZMentionsSwift
//
//  Created by Steve Zweier on 2/1/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import Foundation

class SZDefaultAttributes {
    /**
     @brief Default color
     */
    class var defaultColor: SZAttribute {
        return SZAttribute.init(
            attributeName: NSForegroundColorAttributeName,
            attributeValue: UIColor.greenColor())
    }
    
    /**
     @brief Mention color
     */
    class var mentionColor: SZAttribute {
        return SZAttribute.init(
            attributeName: NSForegroundColorAttributeName,
            attributeValue: UIColor.greenColor())
    }
    
    class func defaultTextAttributes() -> [SZAttribute]
    {
        return [defaultColor];
    }
    
    class func defaultMentionAttributes() -> [SZAttribute]
    {
        return [mentionColor];
    }
}