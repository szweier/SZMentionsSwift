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

    var textView = UITextView.init()
    var hidingMentionsList = true
    var mentionString = ""
    var mentionsListener: SZMentionsListener?

    override func setUp() {
        super.setUp()
        mentionsListener = SZMentionsListener.init(
            mentionTextView: textView,
            mentionsManager: self)
        mentionsListener?.delegate = self
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
        mentionsListener?.spaceAfterMention = true
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

    func hideMentionsList() {
        hidingMentionsList = true
    }

    func showMentionsListWithString(mentionsString: String) {
        hidingMentionsList = false
        mentionString = mentionsString
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
