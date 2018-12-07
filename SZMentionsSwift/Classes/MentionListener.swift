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
    private(set) var mentions: [Mention] = []

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
    private var currentMentionRange: NSRange?

    /**
     @brief String to filter by
     */
    private var filterString: String?

    /**
     @brief String that has been sent to the showMentionsListWithString
     */
    private var stringCurrentlyBeingFiltered: String?

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
     @brief Resets the textView to empty text and removes all mentions
     */
    public func reset() {
        mentions = []
        mentionsTextView.text = ""
        mentionsTextView.typingAttributes = defaultTextAttributes.dictionary
    }

    /**
     @brief Insert mentions into an existing textview.  This is provided assuming you are given text
     along with a list of users mentioned in that text and want to prep the textview in advance.

     @param mention: the mention object adhereing to the CreateMention protocol
     `name` is used as the name to set for the mention.  This parameter
     is returned in the mentions array in the object parameter of the Mention object.
     `range` is used the range to place the metion at
     */
    public func insertExistingMentions(_ existingMentions: [(CreateMention, NSRange)]) {
        mentions |> insert(existingMentions)
        mentionsTextView.attributedText |> insert(existingMentions, with: mentionTextAttributes)
    }

    /**
     @brief Adds a mention to the current mention range (determined by triggers + characters typed up to space or end of line)
     @param mention: the mention object to apply
     @return Bool: whether or not a mention was added
     */
    @discardableResult public func addMention(_ createMention: CreateMention) -> Bool {
        guard let currentMentionRange = currentMentionRange else { return false }

        mentionsTextView.attributedText |>
            add(createMention, spaceAfterMention: spaceAfterMention, at: currentMentionRange, with: mentionTextAttributes) |>
            selectRange(on: mentionsTextView)
        mentions |> add(createMention, spaceAfterMention: spaceAfterMention, at: currentMentionRange)

        filterString = nil
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
        if let filterString = filterString, filterString != stringCurrentlyBeingFiltered {
            stringCurrentlyBeingFiltered = filterString

            if mentionsTextView.selectedRange.location >= 1 {
                let rangeTuple = mentionsTextView.text.range(of: triggers,
                                                             options: .backwards,
                                                             range: NSRange(location: 0,
                                                                            length: NSMaxRange(mentionsTextView.selectedRange)))
                guard rangeTuple.range.location != NSNotFound else { return }

                let location: Int = rangeTuple.range.location

                if location + 1 >= mentionsTextView.text.utf16.count { return }

                let startIndex = mentionsTextView.text.index(mentionsTextView.text.startIndex, offsetBy: location)
                let endIndex = mentionsTextView.text.index(startIndex, offsetBy: 1)
                let substringTrigger = mentionsTextView.text[startIndex ..< endIndex]

                if substringTrigger == rangeTuple.foundString {
                    showMentionsListWithString(filterString, rangeTuple.foundString)
                }
            }
        }
    }
}

extension MentionListener /* Private */ {
    /**
     @brief Uses the text view to determine the current mention being adjusted based on
     the currently selected range and the nearest trigger when doing a backward search.  It also
     sets the currentMentionRange to be used as the range to replace when adding a mention.
     @param textView: the mentions text view
     @param range: the selected range
     */
    private func adjust(_ textView: UITextView, range: NSRange) {
        let startIndex = mentionsTextView.text.startIndex
        let endIndex = mentionsTextView.text.index(startIndex,
                                                   offsetBy: min(NSMaxRange(range), mentionsTextView.text.count))
        let string = String(mentionsTextView.text[startIndex ..< endIndex])

        var textBeforeTrigger = " "

        let rangeTuple = string.range(of: triggers, options: .backwards)

        let location = rangeTuple.range.location
        let trigger = rangeTuple.foundString

        mentionEnabled = false

        if location != NSNotFound {
            mentionEnabled = location == 0

            if location > 0 {
                // Determine whether or not a space exists before the triggter.
                // (in the case of an @ trigger this avoids showing the mention list for an email address)
                let startIndex = mentionsTextView.text.index(mentionsTextView.text.startIndex, offsetBy: location - 1)
                let endIndex = mentionsTextView.text.index(startIndex, offsetBy: 1)
                textBeforeTrigger = String(mentionsTextView.text[startIndex ..< endIndex])
                mentionEnabled = textBeforeTrigger == " " || textBeforeTrigger == "\n"
            }
        }

        if mentionEnabled {
            var mentionString: String = ""
            if searchSpaces {
                let startIndex = mentionsTextView.text.index(mentionsTextView.text.startIndex, offsetBy: location)
                let endIndex = mentionsTextView.text.index(startIndex, offsetBy: textView.selectedRange.location - location + textView.selectedRange.length)
                mentionString = String(mentionsTextView.text[startIndex ..< endIndex])
            } else if let stringBeingTyped = string.components(separatedBy: textBeforeTrigger).last,
                let stringForMention = stringBeingTyped.components(separatedBy: " ").last,
                stringForMention.range(of: trigger, options: .anchored) != nil {
                mentionString = stringForMention
            }

            if !mentionString.isEmpty {
                currentMentionRange = (textView.text as NSString).range(
                    of: mentionString,
                    options: .backwards,
                    range: NSRange(location: 0, length: NSMaxRange(textView.selectedRange))
                )
                filterString = mentionString.replacingOccurrences(of: trigger, with: "").replacingOccurrences(of: "\n", with: "")

                if let filterString = filterString, !(cooldownTimer?.isValid ?? false) {
                    stringCurrentlyBeingFiltered = filterString
                    showMentionsListWithString(filterString, trigger)
                }
                activateCooldownTimer()
                return
            }
        }

        hideMentions()
        mentionEnabled = false
    }

