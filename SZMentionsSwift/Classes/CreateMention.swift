//
//  CreateMention.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 9/21/17.
//  Copyright © 2017 Steven Zweier. All rights reserved.
//

import UIKit

public protocol CreateMention {
    /**
     @brief The name of the mention to be added to the UITextView when selected.
     */
    var mentionName: String { get }
    
    /**
     @brief The range to place the mention at
     */
    var mentionRange: NSRange { get }
}
