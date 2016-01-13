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

    var listener: SZMentionsListener?
    var mentions: [SZExampleMention]?
    var tableView: UITableView?
    var filterString: NSString?

    internal init(mentionTableView: UITableView, mentionsListener: SZMentionsListener) {
        tableView = mentionTableView
        tableView!.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        listener = mentionsListener
    }

    internal func filter(string: NSString?) {
        filterString = string
        tableView?.reloadData()
    }

    func mentionsList() -> [SZExampleMention] {
        if mentions == nil {
            let names = ["Steven Zweier", "Professor Belly Button", "Turtle Paper"]

            var tempMentions = [SZExampleMention]()

            for name in names {
                let mention = SZExampleMention.init()
                mention.szMentionName = name
                tempMentions.append(mention)
            }

            mentions = tempMentions
        }

        return mentions!
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
