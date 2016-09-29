//
//  SZExampleMentionsTableViewDataManager.swift
//  SZMentionsExample
//
//  Created by Steven Zweier on 1/12/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit
import SZMentionsSwift
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SZExampleMentionsTableViewDataManager: NSObject, UITableViewDataSource, UITableViewDelegate {

    fileprivate var listener: SZMentionsListener?
    fileprivate var mentions: [SZExampleMention] {
        let names = [
            "Steven Zweier",
            "John Smith",
            "Joe Tesla"]

        var tempMentions = [SZExampleMention]()

        for name in names {
            let mention = SZExampleMention.init()
            mention.szMentionName = name
            tempMentions.append(mention)
        }

        return tempMentions
    }
    fileprivate var tableView: UITableView?
    fileprivate var filterString: String?

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

    fileprivate func mentionsList() -> [SZExampleMention] {
        var filteredMentions = mentions

        if (filterString?.characters.count > 0) {
            filteredMentions = mentions.filter() {
                if let type = ($0 as SZExampleMention).szMentionName as String! {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = mentionsList()[(indexPath as NSIndexPath).row].szMentionName as String

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      self.addMention(mentionsList()[(indexPath as NSIndexPath).row])
    }
}
