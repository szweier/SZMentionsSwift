//
//  SZMentionsListener.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit

public class SZMentionsListener: NSObject {
    // MARK: Public vars
    /**
     @brief Array of mentions currently added to the textview
     */
    public var mentions: [SZMention] { return mutableMentions }
    
    // MARK: Internal vars
    /**
     @brief An optional delegate that can be used to handle all UITextView delegate
     methods after they've been handled by the SZMentionsListener
     */
    internal weak var delegate: UITextViewDelegate?
    
    /**
     @brief Whether or not we should add a space after the mention, default: false
     */
    internal var spaceAfterMention: Bool
    
    /**
     @brief Tell listener that mention searches can contain spaces, default: false
     */
    internal var searchSpacesInMentions: Bool

    // MARK: Private vars
    /**
     @brief Trigger to start a mention. Default: @
     */
    private var trigger: String

    /**
     @brief Text attributes to be applied to all text excluding mentions.
     */
    private var defaultTextAttributes: [AttributeContainer]

    /**
     @brief Text attributes to be applied to mentions.
     */
    private var mentionTextAttributes: [AttributeContainer]

    /**
     @brief The UITextView being handled by the SZMentionsListener
     */
    private var mentionsTextView: UITextView

    /**
     @brief Manager in charge of handling the creation and dismissal of the mentions
     list.
     */
    private var mentionsManager: MentionsManagerDelegate

    /**
     @brief Amount of time to delay between showMentions calls default:0.5
     */
    private var cooldownInterval: TimeInterval

    /**
     @brief Mutable array list of mentions managed by listener, accessible via the
     public mentions property.
     */
    private var mutableMentions: [SZMention] = []

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
     @param mentionsManager: - the object that will handle showing and hiding of the mentions picker
     @param textViewDelegate: - the object that will handle textview delegate methods
     @param mentionTextAttributes - text style to show for mentions
     @param defaultTextAttributes - text style to show for default text
     @param spaceAfterMention - whether or not to add a space after adding a mention
     @param trigger - what text triggers showing the mentions list
     @param cooldownInterval - amount of time between show / hide mentions calls
     @param searchSpaces - mention searches can / cannot contain spaces
     */
    public init(
        mentionTextView textView: UITextView,
        mentionsManager manager: MentionsManagerDelegate,
        textViewDelegate: UITextViewDelegate? = nil,
        mentionTextAttributes mentionAttributes: [AttributeContainer]? = nil,
        defaultTextAttributes defaultAttributes: [AttributeContainer]? = nil,
        spaceAfterMention spaceAfter: Bool = false,
        trigger mentionTrigger: String = "@",
        cooldownInterval interval: TimeInterval = 0.5,
        searchSpaces: Bool = false) {
        mentionTextAttributes = mentionAttributes ?? [SZAttribute(attributeName: NSAttributedStringKey.foregroundColor.rawValue,
                                                              attributeValue: UIColor.blue)]
        defaultTextAttributes = defaultAttributes ?? [SZAttribute(attributeName: NSAttributedStringKey.foregroundColor.rawValue,
                                                              attributeValue: UIColor.black)]
        SZVerifier.verifySetup(withDefaultTextAttributes: defaultTextAttributes,
                               mentionTextAttributes: mentionTextAttributes)
        searchSpacesInMentions = searchSpaces
        mentionsTextView = textView
        mentionsManager = manager
        delegate = textViewDelegate
        spaceAfterMention = spaceAfter
        trigger = mentionTrigger
        cooldownInterval = interval
        super.init()
        resetEmpty(mentionsTextView)
        mentionsTextView.delegate = self
    }
}

// MARK: Public methods

extension SZMentionsListener {
    /**
     @brief Insert mentions into an existing textview.  This is provided assuming you are given text
     along with a list of users mentioned in that text and want to prep the textview in advance.
     
     @param mention the mention object adhereing to SZInsertMentionProtocol
     mentionName is used as the name to set for the mention.  This parameter
     is returned in the mentions array in the object parameter of the SZMention object.
     mentionRange is used the range to place the metion at
     */
    public func insertExistingMentions(_ existingMentions: [CreateMention]) {
        if let mutableAttributedString = mentionsTextView.attributedText.mutableCopy() as? NSMutableAttributedString {
            
            existingMentions.forEach { mention in
                let range = mention.mentionRange
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
    @discardableResult public func addMention(_ mention: CreateMention) -> Bool {
        guard var currentMentionRange = currentMentionRange,
            let mutableAttributedString = mentionsTextView.attributedText.mutableCopy() as? NSMutableAttributedString
            else { return false }
        
        filterString = nil
        
        let displayName = mention.mentionName + (spaceAfterMention ? " " : "")
        mutableAttributedString.mutableString.replaceCharacters(in: currentMentionRange, with: displayName)
        
        mentions.adjustMentions(forTextChangeAtRange: currentMentionRange, text: displayName)
        
        currentMentionRange = NSRange(location: currentMentionRange.location, length: mention.mentionName.utf16.count)
        
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

// MARK: Internal methods

extension SZMentionsListener {
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
}

// MARK: Private methods

extension SZMentionsListener {
    /**
     @brief Reset typingAttributes for textView
     @param textView: the textView to change the typingAttributes on
     */
    private func resetTypingAttributes(for textView: UITextView) {
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
    private func resetEmpty(_ textView: UITextView) {
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
    
    private func clearMention(_ mention: SZMention) {
        if let index = mutableMentions.index(of: mention) {
            editingMention = true
            mutableMentions.remove(at: index)
        }
        if let mutableAttributedString = mentionsTextView.attributedText.mutableCopy() as? NSMutableAttributedString {
            mutableAttributedString.apply(defaultTextAttributes, range: mention.mentionRange)
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

        if textView.text.isEmpty { resetEmpty(textView) }

        editingMention = false

        if let editedMention = mentions.mentionBeingEdited(atRange: range) {
            clearMention(editedMention)

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

        if text == "\n", mentionEnabled, mentionsManager.didHandleMentionOnReturn() {
            mentionEnabled = false
            mentionsManager.hideMentionsList()

            return false
        } else if text.characters.count > 1 {
            //Pasting
            if let editedMention = mentions.mentionBeingEdited(atRange: range) {
                clearMention(editedMention)
            }
            
            if let mutableAttributedString = textView.attributedText.mutableCopy() as? NSMutableAttributedString {
                mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: text))
                mutableAttributedString.apply(defaultTextAttributes, range: NSRange(location: range.location, length: text.characters.count))
                textView.attributedText = mutableAttributedString
            }
            
            mentions.adjustMentions(forTextChangeAtRange: range, text: text)
            
            return false
        }
        _ = delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text)

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
