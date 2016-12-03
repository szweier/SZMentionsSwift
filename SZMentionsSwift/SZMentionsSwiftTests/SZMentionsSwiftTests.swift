//
//  SZMentionsSwiftTests.swift
//  SZMentionsSwiftTests
//
//  Created by Steven Zweier on 1/16/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import XCTest
@testable import SZMentionsSwift

class SZExampleMention: SZCreateMentionProtocol {
    @objc var szMentionName: String = ""
    @objc var szMentionRange: NSRange = NSMakeRange(0, 0)
}

class SZMentionsSwiftTests: XCTestCase, SZMentionsManagerProtocol, UITextViewDelegate {
    let textView = UITextView.init()
    var hidingMentionsList = true
    var mentionString = ""
    var mentionsListener: SZMentionsListener?

    override func setUp() {
        super.setUp()
        let attribute = SZAttribute.init(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.red)
        let attribute2 = SZAttribute.init(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.black)

        mentionsListener = SZMentionsListener.init(mentionTextView: textView,
            mentionsManager: self,
            textViewDelegate: self,
            mentionTextAttributes: [attribute],
            defaultTextAttributes: [attribute2],
            spaceAfterMention: false,
            addMentionOnReturnKey: true)
    }

    func testThatAddingAttributesThatDoNotMatchThrowsAnError() {
        let attribute = SZAttribute.init(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.red)
        let attribute2 = SZAttribute.init(attributeName: NSBackgroundColorAttributeName, attributeValue: UIColor.black)

        let defaultAttributes = [attribute]
        let mentionAttributes = [attribute, attribute2]

        XCTAssert(mentionsListener!.attributesSetCorrectly(mentionAttributes, defaultAttributes: defaultAttributes) == false)
    }

    func testThatAddingAttributesThatDoMatchDoesNotThrowAnError() {
        let attribute = SZAttribute.init(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.red)
        let attribute2 = SZAttribute.init(attributeName: NSBackgroundColorAttributeName, attributeValue: UIColor.black)

        let defaultAttributes = [attribute, attribute2]
        let mentionAttributes = [attribute2, attribute]

        XCTAssert(mentionsListener!.attributesSetCorrectly(mentionAttributes, defaultAttributes: defaultAttributes) == true)
    }

    func testMentionListIsDisplayed() {
        textView.insertText("@t")
        XCTAssert(hidingMentionsList == false)
    }

    func testMentionListIsHidden() {
        textView.insertText("@t")
        XCTAssert(hidingMentionsList == false)
        textView.insertText(" ")
        XCTAssert(hidingMentionsList == true)
    }
  
