//
//  AppDelegate.swift
//  DAY06
//
//  Created by Zuleykha Pavlichenkova on 18.08.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let window = window {
            window.rootViewController = ViewController()
            window.makeKeyAndVisible()
        }
        return true
    }



}

