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
        let names = [
            "Steven Zweier",
            "John Smith",
            "Joe Tesla"]

        var tempMentions = [SZExampleMention]()

        for name in names {
            let mention = SZExampleMention()
            mention.mentionName = name
            tempMentions.append(mention)
        }

        return tempMentions
    }

    private var tableView: UITableView?
    private var filterString: String?

    init(mentionTableView: UITableView, mentionsListener: SZMentionsListener) {
        tableView = mentionTableView
        tableView!.register(
            UITableViewCell.classForCoder(),
            forCellReuseIdentifier: "Cell")
        listener = mentionsListener
    }

    func filter(_ string: String?) {
        filterString = string
        tableView?.reloadData()
    }

    private func mentionsList() -> [SZExampleMention] {
        var filteredMentions = mentions

        if (filterString?.characters.count ?? 0 > 0) {
            filteredMentions = mentions.filter() {
                if let type = ($0 as SZExampleMention).mentionName as String! {
                    return type.lowercased().contains(filterString!.lowercased())
                } else {
                    return false
                }
            }
        }

        return filteredMentions
    }

    func firstMentionObject() -> SZExampleMention? {
        return mentionsList().first
    }

    func addMention(_ mention: SZExampleMention) {
        listener!.addMention(mention)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionsList().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else { return UITableViewCell() }
        cell.textLabel?.text = mentionsList()[indexPath.row].mentionName

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.addMention(mentionsList()[indexPath.row])
    }
}
