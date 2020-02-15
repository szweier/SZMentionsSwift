# Change Log

## [2.1.3](https://github.com/szweier/SZMentionsSwift/releases/tag/2.1.3) (2/14/2020)

#### Fixed
* Deleting multiple mentions - [Issue #126](https://github.com/szweier/SZMentionsSwift/issues/126)

## [2.1.2](https://github.com/szweier/SZMentionsSwift/releases/tag/2.1.2) (10/25/2019)

#### Added
* Ability to have Emoji in Mention - [Issue #113](https://github.com/szweier/SZMentionsSwift/issues/113)
* Ability to remove the entire mention when edited - [Issue #110](https://github.com/szweier/SZMentionsSwift/issues/110)
* Fix autoCapitalizationType - [Issue #119](https://github.com/szweier/SZMentionsSwift/issues/119)

## [2.1.1](https://github.com/szweier/SZMentionsSwift/releases/tag/2.1.1) (4/30/2019)

#### Fixed
* Carthage - [Issue #105](https://github.com/szweier/SZMentionsSwift/issues/105)

## [2.1.0](https://github.com/szweier/SZMentionsSwift/releases/tag/2.1.0) (3/23/2019)

#### Added
* Carthage - [Issue #105](https://github.com/szweier/SZMentionsSwift/issues/105)
 
## [2.0.9](https://github.com/szweier/SZMentionsSwift/releases/tag/2.0.9) (3/9/2019)

#### Fixed
* No longer crashes when deleting a mention that is currently being edited when search spaces is enabled [Issue #102](https://github.com/szweier/SZMentionsSwift/issues/102)

## [2.0.8](https://github.com/szweier/SZMentionsSwift/releases/tag/2.0.8) (2/24/2019)

#### Fixed
* Enable public getter for mentions array [Issue #101](https://github.com/szweier/SZMentionsSwift/issues/101)

## [2.0.7](https://github.com/szweier/SZMentionsSwift/releases/tag/2.0.7) (2/6/2019)

#### Fixed
* Call proper delegate methods to notify about text changes made by the library [Issue #93](https://github.com/szweier/SZMentionsSwift/issues/93)
* Fix issue where the selectedRange wasn't properly set when spaceAfterMention was set to true [Issue #96](https://github.com/szweier/SZMentionsSwift/issues/96)

## [2.0.6](https://github.com/szweier/SZMentionsSwift/releases/tag/2.0.6) (1/31/2019)

#### Fixed
* Delegate method behavior [Issue #87](https://github.com/szweier/SZMentionsSwift/issues/87)

#### Cleaned
* Refactored code to become more functional

## [2.0.5](https://github.com/szweier/SZMentionsSwift/releases/tag/2.0.5) (10/8/2018)

#### Fixed
* Allow for mention text attributes to be set via a closure [Issue #80](https://github.com/szweier/SZMentionsSwift/issues/80)
* Ensure that the mentions list is shown/hidden correctly when pasting text [Issue #84](https://github.com/szweier/SZMentionsSwift/issues/84)

## [2.0.4](https://github.com/szweier/SZMentionsSwift/releases/tag/2.0.4) (8/19/2018)

#### Fixed
* Allow for resetting of textView and mentionsListener by calling reset() [Issue #75](https://github.com/szweier/SZMentionsSwift/issues/75)
* Using predictive text on when a textView has a lot of text results in scrolling to the top [Issue #76](https://github.com/szweier/SZMentionsSwift/issues/76)

## [2.0.3](https://github.com/szweier/SZMentionsSwift/releases/tag/2.0.3) (8/16/2018)

#### Fixed
* Double insertion of test when using predictive text on an empty textview [Issue #72](https://github.com/szweier/SZMentionsSwift/issues/72)
* Assertion failure when inserting mention after emoji [Issue #73](https://github.com/szweier/SZMentionsSwift/issues/73)

## [2.0.2](https://github.com/szweier/SZMentionsSwift/releases/tag/2.0.2)  (8/7/2018)

#### Fixed
* Exception 'NSRangeException' for searchSpaces feature [Issue #69](https://github.com/szweier/SZMentionsSwift/issues/69)

## [2.0.1](https://github.com/szweier/SZMentionsSwift/releases/tag/2.0.1)  (8/4/2018)

#### Cleaned
* Remove SZ prefix from class files

## [2.0.0](https://github.com/szweier/SZMentionsSwift/releases/tag/2.0.0)  (8/4/2018)

#### Cleaned
* Removed support for < swift 4.0
* Converted classes to structs where appropriate
* Renamed variables to remove redundancies

#### Fixed
* textView(_:shouldChangeTextIn:replacementString:) not being called [Issue #65](https://github.com/szweier/SZMentionsSwift/issues/65)

#### Note
* This release contains breaking changes. Please refer to the ReadMe and documentation within code for more information.

## [1.1.3](https://github.com/szweier/SZMentionsSwift/releases/tag/1.1.3)  (2/19/2018)

#### Cleaned
* Allow for multiple triggers to be chosen for triggering mentions [Issue #55](https://github.com/szweier/SZMentionsSwift/issues/55)

## [1.1.2](https://github.com/szweier/SZMentionsSwift/releases/tag/1.1.2)  (11/9/2017)

#### Cleaned
* Removed the last bit of warnings from most recent Apple updates

## [1.1.1](https://github.com/szweier/SZMentionsSwift/releases/tag/1.1.1) (10/30/2017)

#### Fixed
* Issue where auto correct moves selected range incorrectly

## [1.1.0](https://github.com/szweier/SZMentionsSwift/releases/tag/1.1.0) (9/23/2017)

#### Added
* Xcode 9 + Swift 4 compatibility

#### Note
* This release contains breaking changes, some methods have been updated for clarity as well as classes changes to protocols.
See README for more information.

## [1.0.9](https://github.com/szweier/SZMentionsSwift/releases/tag/1.0.9) (9/6/2017)

#### Added
* The ability to use `pod try SZMentionsSwift` reported by @slxl [Issue #49](https://github.com/szweier/SZMentionsSwift/issues/49)

## [1.0.8](https://github.com/szweier/SZMentionsSwift/releases/tag/1.0.8) (4/30/2017)

#### Fixed
* Issue with inserting text before a mention

#### Cleaned
* General code clean up

## [1.0.7](https://github.com/szweier/SZMentionsSwift/releases/tag/1.0.7) (4/22/2017)

#### Cleaned
* Moved to Quick & Nimble testing
* Updated tests
* Refactored code to be more Swifty
* Moved to static methods instead of class methods

## [1.0.6](https://github.com/szweier/SZMentionsSwift/releases/tag/1.0.6) (4/02/2017)

#### Added
* Option to search mentions that contain spaces thanks to @camdengaba. [Issue #42](https://github.com/szweier/SZMentionsSwift/issues/42)

## [1.0.5](https://github.com/szweier/SZMentionsSwift/releases/tag/1.0.5) (2/10/2017)

#### Fixed
* Issue where emoji can result in an incorrect attributed string appearance thanks to @raphaelcruzeiro

## [1.0.4](https://github.com/szweier/SZMentionsSwift/releases/tag/1.0.4) (2/7/2017)

#### Fixed
* Issue where the count was incorrect when using emoji thanks to @raphaelcruzeiro

## [1.0.3](https://github.com/szweier/SZMentionsSwift/releases/tag/1.0.3) (2/2/2017)

#### Fixed
* Issue where quickly typing an @mention with a space will result in a crash

## [1.0.2](https://github.com/szweier/SZMentionsSwift/releases/tag/1.0.2) (1/25/2017)

#### Fixed
* Issue reported by @raphaelcruzeiro [Issue #32](https://github.com/szweier/SZMentionsSwift/issues/32)

## [1.0.1](https://github.com/szweier/SZMentionsSwift/releases/tag/1.0.1) (1/10/2017)

#### Cleaned
* Refactored code base

#### Fixed
* Issue with cooldown timer not being triggered correctly in certain cases

## [1.0.0](https://github.com/szweier/SZMentionsSwift/releases/tag/1.0.0) (12/2/2016)

#### Added
* More test coverage


## [0.4.4](https://github.com/szweier/SZMentionsSwift/releases/tag/0.4.4) (11/30/2016)

#### Cleaned
* Cleaned codebase, improved use of internal & private

#### Removed
* Objective-C cross compatibility

## [0.4.3](https://github.com/szweier/SZMentionsSwift/releases/tag/0.4.3) (11/9/2016)

#### Fixed
* Crash when deleting text while adding mention

## [0.4.2](https://github.com/szweier/SZMentionsSwift/releases/tag/0.4.2) (11/8/2016)

#### Fixed
* Crash when deleting full line of multiple mentions
* Issue disallowing use of @ in mention name

## [0.4.1](https://github.com/szweier/SZMentionsSwift/releases/tag/0.4.1) (9/30/2016)

#### Fixed
* Setting swift 3.0 tag in build settings

## [0.4.0](https://github.com/szweier/SZMentionsSwift/releases/tag/0.4.0) (9/29/2016)

#### Added
* Swift 3.0 support

## [0.3.1](https://github.com/szweier/SZMentionsSwift/releases/tag/0.3.1) (8/29/2016)

#### Fixed
* Fixed potential retain cycle (thanks @yuvalt)

## [0.3.0](https://github.com/szweier/SZMentionsSwift/releases/tag/0.3.0) (8/17/2016)

#### Fixed
* Issue with timer hitting twice

## [0.2.1](https://github.com/szweier/SZMentionsSwift/releases/tag/0.2.1) (6/8/2016)

#### Added
* The ability to add the topmost mention by hitting the return key

## [0.2.0](https://github.com/szweier/SZMentionsSwift/releases/tag/0.2.0) (6/3/2016)

#### Added 
* Objective-C compatibility

## [0.1.1](https://github.com/szweier/SZMentionsSwift/releases/tag/0.1.1) (6/2/2016)

#### Added
* The ability to add a mention on a new line without the need for a leading space

## [0.1.0](https://github.com/szweier/SZMentionsSwift/releases/tag/0.1.0) (3/22/2016)

#### Added
* The ability to insert mentions to existing text

## [0.0.11](https://github.com/szweier/SZMentionsSwift/releases/tag/0.0.11) (2/12/2016)

#### Cleaned
* Unused methods
* General organization

## [0.0.10](https://github.com/szweier/SZMentionsSwift/releases/tag/0.0.10) (2/12/2016)

#### Fixed
* Issue with mention range setting

## [0.0.9](https://github.com/szweier/SZMentionsSwift/releases/tag/0.0.9) (2/5/2016)

#### Fixed
* Clean up project

## [0.0.8](https://github.com/szweier/SZMentionsSwift/releases/tag/0.0.8) (2/4/2016)

#### Added
* Readonly attributes where necessary
* Changelog

## [0.0.7](https://github.com/szweier/SZMentionsSwift/releases/tag/0.0.7) (2/4/2016)

#### Fixed
* Fix issue with pasting text before a mention at the beginning of the text view

#### Improved
* Documentation

## [0.0.6](https://github.com/szweier/SZMentionsSwift/releases/tag/0.0.6) (2/4/2016)

#### Improved
* Method renames / cleanup

## [0.0.5](https://github.com/szweier/SZMentionsSwift/releases/tag/0.0.5) (2/3/2016)

#### Fixed
* Break out code into multiple classes for clarity
* Fix [Chinese Keyboard Pinyin](https://github.com/szweier/SZMentions/issues/2)

## [0.0.4](https://github.com/szweier/SZMentionsSwift/releases/tag/0.0.4) (1/26/2016)

#### Fixed
* Allow choice of whether or not to add a space after adding a mention

## [0.0.3](https://github.com/szweier/SZMentionsSwift/releases/tag/0.0.3) (1/16/2016)

#### Added
* Tests

#### Improved
* Fine tuning different mention scenarios

## [0.0.2](https://github.com/szweier/SZMentionsSwift/releases/tag/0.0.2) (1/15/2016)

#### Improved
* Fine tuning different mention scenarios

## [0.0.1](https://github.com/szweier/SZMentionsSwift/releases/tag/0.0.1) (1/12/2015)
* Initial release