    private func clearMention() -> (Mention?) -> Bool {
        return { mention in
            guard let mention = mention else { return false }
            self.mentions |> remove([mention])
            self.mentionsTextView.attributedText |> apply(self.defaultTextAttributes, range: mention.range)

            return true
        }
    }

    /**
     @brief Determines whether or not we should allow the textView to adjust its own text
     @param textView: the mentions text view
     @param range: the range of what text will change
     @param text: the text to replace the range with
     @return Bool: whether or not the textView should adjust the text itself
     */
    @discardableResult private func shouldAdjust(_: UITextView, range: NSRange, text: String) -> Bool {
        var shouldAdjust = true

        if mentions |> mentionBeingEdited(at: range) |> clearMention() {
            mentionsTextView.attributedText |>
                replace(charactersIn: range, with: text) |>
                selectRange(on: mentionsTextView)
            shouldAdjust = false
        }

        mentions |> adjusted(forTextChangeAt: range, text: text)

        return shouldAdjust
    }

    /**
     @brief Activates a cooldown timer
     */
    private func activateCooldownTimer() {
        cooldownTimer?.invalidate()
        let timer = Timer(timeInterval: cooldownInterval, target: self,
                          selector: #selector(MentionListener.cooldownTimerFired(_:)), userInfo: nil,
                          repeats: false)
        cooldownTimer = timer
        RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
    }
}

extension MentionListener: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                         replacementText text: String) -> Bool {
        _ = delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text)

        textView.typingAttributes = defaultTextAttributes.dictionary

        if text == "\n", mentionEnabled, didHandleMentionOnReturn() {
            mentionEnabled = false
            hideMentions()

            return false
        } else if text.utf16.count > 1 {
            // Pasting
            _ = mentions |> mentionBeingEdited(at: range) |> clearMention()

            textView.delegate = nil
            // The following snippet is because if you click on a predictive text without this snippet
            // the predictive text will be added twice.
            let originalText = mentionsTextView.attributedText
            _ = mentionsTextView.attributedText |> replace(charactersIn: range, with: text)
            mentionsTextView.attributedText = originalText
            mentionsTextView.attributedText |>
                replace(charactersIn: range, with: text) |>
                selectRange(on: mentionsTextView)

            mentionsTextView.attributedText |> apply(defaultTextAttributes, range: range.adjustLength(for: text))
            mentionsTextView.scrollRangeToVisible(mentionsTextView.selectedRange)
            mentions |> adjusted(forTextChangeAt: range, text: text)
            adjust(textView, range: textView.selectedRange)
            textView.delegate = self

            return false
        }

        return shouldAdjust(textView, range: range, text: text)
    }

    public func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewDidChange?(textView)
    }

    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment,
                         in characterRange: NSRange) -> Bool {
        return delegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange) ?? true
    }

    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return delegate?.textView?(textView, shouldInteractWith: URL, in: characterRange) ?? true
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textViewDidBeginEditing?(textView)
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        delegate?.textViewDidChangeSelection?(textView)
        adjust(textView, range: textView.selectedRange)
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
