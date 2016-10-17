//
//  SZMentionsListener.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


let attributeConsistencyError = "Default and mention attributes must contain the same attribute names: If default attributes specify NSForegroundColorAttributeName mention attributes must specify that same name as well. (Values do not need to match)"

@objc public protocol SZMentionsManagerProtocol {
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
    @objc optional func shouldAddMentionOnReturnKey()
}

@objc public protocol SZCreateMentionProtocol {
    /**
     @brief The name of the mention to be added to the UITextView when selected.
     */
    var szMentionName: String {get}

    /**
     @brief The range to place the mention at
     */
    var szMentionRange: NSRange {get}
}

open class SZMentionsListener: NSObject, UITextViewDelegate {

    /**
     @brief Array of mentions currently added to the textview
     */
    open var mentions:[SZMention] {
        return mutableMentions
    }

    /**
     @brief Trigger to start a mention. Default: @
     */
    fileprivate var trigger: String = "@"

    /**
     @brief Text attributes to be applied to all text excluding mentions.
     */
    fileprivate var defaultTextAttributes: [SZAttribute] = SZDefaultAttributes.defaultTextAttributes()

    /**
     @brief Text attributes to be applied to mentions.
     */
    fileprivate var mentionTextAttributes: [SZAttribute] = SZDefaultAttributes.defaultMentionAttributes()

    /**
     @brief The UITextView being handled by the SZMentionsListener
     */
    fileprivate var mentionsTextView: UITextView

    /**
     @brief An optional delegate that can be used to handle all UITextView delegate
     methods after they've been handled by the SZMentionsListener
     */
    fileprivate weak var delegate: UITextViewDelegate?

    /**
     @brief Manager in charge of handling the creation and dismissal of the mentions
     list.
     */
    fileprivate var mentionsManager: SZMentionsManagerProtocol

    /**
     @brief Amount of time to delay between showMentions calls default:0.5
     */
    fileprivate var cooldownInterval: TimeInterval = 0.5

    /**
     @brief Whether or not we should add a space after the mention, default: false
     */
    internal var spaceAfterMention: Bool = false

