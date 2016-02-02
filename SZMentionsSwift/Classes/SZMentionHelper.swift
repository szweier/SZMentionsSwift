//
//  SZMentionHelper.swift
//  SZMentionsSwift
//
//  Created by Steve Zweier on 2/1/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import Foundation

class SZMentionHelper {
    class func mentionsAfterTextEntry(range: NSRange, mentionsList: [SZMention]) -> [SZMention] {
        var mentionsAfterTextEntry = [SZMention]()
        
        for mention in mentionsList {
            
            if range.location + range.length <= mention.mentionRange.location {
                mentionsAfterTextEntry.append(mention)
            }
        }
        
        let immutableMentionsAfterTextEntry = mentionsAfterTextEntry
        
        return immutableMentionsAfterTextEntry
    }
    
    class func adjustMentions(range : NSRange, text : String, mentions: [SZMention]) {
        for mention in SZMentionHelper.mentionsAfterTextEntry(range, mentionsList: mentions)
        {
            
            var rangeAdjustment = -(range.length > 0 ? range.length : 0)
            
            if text.characters.count > 0 {
                rangeAdjustment = text.characters.count - (range.length > 0 ? range.length : 0)
            }
            mention.mentionRange = NSRange.init(
                location: mention.mentionRange.location + rangeAdjustment,
                length: mention.mentionRange.length)
        }
    }
    
    class func mentionExistsAt(index: NSInteger, mentions: [SZMention]) -> Bool {
        
        let mentionsList = mentions.filter {
            if let range = ($0 as SZMention).mentionRange as NSRange! {
                return index >= range.location && index < range.location + range.length
            } else {
                return false
            }
        }
        
        return mentionsList.count > 0
    }
    
    class func needsToChangeToDefaultColor(textView: UITextView, range: NSRange, mentions: [SZMention]) -> Bool {
        let isAheadOfMention = range.location > 0 &&
            SZMentionHelper.mentionExistsAt(range.location - 1, mentions: mentions)
        let isAtStartOfTextViewAndIsTouchingMention = range.location == 0 &&
            SZMentionHelper.mentionExistsAt(range.location + 1, mentions: mentions)
        
        return isAheadOfMention || isAtStartOfTextViewAndIsTouchingMention
    }
    
    class func shouldHideMentions(text: String) -> Bool {
        return (text == " " || (text.characters.count > 0 && text.characters.last! == " "))
    }
}
