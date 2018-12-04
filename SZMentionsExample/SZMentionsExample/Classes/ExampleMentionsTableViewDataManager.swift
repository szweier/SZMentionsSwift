//
//  ExampleMentionsTableViewDataManager.swift
//  SZMentionsExample
//
//  Created by Steven Zweier on 1/12/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit
import SZMentionsSwift

class ExampleMentionsTableViewDataManager: NSObject {
    private let cellIdentifier = "Cell"
    private let listener: MentionListener
    private let mentions: [ExampleMention] = {
        return [
            "Steven Zweier",
            "John Smith",
            "Joe Tesla"].map {
                ExampleMention(name: $0)
        }
    }()
    private var mentionsList: [ExampleMention] {
        guard !mentions.isEmpty else { return mentions }
        return mentions.filter {
            return $0.name.lowercased().contains(filterString.lowercased())
        }
    }
    private let tableView: UITableView
    private var filterString: String = ""

    init(mentionTableView: UITableView, mentionsListener: MentionListener) {
        tableView = mentionTableView
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: cellIdentifier)
        listener = mentionsListener
        super.init()
    }

    func filter(_ string: String) {
        filterString = string
        tableView.reloadData()
    }
}

extension ExampleMentionsTableViewDataManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listener.addMention(mentionsList[indexPath.row])
    }
}

extension ExampleMentionsTableViewDataManager: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else { return UITableViewCell() }
        cell.textLabel?.text = mentionsList[indexPath.row].name

        return cell
    }
}
