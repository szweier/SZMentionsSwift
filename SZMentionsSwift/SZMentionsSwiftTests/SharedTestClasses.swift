@testable import SZMentionsSwift

class SZExampleMention: CreateMention {
    var name = ""
    var range = NSRange(location: 0, length: 0)
}

var shouldAddMentionOnReturnKeyCalled = false
var hidingMentionsList = false

let hideMentionsBlock: () -> Void = { hidingMentionsList = true }
let showMentionsBlock: (String) -> Void = { _ in
    hidingMentionsList = false
}
let didHandleMentionBlock: () -> Bool = { () -> Bool in
    shouldAddMentionOnReturnKeyCalled = true
    return true
}
