@testable import SZMentionsSwift

struct ExampleMention: CreateMention {
    var name = ""
    var range = NSRange(location: 0, length: 0)
}

var shouldAddMentionOnReturnKeyCalled = false
var hidingMentionsList = false
var mentionsString = ""
var triggerString = ""

func hideMentions() { hidingMentionsList = true }
func showMentions(mention: String, trigger: String) {
    hidingMentionsList = false
    mentionsString = mention
    triggerString = trigger
}
func didHandleMention() -> Bool {
    shouldAddMentionOnReturnKeyCalled = true
    return true
}
