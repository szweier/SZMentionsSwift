//
//  ExampleViewController.swift
//  SZMentionsExample
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import SZMentionsSwift
import UIKit

class ExampleViewController: UIViewController, UITextViewDelegate {
    private var myInputAccessoryView: ExampleAccessoryView!

    init() {
        super.init(nibName: nil, bundle: nil)
        myInputAccessoryView = ExampleAccessoryView(delegate: self)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var inputAccessoryView: UIView {
        return myInputAccessoryView
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
}
