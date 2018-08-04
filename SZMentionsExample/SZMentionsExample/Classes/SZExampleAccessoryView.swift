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

    init(delegate: UITextViewDelegate) {
        super.init(frame: .zero)
        autoresizingMask = .flexibleHeight
        let mentionsListener = SZMentionsListener(mentionTextView: textView,
                                                  textViewDelegate: delegate,
                                                  mentionTextAttributes: mentionAttributes,
                                                  defaultTextAttributes: defaultAttributes,
                                                  spaceAfterMention: true,
                                                  hideMentions: {
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
        },
                                                  didHandleMentionOnReturn: { false },
                                                  showMentionsListWithString: { mentionsString in
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
        })

        setupTextView(textView, delegate: mentionsListener)
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
                withVisualFormat: "V:|-5-[textView(30)]-5-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["textView": textView])
            )
    }

    private func setupTextView(_ textView: UITextView, delegate: SZMentionsListener) {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = delegate
    }

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
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.size.width, height: mentionsTableView.superview == nil ? 40 : 140)
    }
}

