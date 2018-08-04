@testable import SZMentionsSwift

class SZExampleMention: CreateMention {
    var name = ""
    var range = NSRange(location: 0, length: 0)
}

var shouldAddMentionOnReturnKeyCalled = false
var hidingMentionsList = false
var mentionsString = ""
var triggerString = ""

let hideMentionsBlock: () -> Void = { hidingMentionsList = true }
let showMentionsBlock: (String, String) -> Void = { (mention, trigger) in
    hidingMentionsList = false
    mentionsString = mention
    triggerString = trigger
}
let didHandleMentionBlock: () -> Bool = { () -> Bool in
    shouldAddMentionOnReturnKeyCalled = true
    return true
}
