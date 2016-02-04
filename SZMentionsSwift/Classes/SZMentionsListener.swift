//
//  SZMentionsListener.swift
//  SZMentions_Swift
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit

let attributeConsistencyError = "Default and mention attributes must contain the same attribute names: If default attributes specify NSForegroundColorAttributeName mention attributes must specify that same name as well. (Values do not need to match)"

public protocol SZMentionsManagerProtocol {
    /**
     @brief Called when the UITextView is editing a mention.

     @param MentionString the current text entered after the mention trigger.
     Generally used for filtering a mentions list.
     */
    func showMentionsListWithString(mentionsString: String)

    /**
     @brief Called when the UITextView is not editing a mention.
     */
    func hideMentionsList()
}

public protocol SZCreateMentionProtocol {
    /**
     @brief The name of the mention to be added to the UITextView when selected.
     */
    var szMentionName: String {get}
}

public class SZMentionsListener: NSObject, UITextViewDelegate {

    /**
     @brief Array of mentions currently added to the textview
     */
    public var mentions:[SZMention] {
        return mutableMentions
    }

    /**
     @brief Trigger to start a mention. Default: @
     */
    private var trigger: String = "@"

    /**
     @brief Text attributes to be applied to all text excluding mentions.
     */
    private var defaultTextAttributes: [SZAttribute] = SZDefaultAttributes.defaultTextAttributes()

    /**
     @brief Text attributes to be applied to mentions.
     */
    private var mentionTextAttributes: [SZAttribute] = SZDefaultAttributes.defaultMentionAttributes()

    /**
     @brief The UITextView being handled by the SZMentionsListener
     */
    private var mentionsTextView: UITextView

    /**
     @brief An optional delegate that can be used to handle all UITextView delegate
     methods after they've been handled by the SZMentionsListener
     */
    private var delegate: UITextViewDelegate?

    /**
     @brief Manager in charge of handling the creation and dismissal of the mentions
     list.
     */
    private var mentionsManager: SZMentionsManagerProtocol

    /**
     @brief Amount of time to delay between showMentions calls default:0.5
     */
    private var cooldownInterval: NSTimeInterval = 0.5

    /**
     @brief Whether or not we should add a space after the mention, default: false
     */
    internal var spaceAfterMention: Bool = false

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
     @brief Allow us to edit text internally without triggering delegate
     */
    private var settingText: Bool = false

    /**
     @brief String to filter by
     */
    private var filterString: String?

    /**
     @brief Timer to space out mentions requests
     */
    private var cooldownTimer: NSTimer?

    // MARK: Initialization

    public convenience init(mentionTextView: UITextView, mentionsManager: SZMentionsManagerProtocol) {
        self.init(mentionTextView: mentionTextView, mentionsManager: mentionsManager, textViewDelegate: nil)
    }

    public convenience init(mentionTextView: UITextView, mentionsManager: SZMentionsManagerProtocol,
        textViewDelegate: UITextViewDelegate?) {
            self.init(mentionTextView: mentionTextView, mentionsManager: mentionsManager,
                textViewDelegate: textViewDelegate, mentionTextAttributes:nil,
                defaultTextAttributes: nil)
    }

    public convenience init(mentionTextView: UITextView, mentionsManager: SZMentionsManagerProtocol,
        textViewDelegate: UITextViewDelegate?, mentionTextAttributes: [SZAttribute]?,
        defaultTextAttributes: [SZAttribute]?) {
            self.init(mentionTextView: mentionTextView, mentionsManager: mentionsManager,
                textViewDelegate: textViewDelegate, mentionTextAttributes:mentionTextAttributes,
                defaultTextAttributes: defaultTextAttributes, trigger: "@")
    }

