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
     @brief Array of mentions currently added to the textview
     */
    public var mentions: [Mention] { return mutableMentions }

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
    private let searchSpacesInMentions: Bool

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
    private let mentionsTextView: UITextView

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
     @brief Mutable array list of mentions managed by listener, accessible via the
     public mentions property.
     */
    private var mutableMentions: [Mention] = []

    /**
     @brief Range of mention currently being edited.
     */
    private var currentMentionRange: NSRange?

    /**
     @brief Whether or not we are currently editing a mention.
     */
    private var editingMention: Bool = false

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

    // MARK: Initialization

    /**
     @brief Initializer that allows for customization of text attributes for default text and mentions
     @param mentionTextView: - the text view to manage mentions for
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
        mentionTextView textView: UITextView,
        delegate: UITextViewDelegate? = nil,
        attributesForMention mentionAttributes: ((CreateMention?) -> [AttributeContainer])? = nil,
        defaultTextAttributes defaultAttributes: [AttributeContainer]? = nil,
        spaceAfterMention spaceAfter: Bool = false,
        triggers mentionTriggers: [String] = ["@"],
        cooldownInterval interval: TimeInterval = 0.5,
        searchSpaces: Bool = false,
        hideMentions: @escaping () -> Void,
        didHandleMentionOnReturn: @escaping () -> Bool,
        showMentionsListWithString: @escaping (String, String) -> Void
    ) {
        mentionTextAttributes = mentionAttributes ?? { _ in
            [Attribute(name: .foregroundColor,
                       value: UIColor.blue)] }
        defaultTextAttributes = defaultAttributes ?? [Attribute(name: .foregroundColor,
                                                                value: UIColor.black)]

        Verifier.verifySetup(withDefaultTextAttributes: defaultTextAttributes,
                             mentionTextAttributes: mentionTextAttributes(nil))
        searchSpacesInMentions = searchSpaces
        mentionsTextView = textView
        self.delegate = delegate
        spaceAfterMention = spaceAfter
        triggers = mentionTriggers
        cooldownInterval = interval
        self.hideMentions = hideMentions
        self.didHandleMentionOnReturn = didHandleMentionOnReturn
        self.showMentionsListWithString = showMentionsListWithString
        super.init()
        reset(mentionsTextView)
        mentionsTextView.delegate = self
    }
}

extension MentionListener /* Public */ {
    /**
     @brief Resets the textView to empty text and removes all mentions
     */
    public func reset() {
        reset(mentionsTextView)
    }

    /**
     @brief Insert mentions into an existing textview.  This is provided assuming you are given text
     along with a list of users mentioned in that text and want to prep the textview in advance.

     @param mention: the mention object adhereing to the CreateMention protocol
     `name` is used as the name to set for the mention.  This parameter
     is returned in the mentions array in the object parameter of the Mention object.
     `range` is used the range to place the metion at
     */
    public func insertExistingMentions(_ existingMentions: [CreateMention]) {
        if let mutableAttributedString = mentionsTextView.attributedText.mutableCopy() as? NSMutableAttributedString {
            mutableMentions += existingMentions.compactMap { createMention in
                let range = createMention.range
                assert(range.location != NSNotFound, "Mention must have a range to insert into")
                assert(NSMaxRange(range) <= mutableAttributedString.string.utf16.count,
                       "Mention range is out of bounds for the text length")

                mutableAttributedString.apply(mentionTextAttributes(createMention), range: range)

                return Mention(range: range, object: createMention)
            }

            mentionsTextView.attributedText = mutableAttributedString
        }
    }

    /**
     @brief Adds a mention to the current mention range (determined by triggers + characters typed up to space or end of line)
     @param mention: the mention object to apply
     @return Bool: whether or not a mention was added
     */
    @discardableResult public func addMention(_ createMention: CreateMention) -> Bool {
        guard var currentMentionRange = currentMentionRange,
            let mutableAttributedString = mentionsTextView.attributedText.mutableCopy() as? NSMutableAttributedString
        else { return false }

        filterString = nil

        let displayName = createMention.name + mentionPostFix
        mutableAttributedString.mutableString.replaceCharacters(in: currentMentionRange, with: displayName)

        mutableMentions.adjustMentions(forTextChangeAt: currentMentionRange, text: displayName)

        currentMentionRange = NSRange(location: currentMentionRange.location, length: createMention.name.utf16.count)

        mutableMentions.append(Mention(range: currentMentionRange, object: createMention))

        mutableAttributedString.apply(mentionTextAttributes(createMention), range: currentMentionRange)

        var selectedRange = NSRange(location: NSMaxRange(currentMentionRange), length: 0)

        mentionsTextView.attributedText = mutableAttributedString

        if spaceAfterMention { selectedRange.location += 1 }

        mentionsTextView.selectedRange = selectedRange

        hideMentions()

        return true
    }
}

