//
//  SZExampleAccessoryView.swift
//  SZMentionsExample
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit
import SZMentionsSwift

class SZExampleAccessoryView: UIView, SZMentionsManagerProtocol {

    var mentionsListener: SZMentionsListener?
    var textView = UITextView.init()
    var mentionsTableView: UITableView?
    var verticalConstraints: [NSLayoutConstraint]?
    var dataManager: SZExampleMentionsTableViewDataManager?

    init(frame: CGRect, delegate: UITextViewDelegate) {
        super.init(frame: frame)
        textView.translatesAutoresizingMaskIntoConstraints = false
        mentionsListener = SZMentionsListener.init(mentionTextView: textView,
            mentionsManager: self)
        textView.delegate = mentionsListener
        mentionsListener?.delegate = delegate
        mentionsTableView = UITableView.init()
        mentionsTableView?.translatesAutoresizingMaskIntoConstraints = false
        mentionsTableView?.backgroundColor = UIColor.blueColor()
        dataManager = SZExampleMentionsTableViewDataManager.init(mentionTableView: mentionsTableView!, mentionsListener: mentionsListener!)
        mentionsTableView?.delegate = dataManager
        mentionsTableView?.dataSource = dataManager
        mentionsListener?.defaultTextAttributes = defaultAttributes()
        mentionsListener?.mentionTextAttributes = mentionAttributes()
        self.addSubview(textView)
        self.removeConstraints(self.constraints)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-5-[textView]-5-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["textView": textView]))
        verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[textView(30)]-5-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["textView": textView])
        self.addConstraints(verticalConstraints!)
    }

    func mentionAttributes() -> [SZAttribute] {
        var attributes = [SZAttribute]()

        let attribute = SZAttribute.init(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.blackColor())
        let attribute2 = SZAttribute.init(attributeName: NSFontAttributeName, attributeValue: UIFont(name: "ChalkboardSE-Bold", size: 12)!)
        let attribute3 = SZAttribute.init(attributeName: NSBackgroundColorAttributeName, attributeValue: UIColor.lightGrayColor())
        attributes.append(attribute)
        attributes.append(attribute2)
        attributes.append(attribute3)

        return attributes
    }

    func defaultAttributes() -> [SZAttribute] {
        var attributes = [SZAttribute]()

        let attribute = SZAttribute.init(attributeName: NSForegroundColorAttributeName, attributeValue: UIColor.grayColor())
        let attribute2 = SZAttribute.init(attributeName: NSFontAttributeName, attributeValue: UIFont(name: "ArialMT", size: 12)!)
        let attribute3 = SZAttribute.init(attributeName: NSBackgroundColorAttributeName, attributeValue: UIColor.whiteColor())
        attributes.append(attribute)
        attributes.append(attribute2)
        attributes.append(attribute3)

        return attributes
    }

    func addMention() {
        let exampleMention = SZExampleMention.init()
        exampleMention.szMentionName = "Tiffany Zweier"
        mentionsListener?.addMention(exampleMention)
    }

    func showMentionsListWithString(mentionsString: NSString) {
        if mentionsTableView?.superview == nil {
            self.addSubview(mentionsTableView!)
            self.removeConstraints(self.constraints)
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-5-[tableview]-5-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tableview": mentionsTableView!]))
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-5-[textView]-5-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["textView": textView]))
            self.verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[tableview(100)][textView(30)]-5-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["textView": textView, "tableview": mentionsTableView!])
            self.addConstraints(self.verticalConstraints!)
        }

        dataManager?.filter(mentionsString)
    }

    func hideMentionsList() {
        self.mentionsTableView?.removeFromSuperview()
        self.verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[textView(30)]-5-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["textView": textView])
        self.addConstraints(self.verticalConstraints!)
        dataManager?.filter(nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