    public convenience init(mentionTextView: UITextView, mentionsManager: SZMentionsManagerProtocol,
        textViewDelegate: UITextViewDelegate?, mentionTextAttributes: [SZAttribute]?,
        defaultTextAttributes: [SZAttribute]?, trigger: String) {
            self.init(mentionTextView: mentionTextView, mentionsManager: mentionsManager,
                textViewDelegate: textViewDelegate, mentionTextAttributes:mentionTextAttributes,
                defaultTextAttributes: defaultTextAttributes, trigger: trigger, cooldownInterval: 0.5)
    }

    public init(mentionTextView: UITextView, mentionsManager: SZMentionsManagerProtocol,
        textViewDelegate: UITextViewDelegate?, mentionTextAttributes: [SZAttribute]?,
        defaultTextAttributes: [SZAttribute]?, trigger: String, cooldownInterval: NSTimeInterval) {
            self.mentionsTextView = mentionTextView
            self.mentionsManager = mentionsManager
            self.delegate = textViewDelegate
            if (defaultTextAttributes != nil) {
                self.defaultTextAttributes = defaultTextAttributes!
            }

            if (mentionTextAttributes != nil) {
                self.mentionTextAttributes = mentionTextAttributes!
            }
            self.trigger = trigger;
            self.cooldownInterval = cooldownInterval
            super.init()
            assert(attributesSetCorrectly(self.mentionTextAttributes,
                defaultAttributes: self.defaultTextAttributes),
                attributeConsistencyError)
            setDefaultAttributesFor(mentionTextView)
            self.mentionsTextView.delegate = self
    }

    // MARK: Attribute assert

    public func attributesSetCorrectly(mentionAttributes: [SZAttribute],
        defaultAttributes: [SZAttribute]) ->  Bool {

            let attributeNamesToLoop = (defaultAttributes.count >= mentionAttributes.count) ?
                defaultAttributes.map({$0.attributeName}) :
                mentionAttributes.map({$0.attributeName})

            let attributeNamesToCompare = (defaultAttributes.count < mentionAttributes.count) ?
                defaultAttributes.map({$0.attributeName}) :
                mentionAttributes.map({$0.attributeName})

            var attributeHasMatch = true

            for attributeName in attributeNamesToLoop {
                attributeHasMatch = attributeNamesToCompare.contains(attributeName)

                if (attributeHasMatch == false) {
                    break;
                }
            }

            return attributeHasMatch;
    }

    // MARK: TextView Adjustment

    private func setDefaultAttributesFor(textView: UITextView) {
        textView.text = " "
        let mutableAttributedString = textView.attributedText.mutableCopy()
        for attribute in defaultTextAttributes {
            mutableAttributedString.addAttribute(attribute.attributeName, value: attribute.attributeValue,
                range: NSMakeRange(0, 1))
        }
        textView.attributedText = mutableAttributedString as! NSAttributedString
        textView.text = ""
    }

    private func resetEmpty(textView: UITextView, text: String, range: NSRange) {
        mutableMentions.removeAll()
        setDefaultAttributesFor(textView)
    }

    private func adjust(textView: UITextView, range: NSRange, text: String) {
        let substring = (textView.text as NSString).substringToIndex(range.location) as NSString

        var mentionEnabled = false

        let location = substring.rangeOfString(
            trigger as String,
            options: NSStringCompareOptions.BackwardsSearch).location

        if location != NSNotFound {
            mentionEnabled = location == 0

            if location > 0 {
                let substringRange = NSRange.init(location: location - 1, length: 1)
                mentionEnabled = substring.substringWithRange(substringRange) == " "
            }
        }

        let strings = substring.componentsSeparatedByString(" ")

        if ((strings.last! as NSString).rangeOfString(trigger as String).location != NSNotFound) {
            if mentionEnabled {
                self.currentMentionRange = (textView.text as NSString).rangeOfString(
                    strings.last!,
                    options: NSStringCompareOptions.BackwardsSearch)
                let mentionString = strings.last!.stringByAppendingString(text)
                self.filterString = mentionString.stringByReplacingOccurrencesOfString(
                    trigger as String,
                    withString: "")

                if self.filterString?.characters.count > 0 &&
                    (self.cooldownTimer == nil || self.cooldownTimer?.valid == false) {
                        self.mentionsManager.showMentionsListWithString(self.filterString!)
                }
                self.activateCooldownTimer()
                return
            }
        }
        self.mentionsManager.hideMentionsList()
    }

