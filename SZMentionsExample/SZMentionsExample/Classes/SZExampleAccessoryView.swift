//
//  SZExampleAccessoryView.swift
//  SZMentionsExample
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit
import SZMentionsSwift

class SZExampleAccessoryView: UIView {
    struct SZAttribute: AttributeContainer {
        var name: String
        var value: NSObject
    }
    private let textView = UITextView()
    private let mentionsTableView = UITableView()
    private var dataManager: SZExampleMentionsTableViewDataManager?
    private var mentionAttributes: [AttributeContainer] {
        return [
            SZAttribute(
                name: NSAttributedStringKey.foregroundColor.rawValue,
                value: UIColor.black),
            SZAttribute(
                name: NSAttributedStringKey.font.rawValue,
                value: UIFont(name: "ChalkboardSE-Bold", size: 12)!),
            SZAttribute(
                name: NSAttributedStringKey.backgroundColor.rawValue,
                value: UIColor.lightGray)
        ]
    }
    private var defaultAttributes: [AttributeContainer] {
        return [
            SZAttribute(
                name: NSAttributedStringKey.foregroundColor.rawValue,
                value: UIColor.gray),
            SZAttribute(
                name: NSAttributedStringKey.font.rawValue,
                value: UIFont(name: "ArialMT", size: 12)!),
            SZAttribute(
                name: NSAttributedStringKey.backgroundColor.rawValue,
                value: UIColor.white)
        ]
    }

    init(delegate: UITextViewDelegate) {
        super.init(frame: .zero)
        let hideMentionsBlock: () -> Void = {
            if self.mentionsTableView.superview != nil {
                self.mentionsTableView.removeFromSuperview()
                self.addConstraints(NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-5-[textView(30)]-5-|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["textView": self.textView])
                )
            }
            self.dataManager?.filter("")
        }
        let didHandleMentionOnReturnBlock: () -> Bool = { false }
        let showMentionsListWithStringBlock: (String) -> Void = { mentionsString in
            if self.mentionsTableView.superview == nil {
                self.removeConstraints(self.constraints)
                self.addSubview(self.mentionsTableView)
                self.addConstraints(
                    NSLayoutConstraint.constraints(
                        withVisualFormat: "|-5-[tableview]-5-|",
                        options: NSLayoutFormatOptions(rawValue: 0),
                        metrics: nil,
                        views: ["tableview": self.mentionsTableView]) +
                        NSLayoutConstraint.constraints(
                            withVisualFormat: "|-5-[textView]-5-|",
                            options: NSLayoutFormatOptions(rawValue: 0),
                            metrics: nil,
                            views: ["textView": self.textView]) +
                        NSLayoutConstraint.constraints(
                            withVisualFormat: "V:|-5-[tableview(100)][textView(30)]-5-|",
                            options: NSLayoutFormatOptions(rawValue: 0),
                            metrics: nil,
                            views: ["textView": self.textView, "tableview": self.mentionsTableView])
                )
            }
            
            self.dataManager?.filter(mentionsString)
        }
        
        autoresizingMask = .flexibleHeight
        let mentionsListener = SZMentionsListener(mentionTextView: textView,
                                                  delegate: delegate,
                                                  mentionTextAttributes: mentionAttributes,
                                                  defaultTextAttributes: defaultAttributes,
                                                  spaceAfterMention: true,
                                                  hideMentions: hideMentionsBlock,
                                                  didHandleMentionOnReturn: didHandleMentionOnReturnBlock,
                                                  showMentionsListWithString: showMentionsListWithStringBlock)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = mentionsListener
        addSubview(textView)
        addConstraintsToTextView(textView)
        textView.text = "Test Steven Zweier mention"

        let mention = SZExampleMention(name: "Steven Zweier",
                                       range: NSRange(location: 5, length: 13))

        mentionsListener.insertExistingMentions([mention])

        dataManager = SZExampleMentionsTableViewDataManager(
            mentionTableView: mentionsTableView,
            mentionsListener: mentionsListener)

        setupTableView(mentionsTableView, dataManager: dataManager!)
        backgroundColor = UIColor.gray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTableView(_ tableView: UITableView, dataManager: SZExampleMentionsTableViewDataManager) {
        mentionsTableView.translatesAutoresizingMaskIntoConstraints = false
        mentionsTableView.backgroundColor = UIColor.blue
        mentionsTableView.delegate = dataManager
        mentionsTableView.dataSource = dataManager
    }

    private func addConstraintsToTextView(_ textView: UITextView) {
        removeConstraints(constraints)
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-5-[textView]-5-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["textView": textView]) +
            NSLayoutConstraint.constraints(
                views: ["textView": textView]))
        verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-5-[textView(30)]-5-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["textView": textView])
        addConstraints(verticalConstraints)
    }

    private func setupTextView(_ textView: UITextView, delegate: SZMentionsListener) {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = delegate
    }

    private func mentionAttributes() -> [AttributeContainer] {
        var attributes = [AttributeContainer]()

        let attribute = SZAttribute(
            attributeName: NSAttributedStringKey.foregroundColor.rawValue,
            attributeValue: UIColor.black)
        let attribute2 = SZAttribute(
            attributeName: NSAttributedStringKey.font.rawValue,
            attributeValue: UIFont(name: "ChalkboardSE-Bold", size: 12)!)
        let attribute3 = SZAttribute(
            attributeName: NSAttributedStringKey.backgroundColor.rawValue,
            attributeValue: UIColor.lightGray)
        attributes.append(attribute)
        attributes.append(attribute2)
        attributes.append(attribute3)

        return attributes
    }

    private func defaultAttributes() -> [AttributeContainer] {
        var attributes = [AttributeContainer]()

        let attribute = SZAttribute(
            attributeName: NSAttributedStringKey.foregroundColor.rawValue,
            attributeValue: UIColor.gray)
        let attribute2 = SZAttribute(
            attributeName: NSAttributedStringKey.font.rawValue,
            attributeValue: UIFont(name: "ArialMT", size: 12)!)
        let attribute3 = SZAttribute(
            attributeName: NSAttributedStringKey.backgroundColor.rawValue,
            attributeValue: UIColor.white)
        attributes.append(attribute)
        attributes.append(attribute2)
        attributes.append(attribute3)

        return attributes
    }

    func showMentionsListWithString(_ mentionsString: String, trigger: String) {
        if mentionsTableView.superview == nil {
            removeConstraints(constraints)
            addSubview(mentionsTableView)
            addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "|-5-[tableview]-5-|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["tableview": mentionsTableView]))
            addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "|-5-[textView]-5-|",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["textView": textView]))
            verticalConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-5-[tableview(100)][textView(30)]-5-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["textView": textView, "tableview": mentionsTableView])
            addConstraints(verticalConstraints)
        }

        dataManager?.filter(mentionsString)
    }

    func hideMentionsList() {
        if mentionsTableView.superview != nil {
            mentionsTableView.removeFromSuperview()
            verticalConstraints = NSLayoutConstraint.constraints(
>>>>>>> master
                withVisualFormat: "V:|-5-[textView(30)]-5-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["textView": textView])
            )
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.size.width, height: mentionsTableView.superview == nil ? 40 : 140)
    }
}

