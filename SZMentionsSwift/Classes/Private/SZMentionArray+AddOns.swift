//
//  SZMentionHelper.swift
//  SZMentionsSwift
//
//  Created by Steve Zweier on 2/1/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

internal extension Array where Element: SZMention {
    /**
     @brief returns the mention being edited (if a mention is being edited)
     @param range: the range to look for a mention
     @return SZMention?: the mention being edited (if one exists)
     */
    func mentionBeingEdited(atRange range: NSRange) -> SZMention? {
        return filter{ NSIntersectionRange(range, $0.mentionRange).location > 0 && range.location != $0.mentionRange.location }.first
    }

    /**
     @brief adjusts the positioning of mentions that exist after the range where text was edited
     @param range: the range where text was changed
     @param text: the text that was changed
     @param mentions: the list of current mentions
     */
    func adjustMentions(forTextChangeAtRange range: NSRange, text: String) {
        let rangeAdjustment = text.utf16.count - range.length
        mentionsAfterTextEntry(range).forEach { mention in
            mention.mentionRange = NSRange(
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
    func mentionExistsAt(_ index: NSInteger) -> Bool {
        let mentionsList = filter{ index >= $0.mentionRange.location && index < $0.mentionRange.location + $0.mentionRange.length }

        return mentionsList.count > 0
    }

    /**
     @brief Determines what mentions exist after a given range
     @param range: the range where text was changed
     @param mentionsList: the list of current mentions
     @return [SZMention]: list of mentions that exist after the provided range
     */
    private func mentionsAfterTextEntry(_ range: NSRange) -> [SZMention] {
        return filter{ $0.mentionRange.location >= range.location + range.length }
    }
}
