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
    private let textView = UITextView.init()
    private let mentionsTableView = UITableView.init()
    private var verticalConstraints: [NSLayoutConstraint] = []
    private var dataManager: SZExampleMentionsTableViewDataManager?

    init(frame: CGRect, delegate: UITextViewDelegate) {
        super.init(frame: frame)
        let mentionsListener = SZMentionsListener.init(mentionTextView: textView,
            mentionsManager: self)
        mentionsListener.delegate = delegate

        setupTextView(textView, delegate: mentionsListener)
        self.addSubview(textView)
        addConstraintsToTextView(textView)

        dataManager = SZExampleMentionsTableViewDataManager.init(
            mentionTableView: mentionsTableView,
            mentionsListener: mentionsListener)

        setupTableView(mentionsTableView, dataManager: dataManager!)

        mentionsListener.defaultTextAttributes = defaultAttributes()
        mentionsListener.mentionTextAttributes = mentionAttributes()
        self.backgroundColor = UIColor.grayColor()
    }

    private func setupTableView(tableView: UITableView, dataManager: SZExampleMentionsTableViewDataManager) {
        mentionsTableView.translatesAutoresizingMaskIntoConstraints = false
        mentionsTableView.backgroundColor = UIColor.blueColor()
        mentionsTableView.delegate = dataManager
        mentionsTableView.dataSource = dataManager
    }

    private func addConstraintsToTextView(textView: UITextView) {
        self.removeConstraints(self.constraints)
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "|-5-[textView]-5-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["textView": textView]))
        verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-5-[textView(30)]-5-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["textView": textView])
        self.addConstraints(verticalConstraints)
    }

    private func setupTextView(textView: UITextView, delegate: SZMentionsListener) {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = delegate
    }

    private func mentionAttributes() -> [SZAttribute] {
        var attributes = [SZAttribute]()

        let attribute = SZAttribute.init(
            attributeName: NSForegroundColorAttributeName,
            attributeValue: UIColor.blackColor())
        let attribute2 = SZAttribute.init(
            attributeName: NSFontAttributeName,
            attributeValue: UIFont(name: "ChalkboardSE-Bold", size: 12)!)
        let attribute3 = SZAttribute.init(
            attributeName: NSBackgroundColorAttributeName,
            attributeValue: UIColor.lightGrayColor())
        attributes.append(attribute)
        attributes.append(attribute2)
        attributes.append(attribute3)

        return attributes
    }

    private func defaultAttributes() -> [SZAttribute] {
        var attributes = [SZAttribute]()

        let attribute = SZAttribute.init(
            attributeName: NSForegroundColorAttributeName,
            attributeValue: UIColor.grayColor())
        let attribute2 = SZAttribute.init(
            attributeName: NSFontAttributeName,
            attributeValue: UIFont(name: "ArialMT", size: 12)!)
        let attribute3 = SZAttribute.init(
            attributeName: NSBackgroundColorAttributeName,
            attributeValue: UIColor.whiteColor())
        attributes.append(attribute)
        attributes.append(attribute2)
        attributes.append(attribute3)

        return attributes
    }

    func showMentionsListWithString(mentionsString: String) {
        if (mentionsTableView.superview == nil) {
            self.addSubview(mentionsTableView)
            self.removeConstraints(self.constraints)
            self.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "|-5-[tableview]-5-|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["tableview": mentionsTableView]))
            self.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "|-5-[textView]-5-|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["textView": textView]))
            self.verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-5-[tableview(100)][textView(30)]-5-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["textView": textView, "tableview": mentionsTableView])
            self.addConstraints(self.verticalConstraints)
        }

        dataManager?.filter(mentionsString)
    }

    func hideMentionsList() {
        if (mentionsTableView.superview != nil) {
            self.mentionsTableView.removeFromSuperview()
            self.verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-5-[textView(30)]-5-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["textView": textView])
            self.addConstraints(self.verticalConstraints)
        }
        dataManager?.filter(nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
