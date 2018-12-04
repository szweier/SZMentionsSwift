//
//  Array+Mention.swift
//  SZMentionsSwift
//
//  Created by Steve Zweier on 2/1/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

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
     */
    func adjustMentions(forTextChangeAt range: NSRange, text: String) -> [Mention] {
        let rangeAdjustment = text.utf16.count - range.length
        return compactMap { mention in
            guard mention.range.location >= NSMaxRange(range) else { return mention }
            var adjustedMention = mention
            adjustedMention.range.location += rangeAdjustment

            return adjustedMention
        }
    }

    /**
     @brief inserts mentions into the mentions array
     @param mentions: the mentions to add along with the position to add them in
     */
    func insert(_ mentions: [(CreateMention, NSRange)]) -> [Mention] {
        return self + mentions.compactMap { createMention, range in
            assert(range.location != NSNotFound, "Mention must have a range to insert into")

            return Mention(range: range, object: createMention)
        }
    }

    /**
     @brief inserts mentions into the mentions array
     @param mentions: the mentions to add along with the position to add them in
     */
    func remove(_ mentions: [Mention]) -> [Mention] {
        return filter { !mentions.contains($0) }
    }

    func add(_ mention: CreateMention, spaceAfterMention: Bool, at range: NSRange) -> [Mention] {
        let adjustedRange = range.adjusted(for: mention.name)
        return adjustMentions(forTextChangeAt: range,
                              text: mention.mentionName(with: spaceAfterMention))
            .insert([(mention, adjustedRange)])
    }
}
