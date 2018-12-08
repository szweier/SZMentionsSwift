//
//  UITextView.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 12/6/18.
//  Copyright © 2018 Steven Zweier. All rights reserved.
//

import UIKit

func selectRange(on textView: UITextView) -> (NSRange) -> Void {
    return { range in textView.selectedRange = range }
}