    private func shouldAdjust(textView: UITextView, range: NSRange, text: String) -> Bool {
        if (textView.text.characters.count == 0) {
            self.resetEmpty(textView, text: text, range: range)
        }

        if (SZMentionHelper.shouldHideMentions(text)) {
            self.mentionsManager.hideMentionsList()
        }

        self.editingMention = false
        let mention = self.mentionBeingEdited(range)

        if (mention != nil) {
            if let index = self.mutableMentions.indexOf(mention!) {
                self.editingMention = true
                self.mutableMentions.removeAtIndex(index)
            }
        }

        SZMentionHelper.adjustMentions(range, text: text, mentions: self.mentions)

        self.delegate?.textView?(textView, shouldChangeTextInRange: range, replacementText: text)

        if editingMention == true {
            return self.handleEditingMention(mention!, textView: textView, range: range, text: text)
        }

        if SZMentionHelper.needsToChangeToDefaultAttributes(textView, range: range, mentions: self.mentions) {
            return self.forceDefaultColor(textView, range: range, text: text)
        }

        return true
    }

    // MARK: Color management

    private func forceDefaultColor(textView: UITextView, range: NSRange, text: String) -> Bool {
        let mutableAttributedString = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        mutableAttributedString.mutableString.replaceCharactersInRange(range, withString: text)

        SZAttributedStringHelper.apply(
            self.defaultTextAttributes,
            range: NSRange.init(location: range.location, length: text.characters.count),
            mutableAttributedString: mutableAttributedString)
        self.settingText = true
        textView.attributedText = mutableAttributedString
        self.settingText = false

        var newRange = NSRange.init(location: range.location, length: 0)

        if newRange.length <= 0 {
            newRange.location = range.location + text.characters.count
        }

        textView.selectedRange = newRange

        return false
    }

    // MARK: Mention management

    public func addMention(mention: SZCreateMentionProtocol) {
        if (self.currentMentionRange == nil) {
            return
        }

        self.filterString = nil
        var displayName = mention.szMentionName

        if self.spaceAfterMention {
            displayName = displayName.stringByAppendingString(" ")
        }

        let mutableAttributedString = self.mentionsTextView.attributedText.mutableCopy()
        mutableAttributedString.mutableString.replaceCharactersInRange(
            self.currentMentionRange!,
            withString: displayName)

        SZMentionHelper.adjustMentions(self.currentMentionRange!, text: displayName, mentions: self.mentions)

        self.currentMentionRange = NSMakeRange(
            self.currentMentionRange!.location,
            mention.szMentionName.characters.count)

        SZAttributedStringHelper.apply(
            self.mentionTextAttributes,
            range: self.currentMentionRange!,
            mutableAttributedString: mutableAttributedString as! NSMutableAttributedString)

        let newRange = NSMakeRange(self.currentMentionRange!.location + self.currentMentionRange!.length - 1, 0)
        SZAttributedStringHelper.apply(
            self.defaultTextAttributes,
            range: newRange,
            mutableAttributedString: mutableAttributedString as! NSMutableAttributedString)

        self.settingText = true
        self.mentionsTextView.attributedText = mutableAttributedString as! NSMutableAttributedString

        var selectedRange = NSMakeRange(self.currentMentionRange!.location + self.currentMentionRange!.length, 0)

        if self.spaceAfterMention {
            selectedRange.location++
        }

        self.mentionsTextView.selectedRange = selectedRange
        self.settingText = false

        let szmention = SZMention.init(
            mentionRange: self.currentMentionRange!,
            mentionObject: mention)
        self.mentionsManager.hideMentionsList()
        self.mutableMentions.append(szmention)
    }