    /**
     @brief Tell listener for observer Return key, default: false
     */
    internal var addMentionAfterReturnKey: Bool = false

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
     @brief Allow us to edit text internally without triggering delegate
     */
    fileprivate var settingText: Bool = false

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
            addMentionOnReturnKey: false,
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
     @param addMentionOnReturnKey - tell listener for observer Return key
     */
    public convenience init(
        mentionTextView: UITextView,
        mentionsManager: SZMentionsManagerProtocol,
        textViewDelegate: UITextViewDelegate?,
        mentionTextAttributes: [SZAttribute]?,
        defaultTextAttributes: [SZAttribute]?,
        spaceAfterMention: Bool,
        addMentionOnReturnKey: Bool) {
        self.init(
            mentionTextView: mentionTextView,
            mentionsManager: mentionsManager,
            textViewDelegate: textViewDelegate,
            mentionTextAttributes: mentionTextAttributes,
            defaultTextAttributes: defaultTextAttributes,
            spaceAfterMention: spaceAfterMention,
            addMentionOnReturnKey: addMentionOnReturnKey,
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
     @param addMentionOnReturnKey - tell listener for observer Return key
     @param trigger - what text triggers showing the mentions list
     */
    public convenience init(
        mentionTextView: UITextView,
        mentionsManager: SZMentionsManagerProtocol,
        textViewDelegate: UITextViewDelegate?,
        mentionTextAttributes: [SZAttribute]?,
        defaultTextAttributes: [SZAttribute]?,
        spaceAfterMention: Bool,
        addMentionOnReturnKey: Bool,
        trigger: String) {
        self.init(
            mentionTextView: mentionTextView,
            mentionsManager: mentionsManager,
            textViewDelegate: textViewDelegate,
            mentionTextAttributes: mentionTextAttributes,
            defaultTextAttributes: defaultTextAttributes,
            spaceAfterMention: spaceAfterMention,
            addMentionOnReturnKey: addMentionOnReturnKey,
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
     @param addMentionOnReturnKey - tell listener for observer Return key
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
        addMentionOnReturnKey: Bool,
        trigger: String,
        cooldownInterval: TimeInterval) {
        self.mentionsTextView = mentionTextView
        self.mentionsManager = mentionsManager
        self.delegate = textViewDelegate
        self.spaceAfterMention = spaceAfterMention
        self.addMentionAfterReturnKey = addMentionOnReturnKey
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
    open func attributesSetCorrectly(_ mentionAttributes: [SZAttribute],
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
    fileprivate func resetEmpty(_ textView: UITextView) {
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
    var mentionEnabled = false
    fileprivate func adjust(_ textView: UITextView, range: NSRange) {
        let substring = (textView.text as NSString).substring(to: range.location) as NSString


        var textBeforeTrigger = " "
        let location = substring.range(
            of: trigger as String,
            options: NSString.CompareOptions.backwards).location

        if location != NSNotFound {
            mentionEnabled = location == 0

            if location > 0 {
                //Determine whether or not a space exists before the trigger.
                //(in the case of an @ trigger this avoids showing the mention list for an email address)
                let substringRange = NSRange.init(location: location - 1, length: 1)
                textBeforeTrigger = substring.substring(with: substringRange)
                mentionEnabled = textBeforeTrigger == " " || textBeforeTrigger == "\n"
            }
        }

        if mentionEnabled {
            if let stringBeingTyped = substring.components(separatedBy: textBeforeTrigger).last {
                if let stringForMention = stringBeingTyped.components(separatedBy: " ").last {

                    if ((stringForMention as NSString).range(of: trigger as String).location != NSNotFound) {

                        self.currentMentionRange = (textView.text as NSString).range(
                            of: stringBeingTyped,
                            options: NSString.CompareOptions.backwards,
                            range: NSMakeRange(0, textView.selectedRange.location + textView.selectedRange.length))
                        self.filterString = (stringBeingTyped as NSString).replacingOccurrences(
                            of: trigger as String,
                            with: "")
                        self.filterString = self.filterString?.replacingOccurrences(of: "\n", with: "")

                        if self.filterString?.characters.count > 0 &&
                            (self.cooldownTimer == nil || self.cooldownTimer?.isValid == false) {
                            self.stringCurrentlyBeingFiltered = filterString
                            self.mentionsManager.showMentionsListWithString(filterString!)
                        }
                        self.activateCooldownTimer()
                        return
                    }
                }


            }
        }
        mentionEnabled = false
        self.mentionsManager.hideMentionsList()
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

        if (textView.text.characters.count == 0) {
            self.resetEmpty(textView)
        }

        self.editingMention = false
        let editedMention = self.mentionBeingEdited(range)

        if (editedMention != nil) {
            if let index = self.mutableMentions.index(of: editedMention!) {
                self.editingMention = true
                self.mutableMentions.remove(at: index)
            }

            shouldAdjust = self.handleEditingMention(editedMention!, textView: textView, range: range, text: text)
        }

        if SZMentionHelper.needsToChangeToDefaultAttributes(textView, range: range, mentions: self.mentions) {
            shouldAdjust = self.forceDefaultAttributes(textView, range: range, text: text)
        }

        SZMentionHelper.adjustMentions(range, text: text, mentions: self.mentions)

        let _ = self.delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text)

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
    fileprivate func forceDefaultAttributes(_ textView: UITextView, range: NSRange, text: String) -> Bool {
        let mutableAttributedString = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        mutableAttributedString.mutableString.replaceCharacters(in: range, with: text)

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
    open func insertExistingMentions(_ existingMentions: [SZCreateMentionProtocol]) {
        let mutableAttributedString = mentionsTextView.attributedText.mutableCopy()

        for mention in existingMentions {
            let range = mention.szMentionRange
            assert(range.location != NSNotFound, "Mention must have a range to insert into")

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

    /**
     @brief Adds a mention to the current mention range (determined by trigger + characters typed up to space or end of line)
     @param mention: the mention object to apply
     */
    open func addMention(_ mention: SZCreateMentionProtocol) {
        if (self.currentMentionRange == nil) {
            return
        }

        self.filterString = nil
        var displayName = mention.szMentionName

        if self.spaceAfterMention {
            displayName = displayName + " "
        }

        let mutableAttributedString = self.mentionsTextView.attributedText.mutableCopy()
        (mutableAttributedString as AnyObject).mutableString.replaceCharacters(
            in: self.currentMentionRange!,
            with: displayName)

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
            selectedRange.location += 1
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
    fileprivate func handleEditingMention(_ mention: SZMention, textView: UITextView,
                                          range: NSRange, text: String) -> Bool {
        let mutableAttributedString = textView.attributedText.mutableCopy()

        SZAttributedStringHelper.apply(
            self.defaultTextAttributes,
            range: mention.mentionRange,
            mutableAttributedString: mutableAttributedString as! NSMutableAttributedString)

        (mutableAttributedString as AnyObject).mutableString.replaceCharacters(in: range, with: text)

        self.settingText = true
        textView.attributedText = mutableAttributedString as! NSMutableAttributedString
        self.settingText = false
        textView.selectedRange = NSMakeRange(range.location + text.characters.count, 0)

        let _ = self.delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text)

        return false
    }

    /**
     @brief returns the mention being edited (if a mention is being edited)
     @param range: the range to look for a mention
     @return SZMention?: the mention being edited (if one exists)
     */
    fileprivate func mentionBeingEdited(_ range: NSRange) -> SZMention? {
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
    internal func cooldownTimerFired(_ timer: Timer) {
        if ((self.filterString?.characters.count) != nil  && self.filterString != self.stringCurrentlyBeingFiltered && self.mentionEnabled) {
            self.stringCurrentlyBeingFiltered = filterString
            self.mentionsManager.showMentionsListWithString(filterString!)
        }
    }

    /**
     @brief Activates a cooldown timer
     */
    fileprivate func activateCooldownTimer() {
        self.cooldownTimer?.invalidate()

        let timer = Timer.init(
            timeInterval: self.cooldownInterval,
            target: self,
            selector: #selector(SZMentionsListener.cooldownTimerFired(_:)),
            userInfo: nil,
            repeats: false)
        self.cooldownTimer = timer
        RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }

    // MARK: TextView Delegate

    open func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String) -> Bool {
        assert((textView.delegate?.isEqual(self))!,
               "Textview delegate must be set equal to SZMentionsListener")

        if text == "\n" && self.addMentionAfterReturnKey && self.mentionEnabled {
            self.mentionsManager.shouldAddMentionOnReturnKey?()
            self.mentionEnabled = false
            self.mentionsManager.hideMentionsList()

            return false
        }
        let _ = self.delegate?.textView?(
            textView,
            shouldChangeTextIn: range,
            replacementText: text)

        if (self.settingText == true) {
            return false
        }

        return self.shouldAdjust(textView, range: range, text: text)
    }

    open func textViewDidChange(_ textView: UITextView) {
        self.delegate?.textViewDidChange?(textView)
    }

    open func textView(
        _ textView: UITextView,
        shouldInteractWith textAttachment: NSTextAttachment,
        in characterRange: NSRange) -> Bool {

        let _ = self.delegate?.textView?(
            textView,
            shouldInteractWith: textAttachment,
            in: characterRange)

        return true
    }

    open func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange) -> Bool {

        let _ = self.delegate?.textView?(textView, shouldInteractWith: URL, in: characterRange)

        return true
    }

    open func textViewDidBeginEditing(_ textView: UITextView) {
        self.delegate?.textViewDidBeginEditing?(textView)
    }

    open func textViewDidChangeSelection(_ textView: UITextView) {
        if editingMention == false {
            self.adjust(textView, range: textView.selectedRange)
            self.delegate?.textViewDidChangeSelection?(textView)
        }
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.textViewDidEndEditing?(textView)
    }
    
    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let shouldBeginEditing = self.delegate?.textViewShouldBeginEditing?(textView) {
            return shouldBeginEditing
        }
        
        return true
    }
    
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let shouldEndEditing = self.delegate?.textViewShouldEndEditing?(textView) {
            return shouldEndEditing
        }
        
        return true
    }
}
