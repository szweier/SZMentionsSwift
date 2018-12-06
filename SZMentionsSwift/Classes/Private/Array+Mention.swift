//
//  Array+Mention.swift
//  SZMentionsSwift
//
//  Created by Steve Zweier on 2/1/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//
import UIKit

internal extension Array where Element == Mention {
    /**
     @brief returns the mention being edited (if a mention is being edited)
     @param range: the range to look for a mention
     @return Mention?: the mention being edited (if one exists)
     */
    func mentionBeingEdited(at range: NSRange) -> Mention? {
        return first {
            NSIntersectionRange(range, $0.range).length > 0 ||
                NSMaxRange(range) > $0.range.location &&
                NSMaxRange(range) < NSMaxRange($0.range)
        }
    }

    /**
     @brief adjusts the positioning of mentions that exist after the range where text was edited
     @param range: the range where text was changed
     @param text: the text that was changed

     @return [Mention]: A new mention array
     */
    func adjusted(forTextChangeAt range: NSRange, text: String) -> [Mention] {
        let remainingLengthOfMention = text.utf16.count - range.length
        return compactMap { mention in
            guard mention.range.location >= NSMaxRange(range) else { return mention }
            var adjustedMention = mention
            adjustedMention.range.location += remainingLengthOfMention

            return adjustedMention
        }
    }

    /**
     @brief inserts mentions into the mentions array
     @param mentions: the mentions to add along with the position to add them in

     @return [Mention]: A new mention array
     */
    func insert(_ mentions: [(CreateMention, NSRange)]) -> [Mention] {
        return self + mentions.map { createMention, range in
            Mention(range: range, object: createMention)
        }
    }

    /**
     @brief removes mentions from the mentions array
     @param mentions: the mentions to remove

     @return [Mention]: A new mention array
     */
    func remove(_ mentions: [Mention]) -> [Mention] {
        return filter { !mentions.contains($0) }
    }

    /**
     @brief adds mentions into the mentions array
     @param mentions: the mentions to add along with the position to add them in

     @return [Mention]: A new mention array
     */
    func add(_ mention: CreateMention, spaceAfterMention: Bool, at range: NSRange) -> [Mention] {
        let adjustedRange = range.adjustLength(for: mention.name)
        return adjusted(forTextChangeAt: range,
                        text: mention.mentionName(with: spaceAfterMention))
            .insert([(mention, adjustedRange)])
    }
}
