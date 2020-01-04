//
//  MentionListener.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit

public class MentionListener: NSObject {
    /**
     @brief Array list of mentions managed by listener, accessible via the
     public mentions property.
     */
    public private(set) var mentions: [Mention] = []

    /**
     @brief An optional delegate that can be used to handle all UITextView delegate
     methods after they've been handled by the MentionListener
     */
    internal weak var delegate: UITextViewDelegate?

    /**
     @brief Whether or not we should add a space after the mention, default: false
     */
    private let spaceAfterMention: Bool

    /**
     @brief Tell listener that mention searches can contain spaces, default: false
     */
    private let searchSpaces: Bool

    /**
     @brief Triggers to start a mention. Default: @
     */
    private let triggers: [String]

    /**
     @brief Whether or not the entire mention text should be removed when edited
     */
    private let removeEntireMention: Bool

    /**
     @brief Text attributes to be applied to all text excluding mentions.
     */
    private let defaultTextAttributes: [AttributeContainer]

    /**
     @brief Block used to determine attributes for a given mention
     */
    private let mentionTextAttributes: (CreateMention?) -> [AttributeContainer]

    /**
     @brief The UITextView being handled by the MentionListener
     */
    internal let mentionsTextView: UITextView

    /**
     @brief Called when the UITextView is not editing a mention.
     */
    private let hideMentions: () -> Void

    /**
     @brief Called when a user hits enter while entering a mention
     @return Whether or not the mention was handled
     */
    private let didHandleMentionOnReturn: () -> Bool

    /**
     @brief Called when the UITextView is editing a mention.

     @param MentionString the current text entered after the mention trigger.
     Generally used for filtering a mentions list.
     */
    private let showMentionsListWithString: (_ mentionString: String, _ trigger: String) -> Void

    /**
     @brief Amount of time to delay between showMentions calls default:0.5
     */
    private let cooldownInterval: TimeInterval

    /**
     @brief Range of mention currently being edited.
     */
    private var currentMentionRange = NSRange(location: NSNotFound, length: 0)

    /**
     @brief String to filter by
     */
    private var filterString: String = ""

    /**
     @brief String that has been sent to the showMentionsListWithString
     */
    private var stringCurrentlyBeingFiltered: String = ""

    /**
     @brief Timer to space out mentions requests
     */
    private var cooldownTimer: Timer?

    /**
     @brief Whether or not a mention is currently being edited
     */
    private var mentionEnabled = false

    /**
     @brief Initializer that allows for customization of text attributes for default text and mentions
     @param mentionsTextView: - the text view to manage mentions for
     @param delegate: - the object that will handle textview delegate methods
     @param mentionTextAttributes - block used to determine text style to show for a given mention
     @param defaultTextAttributes - text style to show for default text
     @param spaceAfterMention - whether or not to add a space after adding a mention
     @param triggers - what text triggers showing the mentions list
     @param cooldownInterval - amount of time between show / hide mentions calls
     @param searchSpaces - mention searches can / cannot contain spaces
     @param removeEntireMention - remove mention text entirely when edited if true
     @param hideMentions - block of code that is run when the mentions view is to be hidden
     @param didHandleMentionOnReturn - block of code that is run when enter is hit while in the midst of editing a mention.
     Use this block to either:
     - 1. add the mention and return true stating that the mention was handled on your end (this will tell the listener to hide the view)
     - 2. return false stating that the mention was NOT handled on your end (this will allow the listener to input a line break).
     @param showMentionsListWithString - block of code that is run when the mentions list is to be shown
     */
    public init(
        mentionsTextView: UITextView,
        delegate: UITextViewDelegate? = nil,
        mentionTextAttributes: ((CreateMention?) -> [AttributeContainer])? = nil,
        defaultTextAttributes: [AttributeContainer]? = nil,
        spaceAfterMention: Bool = false,
        triggers: [String] = ["@"],
        cooldownInterval: TimeInterval = 0.5,
        searchSpaces: Bool = false,
        removeEntireMention: Bool = false,
        hideMentions: @escaping () -> Void,
        didHandleMentionOnReturn: @escaping () -> Bool,
        showMentionsListWithString: @escaping (String, String) -> Void
    ) {
        self.mentionTextAttributes = mentionTextAttributes ?? { _ in
            [Attribute(name: .foregroundColor, value: UIColor.blue)]
        }
        self.defaultTextAttributes = defaultTextAttributes ?? [Attribute(name: .foregroundColor,
                                                                         value: UIColor.black)]
        Verifier.verifySetup(withDefaultTextAttributes: self.defaultTextAttributes,
                             mentionTextAttributes: self.mentionTextAttributes(nil))

        self.searchSpaces = searchSpaces
        self.mentionsTextView = mentionsTextView
        self.delegate = delegate
        self.spaceAfterMention = spaceAfterMention
        self.triggers = triggers
        self.cooldownInterval = cooldownInterval
        self.removeEntireMention = removeEntireMention
        self.hideMentions = hideMentions
        self.didHandleMentionOnReturn = didHandleMentionOnReturn
        self.showMentionsListWithString = showMentionsListWithString
        self.mentionsTextView.typingAttributes = self.defaultTextAttributes.dictionary
        super.init()
        mentionsTextView.delegate = self
    }
}

