//
//  SZMentionHelper.swift
//  SZMentionsSwift
//
//  Created by Steve Zweier on 2/1/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import Foundation

class SZMentionHelper {
    /**
     @brief Determines what mentions exist after a given range
     @param range: the range where text was changed
     @param mentionsList: the list of current mentions
     @return [SZMention]: list of mentions that exist after the provided range
     */
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

    /**
     @brief adjusts the positioning of mentions that exist after the range where text was edited
     @param range: the range where text was changed
     @param text: the text that was changed
     @param mentions: the list of current mentions
     */
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

    /**
     @brief Determines whether or not a mention exists at a specific location
     @param index: the location to check
     @param mentions: the list of current mentions
     @return Bool: Whether or not a mention exists at a specific location
     */
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

    /**
     @brief Determine whether or not we need to change the color back to default attributes
     @param textView: the mentions text view
     @param range: the current selection in the text view
     @param mentions: the list of current mentions
     @return Bool: whether or not we need to change back to default attributes
     */
    class func needsToChangeToDefaultAttributes(textView: UITextView, range: NSRange, mentions: [SZMention]) -> Bool {
        let isAheadOfMention = range.location > 0 &&
            SZMentionHelper.mentionExistsAt(range.location - 1, mentions: mentions)
        let isAtStartOfTextViewAndIsTouchingMention = range.location == 0 &&
            SZMentionHelper.mentionExistsAt(range.location + 1, mentions: mentions)

        return isAheadOfMention || isAtStartOfTextViewAndIsTouchingMention
    }

    /**
     @brief Uses the text being entered into the view to determine whether or not we should hide the mentions list
     @param text: the text being entered
     @return Bool: whether or not we should hide the mentions list.
     */
    class func shouldHideMentions(text: String) -> Bool {
        return (text == " " || (text.characters.count > 0 && text.characters.last! == " "))
    }
}
