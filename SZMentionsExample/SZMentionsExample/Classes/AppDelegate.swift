//
//  AppDelegate.swift
//  SZMentionsExample
//
//  Created by Steven Zweier on 1/11/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit
import SZMentionsSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()

        let exampleVC = SZExampleViewController.init()
        window?.rootViewController = exampleVC

        return true
    }
}

