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
    fileprivate weak var delegate: UITextViewDelegate?

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
     */
    public init(
        mentionTextView textView: UITextView,
        mentionsManager manager: SZMentionsManagerProtocol,
        textViewDelegate: UITextViewDelegate? = nil,
        mentionTextAttributes mentionAttributes: [SZAttribute] = SZDefaultAttributes.defaultMentionAttributes(),
        defaultTextAttributes defaultAttributes: [SZAttribute] = SZDefaultAttributes.defaultTextAttributes(),
        spaceAfterMention spaceAfter: Bool = false,
        addMentionOnReturnKey mentionOnReturn: Bool = false,
        trigger mentionTrigger: String = "@",
        cooldownInterval interval: TimeInterval = 0.5) {
        SZVerifier.verifySetup(withDefaultTextAttributes: defaultAttributes,
                               mentionTextAttributes: mentionAttributes)
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
        let mutableAttributedString = mentionsTextView.attributedText.mutableCopy() as! NSMutableAttributedString

        existingMentions.forEach { mention in
            let range = mention.szMentionRange
            assert(range.location != NSNotFound, "Mention must have a range to insert into")

            let szMention = SZMention(mentionRange: range, mentionObject: mention)
            mutableMentions.append(szMention)

            SZAttributedStringHelper.apply(
                mentionTextAttributes,
                range:range,
                mutableAttributedString: mutableAttributedString)
        }

        settingText = true
        mentionsTextView.attributedText = mutableAttributedString
        settingText = false
    }

    /**
     @brief Adds a mention to the current mention range (determined by trigger + characters typed up to space or end of line)
     @param mention: the mention object to apply
     @return Bool: whether or not a mention was added
     */
    @discardableResult public func addMention(_ mention: SZCreateMentionProtocol) -> Bool {
        guard var currentMentionRange = currentMentionRange else { return false }

        filterString = nil
        var displayName = mention.szMentionName

        if spaceAfterMention { displayName = displayName + " " }

        let mutableAttributedString = mentionsTextView.attributedText.mutableCopy() as! NSMutableAttributedString
        mutableAttributedString.mutableString.replaceCharacters(
            in: currentMentionRange,
            with: displayName)

        SZMentionHelper.adjustMentions(currentMentionRange, text: displayName, mentions: mentions)

        currentMentionRange = NSMakeRange(
            currentMentionRange.location,
            mention.szMentionName.characters.count)

        let szmention = SZMention(
            mentionRange: currentMentionRange,
            mentionObject: mention)
        mutableMentions.append(szmention)

        SZAttributedStringHelper.apply(
            mentionTextAttributes,
            range: currentMentionRange,
            mutableAttributedString: mutableAttributedString)

        settingText = true

        var selectedRange = NSMakeRange(currentMentionRange.location + currentMentionRange.length, 0)

        mentionsTextView.attributedText = mutableAttributedString

        if spaceAfterMention { selectedRange.location += 1 }

        mentionsTextView.selectedRange = selectedRange
        settingText = false
        
        mentionsManager.hideMentionsList()
        
        return true
    }
}

// MARK: Private methods

extension SZMentionsListener {
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
    fileprivate func adjust(_ textView: UITextView, range: NSRange) {
        let substring = (textView.text as NSString).substring(to: range.location) as NSString
        var textBeforeTrigger = " "
        let location = substring.range(
            of: trigger,
            options: NSString.CompareOptions.backwards).location

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
            if let stringBeingTyped = substring.components(separatedBy: textBeforeTrigger).last,
                let stringForMention = stringBeingTyped.components(separatedBy: " ").last,
                (stringForMention as NSString).range(of: trigger).location != NSNotFound {

                currentMentionRange = (textView.text as NSString).range(
                    of: stringBeingTyped,
                    options: NSString.CompareOptions.backwards,
                    range: NSMakeRange(0, textView.selectedRange.location + textView.selectedRange.length))
                filterString = (stringBeingTyped as NSString).replacingOccurrences(
                    of: trigger,
                    with: "")
                filterString = filterString?.replacingOccurrences(of: "\n", with: "")

                if filterString != nil &&
                    (cooldownTimer == nil || cooldownTimer?.isValid == false) {
                    stringCurrentlyBeingFiltered = filterString
                    mentionsManager.showMentionsListWithString(filterString!)
                }
                activateCooldownTimer()
                return
            }
        }
        mentionEnabled = false
        mentionsManager.hideMentionsList()
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

        if let editedMention = SZMentionHelper.mentionBeingEdited(range, mentionsList: mentions) {
            if let index = mutableMentions.index(of: editedMention) {
                editingMention = true
                mutableMentions.remove(at: index)
            }

            shouldAdjust = handleEditingMention(editedMention, textView: textView, range: range, text: text)
        }

