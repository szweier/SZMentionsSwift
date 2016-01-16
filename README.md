[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/SZMentionsSwift.svg)](https://img.shields.io/cocoapods/v/SZMentionsSwift.svg)
[![Platform](https://img.shields.io/cocoapods/p/SZMentionsSwift.svg?style=flat)](http://cocoadocs.org/docsets/SZMentionsSwift)
[![Twitter](https://img.shields.io/badge/twitter-@StevenZweier-blue.svg?style=flat)](http://twitter.com/StevenZweier)

SZMentionsSwift is a lightweight mentions library for iOS. This library was built to assist with the adding, removing and editing of a mention within a textview.

## How To Get Started

- [Download SZMentionsSwift](https://github.com/szweier/SZMentionsSwift/archive/master.zip) and try out the iOS example app. 

## Communication

- If you **need help**, feel free to tweet @StevenZweier
- If you **found a bug**, **have a feature request**, or **have a general question** open an issue.
- If you **want to contribute**, submit a pull request.

## Installation with CocoaPods

[CocoaPods](http://cocoapods.org) 

#### Podfile

To integrate SZMentionsSwift into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

pod 'SZMentionsSwift'
```

Then, run the following command:

```bash
$ pod install
```

## Requirements

| SZMentionsSwift Version | Minimum iOS Target |
|:--------------------:|:---------------------------:||
| 0.0.x | iOS 8.1 |

## Usage

Below is a quick run through of the objects used in this library but as always the best place to get an understanding of the current implementation of the SZMentionsSwift library is in the example code.

#### SZMentionsSwiftListener

This class manages the mention interaction.

##### Setup

`trigger` : The string used to start a mention. Default is `@`

`defaultTextAttributes` : Attributes (see: `SZAttribute`) to apply to the textview for all text that is not a mention.
`mentionTextAttributes` : Attributes (see: `SZAttribute`) to apply to the textview for all mentions

`mentionsTextView` : **required** The text view we are applying the mentions listener to. Note: it's delegate **must** be the mentions manager.

`delegate` : **optional** If you would like to receive UITextView delegate methods set this and it will be passed through after processing view the mentions listener.

`mentionsManager` : **required** The class that will be handling the mention interaction.

`cooldownInterval` : **optional** The amount of time to wait between calling showMentionsList. Default is `0.5`

`spaceAfterMention` : **optional** Whether or not you would like a space to be added to the end of your mentions. Default is `NO`

`mentions` : **readonly** Array of all mentions currently applied to the text view.

`public func addMention(mention: SZCreateMentionProtocol)` : Call this method while adding a mention to apply the mention to the current text.

#### SZCreateMentionProtocol

This required properties for a mention being sent to the mentions listener

#### SZMentionsSwiftManagerProtocol

The require methods for handling mention interaction.

`func showMentionsListWithString(mentionsString: NSString)` lets the delegate know to show a mentions list as well as provides the current string typed into the textview, allowing for filtering of the mentions list.
`func hideMentionsList()` lets the delegate know we are no longer typing in a mention. 

#### SZMention

This class is returned via the `mentions` method, it includes the `range` of the mention as well as `object` containing the object sent to the mentions listener via the `addMention:(id)mention` method.

#### SZAttribute

This class is used to pass attributes to apply mentions text as well as regular text.

Example:
    
    SZAttribute.init(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.blackColor())
    

## Unit Tests

SZMentionsSwift includes unit tests which can be run on the SZMentionsSwift example project.

## Credits

SZMentionsSwift was originally created by [Steven Zweier](http://twitter.com/StevenZweier)
