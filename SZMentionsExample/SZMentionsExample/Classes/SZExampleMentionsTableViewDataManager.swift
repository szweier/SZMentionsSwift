//
//  SZExampleMentionsTableViewDataManager.swift
//  SZMentionsExample
//
//  Created by Steven Zweier on 1/12/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit
import SZMentionsSwift

class SZExampleMentionsTableViewDataManager: NSObject {
    private let cellIdentifier = "Cell"
    private let listener: SZMentionsListener
    private let mentions: [SZExampleMention] = {
        return [
            "Steven Zweier",
            "John Smith",
            "Joe Tesla"].map {
                SZExampleMention(name: $0, range: NSRange(location: 0, length: 0))
        }
    }()
    private var mentionsList: [SZExampleMention] {
        guard !mentions.isEmpty else { return mentions }
        return mentions.filter {
            return $0.name.lowercased().contains(filterString.lowercased())
        }
    }
    private let tableView: UITableView
    private var filterString: String = ""

    init(mentionTableView: UITableView, mentionsListener: SZMentionsListener) {
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

extension SZExampleMentionsTableViewDataManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listener.addMention(mentionsList[indexPath.row])
    }
}

extension SZExampleMentionsTableViewDataManager: UITableViewDataSource {
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
