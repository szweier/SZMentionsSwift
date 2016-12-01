//
//  SZExampleViewController.swift
//  SZMentionsExample
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit
import SZMentionsSwift

class SZExampleViewController: UIViewController, UITextViewDelegate {

    private var myInputAccessoryView: UIView?

    init() {
        super.init(nibName: nil, bundle: nil)
        let frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40)
        myInputAccessoryView = SZExampleAccessoryView(frame: frame, delegate: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var inputAccessoryView: UIView {
        return myInputAccessoryView!
    }

    override var canBecomeFirstResponder : Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
}

