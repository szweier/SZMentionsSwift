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

    var myInputAccessoryView: UIView?

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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

