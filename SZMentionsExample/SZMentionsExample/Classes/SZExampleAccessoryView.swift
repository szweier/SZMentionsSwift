//
//  SZExampleAccessoryView.swift
//  SZMentionsExample
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit
import SZMentionsSwift

//As SZAttribute is private only
struct CustomAttr: AttributeContainer {
    /**
     @brief Name of the attribute to set on a string
     */
    public var attributeName: String
    
    /**
     @brief Value of the attribute to set on a string
     */
    public var attributeValue: NSObject
}

class SZExampleAccessoryView: UIView, MentionsManagerDelegate {
    private let textView = UITextView()
    private let mentionsTableView = UITableView()
    private var verticalConstraints: [NSLayoutConstraint] = []
    private var dataManager: SZExampleMentionsTableViewDataManager?

    init(delegate: UITextViewDelegate) {
        super.init(frame: .zero)
        autoresizingMask = .flexibleHeight
        let mentionsListener = SZMentionsListener(mentionTextView: textView, mentionsManager: self, textViewDelegate: delegate, mentionTextAttributes: mentionAttributes(), defaultTextAttributes: defaultAttributes(), spaceAfterMention: true, triggers: ["@", "!", "#"], cooldownInterval: 0.3, searchSpaces: true)

        setupTextView(textView, delegate: mentionsListener)
        addSubview(textView)
        addConstraintsToTextView(textView)
        textView.text = "Test Steven Zweier mention"

        let mention = SZExampleMention()
        mention.mentionName = "Steven Zweier"
        mention.mentionRange = NSRange(location: 5, length: 13)

        mentionsListener.insertExistingMentions([mention])

        dataManager = SZExampleMentionsTableViewDataManager(
            mentionTableView: mentionsTableView,
            mentionsListener: mentionsListener)

        setupTableView(mentionsTableView, dataManager: dataManager!)
        backgroundColor = UIColor.gray
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

        let attribute = CustomAttr(
            attributeName: NSAttributedStringKey.foregroundColor.rawValue,
            attributeValue: UIColor.black)
        let attribute2 = CustomAttr(
            attributeName: NSAttributedStringKey.font.rawValue,
            attributeValue: UIFont(name: "ChalkboardSE-Bold", size: 12)!)
        let attribute3 = CustomAttr(
            attributeName: NSAttributedStringKey.backgroundColor.rawValue,
            attributeValue: UIColor.lightGray)
        attributes.append(attribute)
        attributes.append(attribute2)
        attributes.append(attribute3)

        return attributes
    }

    private func defaultAttributes() -> [AttributeContainer] {
        var attributes = [AttributeContainer]()

        let attribute = CustomAttr(
            attributeName: NSAttributedStringKey.foregroundColor.rawValue,
            attributeValue: UIColor.gray)
        let attribute2 = CustomAttr(
            attributeName: NSAttributedStringKey.font.rawValue,
            attributeValue: UIFont(name: "ArialMT", size: 12)!)
        let attribute3 = CustomAttr(
            attributeName: NSAttributedStringKey.backgroundColor.rawValue,
            attributeValue: UIColor.white)
        attributes.append(attribute)
        attributes.append(attribute2)
        attributes.append(attribute3)

        return attributes
    }

    func showMentionsListWithString(_ mentionsString: String, trigger: String) {
        print(mentionsString,trigger)
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
                withVisualFormat: "V:|-5-[textView(30)]-5-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["textView": textView])
            addConstraints(verticalConstraints)
        }
        dataManager?.filter(nil)
    }

    func didHandleMentionOnReturn() -> Bool { return true }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.size.width, height: mentionsTableView.superview == nil ? 40 : 140)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