extension MentionListener /* Internal */ {
    /**
     @brief The string to append when adding a mention to the TextView
     @return String
     */
    internal var mentionPostFix: String {
        return spaceAfterMention ? " " : ""
    }

    /**
     @brief Calls show mentions if necessary when the timer fires
     @param timer: the timer that called the method
     */
    @objc internal func cooldownTimerFired(_: Timer) {
        if let filterString = filterString, filterString != stringCurrentlyBeingFiltered {
            stringCurrentlyBeingFiltered = filterString

            if mentionsTextView.selectedRange.location >= 1 {
                guard let rangeTuple = mentionsTextView.text.range(of: triggers,
                                                                   options: NSString.CompareOptions.backwards,
                                                                   range: NSRange(location: 0, length: NSMaxRange(mentionsTextView.selectedRange))) else { return }

                var location: Int = 0

                if rangeTuple.range.location != NSNotFound { location = rangeTuple.range.location }

                if location + 1 >= mentionsTextView.text.utf16.count { return }

                let substringTrigger = (mentionsTextView.text as NSString).substring(with: NSRange(location: location, length: 1))

                if substringTrigger == rangeTuple.foundString {
                    showMentionsListWithString(filterString, rangeTuple.foundString)
                }
            }
        }
    }
}

extension MentionListener /* Private */ {
    /**
     @brief Reset typingAttributes for textView
     @param textView: the textView to change the typingAttributes on
     */
    private func resetTypingAttributes(for textView: UITextView) {
        var attributes = [NSAttributedString.Key: Any]()
        for attribute in defaultTextAttributes {
            attributes[attribute.name] = attribute.value
        }
        textView.typingAttributes = attributes
    }

    /**
     @brief Resets the empty text view
     @param textView: the text view to reset
     */
    private func reset(_ textView: UITextView) {
        mutableMentions.removeAll()
        resetTypingAttributes(for: textView)
        textView.text = " "
        if let mutableAttributedString = textView.attributedText.mutableCopy() as? NSMutableAttributedString {
            mutableAttributedString.apply(defaultTextAttributes, range: NSRange(location: 0, length: 1))
            textView.attributedText = mutableAttributedString
        }
        textView.text = ""
    }

