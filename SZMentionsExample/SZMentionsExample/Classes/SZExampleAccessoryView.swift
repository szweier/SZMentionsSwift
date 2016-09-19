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
    fileprivate let textView = UITextView.init()
    fileprivate let mentionsTableView = UITableView.init()
    fileprivate var verticalConstraints: [NSLayoutConstraint] = []
    fileprivate var dataManager: SZExampleMentionsTableViewDataManager?

    init(frame: CGRect, delegate: UITextViewDelegate) {
        super.init(frame: frame)
        let mentionsListener = SZMentionsListener.init(mentionTextView: textView,
            mentionsManager: self, textViewDelegate: delegate, mentionTextAttributes: mentionAttributes(), defaultTextAttributes: defaultAttributes(),spaceAfterMention: true, addMentionOnReturnKey: true)

        setupTextView(textView, delegate: mentionsListener)
        self.addSubview(textView)
        addConstraintsToTextView(textView)

        dataManager = SZExampleMentionsTableViewDataManager.init(
            mentionTableView: mentionsTableView,
            mentionsListener: mentionsListener)

        setupTableView(mentionsTableView, dataManager: dataManager!)
        self.backgroundColor = UIColor.gray
    }

    fileprivate func setupTableView(_ tableView: UITableView, dataManager: SZExampleMentionsTableViewDataManager) {
        mentionsTableView.translatesAutoresizingMaskIntoConstraints = false
        mentionsTableView.backgroundColor = UIColor.blue
        mentionsTableView.delegate = dataManager
        mentionsTableView.dataSource = dataManager
    }

    fileprivate func addConstraintsToTextView(_ textView: UITextView) {
        self.removeConstraints(self.constraints)
        self.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-5-[textView]-5-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["textView": textView]))
        verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-5-[textView(30)]-5-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["textView": textView])
        self.addConstraints(verticalConstraints)
    }

    fileprivate func setupTextView(_ textView: UITextView, delegate: SZMentionsListener) {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = delegate
    }

    fileprivate func mentionAttributes() -> [SZAttribute] {
        var attributes = [SZAttribute]()

        let attribute = SZAttribute.init(
            attributeName: NSForegroundColorAttributeName,
            attributeValue: UIColor.black)
        let attribute2 = SZAttribute.init(
            attributeName: NSFontAttributeName,
            attributeValue: UIFont(name: "ChalkboardSE-Bold", size: 12)!)
        let attribute3 = SZAttribute.init(
            attributeName: NSBackgroundColorAttributeName,
            attributeValue: UIColor.lightGray)
        attributes.append(attribute)
        attributes.append(attribute2)
        attributes.append(attribute3)

        return attributes
    }

    fileprivate func defaultAttributes() -> [SZAttribute] {
        var attributes = [SZAttribute]()

        let attribute = SZAttribute.init(
            attributeName: NSForegroundColorAttributeName,
            attributeValue: UIColor.gray)
        let attribute2 = SZAttribute.init(
            attributeName: NSFontAttributeName,
            attributeValue: UIFont(name: "ArialMT", size: 12)!)
        let attribute3 = SZAttribute.init(
            attributeName: NSBackgroundColorAttributeName,
            attributeValue: UIColor.white)
        attributes.append(attribute)
        attributes.append(attribute2)
        attributes.append(attribute3)

        return attributes
    }

    func showMentionsListWithString(_ mentionsString: String) {
        if (mentionsTableView.superview == nil) {
            self.addSubview(mentionsTableView)
            self.removeConstraints(self.constraints)
            self.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "|-5-[tableview]-5-|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["tableview": mentionsTableView]))
            self.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "|-5-[textView]-5-|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["textView": textView]))
            self.verticalConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-5-[tableview(100)][textView(30)]-5-|",
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
            self.verticalConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-5-[textView(30)]-5-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["textView": textView])
            self.addConstraints(self.verticalConstraints)
        }
        dataManager?.filter(nil)
    }
  
  //**Optional function Called when user tap Return key you must init SZMentionsListener with addMentionOnReturnKey = true
    func shouldAddMentionOnReturnKey() {
      if let mention = dataManager?.firstMentionObject() {
        dataManager?.addMention(mention)
      }
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