        if SZMentionHelper.needsToChangeToDefaultAttributes(textView, range: range, mentions: mentions) {
            shouldAdjust = forceDefaultAttributes(textView, range: range, text: text, replaceCharacters: editingMention == false)
        }

        SZMentionHelper.adjustMentions(range, text: text, mentions: mentions)

        _ = delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text)

        return shouldAdjust
    }

    /**
     @brief Forces default attributes on a string of text
     @param textView: the mentions text view
     @param range: the range of text being replaced
     @param text: the text to replace the range with
     @return Bool: false (we do not want the text view handling text input in this case)
     */
    private func forceDefaultAttributes(_ textView: UITextView, range: NSRange, text: String, replaceCharacters: Bool) -> Bool {
        let mutableAttributedString = textView.attributedText.mutableCopy() as! NSMutableAttributedString

        if replaceCharacters { mutableAttributedString.mutableString.replaceCharacters(in: range, with: text) }

        SZAttributedStringHelper.apply(
            defaultTextAttributes,
            range: NSRange(location: range.location, length: text.characters.count),
            mutableAttributedString: mutableAttributedString)
        settingText = true
        textView.attributedText = mutableAttributedString
        settingText = false

        var newRange = NSRange(location: range.location, length: 0)

        if newRange.length <= 0 { newRange.location = range.location + text.characters.count }

        textView.selectedRange = newRange

        return false
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
        let mutableAttributedString = textView.attributedText.mutableCopy() as! NSMutableAttributedString

        SZAttributedStringHelper.apply(
            defaultTextAttributes,
            range: mention.mentionRange,
            mutableAttributedString: mutableAttributedString)

        mutableAttributedString.mutableString.replaceCharacters(in: range, with: text)

        settingText = true
        textView.attributedText = mutableAttributedString
        settingText = false
        textView.selectedRange = NSMakeRange(range.location + text.characters.count, 0)

        _ = delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text)

        return false
    }

    /**
     @brief Calls show mentions if necessary when the timer fires
     @param timer: the timer that called the method
     */
    internal func cooldownTimerFired(_ timer: Timer) {
        if filterString != nil, filterString != stringCurrentlyBeingFiltered {
            stringCurrentlyBeingFiltered = filterString

            guard mentionsTextView.selectedRange.location >= 1 else { return }

            let range = (mentionsTextView.text as NSString).range(
                of: " ",
                options: NSString.CompareOptions.backwards,
                range: NSMakeRange(0, mentionsTextView.selectedRange.location + mentionsTextView.selectedRange.length))

            var location: Int = 0

            if range.location != NSNotFound {
                location = range.location + 1
            }

            let substringTrigger = (mentionsTextView.text as NSString).substring(with: NSMakeRange(location, 1))

            if substringTrigger == trigger {
                mentionsManager.showMentionsListWithString(filterString!)
            }
        }
    }

    /**
     @brief Activates a cooldown timer
     */
    private func activateCooldownTimer() {
        cooldownTimer?.invalidate()

        let timer = Timer(
            timeInterval: cooldownInterval,
            target: self,
            selector: #selector(SZMentionsListener.cooldownTimerFired(_:)),
            userInfo: nil,
            repeats: false)
        cooldownTimer = timer
        RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
}

// MARK: TextView Delegate

extension SZMentionsListener: UITextViewDelegate {

    public func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String) -> Bool {
        assert((textView.delegate?.isEqual(self))!,
               "Textview delegate must be set equal to SZMentionsListener")

        if text == "\n", addMentionAfterReturnKey, mentionEnabled {
            mentionsManager.shouldAddMentionOnReturnKey()
            mentionEnabled = false
            mentionsManager.hideMentionsList()

            return false
        }
        _ = delegate?.textView?(
            textView,
            shouldChangeTextIn: range,
            replacementText: text)

        if settingText { return false }

        return shouldAdjust(textView, range: range, text: text)
    }

    public func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewDidChange?(textView)
    }

    public func textView(
        _ textView: UITextView,
        shouldInteractWith textAttachment: NSTextAttachment,
        in characterRange: NSRange) -> Bool {

        _ = delegate?.textView?(
            textView,
            shouldInteractWith: textAttachment,
            in: characterRange)

        return true
    }

    public func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange) -> Bool {

        _ = delegate?.textView?(textView, shouldInteractWith: URL, in: characterRange)

        return true
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textViewDidBeginEditing?(textView)
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        if editingMention == false {
            adjust(textView, range: textView.selectedRange)
            delegate?.textViewDidChangeSelection?(textView)
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textViewDidEndEditing?(textView)
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let shouldBeginEditing = delegate?.textViewShouldBeginEditing?(textView) {
            return shouldBeginEditing
        }
        
        return true
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let shouldEndEditing = delegate?.textViewShouldEndEditing?(textView) {
            return shouldEndEditing
        }
        
        return true
    }
}