extension MentionListener /* Public */ {
    /**
     @brief Resets the textView to empty text, default typing attributes and removes all mentions
     */
    public func reset() {
        mentions = []

        mentionsTextView.text = ""
        mentionsTextView.typingAttributes = defaultTextAttributes.dictionary
    }

    /**
     @brief Sets up UITextView and Mentions array with provided list of mentions and their ranges.

     @param existingMentions: Tuple array of (CreateMention, NSRange) which is used to update the
     mentions arrtay and apply mention attributes to the provided ranges
     */
    public func insertExistingMentions(_ existingMentions: [(CreateMention, NSRange)]) {
        mentions = mentions |> insert(existingMentions)

        let (text, selectedRange) = mentionsTextView.attributedText
            |> apply(attributes: mentionTextAttributes, to: existingMentions)
        mentionsTextView.attributedText = text
        mentionsTextView.selectedRange = selectedRange

        notifyOfTextViewChange(on: mentionsTextView)
    }

    /**
     @brief Adds a mention to the current mention range
     @param createMention: The mention to be added

     @return Bool: Whether or not a mention was added
     */
    @discardableResult public func addMention(_ createMention: CreateMention) -> Bool {
        guard currentMentionRange.location != NSNotFound else { return false }

        mentions = mentions
            |> add(createMention, spaceAfterMention: spaceAfterMention, at: currentMentionRange)

        let (text, selectedRange) = mentionsTextView.attributedText
            |> add(createMention, spaceAfterMention: spaceAfterMention, at: currentMentionRange, with: mentionTextAttributes)
        mentionsTextView.attributedText = text
        mentionsTextView.selectedRange = selectedRange

        notifyOfTextViewChange(on: mentionsTextView)

        mentionEnabled = false
        filterString = ""
        hideMentions()

        return true
    }
}

extension MentionListener /* Internal */ {
    /**
     @brief Calls show mentions if necessary when the timer fires
     @param timer: the timer that called the method
     */
    @objc internal func cooldownTimerFired(_: Timer) {
        if filterString != stringCurrentlyBeingFiltered,
            !filterString.isEmpty, !filterString.contains(" ") || searchSpaces {
            stringCurrentlyBeingFiltered = filterString

            let searchResult = mentionsTextView.text.range(of: triggers,
                                                           options: .backwards,
                                                           range: NSRange(location: 0,
                                                                          length: NSMaxRange(mentionsTextView.selectedRange)))
            let location = searchResult.range.location
            guard location != NSNotFound, location <= mentionsTextView.text.utf16.count else { return }

            showMentionsListWithString(filterString, searchResult.foundString)
        }
    }
}

