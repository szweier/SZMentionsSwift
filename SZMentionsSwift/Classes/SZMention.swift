//
//  SZMention.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit

public class SZMention: Equatable {
    /**
     @brief The location of the mention within the attributed string of the UITextView
     */
    public internal(set) var mentionRange: NSRange

    /**
     @brief Contains a reference to the object sent to the addMention: method
     */
    public private(set) var mentionObject: CreateMention

    /**
     @brief initializer for creating a mention object
     @param mentionRange: the range of the mention
     @param mentionObject: the object of your mention (assuming you get extra data you need to store and retrieve later)
     */
    public init(mentionRange: NSRange, mentionObject: CreateMention) {
        self.mentionRange = mentionRange
        self.mentionObject = mentionObject
    }

    public static func ==(lhs: SZMention, rhs: SZMention) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
