@testable import SZMentionsSwift
import XCTest

private final class MentionsArraySearchTests: XCTestCase {
    var mentions: [Mention]!

    override func setUp() {
        super.setUp()
        mentions = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]
    }

    func test_shouldNOTReturnMentionBeingEditedIfPositionedBEFORETheFIRSTLetterOfTheMention() {
        XCTAssertNil(mentions |> mentionBeingEdited(at: NSRange(location: 0, length: 0)))
    }

    func test_shouldReturnMentionBeingEditedIfPositionedAFTERTheFIRSTLetterOfTheMention() {
        XCTAssertEqual(mentions |> mentionBeingEdited(at: NSRange(location: 1, length: 0)), mentions[0])
    }

    func test_shouldReturnMentionBeingEditedIfPositionedBEFORETheLASTLetterOfTheMention() {
        XCTAssertEqual(mentions |> mentionBeingEdited(at: NSRange(location: 9, length: 0)), mentions[0])
    }

    func test_shouldNOTReturnMentionBeingEditedIfPositionedAFTERTheLASTLetterOfTheMention() {
        XCTAssertNil(mentions |> mentionBeingEdited(at: NSRange(location: 10, length: 0)))
    }
}

private final class MentionsArrayAdjustTests: XCTestCase {
    func test_shouldProperlyAdjustTheLocationOfMentionsLocatedAfterAddedText() {
        var mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention()),
                                   Mention(range: NSRange(location: 15, length: 10), object: ExampleMention())]

        let insertText = "Test "
        XCTAssertEqual(mentions[0].range.location, 0)
        XCTAssertEqual(mentions[1].range.location, 15)
        mentions = mentions |> adjusted(forTextChangeAt: NSRange(location: 5, length: 0), text: insertText)
        XCTAssertEqual(mentions[0].range.location, 0)
        XCTAssertEqual(mentions[1].range.location, 15 + insertText.count)
    }
}

private final class MentionsArrayMentionBeingEditedTests: XCTestCase {
    func test_shouldReturnNilBeingEditedIfSelectionIsBeforeTheFirstLetter() {
        let mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]

        XCTAssertNil(mentions |> mentionBeingEdited(at: NSRange(location: 0, length: 0)))
    }

    func test_shouldReturnTheMentionBeingEditedIfSelectionIsAfterTheFirstLetter() {
        let mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]

        XCTAssertNotNil(mentions |> mentionBeingEdited(at: NSRange(location: 1, length: 0)))
    }

    func test_shouldReturnNilBeingEditedIfSelectionIsAfterTheLastLetter() {
        let mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]

        XCTAssertNil(mentions |> mentionBeingEdited(at: NSRange(location: 10, length: 0)))
    }

    func test_shouldReturnTheMentionBeingEditedIfSelectionIsBeforeTheLastLetter() {
        let mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]

        XCTAssertNotNil(mentions |> mentionBeingEdited(at: NSRange(location: 9, length: 0)))
    }

    func test_shouldReturnTheMentionBeingEditedIfSelectionIntersectsTheMentionAtTheBeginning() {
        let mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]

        XCTAssertNotNil(mentions |> mentionBeingEdited(at: NSRange(location: 0, length: 3)))
    }

    func test_shouldReturnTheMentionBeingEditedIfSelectionIntersectsTheMentionAtTheEnd() {
        let mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]

        XCTAssertNotNil(mentions |> mentionBeingEdited(at: NSRange(location: 9, length: 3)))
    }
}

private final class MentionsArrayInsertMentionTests: XCTestCase {
    func test_shouldReturnANewMentionsArrayWithAMentionInserted() {
        var mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]
        let createMentionObject = ExampleMention(name: "Test Mention")
        mentions = mentions |> insert([(createMentionObject, NSRange(location: 15, length: 12))])
        XCTAssertEqual(mentions.count, 2)
        XCTAssertEqual(mentions[1], Mention(range: NSRange(location: 15, length: 12), object: createMentionObject))
    }
}

private final class MentionsArrayRemoveMentionTests: XCTestCase {
    func test_shouldReturnAnArrayWithASingleItemRemoved() {
        var mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention()),
                                   Mention(range: NSRange(location: 13, length: 10), object: ExampleMention())]
        mentions = mentions |> remove([mentions[0]])
        XCTAssertEqual(mentions.count, 1)
    }

    func test_shouldReturnAnArrayWithAMultipleItemsRemoved() {
        var mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention()),
                                   Mention(range: NSRange(location: 13, length: 10), object: ExampleMention())]
        mentions = mentions |> remove([mentions[0], mentions[1]])
        XCTAssertTrue(mentions.isEmpty)
    }
}

private final class MentionsArrayAddMentionTests: XCTestCase {
    func test_shouldReturnAnArrayWithASingleItemAdded() {
        var mentions: [Mention] = [Mention(range: NSRange(location: 0, length: 10), object: ExampleMention())]
        let mentionToAdd = ExampleMention(name: "Added Mention")
        mentions = mentions |> SZMentionsSwift.add(mentionToAdd, spaceAfterMention: false, at: NSRange(location: 0, length: 0))
        XCTAssertEqual(mentions.count, 2)
        XCTAssertEqual(mentions[0], Mention(range: NSRange(location: 13, length: 10), object: ExampleMention()))
        XCTAssertEqual(mentions[1], Mention(range: NSRange(location: 0, length: 13), object: mentionToAdd))
    }
}