    /**
     @brief Uses the text view to determine the current mention being adjusted based on
     the currently selected range and the nearest trigger when doing a backward search.  It also
     sets the currentMentionRange to be used as the range to replace when adding a mention.
     @param textView: the mentions text view
     @param range: the selected range
     */
    private func adjust(_ textView: UITextView, range: NSRange) {
        let string = (textView.text as NSString).substring(to: NSMaxRange(range))
        var textBeforeTrigger = " "

        guard let rangeTuple = string.range(of: triggers, options: NSString.CompareOptions.backwards) else { return }

        let location = rangeTuple.range.location
        let trigger = rangeTuple.foundString
        let substring = (string as NSString)

        mentionEnabled = false

        if location != NSNotFound {
            mentionEnabled = location == 0

            if location > 0 {
                // Determine whether or not a space exists before the triggter.
                // (in the case of an @ trigger this avoids showing the mention list for an email address)
                let substringRange = NSRange(location: location - 1, length: 1)
                textBeforeTrigger = substring.substring(with: substringRange)
                mentionEnabled = textBeforeTrigger == " " || textBeforeTrigger == "\n"
            }
        }

        if mentionEnabled {
            var mentionString: String = ""
            if searchSpacesInMentions {
                mentionString = substring.substring(with: NSRange(location: location, length: (textView.selectedRange.location - location) + textView.selectedRange.length))
            } else if let stringBeingTyped = substring.components(separatedBy: textBeforeTrigger).last,
                let stringForMention = stringBeingTyped.components(separatedBy: " ").last,
                (stringForMention as NSString).range(of: trigger).location != NSNotFound {
                mentionString = stringForMention
            }

            if !mentionString.isEmpty {
                currentMentionRange = (textView.text as NSString).range(
                    of: mentionString,
                    options: NSString.CompareOptions.backwards,
                    range: NSRange(location: 0, length: NSMaxRange(textView.selectedRange))
                )
                filterString = (mentionString as NSString).replacingOccurrences(of: trigger, with: "")
                filterString = filterString?.replacingOccurrences(of: "\n", with: "")

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

    private func clearMention(_ mention: Mention) {
        if let index = mutableMentions.index(of: mention) {
            editingMention = true
            mutableMentions.remove(at: index)
        }
        if let mutableAttributedString = mentionsTextView.attributedText.mutableCopy() as? NSMutableAttributedString {
            mutableAttributedString.apply(defaultTextAttributes, range: mention.range)
            mentionsTextView.attributedText = mutableAttributedString
        }
    }

    /**
     @brief Determines whether or not we should allow the textView to adjust its own text
     @param textView: the mentions text view
     @param range: the range of what text will change
     @param text: the text to replace the range with
     @return Bool: whether or not the textView should adjust the text itself
     */
    @discardableResult private func shouldAdjust(_ textView: UITextView, range: NSRange, text: String) -> Bool {
        var shouldAdjust = true

        if textView.text.isEmpty { reset(textView) }

        editingMention = false

        if let editedMention = mentions.mentionBeingEdited(at: range) {
            clearMention(editedMention)

            shouldAdjust = handleEditingMention(editedMention, textView: textView, range: range, text: text)
        }

        mutableMentions.adjustMentions(forTextChangeAt: range, text: text)

        _ = delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text)

        return shouldAdjust
    }

    /**
     @brief Resets the attributes of the mention to default attributes
     @param mention: the mention being edited
     @param textView: the mention text view
     @param range: the current range selected
     @param text: text to replace range
     */
    private func handleEditingMention(_: Mention, textView: UITextView,
                                      range: NSRange, text: String) -> Bool {
        if let mutableAttributedString = textView.attributedText.mutableCopy() as? NSMutableAttributedString {
            mutableAttributedString.mutableString.replaceCharacters(in: range, with: text)
            textView.attributedText = mutableAttributedString
            textView.selectedRange = NSRange(location: range.location + text.utf16.count, length: 0)

            _ = delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text)
        }

        return false
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
        assert((textView.delegate?.isEqual(self))!, "Textview delegate must be set equal to MentionListener")

        defer {
            _ = delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text)
        }

        if textView.text.isEmpty { reset(textView) }
        else { resetTypingAttributes(for: textView) }

        if text == "\n", mentionEnabled, didHandleMentionOnReturn() {
            mentionEnabled = false
            hideMentions()

            return false
        } else if text.utf16.count > 1 {
            // Pasting
            if let editedMention = mentions.mentionBeingEdited(at: range) {
                clearMention(editedMention)
            }

            textView.delegate = nil
            if let mutableAttributedString = textView.attributedText.mutableCopy() as? NSMutableAttributedString {
                mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: text))
                mutableAttributedString.apply(defaultTextAttributes, range: NSRange(location: range.location, length: text.utf16.count))
                mentionsTextView.selectedRange = NSRange(location: 0, length: 0)
                textView.attributedText = mutableAttributedString
                mentionsTextView.selectedRange = NSRange(location: range.location + text.utf16.count, length: 0)
                mentionsTextView.scrollRangeToVisible(mentionsTextView.selectedRange)
            }
            mutableMentions.adjustMentions(forTextChangeAt: range, text: text)
            adjust(textView, range: textView.selectedRange)
            textView.delegate = self

            return false
        }

        return shouldAdjust(textView, range: range, text: text)
    }

    public func textViewDidChange(_ textView: UITextView) {
        if textView.selectedRange.location > 1 {
            let substring = (textView.attributedText.string as NSString).substring(with: NSRange(location: textView.selectedRange.location - 2, length: 2))
            if substring == ". ", let mutableAttributedString = textView.attributedText.mutableCopy() as? NSMutableAttributedString {
                mutableAttributedString.apply(defaultTextAttributes, range: NSRange(location: textView.selectedRange.location - 2, length: 2))
                textView.attributedText = mutableAttributedString
            }
        }
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
        if !editingMention { adjust(textView, range: textView.selectedRange) }
        delegate?.textViewDidChangeSelection?(textView)
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
