import Quick
import Nimble
@testable import SZMentionsSwift

class AddingMentions: QuickSpec {
    override func spec() {
        describe("Adding Mentions") {
            let textView = UITextView()
            var mentionsListener: SZMentionsListener!

            beforeEach {
                mentionsListener = generateMentionsListener(spaceAfterMention: false)
            }

            it("Should add mention") {
                textView.insertText("@t")
                let mention = SZExampleMention()
                mention.name = "Steven"
                mentionsListener.addMention(mention)

                expect(mentionsListener.mentions.count).to(equal(1))
            }

            it("Should add mention to the correct starting point") {
                textView.insertText("@t")
                let mention = SZExampleMention()
                mention.name = "Steven"
                mentionsListener.addMention(mention)

                expect(mentionsListener.mentions.first?.range.location).to(equal(0))
            }

            it("Should add mention to the correct starting point when added after text") {
                textView.insertText("Testing @t")
                let mention = SZExampleMention()
                mention.name = "Steven"
                mentionsListener.addMention(mention)

                expect(mentionsListener.mentions.first?.range.location).to(equal(8))
            }
            
            it("Should have the correct length of the mention created") {
                textView.insertText("@t")
                var mention = SZExampleMention()
                mention.name = "Steven"
                mentionsListener.addMention(mention)
                
                expect(mentionsListener.mentions.first?.range.length).to(equal(6))
                
                textView.insertText("Testing @t")
                mention = SZExampleMention()
                mention.name = "Steven Zweier"
                mentionsListener.addMention(mention)
                
                expect(mentionsListener.mentions.last?.range.length).to(equal(13))
            }
            
            it("Should have the correct length of the mention created") {
                textView.insertText("@t")
                let mention = SZExampleMention()
                mention.name = "Steven"
                mentionsListener.addMention(mention)
                
                expect(mentionsListener.mentions.first?.range.length).to(equal(6))
                
                textView.insertText(". ")

                #if swift(>=4.0)
                    expect((textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.red))
                    expect((textView.attributedText.attribute(.foregroundColor, at: 7, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                #else
                    expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.red))
                    expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 7, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                #endif
            }

            it("Should adjust the location of an existing mention correctly") {
                textView.insertText("Testing @t")
                let mention = SZExampleMention()
                mention.name = "Steven"
                mentionsListener.addMention(mention)

                expect(mentionsListener.mentions.first?.range.location).to(equal(8))

                var beginning = textView.beginningOfDocument
                var start = textView.position(from: beginning, offset: 0)
                var end = textView.position(from: start!, offset: 3)

                var textRange = textView.textRange(from: start!, to: end!)

                if mentionsListener.textView(textView, shouldChangeTextIn: NSRange(location: 0, length: 3), replacementText: "") {
                    textView.replace(textRange!, withText: "")
                }

                expect(mentionsListener.mentions.first?.range.location).to(equal(5))

                beginning = textView.beginningOfDocument
                start = textView.position(from: beginning, offset: 0)
                end = textView.position(from: start!, offset: 5)

                textRange = textView.textRange(from: start!, to: end!)

                if mentionsListener.textView(textView, shouldChangeTextIn: NSRange(location: 0, length: 5), replacementText: "") {
                    textView.replace(textRange!, withText: "")
                }

                expect(mentionsListener.mentions.first?.range.location).to(equal(0))
            }

            it("Should adjust the location of an existing mention correctly") {
                textView.insertText("@t")
                var mention = SZExampleMention()
                mention.name = "Steven"
                mentionsListener.addMention(mention)

                expect(mentionsListener.mentions.first?.range.location).to(equal(0))
                expect(mentionsListener.mentions.first?.range.length).to(equal(6))

                textView.selectedRange = NSRange(location: 0, length: 0)

                if mentionsListener.textView(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "@") {
                    textView.insertText("@")
                }
                if mentionsListener.textView(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "t") {
                    textView.insertText("t")
                }
                mention = SZExampleMention()
                mention.name = "Steven Zweier"
                mentionsListener.addMention(mention)

                expect(mentionsListener.mentions[1].range.location).to(equal(0))
                expect(mentionsListener.mentions[1].range.length).to(equal(13))
                expect(mentionsListener.mentions[0].range.location).to(equal(13))
            }

            it("Should remove the mention when editing the middle of a mention") {
                textView.insertText("Testing @t")
                let mention = SZExampleMention()
                mention.name = "Steven"
                mentionsListener.addMention(mention)

                expect(mentionsListener.mentions.count).to(equal(1))

                textView.selectedRange = NSRange(location: 11, length: 1)

                if mentionsListener.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "") {
                    textView.deleteBackward()
                }

                expect(mentionsListener.mentions.isEmpty).to(beTruthy())
            }

            it("Should test mention location is adjusted properly when a mention is inserted behind a mention when space after mention is true") {
                mentionsListener = generateMentionsListener(spaceAfterMention: true)
                textView.insertText("@t")
                var mention = SZExampleMention()
                mention.name = "Steven"
                mentionsListener.addMention(mention)

                expect(mentionsListener.mentions.first?.range.location).to(equal(0))
                expect(mentionsListener.mentions.first?.range.length).to(equal(6))

                textView.selectedRange = NSRange(location: 0, length: 0)

                if mentionsListener.textView(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "@t") {
                    textView.insertText("@t")
                }
                mention = SZExampleMention()
                mention.name = "Steven Zweier"
                mentionsListener.addMention(mention)

                expect(mentionsListener.mentions[1].range.location).to(equal(0))
                expect(mentionsListener.mentions[1].range.length).to(equal(13))
                expect(mentionsListener.mentions[0].range.location).to(equal(14))
            }

            it("Should test editing after mention does not delete the mention") {
                textView.insertText("Testing @t")
                let mention = SZExampleMention()
                mention.name = "Steven"
                mentionsListener.addMention(mention)

                textView.insertText(" ")

                expect(mentionsListener.mentions.count).to(equal(1))

                textView.selectedRange = NSRange(location: 14, length: 1)

                if mentionsListener.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "") {
                    textView.deleteBackward()
                }

                expect(mentionsListener.mentions.count).to(equal(1))
            }

            it("Should test that pasting text before a leading mention resets its attributes") {
                textView.insertText("@s")
                let mention = SZExampleMention()
                mention.name = "Steven"
                mentionsListener.addMention(mention)
                textView.selectedRange = NSRange(location: 0, length: 0)
                if mentionsListener.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "test") {
                    textView.insertText("test")
                }
                #if swift(>=4.0)
                    expect((textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                #else
                    expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                #endif
            }

            it("Should test that the correct mention range is replaced if multiple exist and that the selected range is correct") {
                textView.insertText(" @st")
                textView.selectedRange = NSRange(location: 0, length: 0)
                textView.insertText("@st")

                let mention = SZExampleMention()
                mention.name = "Steven"

                mentionsListener.addMention(mention)

                expect(mentionsListener.mentions[0].range.location).to(equal(0))
                expect(textView.selectedRange.location).to(equal(6))
            }

            it("Should test that the correct mention range is replaced if multiple exist and that the selected range is correct when space after mention is true") {
                mentionsListener = generateMentionsListener(spaceAfterMention: true)
                textView.insertText(" @st")
                textView.selectedRange = NSRange(location: 0, length: 0)
                textView.insertText("@st")

                let mention = SZExampleMention()
                mention.name = "Steven"

                mentionsListener.addMention(mention)

                expect(mentionsListener.mentions[0].range.location).to(equal(0))
                expect(textView.selectedRange.location).to(equal(7))
            }

            it("Should test that adding text immediately after the mention changes back to default attributes") {
                textView.insertText("@s")
                let mention = SZExampleMention()
                mention.name = "Steven"
                mentionsListener.addMention(mention)

                if mentionsListener.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "test") {
                    textView.insertText("test")
                }

                #if swift(>=4.0)
                    expect((textView.attributedText.attribute(.foregroundColor, at: textView.selectedRange.location - 1, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                #else
                    expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: textView.selectedRange.location - 1, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                #endif
            }

            it("Should test that the mention position is correct to start text on a new line") {
                textView.insertText("\n@t")
                let mention = SZExampleMention()
                mention.name = "Steven"
                mentionsListener.addMention(mention)

                expect(mentionsListener.mentions.first?.range.location).to(equal(1))
            }

            it("Should test that mention position is correct in the middle of new line text") {
                textView.insertText("Testing \nnew line @t")
                let mention = SZExampleMention()
                mention.name = "Steven"
                mentionsListener.addMention(mention)

                expect(mentionsListener.mentions.first?.range.location).to(equal(18))
            }

            it("Should accurately detect whether or not a mention is being edited") {
                textView.insertText("@s")
                let mention = SZExampleMention()
                mention.name = "Steven"
                mentionsListener.addMention(mention)

                expect(mentionsListener.mentions.mentionBeingEdited(atRange: NSRange(location: 0, length: 0))).to(beNil())
                textView.selectedRange = NSRange(location: 0, length: 0)
                _ = mentionsListener.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "t")
                expect(mentionsListener.mentions.mentionBeingEdited(atRange: NSRange(location: 1, length: 0))).to(beNil())
            }
            
            it("Should not crash when deleting two mentions at a time") {
                textView.insertText("@St")
                var mention = SZExampleMention()
                mention.name = "Steven Zweier"
                mentionsListener.addMention(mention)
                
                textView.insertText(" ")
                
                textView.insertText("@Jo")
                mention = SZExampleMention()
                mention.name = "John Smith"
                mentionsListener.addMention(mention)
                
                textView.selectedRange = NSRange(location: 0, length: textView.text.utf16.count)
                
                if mentionsListener.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "") {
                    textView.deleteBackward()
                }
                expect(textView.text.isEmpty).to(beTruthy())
            }
            
            it("Should remove existing mention when pasting text within the mention") {
                textView.insertText("@St")
                let mention = SZExampleMention()
                mention.name = "Steven Zweier"
                mentionsListener.addMention(mention)
                
                textView.selectedRange = NSRange(location: 7, length: 0)
                
                expect(mentionsListener.mentions.count).to(equal(1))
                expect(textView.attributedText.string).to(equal("Steven Zweier"))

                #if swift(>=4.0)
                    expect((textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.red))
                    expect((textView.attributedText.attribute(.foregroundColor, at: 12, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.red))
                #else
                    expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.red))
                    expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 12, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.red))
                #endif
                
