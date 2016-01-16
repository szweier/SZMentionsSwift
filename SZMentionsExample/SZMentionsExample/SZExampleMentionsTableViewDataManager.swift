//
//  SZExampleMentionsTableViewDataManager.swift
//  SZMentionsExample
//
//  Created by Steven Zweier on 1/12/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit
import SZMentionsSwift

class SZExampleMentionsTableViewDataManager: NSObject, UITableViewDataSource, UITableViewDelegate {

    private var listener: SZMentionsListener?
    private var mentions: [SZExampleMention] {
        let names = ["Steven Zweier", "Professor Belly Button", "Turtle Paper"]

        var tempMentions = [SZExampleMention]()

        for name in names {
            let mention = SZExampleMention.init()
            mention.szMentionName = name
            tempMentions.append(mention)
        }

        return tempMentions
    }
    private var tableView: UITableView?
    private var filterString: String?

    init(mentionTableView: UITableView, mentionsListener: SZMentionsListener) {
        tableView = mentionTableView
        tableView!.registerClass(
            UITableViewCell.classForCoder(),
            forCellReuseIdentifier: "Cell")
        listener = mentionsListener
    }

    func filter(string: String?) {
        filterString = string
        tableView?.reloadData()
    }

    private func mentionsList() -> [SZExampleMention] {
        var filteredMentions = mentions

        if (filterString?.characters.count > 0) {
            filteredMentions = mentions.filter() {
                if let type = ($0 as SZExampleMention).szMentionName as String! {
                    return type.lowercaseString.containsString(filterString!.lowercaseString)
                } else {
                    return false
                }
            }
        }

        return filteredMentions
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionsList().count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        cell?.textLabel?.text = mentionsList()[indexPath.row].szMentionName as String

        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        listener!.addMention(mentionsList()[indexPath.row])
    }
}
