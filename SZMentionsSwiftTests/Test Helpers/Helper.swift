@testable import SZMentionsSwift
import UIKit

extension NSRange {
    var advance: NSRange {
        return NSRange(location: location + 1, length: length)
    }
}

struct ExampleMention: CreateMention {
    var name = ""
}

enum TextUpdate {
    case insert
    case delete
    case replace
}

func type(text: String, at range: NSRange? = nil, on listener: MentionListener) {
    var newRange = range
    text.forEach { letter in
        update(text: String(letter), type: .insert, at: newRange, on: listener)
        newRange = newRange?.advance
    }
}

func update(text: String, type: TextUpdate, at range: NSRange? = nil, on listener: MentionListener) {
    let textView = listener.mentionsTextView
    if let range = range { textView.selectedRange = range }
    if listener.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: text) {
        switch type {
        case .insert:
            textView.insertText(text)
        case .delete:
            textView.deleteBackward()
        case .replace:
            if let range = textView.selectedTextRange {
                textView.replace(range, withText: text)
            }
        }
    }
}

@discardableResult func addMention(named name: String, on listener: MentionListener) -> Bool {
    let mention = ExampleMention(name: name)
    return listener.addMention(mention)
}
