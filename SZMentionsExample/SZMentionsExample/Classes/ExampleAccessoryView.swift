//
//  ExampleAccessoryView.swift
//  SZMentionsExample
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import SZMentionsSwift
import UIKit

class ExampleAccessoryView: UIView {
    struct Attribute: AttributeContainer {
        var name: NSAttributedString.Key
        var value: Any
    }

    private let textView = UITextView()
    private let mentionsTableView = UITableView()
    private let mentionAttributes: [AttributeContainer] = [
        Attribute(
            name: .foregroundColor,
            value: UIColor.black
        ),
        Attribute(
            name: .font,
            value: UIFont(name: "ChalkboardSE-Bold", size: 12)!
        ),
        Attribute(
            name: .backgroundColor,
            value: UIColor.lightGray
        ),
    ]
    private let defaultAttributes: [AttributeContainer] = [
        Attribute(
            name: .foregroundColor,
            value: UIColor.gray
        ),
        Attribute(
            name: .font,
            value: UIFont(name: "ArialMT", size: 12)!
        ),
        Attribute(
            name: .backgroundColor,
            value: UIColor.white
        ),
    ]
    private var dataManager: ExampleMentionsTableViewDataManager?

    init(delegate _: UITextViewDelegate) {
        super.init(frame: .zero)
        autoresizingMask = .flexibleHeight
        let mentionsListener = MentionListener(mentionsTextView: textView,
                                               mentionTextAttributes: { _ in self.mentionAttributes },
                                               defaultTextAttributes: defaultAttributes,
                                               spaceAfterMention: false,
                                               hideMentions: hideMentions,
                                               didHandleMentionOnReturn: didHandleMentionOnReturn,
                                               showMentionsListWithString: showMentionsListWithString)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = mentionsListener
        addSubview(textView)
        addConstraintsToTextView(textView)
        textView.text = "Test Steven Zweier mention"

        let mention = ExampleMention(name: "Steven Zweier")
        mentionsListener.insertExistingMentions([(mention, NSRange(location: 5, length: 13))])

        dataManager = ExampleMentionsTableViewDataManager(
            mentionTableView: mentionsTableView,
            mentionsListener: mentionsListener
        )

        setupTableView(mentionsTableView, dataManager: dataManager)
        backgroundColor = .gray
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTableView(_: UITableView, dataManager: ExampleMentionsTableViewDataManager?) {
        mentionsTableView.translatesAutoresizingMaskIntoConstraints = false
        mentionsTableView.backgroundColor = .blue
        mentionsTableView.delegate = dataManager
        mentionsTableView.dataSource = dataManager
    }

    private func addConstraintsToTextView(_ textView: UITextView) {
        removeConstraints(constraints)
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-5-[textView]-5-|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: ["textView": textView]
            ) +
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-5-[textView(30)]-5-|",
                    options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["textView": textView]
                )
        )
    }

    private func setupTextView(_ textView: UITextView, delegate: MentionListener) {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = delegate
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.size.width, height: mentionsTableView.superview == nil ? 40 : 140)
    }
}

extension ExampleAccessoryView {
    func hideMentions() {
        if mentionsTableView.superview != nil {
            mentionsTableView.removeFromSuperview()
            addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-5-[textView(30)]-5-|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: ["textView": textView]
            )
            )
        }
        dataManager?.filter("")
    }

    func didHandleMentionOnReturn() -> Bool { return false }
    func showMentionsListWithString(mentionsString: String, trigger _: String) {
        if mentionsTableView.superview == nil {
            removeConstraints(constraints)
            addSubview(mentionsTableView)
            addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "|-5-[tableview]-5-|",
                    options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["tableview": mentionsTableView]
                ) +
                    NSLayoutConstraint.constraints(
                        withVisualFormat: "|-5-[textView]-5-|",
                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                        metrics: nil,
                        views: ["textView": textView]
                    ) +
                    NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|-5-[tableview(100)][textView(30)]-5-|",
                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                        metrics: nil,
                        views: ["textView": textView, "tableview": mentionsTableView]
                    )
            )
        }

        dataManager?.filter(mentionsString)
    }
}
