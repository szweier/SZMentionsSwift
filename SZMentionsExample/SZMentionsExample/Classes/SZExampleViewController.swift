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
        let frame = CGRectMake(0, 0, self.view.frame.size.width, 40)
        myInputAccessoryView = SZExampleAccessoryView.init(frame: frame, delegate: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var inputAccessoryView: UIView {
        return myInputAccessoryView!
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
}

