//
//  NSRange.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 12/4/18.
//  Copyright © 2018 Steven Zweier. All rights reserved.
//

import Foundation

internal extension NSRange {
    func adjustLength(for text: String) -> NSRange {
        return NSRange(location: location, length: text.utf16.count)
    }
}
