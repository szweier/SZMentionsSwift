//
//  SZMention.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit

public struct SZMention: Equatable {
    /**
     @brief The location of the mention within the attributed string of the UITextView
     */
    public internal(set) var range: NSRange

    /**
     @brief Contains a reference to the object sent to the addMention: method
     */
    public private(set) var object: CreateMention

    public static func == (lhs: SZMention, rhs: SZMention) -> Bool {
        return lhs.range == rhs.range && lhs.object.name == rhs.object.name && lhs.object.range == rhs.object.range
    }
}
