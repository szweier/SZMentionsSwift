//
//  SZMentionsListener.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit

public protocol SZMentionsManagerProtocol {
    /**
     @brief Called when the UITextView is editing a mention.

     @param MentionString the current text entered after the mention trigger.
     Generally used for filtering a mentions list.
     */
    func showMentionsListWithString(_ mentionsString: String)

    /**
     @brief Called when the UITextView is not editing a mention.
     */
    func hideMentionsList()

    /**
     @brief Called when addMentionAfterReturnKey = true  (mention table show and user hit Return key).
     */
    func shouldAddMentionOnReturnKey()
}

public protocol SZCreateMentionProtocol {
    /**
     @brief The name of the mention to be added to the UITextView when selected.
     */
    var szMentionName: String {get}

    /**
     @brief The range to place the mention at
     */
    var szMentionRange: NSRange {get}
}

public class SZMentionsListener: NSObject {
    /**
     @brief Array of mentions currently added to the textview
     */
    public var mentions:[SZMention] { return mutableMentions }

    /**
     @brief Trigger to start a mention. Default: @
     */
    fileprivate var trigger: String

    /**
     @brief Text attributes to be applied to all text excluding mentions.
     */
    fileprivate var defaultTextAttributes: [SZAttribute]

    /**
     @brief Text attributes to be applied to mentions.
     */
    private var mentionTextAttributes: [SZAttribute]

    /**
     @brief The UITextView being handled by the SZMentionsListener
     */
    fileprivate var mentionsTextView: UITextView

    /**
     @brief An optional delegate that can be used to handle all UITextView delegate
     methods after they've been handled by the SZMentionsListener
     */
    internal weak var delegate: UITextViewDelegate?

    /**
     @brief Manager in charge of handling the creation and dismissal of the mentions
     list.
     */
    fileprivate var mentionsManager: SZMentionsManagerProtocol

    /**
     @brief Amount of time to delay between showMentions calls default:0.5
     */
    fileprivate var cooldownInterval: TimeInterval

    /**
     @brief Whether or not we should add a space after the mention, default: false
     */
    internal var spaceAfterMention: Bool

    /**
     @brief Tell listener for observer Return key, default: false
     */
    internal var addMentionAfterReturnKey: Bool

    /**
     @brief Tell listener that mention searches can contain spaces, default: false
     */
    internal var searchSpacesInMentions: Bool

    /**
     @brief Mutable array list of mentions managed by listener, accessible via the
     public mentions property.
     */
    fileprivate var mutableMentions: [SZMention] = []

    /**
     @brief Range of mention currently being edited.
     */
    fileprivate var currentMentionRange: NSRange?

    /**
     @brief Whether or not we are currently editing a mention.
     */
    fileprivate var editingMention: Bool = false

    /**
     @brief String to filter by
     */
    fileprivate var filterString: String?

    /**
     @brief String that has been sent to the showMentionsListWithString
     */
    fileprivate var stringCurrentlyBeingFiltered: String?

    /**
     @brief Timer to space out mentions requests
     */
    fileprivate var cooldownTimer: Timer?

    /**
     @brief Whether or not a mention is currently being edited
     */
    fileprivate var mentionEnabled = false

    /**
     @brief Initializer that allows for customization of text attributes for default text and mentions
     @param mentionTextView: - the text view to manage mentions for
     @param mentionsManager: - the object that will handle showing and hiding of the mentions picker
     @param textViewDelegate: - the object that will handle textview delegate methods
     @param mentionTextAttributes - text style to show for mentions
     @param defaultTextAttributes - text style to show for default text
     @param spaceAfterMention - whether or not to add a space after adding a mention
     @param addMentionOnReturnKey - tell listener for observer Return key
     @param trigger - what text triggers showing the mentions list
     @param cooldownInterval - amount of time between show / hide mentions calls
     @param searchSpaces - mention searches can / cannot contain spaces
     */
    public init(
        mentionTextView textView: UITextView,
        mentionsManager manager: SZMentionsManagerProtocol,
        textViewDelegate: UITextViewDelegate? = nil,
        mentionTextAttributes mentionAttributes: [SZAttribute] = [SZAttribute(attributeName: NSAttributedStringKey.foregroundColor.rawValue,
                                                                             attributeValue: UIColor.blue)],
        defaultTextAttributes defaultAttributes: [SZAttribute] = [SZAttribute(attributeName: NSAttributedStringKey.foregroundColor.rawValue,
                                                                              attributeValue: UIColor.black)],
        spaceAfterMention spaceAfter: Bool = false,
        addMentionOnReturnKey mentionOnReturn: Bool = false,
        trigger mentionTrigger: String = "@",
        cooldownInterval interval: TimeInterval = 0.5,
        searchSpaces: Bool = false) {
        SZVerifier.verifySetup(withDefaultTextAttributes: defaultAttributes,
                               mentionTextAttributes: mentionAttributes)
        searchSpacesInMentions = searchSpaces
        mentionsTextView = textView
        mentionsManager = manager
        delegate = textViewDelegate
        defaultTextAttributes = defaultAttributes
        mentionTextAttributes = mentionAttributes
        spaceAfterMention = spaceAfter
        addMentionAfterReturnKey = mentionOnReturn
        trigger = mentionTrigger
        cooldownInterval = interval
        super.init()
        resetEmpty(mentionsTextView)
        mentionsTextView.delegate = self
    }

