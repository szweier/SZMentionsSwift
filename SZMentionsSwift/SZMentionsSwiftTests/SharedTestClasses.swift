@testable import SZMentionsSwift

class SZExampleMention: SZCreateMentionProtocol {
    var szMentionName: String = ""
    var szMentionRange: NSRange = NSMakeRange(0, 0)
}

class TestMentionDelegate: NSObject, SZMentionsManagerProtocol, UITextViewDelegate {
    var hidingMentionsList = false
    var shouldAddMentionOnReturnKeyCalled = false
    /**
     @brief Called when addMentionAfterReturnKey = true  (mention table show and user hit Return key).
     */
    func shouldAddMentionOnReturnKey() { shouldAddMentionOnReturnKeyCalled = true }

    /**
     @brief Called when the UITextView is not editing a mention.
     */
    func hideMentionsList() { hidingMentionsList = true }

    /**
     @brief Called when the UITextView is editing a mention.

     @param MentionString the current text entered after the mention trigger.
     Generally used for filtering a mentions list.
     */
    func showMentionsListWithString(_ mentionsString: String) { }
}