                _ = mentionsListener.textView(textView, shouldChangeTextIn: textView.selectedRange, replacementText: "Test")
                
                expect(textView.attributedText.string).to(equal("Steven TestZweier"))
                #if swift(>=4.0)
                    expect((textView.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                    expect((textView.attributedText.attribute(.foregroundColor, at: 16, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                #else
                    expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                    expect((textView.attributedText.attribute(NSForegroundColorAttributeName, at: 16, effectiveRange: nil)! as! UIColor)).to(equal(UIColor.black))
                #endif
                expect(mentionsListener.mentions.count).to(equal(0))
            }
            
            it("Should call reset empty") {
                textView.insertText("@t")
                let mention = SZExampleMention()
                mention.name = "John Smith"
                mentionsListener.addMention(mention)
                XCTAssertTrue(mentionsListener.mentions.count == 1)
                textView.attributedText = NSAttributedString(string: "test")
                textView.text = ""
                _ = mentionsListener.textView(textView, shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "")
                expect(mentionsListener.mentions.isEmpty).to(beTruthy())
            }
            
            it("Should not add mention if range is nil") {
                let mention = SZExampleMention()
                mention.name = "John Smith"
                expect(mentionsListener.addMention(mention)).to(beFalsy())
            }

            it("Should properly delete text during mention creation") {
                textView.insertText("@")
                textView.insertText("s")
                textView.insertText("t")
                textView.insertText("e")
                textView.deleteBackward()
                textView.deleteBackward()
                mentionsListener.cooldownTimerFired(Timer())
                textView.deleteBackward()
                mentionsListener.cooldownTimerFired(Timer())

                expect(textView.text.utf16.count).to(equal(1))
            }

            it("Should properly add a space during mention creation") {
                textView.insertText("@")
                textView.insertText("s")
                textView.insertText("t")
                textView.insertText("e")
                textView.insertText(" ")
                mentionsListener.cooldownTimerFired(Timer())
                expect(textView.text.utf16.count).to(equal(5))
            }
            
            
            func generateMentionsListener(spaceAfterMention: Bool) -> SZMentionsListener {
                #if swift(>=4.0)
                let attribute = SZAttribute(name: NSAttributedStringKey.foregroundColor.rawValue, value: UIColor.red)
                let attribute2 = SZAttribute(name: NSAttributedStringKey.foregroundColor.rawValue, value: UIColor.black)
                #else
                let attribute = SZAttribute(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.red)
                let attribute2 = SZAttribute(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.black)
                #endif
                
                return SZMentionsListener(mentionTextView: textView,
                                          mentionTextAttributes: [attribute],
                                          defaultTextAttributes: [attribute2],
                                          spaceAfterMention: spaceAfterMention)
            }
        }
    }
}