    /**
     @brief Insert mentions into an existing textview.  This is provided assuming you are given text
     along with a list of users mentioned in that text and want to prep the textview in advance.

     @param mention the mention object adhereing to SZInsertMentionProtocol
     szMentionName is used as the name to set for the mention.  This parameter
     is returned in the mentions array in the object parameter of the SZMention object.
     szMentionRange is used the range to place the metion at
     */
    public func insertExistingMentions(_ existingMentions: [SZCreateMentionProtocol]) {
        if let mutableAttributedString = mentionsTextView.attributedText.mutableCopy() as? NSMutableAttributedString {

            existingMentions.forEach { mention in
                let range = mention.szMentionRange
                assert(range.location != NSNotFound, "Mention must have a range to insert into")
                assert(range.location + range.length < mutableAttributedString.string.characters.count,
                       "Mention range is out of bounds for the text length")

                let szMention = SZMention(mentionRange: range, mentionObject: mention)
                mutableMentions.append(szMention)

                mutableAttributedString.apply(mentionTextAttributes, range:range)
            }

            mentionsTextView.attributedText = mutableAttributedString
        }
    }

    /**
     @brief Adds a mention to the current mention range (determined by trigger + characters typed up to space or end of line)
     @param mention: the mention object to apply
     @return Bool: whether or not a mention was added
     */
    @discardableResult public func addMention(_ mention: SZCreateMentionProtocol) -> Bool {
        guard var currentMentionRange = currentMentionRange,
            let mutableAttributedString = mentionsTextView.attributedText.mutableCopy() as? NSMutableAttributedString
            else { return false }

        filterString = nil

        let displayName = mention.szMentionName + (spaceAfterMention ? " " : "")
        mutableAttributedString.mutableString.replaceCharacters(in: currentMentionRange, with: displayName)

        mentions.adjustMentions(forTextChangeAtRange: currentMentionRange, text: displayName)

        currentMentionRange = NSRange(location: currentMentionRange.location, length: mention.szMentionName.utf16.count)

        let szmention = SZMention(mentionRange: currentMentionRange, mentionObject: mention)
        mutableMentions.append(szmention)

        mutableAttributedString.apply(mentionTextAttributes, range: currentMentionRange)

        var selectedRange = NSRange(location: currentMentionRange.location + currentMentionRange.length, length: 0)

        mentionsTextView.attributedText = mutableAttributedString

        if spaceAfterMention { selectedRange.location += 1 }

        mentionsTextView.selectedRange = selectedRange

        mentionsManager.hideMentionsList()

        return true
    }
}

// MARK: Private methods

extension SZMentionsListener {
    /**
     @brief Reset typingAttributes for textView
     @param textView: the textView to change the typingAttributes on
     */
    fileprivate func resetTypingAttributes(for textView: UITextView) {
        var attributes = [String: Any]()
        for attribute in defaultTextAttributes {
            attributes[attribute.attributeName] = attribute.attributeValue
        }
        textView.typingAttributes = attributes
    }
    
