//
//  SZMentionsListener.swift
//  SZMentionsSwift
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

    /**
    @brief The range to place the mention at (optional: if not set mention will be added to the current range being edited)
    */
    var szMentionRange: NSRange? {get}
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

    /**
    @brief Initializer that allows for customization of text attributes for default text and mentions
    @param mentionTextView: - the text view to manage mentions for
    @param mentionsManager: - the object that will handle showing and hiding of the mentions picker
    */
    public convenience init(
        mentionTextView: UITextView,
        mentionsManager: SZMentionsManagerProtocol) {
        self.init(
            mentionTextView: mentionTextView,
            mentionsManager: mentionsManager,
            textViewDelegate: nil)
    }

    /**
     @brief Initializer that allows for customization of text attributes for default text and mentions
     @param mentionTextView: - the text view to manage mentions for
     @param mentionsManager: - the object that will handle showing and hiding of the mentions picker
     @param textViewDelegate: - the object that will handle textview delegate methods
     */
    public convenience init(
        mentionTextView: UITextView,
        mentionsManager: SZMentionsManagerProtocol,
        textViewDelegate: UITextViewDelegate?) {
            self.init(
                mentionTextView: mentionTextView,
                mentionsManager: mentionsManager,
                textViewDelegate: textViewDelegate,
                mentionTextAttributes:nil,
                defaultTextAttributes: nil)
    }

    /**
     @brief Initializer that allows for customization of text attributes for default text and mentions
     @param mentionTextView: - the text view to manage mentions for
     @param mentionsManager: - the object that will handle showing and hiding of the mentions picker
     @param textViewDelegate: - the object that will handle textview delegate methods
     @param mentionTextAttributes - text style to show for mentions
     @param defaultTextAttributes - text style to show for default text
     */
    public convenience init(
        mentionTextView: UITextView,
        mentionsManager: SZMentionsManagerProtocol,
        textViewDelegate: UITextViewDelegate?,
        mentionTextAttributes: [SZAttribute]?,
        defaultTextAttributes: [SZAttribute]?) {
            self.init(
                mentionTextView: mentionTextView,
                mentionsManager: mentionsManager,
                textViewDelegate: textViewDelegate,
                mentionTextAttributes: mentionTextAttributes,
                defaultTextAttributes: defaultTextAttributes,
                spaceAfterMention: false)
    }

    /**
     @brief Initializer that allows for customization of text attributes for default text and mentions
     @param mentionTextView: - the text view to manage mentions for
     @param mentionsManager: - the object that will handle showing and hiding of the mentions picker
     @param textViewDelegate: - the object that will handle textview delegate methods
     @param mentionTextAttributes - text style to show for mentions
     @param defaultTextAttributes - text style to show for default text
     @param spaceAfterMention - whether or not to add a space after adding a mention
     */
    public convenience init(
        mentionTextView: UITextView,
        mentionsManager: SZMentionsManagerProtocol,
        textViewDelegate: UITextViewDelegate?,
        mentionTextAttributes: [SZAttribute]?,
        defaultTextAttributes: [SZAttribute]?,
        spaceAfterMention: Bool) {
            self.init(
                mentionTextView: mentionTextView,
                mentionsManager: mentionsManager,
                textViewDelegate: textViewDelegate,
                mentionTextAttributes: mentionTextAttributes,
                defaultTextAttributes: defaultTextAttributes,
                spaceAfterMention: spaceAfterMention,
                trigger: "@")
    }

    /**
     @brief Initializer that allows for customization of text attributes for default text and mentions
     @param mentionTextView: - the text view to manage mentions for
     @param mentionsManager: - the object that will handle showing and hiding of the mentions picker
     @param textViewDelegate: - the object that will handle textview delegate methods
     @param mentionTextAttributes - text style to show for mentions
     @param defaultTextAttributes - text style to show for default text
     @param spaceAfterMention - whether or not to add a space after adding a mention
     @param trigger - what text triggers showing the mentions list
     */
    public convenience init(
        mentionTextView: UITextView,
        mentionsManager: SZMentionsManagerProtocol,
        textViewDelegate: UITextViewDelegate?,
        mentionTextAttributes: [SZAttribute]?,
        defaultTextAttributes: [SZAttribute]?,
        spaceAfterMention: Bool,
        trigger: String) {
            self.init(
                mentionTextView: mentionTextView,
                mentionsManager: mentionsManager,
                textViewDelegate: textViewDelegate,
                mentionTextAttributes: mentionTextAttributes,
                defaultTextAttributes: defaultTextAttributes,
                spaceAfterMention: spaceAfterMention,
                trigger: trigger,
                cooldownInterval: 0.5)
    }

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
     */
    public init(
        mentionTextView: UITextView,
        mentionsManager: SZMentionsManagerProtocol,
        textViewDelegate: UITextViewDelegate?,
        mentionTextAttributes: [SZAttribute]?,
        defaultTextAttributes: [SZAttribute]?,
        spaceAfterMention: Bool,
        trigger: String,
        cooldownInterval: NSTimeInterval) {
            self.mentionsTextView = mentionTextView
            self.mentionsManager = mentionsManager
            self.delegate = textViewDelegate
            self.spaceAfterMention = spaceAfterMention
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
            resetEmpty(self.mentionsTextView)
            self.mentionsTextView.delegate = self
    }

    // MARK: Attribute assert

    /**
    @brief Checks that attributes have existing counterparts for mentions and default
    @param mentionAttributes: The attributes to apply to mention objects
    @param defaultAttributes: The attributes to apply to default text
    */
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

    /**
    @brief Resets the empty text view
    @param textView: the text view to reset
    */
    private func resetEmpty(textView: UITextView) {
        mutableMentions.removeAll()
        textView.text = " "
        let mutableAttributedString = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        SZAttributedStringHelper.apply(defaultTextAttributes, range: NSMakeRange(0, 1), mutableAttributedString: mutableAttributedString)
        textView.attributedText = mutableAttributedString
        textView.text = ""
    }

    /**
     @brief Uses the text view to determine the current mention being adjusted based on
     the currently selected range and the nearest trigger when doing a backward search.  It also
     sets the currentMentionRange to be used as the range to replace when adding a mention.
     @param textView: the mentions text view
     @param range: the selected range
     */
    private func adjust(textView: UITextView, range: NSRange) {
        let substring = (textView.text as NSString).substringToIndex(range.location) as NSString

        var mentionEnabled = false

        let location = substring.rangeOfString(
            trigger as String,
            options: NSStringCompareOptions.BackwardsSearch).location

        if location != NSNotFound {
            mentionEnabled = location == 0

            if location > 0 {
                //Determine whether or not a space exists before the trigger.
                //(in the case of an @ trigger this avoids showing the mention list for an email address)
                let substringRange = NSRange.init(location: location - 1, length: 1)
                mentionEnabled = substring.substringWithRange(substringRange) == " "
            }
        }

        if mentionEnabled {
            if let stringBeingTyped = substring.componentsSeparatedByString(" ").last {
                if ((stringBeingTyped as NSString).rangeOfString(trigger as String).location != NSNotFound) {

                    self.currentMentionRange = (textView.text as NSString).rangeOfString(
                        stringBeingTyped,
                        options: NSStringCompareOptions.BackwardsSearch,
                        range: NSMakeRange(0, textView.selectedRange.location + textView.selectedRange.length))
                        self.filterString = (stringBeingTyped as NSString).stringByReplacingOccurrencesOfString(
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
        }
        self.mentionsManager.hideMentionsList()
    }

    /**
     @brief Determines whether or not we should allow the textView to adjust its own text
     @param textView: the mentions text view
     @param range: the range of what text will change
     @param text: the text to replace the range with
     @return Bool: whether or not the textView should adjust the text itself
     */
    private func shouldAdjust(textView: UITextView, range: NSRange, text: String) -> Bool {
        var shouldAdjust = true

        if (textView.text.characters.count == 0) {
            self.resetEmpty(textView)
        }

        self.editingMention = false
        let editedMention = self.mentionBeingEdited(range)

        if (editedMention != nil) {
            if let index = self.mutableMentions.indexOf(editedMention!) {
                self.editingMention = true
                self.mutableMentions.removeAtIndex(index)
            }

            shouldAdjust = self.handleEditingMention(editedMention!, textView: textView, range: range, text: text)
        }

        if SZMentionHelper.needsToChangeToDefaultAttributes(textView, range: range, mentions: self.mentions) {
            shouldAdjust = self.forceDefaultAttributes(textView, range: range, text: text)
        }

        SZMentionHelper.adjustMentions(range, text: text, mentions: self.mentions)

        self.delegate?.textView?(textView, shouldChangeTextInRange: range, replacementText: text)

        return shouldAdjust
    }

    // MARK: attribute management

    /**
    @brief Forces default attributes on a string of text
    @param textView: the mentions text view
    @param range: the range of text being replaced
    @param text: the text to replace the range with
    @return Bool: false (we do not want the text view handling text input in this case)
    */
    private func forceDefaultAttributes(textView: UITextView, range: NSRange, text: String) -> Bool {
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

    /**
    @brief Insert mentions into an existing textview.  This is provided assuming you are given text
    along with a list of users mentioned in that text and want to prep the textview in advance.

    @param mention the mention object adhereing to SZInsertMentionProtocol
    szMentionName is used as the name to set for the mention.  This parameter
    is returned in the mentions array in the object parameter of the SZMention object.
    szMentionRange is used the range to place the metion at
    */
    public func insertExistingMentions(existingMentions: [SZCreateMentionProtocol]) {
        let mutableAttributedString = mentionsTextView.attributedText.mutableCopy()

        for mention in existingMentions {
            if let range = mention.szMentionRange {
            assert(mention.szMentionRange?.location != NSNotFound, "Mention must have a range to insert into")

            let szMention = SZMention(mentionRange: range, mentionObject: mention)
            mutableMentions.append(szMention)

                SZAttributedStringHelper.apply(
                    self.mentionTextAttributes,
                    range:range,
                    mutableAttributedString: mutableAttributedString as! NSMutableAttributedString)
            }

            settingText = true
            mentionsTextView.attributedText = mutableAttributedString as! NSAttributedString
            settingText = false
        }
    }

    /**
    @brief Adds a mention to the current mention range (determined by trigger + characters typed up to space or end of line)
    @param mention: the mention object to apply
    */
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

        let szmention = SZMention.init(
            mentionRange: self.currentMentionRange!,
            mentionObject: mention)
        self.mutableMentions.append(szmention)

        SZAttributedStringHelper.apply(
            self.mentionTextAttributes,
            range: self.currentMentionRange!,
            mutableAttributedString: mutableAttributedString as! NSMutableAttributedString)

        self.settingText = true

        var selectedRange = NSMakeRange(self.currentMentionRange!.location + self.currentMentionRange!.length, 0)

        self.mentionsTextView.attributedText = mutableAttributedString as! NSMutableAttributedString

        if self.spaceAfterMention {
            selectedRange.location++
        }

        self.mentionsTextView.selectedRange = selectedRange
        self.settingText = false

        self.mentionsManager.hideMentionsList()
    }

    /**
     @brief Resets the attributes of the mention to default attributes
     @param mention: the mention being edited
     @param textView: the mention text view
     @param range: the current range selected
     @param text: text to replace range
     */
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

    /**
     @brief returns the mention being edited (if a mention is being edited)
     @param range: the range to look for a mention
     @return SZMention?: the mention being edited (if one exists)
     */
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

    /**
    @brief Calls show mentions if necessary when the timer fires
    @param timer: the timer that called the method
    */
    internal func cooldownTimerFired(timer: NSTimer) {
        if ((self.filterString?.characters.count) != nil) {
            self.mentionsManager.showMentionsListWithString(self.filterString!)
        }
    }

    /**
     @brief Activates a cooldown timer
     */
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
            self.adjust(textView, range: textView.selectedRange)
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