    func testMentionsCanBePlacedInAdvance() {
        textView.text = "Testing Steven Zweier and Tiffany get mentioned correctly";

        let mention = SZExampleMention()
        mention.szMentionName = "Steve"
        mention.szMentionRange = NSMakeRange(8, 13)

        let mention2 = SZExampleMention()
        mention2.szMentionName = "Tiff"
        mention2.szMentionRange = NSMakeRange(26, 7)

        let insertMentions : Array<SZCreateMentionProtocol> = [mention, mention2]

        mentionsListener!.insertExistingMentions(insertMentions)

        XCTAssert(mentionsListener!.mentions.count == 2)
        XCTAssert((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: nil)! as AnyObject).isEqual( UIColor.black))
        XCTAssert((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 9, effectiveRange: nil)! as AnyObject).isEqual( UIColor.red))
        XCTAssert((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 21, effectiveRange: nil)! as AnyObject).isEqual( UIColor.black))
        XCTAssert((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 27, effectiveRange: nil)! as AnyObject).isEqual( UIColor.red))
        XCTAssert((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 33, effectiveRange: nil)! as AnyObject).isEqual( UIColor.black))
    }

    func testMentionIsAdded() {
        textView.insertText("@t")
        let mention = SZExampleMention.init()
        mention.szMentionName = "Steven"
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.count == 1)
    }

    func testMentionPositionIsCorrectToStartText() {
        textView.insertText("@t")
        let mention = SZExampleMention.init()
        mention.szMentionName = "Steven"
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 0)
    }

    func testMentionPositionIsCorrectInTheMidstOfText() {
        textView.insertText("Testing @t")
        let mention = SZExampleMention.init()
        mention.szMentionName = "Steven"
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 8)
    }

    func testMentionLengthIsCorrect() {
        textView.insertText("@t")
        var mention = SZExampleMention.init()
        mention.szMentionName = "Steven"
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.length == 6)

        textView.insertText("Testing @t")
        mention = SZExampleMention.init()
        mention.szMentionName = "Steven Zweier"
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions[1].mentionRange.length == 13)
    }

    func testMentionLocationIsAdjustedProperly() {
        textView.insertText("Testing @t")
        let mention = SZExampleMention.init()
        mention.szMentionName = "Steven"
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 8)

        var beginning = textView.beginningOfDocument
        var start = textView.position(from: beginning, offset: 0)
        var end = textView.position(from: start!, offset: 3)

        var textRange = textView.textRange(from: start!, to: end!)

        if mentionsListener?.textView(textView, shouldChangeTextIn: NSMakeRange(0, 3), replacementText: "") == true {
            textView.replace(textRange!, withText: "")
        }

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 5)

        beginning = textView.beginningOfDocument
        start = textView.position(from: beginning, offset: 0)
        end = textView.position(from: start!, offset: 5)

        textRange = textView.textRange(from: start!, to: end!)

        if mentionsListener?.textView(textView, shouldChangeTextIn: NSMakeRange(0, 5), replacementText: "") == true {
            textView.replace(textRange!, withText: "")
        }

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 0)
    }

    func testMentionLocationIsAdjustedProperlyWhenAMentionIsInsertsBehindAMentionSpaceAfterMentionIsFalse() {
        textView.insertText("@t")
        var mention = SZExampleMention.init()
        mention.szMentionName = "Steven"
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 0)
        XCTAssert(mentionsListener?.mentions.first?.mentionRange.length == 6)

        textView.selectedRange = NSMakeRange(0, 0)

        if mentionsListener?.textView(textView, shouldChangeTextIn: NSMakeRange(0, 0), replacementText: "@t") == true {
            textView.insertText("@t")
        }
        mention = SZExampleMention.init()
        mention.szMentionName = "Steven Zweier"
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions[1].mentionRange.location == 0)
        XCTAssert(mentionsListener?.mentions[1].mentionRange.length == 13)
        XCTAssert(mentionsListener?.mentions[0].mentionRange.location == 13)
    }

    func testMentionLocationIsAdjustedProperlyWhenAMentionIsInsertsBehindAMentionSpaceAfterMentionIsTrue() {
        mentionsListener?.spaceAfterMention = true
        textView.insertText("@t")
        var mention = SZExampleMention.init()
        mention.szMentionName = "Steven"
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 0)
        XCTAssert(mentionsListener?.mentions.first?.mentionRange.length == 6)

        textView.selectedRange = NSMakeRange(0, 0)

        if mentionsListener?.textView(textView, shouldChangeTextIn: NSMakeRange(0, 0), replacementText: "@t") == true {
            textView.insertText("@t")
        }
        mention = SZExampleMention.init()
        mention.szMentionName = "Steven Zweier"
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions[1].mentionRange.location == 0)
        XCTAssert(mentionsListener?.mentions[1].mentionRange.length == 13)
        XCTAssert(mentionsListener?.mentions[0].mentionRange.location == 14)
    }

    func testEditingTheMiddleOfTheMentionRemovesTheMention() {
        textView.insertText("Testing @t")
        let mention = SZExampleMention.init()
        mention.szMentionName = "Steven"
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.count == 1)

        textView.selectedRange = NSMakeRange(11, 1)

        if mentionsListener?.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "") == true {
            textView.deleteBackward()
        }

        XCTAssert(mentionsListener?.mentions.count == 0)
    }

    func testEditingTheEndOfTheMentionRemovesTheMention() {
        textView.insertText("Testing @t")
        let mention = SZExampleMention.init()
        mention.szMentionName = "Steven"
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.count == 1)

        textView.selectedRange = NSMakeRange(13, 1)

        if mentionsListener?.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "") == true {
            textView.deleteBackward()
        }

        XCTAssert(mentionsListener?.mentions.count == 0)
    }

    func testEditingAfterTheMentionDoesNotDeleteTheMention() {
        textView.insertText("Testing @t")
        let mention = SZExampleMention.init()
        mention.szMentionName = "Steven"
        mentionsListener?.addMention(mention)

        textView.insertText(" ")

        XCTAssert(mentionsListener?.mentions.count == 1)

        textView.selectedRange = NSMakeRange(14, 1)

        if mentionsListener?.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "") == true {
            textView.deleteBackward()
        }

        XCTAssert(mentionsListener?.mentions.count == 1)
    }

    func testPastingTextBeforeLeadingMentionResetsAttributes() {
        textView.insertText("@s")
        let mention = SZExampleMention.init()
        mention.szMentionName = "Steven"
        mentionsListener?.addMention(mention)
        textView.selectedRange = NSMakeRange(0, 0)
        if mentionsListener?.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "test") == true {
            textView.insertText("test")
        }
        XCTAssert((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: nil)! as AnyObject).isEqual( UIColor.black))
    }

    func hideMentionsList() {
        hidingMentionsList = true
    }

    func showMentionsListWithString(_ mentionsString: String) {
        hidingMentionsList = false
        mentionString = mentionsString
    }

    func testMentionsLibraryReplacesCorrectMentionRangeIfMultipleExistAndThatSelectedRangeWillBeCorrect()
    {
        textView.insertText(" @st")
        textView.selectedRange = NSMakeRange(0, 0)
        textView.insertText("@st")

        let mention = SZExampleMention.init()
        mention.szMentionName = "Steven"

        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions[0].mentionRange.location == 0);
        XCTAssert(self.textView.selectedRange.location == 6);
    }

    func testMentionsLibraryReplacesCorrectMentionRangeIfMultipleExistAndThatSelectedRangeWillBeCorrectWithSpaceAfterMentionEnabled()
    {
        mentionsListener?.spaceAfterMention = true
        textView.insertText(" @st")
        textView.selectedRange = NSMakeRange(0, 0)
        textView.insertText("@st")

        let mention = SZExampleMention.init()
        mention.szMentionName = "Steven"

        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions[0].mentionRange.location == 0);
        XCTAssert(self.textView.selectedRange.location == 7);
    }

    func testAddingTestImmediatelyAfterMentionChangesToDefaultText()
    {
        textView.insertText("@s")
        let mention = SZExampleMention()
        mention.szMentionName = "Steven"
        self.mentionsListener?.addMention(mention)

        if mentionsListener?.textView(textView, shouldChangeTextIn: self.textView.selectedRange, replacementText: "test") == true {
            textView.insertText("test")
        }

        XCTAssert((textView.attributedText.attribute(NSForegroundColorAttributeName, at: textView.selectedRange.location - 1, effectiveRange: nil)! as AnyObject).isEqual( UIColor.black))
    }

    func testCheckDeletingTextDuringMentionCreation()
    {
        textView.insertText("@")
        textView.insertText("s")
        textView.insertText("t")
        textView.insertText("e")
        textView.deleteBackward()
        textView.deleteBackward()
        mentionsListener?.cooldownTimerFired(Timer())
        textView.deleteBackward()
        mentionsListener?.cooldownTimerFired(Timer())

        XCTAssert(textView.text.characters.count == 1)
    }
    
    func testMentionListOnNewlineIsDisplayed() {
        textView.insertText("\n@t")
        XCTAssert(hidingMentionsList == false)
    }
    
    func testMentionListOnNewLineIsHidden() {
        textView.insertText("\n@t")
        XCTAssert(hidingMentionsList == false)
        textView.insertText(" ")
        XCTAssert(hidingMentionsList == true)
    }
    
    func testMentionPositionIsCorrectToStartTextOnNewline() {
        textView.insertText("\n@t")
        let mention = SZExampleMention.init()
        mention.szMentionName = "Steven"
        mentionsListener?.addMention(mention)
        
        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 1)
    }

    func testMentionPositionIsCorrectInTheMidstOfNewlineText() {
        textView.insertText("Testing \nnew line @t")
        let mention = SZExampleMention.init()
        mention.szMentionName = "Steven"
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 18)
    }

    func testTwoMentionsDeletedAtOnceDoesntCrash() {
        textView.insertText("@St")
        var mention = SZExampleMention.init()
        mention.szMentionName = "Steven Zweier"
        mentionsListener?.addMention(mention)

        textView.insertText(" ")

        textView.insertText("@Jo")
        mention = SZExampleMention.init()
        mention.szMentionName = "John Smith"
        mentionsListener?.addMention(mention)

        textView.selectedRange = NSMakeRange(0, textView.text.characters.count)

        if mentionsListener?.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "") == true {
            textView.deleteBackward()
        }
        XCTAssert(textView.text.isEmpty)
    }

    func testShouldAddMentionOnReturnKeyShouldCalledWhenHitReturnKey() {

        mentionsListener?.addMentionAfterReturnKey = true

        textView.insertText("@t")
        XCTAssert(hidingMentionsList == false)

        if mentionsListener?.textView(textView, shouldChangeTextIn: self.textView.selectedRange, replacementText: "\n") == true {
            textView.insertText("\n")
        }

        XCTAssertTrue(shouldAddMentionOnReturnKeyCalled)
        XCTAssert(hidingMentionsList == true)
    }

    func testShouldHaveCorrectDefaultColor() {
        let attribute: SZAttribute = SZDefaultAttributes.defaultColor
        XCTAssertTrue(attribute.attributeName == NSForegroundColorAttributeName)
        XCTAssertTrue(attribute.attributeValue == UIColor.black)
    }

    func testShouldHaveCorrectMentionColor() {
        let attribute: SZAttribute = SZDefaultAttributes.mentionColor
        XCTAssertTrue(attribute.attributeName == NSForegroundColorAttributeName)
        XCTAssertTrue(attribute.attributeValue == UIColor.blue)
    }

    func testShouldHaveCorrectDefaultTextAttributes() {
        let attributes: [SZAttribute] = SZDefaultAttributes.defaultTextAttributes()
        let attribute = attributes[0]
        XCTAssertTrue(attributes.count == 1)
        XCTAssertTrue(attribute.attributeName == NSForegroundColorAttributeName)
        XCTAssertTrue(attribute.attributeValue == UIColor.black)
    }

    func testShouldHaveCorrectDefaultMentionAttributes() {
        let attributes: [SZAttribute] = SZDefaultAttributes.defaultMentionAttributes()
        let attribute = attributes[0]
        XCTAssertTrue(attributes.count == 1)
        XCTAssertTrue(attribute.attributeName == NSForegroundColorAttributeName)
        XCTAssertTrue(attribute.attributeValue == UIColor.blue)
    }

    func testResetEmptyIsCalled() {
        textView.insertText("@t")
        let mention = SZExampleMention.init()
        mention.szMentionName = "John Smith"
        mentionsListener?.addMention(mention)
        XCTAssertTrue(mentionsListener?.mentions.count == 1)
        textView.attributedText = NSAttributedString(string: "test")
        textView.text = ""
        let _ = mentionsListener?.textView(textView, shouldChangeTextIn: NSMakeRange(0, 0), replacementText: "")
        XCTAssertTrue(mentionsListener?.mentions.count == 0)
    }

    func testAddMentionStopsRunningIfCurrentMentionRangeIsNil() {
        let mention = SZExampleMention.init()
        mention.szMentionName = "John Smith"
        XCTAssertTrue(mentionsListener?.addMention(mention) == false)
    }

    func testMentionListenerTextAttachmentDelegateReturnsTrue() {
        XCTAssertTrue(mentionsListener?.textView(textView, shouldInteractWith: NSTextAttachment(), in: NSMakeRange(0, 0)) == true)
    }

    func testMentionListenerURLDelegateReturnsTrue() {
        XCTAssertTrue(mentionsListener?.textView(textView, shouldInteractWith: URL(string: "http://test.com")!, in: NSMakeRange(0, 0)) == true)
    }

    func testMentionListenerShouldBeginEditingReturnsTrueWhenNotOverridden() {
        XCTAssertTrue(mentionsListener?.textViewShouldBeginEditing(textView) == true)
    }

    func testMentionListenerShouldBeginEditingReturnsDelegateResponse() {
        let delegate = testDelegate()
        let mentionsListener = SZMentionsListener.init(mentionTextView: textView,
                                                       mentionsManager: self,
                                                       textViewDelegate: delegate,
                                                       spaceAfterMention: false,
                                                       addMentionOnReturnKey: true)
        XCTAssertTrue(mentionsListener.textViewShouldBeginEditing(textView) == true)
        delegate.shouldBeginEditing = false
        XCTAssertTrue(mentionsListener.textViewShouldBeginEditing(textView) == false)
    }

    func testMentionListenerShouldEndEditingReturnsTrueWhenNotOverridden() {
        XCTAssertTrue(mentionsListener?.textViewShouldEndEditing(textView) == true)
    }

    func testMentionListenerShouldEndEditingReturnsDelegateResponse() {
        let delegate = testDelegate()
        let mentionsListener = SZMentionsListener.init(mentionTextView: textView,
                                                       mentionsManager: self,
                                                       textViewDelegate: delegate,
                                                       spaceAfterMention: false,
                                                       addMentionOnReturnKey: true)
        XCTAssertTrue(mentionsListener.textViewShouldEndEditing(textView) == true)
        delegate.shouldEndEditing = false
        XCTAssertTrue(mentionsListener.textViewShouldEndEditing(textView) == false)
    }

    func testMentionListenerDidBeginEditingReturnsDelegateResponse() {
        let delegate = testDelegate()
        let mentionsListener = SZMentionsListener.init(mentionTextView: textView,
                                                       mentionsManager: self,
                                                       textViewDelegate: delegate,
                                                       spaceAfterMention: false,
                                                       addMentionOnReturnKey: true)
        XCTAssertTrue(delegate.triggeredDelegateMethod == false)
        mentionsListener.textViewDidBeginEditing(textView)
        XCTAssertTrue(delegate.triggeredDelegateMethod == true)
    }

    func testMentionListenerDidEndEditingReturnsDelegateResponse() {
        let delegate = testDelegate()
        let mentionsListener = SZMentionsListener.init(mentionTextView: textView,
                                                       mentionsManager: self,
                                                       textViewDelegate: delegate,
                                                       spaceAfterMention: false,
                                                       addMentionOnReturnKey: true)
        XCTAssertTrue(delegate.triggeredDelegateMethod == false)
        mentionsListener.textViewDidEndEditing(textView)
        XCTAssertTrue(delegate.triggeredDelegateMethod == true)
    }

    var shouldAddMentionOnReturnKeyCalled = false

    func shouldAddMentionOnReturnKey() {
      shouldAddMentionOnReturnKeyCalled = true
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}

class testDelegate: NSObject, UITextViewDelegate {
    var shouldBeginEditing: Bool = true
    var shouldEndEditing: Bool = true
    var triggeredDelegateMethod: Bool = false

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        triggeredDelegateMethod = true
        return shouldBeginEditing
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        triggeredDelegateMethod = true
        return shouldEndEditing
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        triggeredDelegateMethod = true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        triggeredDelegateMethod = true
    }
}