    private func handleEditingMention(mention: SZMention, textView: UITextView,
        range: NSRange, text: String) -> Bool {
            let mutableAttributedString = textView.attributedText.mutableCopy()

            SZAttributedStringHelper.apply(
                self.defaultTextAttributes,
                range: mention.mentionRange,
                mutableAttributedString: mutableAttributedString as! NSMutableAttributedString)

            mutableAttributedString.mutableString.replaceCharactersInRange(range, withString: text)

            self.settingText = true
            textView.attributedText = mutableAttributedString as! NSMutableAttributedString
            self.settingText = false
            textView.selectedRange = NSMakeRange(range.location + text.characters.count, 0)

            self.delegate?.textView?(textView, shouldChangeTextInRange: range, replacementText: text)

            return false
    }

    private func mentionBeingEdited(range: NSRange) -> SZMention? {
        var editedMention: SZMention?

        for mention in self.mentions {
            let currentMentionRange = mention.mentionRange
            if (NSIntersectionRange(range, currentMentionRange).length > 0 ||
                (range.length == 0 &&
                    range.location > currentMentionRange.location &&
                    range.location < currentMentionRange.length + currentMentionRange.location))
            {
                editedMention = mention
            }
        }

        return editedMention
    }

    // MARK: Timer

    internal func cooldownTimerFired(timer: NSTimer) {
        if ((self.filterString?.characters.count) != nil) {
            self.mentionsManager.showMentionsListWithString(self.filterString!)
        }
    }

    private func activateCooldownTimer() {
        self.cooldownTimer?.invalidate()

        let timer = NSTimer.init(
            timeInterval: self.cooldownInterval,
            target: self,
            selector: Selector("cooldownTimerFired:"),
            userInfo: nil,
            repeats: false)
        self.cooldownTimer = timer
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }

    // MARK: TextView Delegate
    public func textView(
        textView: UITextView,
        shouldChangeTextInRange range: NSRange,
        replacementText text: String) -> Bool {
            assert((textView.delegate?.isEqual(self))!,
                "Textview delegate must be set equal to SZMentionsListener")

            self.delegate?.textView?(
                textView,
                shouldChangeTextInRange: range,
                replacementText: text)

            if (self.settingText == true) {
                return false
            }

            return self.shouldAdjust(textView, range: range, text: text)
    }

    public func textViewDidChange(textView: UITextView) {
        self.delegate?.textViewDidChange?(textView)
    }

    public func textView(
        textView: UITextView,
        shouldInteractWithTextAttachment textAttachment: NSTextAttachment,
        inRange characterRange: NSRange) -> Bool {

            self.delegate?.textView?(
                textView,
                shouldInteractWithTextAttachment: textAttachment,
                inRange: characterRange)

            return true
    }

    public func textView(
        textView: UITextView,
        shouldInteractWithURL URL: NSURL,
        inRange characterRange: NSRange) -> Bool {

            self.delegate?.textView?(textView, shouldInteractWithURL: URL, inRange: characterRange)

            return true
    }

    public func textViewDidBeginEditing(textView: UITextView) {
        self.delegate?.textViewDidBeginEditing?(textView)
    }

    public func textViewDidChangeSelection(textView: UITextView) {
        if editingMention == false {
            self.adjust(textView, range: textView.selectedRange, text: "")
            self.delegate?.textViewDidChangeSelection?(textView)
        }
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        self.delegate?.textViewDidEndEditing?(textView)
    }
    
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if let shouldBeginEditing = self.delegate?.textViewShouldBeginEditing?(textView) {
            return shouldBeginEditing
        }
        
        return true
    }
    
    public func textViewShouldEndEditing(textView: UITextView) -> Bool {
        if let shouldEndEditing = self.delegate?.textViewShouldEndEditing?(textView) {
            return shouldEndEditing
        }
        
        return true
    }
}
