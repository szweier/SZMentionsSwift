//
//  SZMention.swift
//  SZMentions_Swift
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit

public class SZMention: NSObject {
    /**
     @brief The location of the mention within the attributed string of the UITextView
     */
    var mentionRange: NSRange
    
    /**
     @brief Contains a reference to the object sent to the addMention: method
     */
    var mentionObject: SZCreateMentionProtocol

    init(mentionRange: NSRange, mentionObject: SZCreateMentionProtocol) {
        self.mentionRange = mentionRange;
        self.mentionObject = mentionObject;
    }
}
