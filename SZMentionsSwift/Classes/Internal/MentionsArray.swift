//
//  Array+Mention.swift
//  SZMentionsSwift
//
//  Created by Steve Zweier on 2/1/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//
import UIKit

/**
 @brief returns the mention being edited (if a mention is being edited)
 @param range: the range to look for a mention

 @return Mention?: the mention being edited (if one exists)
 */
internal func mentionBeingEdited(at range: NSRange) -> ([Mention]) -> Mention? {
    return { mentions in
        mentions.first {
            NSIntersectionRange(range, $0.range).length > 0 ||
                NSMaxRange(range) > $0.range.location &&
                NSMaxRange(range) < NSMaxRange($0.range)
        }
    }
}

/**
 @brief adjusts the positioning of mentions that exist after the range where text was edited
 @param range: the range where text was changed
 @param text: the text that was changed

 @return [Mention]: A new mention array
 */
internal func adjusted(forTextChangeAt range: NSRange, text: String) -> ([Mention]) -> [Mention] {
    return { mentions in
        let remainingLengthOfMention = text.utf16.count - range.length

        return mentions.map { mention in
            guard mention.range.location >= NSMaxRange(range) else { return mention }
            var adjustedMention = mention
            adjustedMention.range.location += remainingLengthOfMention

            return adjustedMention
        }
    }
}

/**
 @brief inserts mentions into the mentions array
 @param mentions: the mentions to add along with the position to add them in

 @return [Mention]: A new mention array
 */
internal func insert(_ newMentions: [(CreateMention, NSRange)]) -> ([Mention]) -> [Mention] {
    return { mentions in
        mentions + newMentions.map { createMention, range in
            Mention(range: range, object: createMention)
        }
    }
}

/**
 @brief removes mentions from the mentions array
 @param mentions: the mentions to remove

 @return [Mention]: A new mention array
 */
internal func remove(_ mentionsToRemove: [Mention]) -> ([Mention]) -> [Mention] {
    return { mentions in
        mentions.filter { !mentionsToRemove.contains($0) }
    }
}

/**
 @brief adds mentions into the mentions array
 @param mentions: the mentions to add along with the position to add them in

 @return [Mention]: A new mention array
 */
internal func add(_ mention: CreateMention, spaceAfterMention: Bool, at range: NSRange) -> ([Mention]) -> [Mention] {
    return { mentions in
        let adjustedRange = range.adjustLength(for: mention.name)
        return mentions
            |> adjusted(forTextChangeAt: range, text: mention.mentionName(with: spaceAfterMention))
            >>> insert([(mention, adjustedRange)])
    }
}
