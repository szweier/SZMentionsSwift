//
//  Operators.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 12/6/18.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//
import UIKit

precedencegroup ForwardApplication {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator |>: ForwardApplication

internal func |> <A, B>(a: A, f: (A) -> B) -> B {
    return f(a)
}

precedencegroup ForwardComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator >>>: ForwardComposition

func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
    return { a in
        g(f(a))
    }
}

precedencegroup EffectfulComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator >=>: EffectfulComposition

internal func >=> <A, B, C>(
    _ f: @escaping (A) -> B?,
    _ g: @escaping (B) -> C?
) -> ((A) -> C?) {
    return { a in
        guard let b = f(a) else { return nil }
        let c = g(b)

        return c
    }
}

internal func >=> <A, B, C>(
    _ f: @escaping (A) -> (B, NSRange),
    _ g: @escaping (B) -> (C, NSRange)
) -> ((A) -> (C, NSRange)) {
    return { a in
        let (b, _) = f(a)
        let (c, selectedRange) = g(b)
        return (c, selectedRange)
    }
}