extension MentionListener /* Private */ {
    /**
     @brief Determines whether or not a mention is being added.
     If a mention is being added then set `currentMentionRange`, `filterString` and call
     `showMentionsListWithString`
     otherwise call `hideMentions`
     */
    private func handleMentionsList(_ textView: UITextView, range: NSRange) {
        let startIndex = mentionsTextView.text.startIndex
        let endIndex = mentionsTextView.text.index(startIndex,
                                                   offsetBy: min(NSMaxRange(range), mentionsTextView.text.count))
        let stringToSelectedIndex = String(mentionsTextView.text[startIndex ..< endIndex])

        var textBeforeTrigger = " "
        let searchResult = stringToSelectedIndex.range(of: triggers, options: .backwards)

        let location = searchResult.range.location
        let trigger = searchResult.foundString

        if location != NSNotFound {
            (mentionEnabled, textBeforeTrigger) = mentionsTextView.text.isMentionEnabledAt(location)
        } else {
            mentionEnabled = false
        }

        if mentionEnabled {
            var mentionString: String = ""
            if searchSpaces {
                let startIndex = mentionsTextView.text.utf16.index(mentionsTextView.text.startIndex, offsetBy: location)
                let endIndex = mentionsTextView.text.utf16.index(startIndex, offsetBy: NSMaxRange(textView.selectedRange) - location)
                mentionString = String(mentionsTextView.text[startIndex ..< endIndex])
            } else if let stringBeingTyped = stringToSelectedIndex.components(separatedBy: textBeforeTrigger).last,
                let stringForMention = stringBeingTyped.components(separatedBy: " ").last,
                stringForMention.range(of: trigger, options: .anchored) != nil {
                mentionString = stringForMention
            }

            filterString = ""

            if !mentionString.isEmpty {
                currentMentionRange = (textView.text as NSString).range(
                    of: mentionString,
                    options: .backwards,
                    range: NSRange(location: 0, length: NSMaxRange(textView.selectedRange))
                )
                filterString = mentionString.filter { ![trigger, "\n"].contains(String($0)) }

                if !(cooldownTimer?.isValid ?? false) {
                    stringCurrentlyBeingFiltered = filterString
                    showMentionsListWithString(filterString, trigger)
                }
                activateCooldownTimer()
                return
            }
        }

        hideMentions()
    }

    /**
     @brief Removes the provided mention from the mentions list and resets the text attributes to default
     on the text view.
     */
    private func clearMention() -> (Mention?) -> Void {
        return { mention in
            guard let mention = mention else { return }

            self.mentions = self.mentions |> remove([mention])

            let (text, selectedRange) = self.mentionsTextView.attributedText
                |> apply(self.defaultTextAttributes, range: mention.range)
            self.mentionsTextView.attributedText = text
            self.mentionsTextView.selectedRange = selectedRange
        }
    }

    /**
     @brief Activates a cooldown timer
     */
    private func activateCooldownTimer() {
        cooldownTimer?.invalidate()
        let timer = Timer(timeInterval: cooldownInterval, target: self,
                          selector: #selector(cooldownTimerFired(_:)), userInfo: nil,
                          repeats: false)
        cooldownTimer = timer
        RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
    }

    private func notifyOfTextViewChange(on textView: UITextView) {
        // Calling textViewDidChange delegate method because we manually adjusted the textView.
        delegate?.textViewDidChange?(textView)
        delegate?.textViewDidChangeSelection?(textView)
    }
}

extension MentionListener: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                         replacementText text: String) -> Bool {
        _ = delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text)

        textView.typingAttributes = defaultTextAttributes.dictionary

        var shouldChangeText = true

        if text == "\n", mentionEnabled, didHandleMentionOnReturn() {
            // If mentions were handled on return then `addMention` should've been called.
            // Nothing to do here.
            shouldChangeText = false
        } else {
            if let mention = mentions |> mentionBeingEdited(at: range) {
                mention |> clearMention()
                let values: (text: NSAttributedString, selectedRange: NSRange)
                let replacementRange: NSRange

                if removeEntireMention {
                    replacementRange = mention.range
                } else {
                    replacementRange = range
                }
                values = mentionsTextView.attributedText
                    |> replace(charactersIn: replacementRange, with: text)
                mentionsTextView.attributedText = values.text
                mentionsTextView.selectedRange = values.selectedRange

                shouldChangeText = false

                mentions = mentions |> adjusted(forTextChangeAt: replacementRange, text: text)
            } else {
                mentions = mentions |> adjusted(forTextChangeAt: range, text: text)
            }
        }

        if !shouldChangeText {
            notifyOfTextViewChange(on: textView)
        }
        return shouldChangeText
    }

    public func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewDidChange?(textView)
    }

    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return delegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? true
    }

    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return delegate?.textView?(textView, shouldInteractWith: URL, in: characterRange, interaction: interaction) ?? true
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textViewDidBeginEditing?(textView)
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        delegate?.textViewDidChangeSelection?(textView)
        handleMentionsList(textView, range: textView.selectedRange)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textViewDidEndEditing?(textView)
    }

    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return delegate?.textViewShouldBeginEditing?(textView) ?? true
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return delegate?.textViewShouldEndEditing?(textView) ?? true
    }
}