    /**
     @brief Resets the empty text view
     @param textView: the text view to reset
     */
    fileprivate func resetEmpty(_ textView: UITextView) {
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
    fileprivate func adjust(_ textView: UITextView, range: NSRange) {
        let substring = (textView.text as NSString).substring(to: range.location) as NSString
        var textBeforeTrigger = " "
        let location = substring.range(of: trigger, options: NSString.CompareOptions.backwards).location
        mentionEnabled = false

        if location != NSNotFound {
            mentionEnabled = location == 0

            if location > 0 {
                //Determine whether or not a space exists before the trigger.
                //(in the case of an @ trigger this avoids showing the mention list for an email address)
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
                    range: NSRange(location: 0, length: textView.selectedRange.location + textView.selectedRange.length))
                filterString = (mentionString as NSString).replacingOccurrences(of: trigger, with: "")
                filterString = filterString?.replacingOccurrences(of: "\n", with: "")

                if let filterString = filterString, let cooldownTimer = cooldownTimer, !cooldownTimer.isValid {
                    stringCurrentlyBeingFiltered = filterString
                    mentionsManager.showMentionsListWithString(filterString)
                }
                activateCooldownTimer()
                return
            }
        }

        mentionsManager.hideMentionsList()
        mentionEnabled = false
    }

    /**
     @brief Determines whether or not we should allow the textView to adjust its own text
     @param textView: the mentions text view
     @param range: the range of what text will change
     @param text: the text to replace the range with
     @return Bool: whether or not the textView should adjust the text itself
     */
    fileprivate func shouldAdjust(_ textView: UITextView, range: NSRange, text: String) -> Bool {
        var shouldAdjust = true

        if textView.text.isEmpty { resetEmpty(textView) }

        editingMention = false

        if let editedMention = mentions.mentionBeingEdited(atRange: range) {
            if let index = mutableMentions.index(of: editedMention) {
                editingMention = true
                mutableMentions.remove(at: index)
            }

            shouldAdjust = handleEditingMention(editedMention, textView: textView, range: range, text: text)
        }

        mentions.adjustMentions(forTextChangeAtRange: range, text: text)

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
    private func handleEditingMention(_ mention: SZMention, textView: UITextView,
                                      range: NSRange, text: String) -> Bool {
        if let mutableAttributedString = textView.attributedText.mutableCopy() as? NSMutableAttributedString {
            mutableAttributedString.apply(defaultTextAttributes, range: mention.mentionRange)
            mutableAttributedString.mutableString.replaceCharacters(in: range, with: text)
            textView.attributedText = mutableAttributedString
            textView.selectedRange = NSRange(location: range.location + text.utf16.count, length: 0)

            _ = delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text)
        }

        return false
    }

    /**
     @brief Calls show mentions if necessary when the timer fires
     @param timer: the timer that called the method
     */
    @objc internal func cooldownTimerFired(_ timer: Timer) {
        if let filterString = filterString, filterString != stringCurrentlyBeingFiltered {
            stringCurrentlyBeingFiltered = filterString

            if mentionsTextView.selectedRange.location >= 1 {

                let range = (mentionsTextView.text as NSString).range(
                    of: trigger,
                    options: NSString.CompareOptions.backwards,
                    range: NSRange(location: 0, length: mentionsTextView.selectedRange.location + mentionsTextView.selectedRange.length))

                var location: Int = 0

                if range.location != NSNotFound { location = range.location }

                if location + 1 >= mentionsTextView.text.utf16.count { return }

                let substringTrigger = (mentionsTextView.text as NSString).substring(with: NSRange(location: location, length: 1))

                if substringTrigger == trigger {
                    mentionsManager.showMentionsListWithString(filterString)
                }
            }
        }
    }

    /**
     @brief Activates a cooldown timer
     */
    private func activateCooldownTimer() {
        cooldownTimer?.invalidate()
        let timer = Timer(timeInterval: cooldownInterval, target: self,
                          selector: #selector(SZMentionsListener.cooldownTimerFired(_:)), userInfo: nil,
                          repeats: false)
        cooldownTimer = timer
        RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
}

// MARK: TextView Delegate

extension SZMentionsListener: UITextViewDelegate {

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                         replacementText text: String) -> Bool {
        assert((textView.delegate?.isEqual(self))!, "Textview delegate must be set equal to SZMentionsListener")

        resetTypingAttributes(for: textView)

        if text == "\n", addMentionAfterReturnKey, mentionEnabled {
            mentionsManager.shouldAddMentionOnReturnKey()
            mentionEnabled = false
            mentionsManager.hideMentionsList()

            return false
        }
        _ = delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text)

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
        if !editingMention {
            adjust(textView, range: textView.selectedRange)
            delegate?.textViewDidChangeSelection?(textView)
        }
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
