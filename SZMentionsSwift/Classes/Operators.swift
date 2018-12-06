//
//  Operators.swift
//  SZMentionsSwift
//
//  Created by Steven Zweier on 12/6/18.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

precedencegroup ForwardApplication {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator |>: ForwardApplication

func |> <A, B>(a: A, f: (A) -> B) -> B {
    return f(a)
}

func |> <A, B>(a: inout A, f: (inout A) -> B) -> B {
    return f(&a)
}
