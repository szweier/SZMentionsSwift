//
//  SZMentionsSwiftTests.swift
//  SZMentionsSwiftTests
//
//  Created by Steven Zweier on 1/16/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import XCTest
import SZMentionsSwift

class SZExampleMention: SZCreateMentionProtocol {
    var szMentionName: String = ""
}

class SZMentionsSwiftTests: XCTestCase, SZMentionsManagerProtocol, UITextViewDelegate {
    let textView = UITextView.init()
    var hidingMentionsList = true
    var mentionString = ""
    var mentionsListener: SZMentionsListener?

    override func setUp() {
        super.setUp()
        let attribute = SZAttribute.init(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.redColor())
        let attribute2 = SZAttribute.init(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.blackColor())

        mentionsListener = SZMentionsListener.init(mentionTextView: textView,
            mentionsManager: self,
            textViewDelegate: self,
            mentionTextAttributes: [attribute],
            defaultTextAttributes: [attribute2])
    }

    func testThatAddingAttributesThatDoNotMatchThrowsAnError() {
        let attribute = SZAttribute.init(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.redColor())
        let attribute2 = SZAttribute.init(attributeName: NSBackgroundColorAttributeName, attributeValue: UIColor.blackColor())

        let defaultAttributes = [attribute]
        let mentionAttributes = [attribute, attribute2]

        XCTAssert(mentionsListener!.attributesSetCorrectly(mentionAttributes, defaultAttributes: defaultAttributes) == false)
    }

    func testThatAddingAttributesThatDoMatchDoesNotThrowAnError() {
        let attribute = SZAttribute.init(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.redColor())
        let attribute2 = SZAttribute.init(attributeName: NSBackgroundColorAttributeName, attributeValue: UIColor.blackColor())

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
        var start = textView.positionFromPosition(beginning, offset: 0)
        var end = textView.positionFromPosition(start!, offset: 3)

        var textRange = textView.textRangeFromPosition(start!, toPosition: end!)

        if mentionsListener?.textView(textView, shouldChangeTextInRange: NSMakeRange(0, 3), replacementText: "").boolValue == true {
            textView.replaceRange(textRange!, withText: "")
        }

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 5)

        beginning = textView.beginningOfDocument
        start = textView.positionFromPosition(beginning, offset: 0)
        end = textView.positionFromPosition(start!, offset: 5)

        textRange = textView.textRangeFromPosition(start!, toPosition: end!)

        if mentionsListener?.textView(textView, shouldChangeTextInRange: NSMakeRange(0, 5), replacementText: "").boolValue == true {
            textView.replaceRange(textRange!, withText: "")
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

        if mentionsListener?.textView(textView, shouldChangeTextInRange: NSMakeRange(0, 0), replacementText: "@t").boolValue == true {
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
        mentionsListener?.setValue(true, forKey: "spaceAfterMention")
        textView.insertText("@t")
        var mention = SZExampleMention.init()
        mention.szMentionName = "Steven"
        mentionsListener?.addMention(mention)

        XCTAssert(mentionsListener?.mentions.first?.mentionRange.location == 0)
        XCTAssert(mentionsListener?.mentions.first?.mentionRange.length == 6)

        textView.selectedRange = NSMakeRange(0, 0)

        if mentionsListener?.textView(textView, shouldChangeTextInRange: NSMakeRange(0, 0), replacementText: "@t").boolValue == true {
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

        if mentionsListener?.textView(textView, shouldChangeTextInRange: textView.selectedRange, replacementText: "").boolValue == true {
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

        if mentionsListener?.textView(textView, shouldChangeTextInRange: textView.selectedRange, replacementText: "").boolValue == true {
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

        if mentionsListener?.textView(textView, shouldChangeTextInRange: textView.selectedRange, replacementText: "").boolValue == true {
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
        if mentionsListener?.textView(textView, shouldChangeTextInRange: textView.selectedRange, replacementText: "test").boolValue == true {
            textView.insertText("test")
        }
        XCTAssert(textView.attributedText.attribute(NSForegroundColorAttributeName, atIndex: 0, effectiveRange: nil)!.isEqual( UIColor.blackColor()))
    }

    func hideMentionsList() {
        hidingMentionsList = true
    }

    func showMentionsListWithString(mentionsString: String) {
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
        mentionsListener?.setValue(true, forKey: "spaceAfterMention")
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

        if mentionsListener?.textView(textView, shouldChangeTextInRange: self.textView.selectedRange, replacementText: "test").boolValue == true {
            textView.insertText("test")
        }

        XCTAssert(textView.attributedText.attribute(NSForegroundColorAttributeName, atIndex: textView.selectedRange.location - 1, effectiveRange: nil)!.isEqual( UIColor.blackColor()))
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
