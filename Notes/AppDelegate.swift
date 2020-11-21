//
//  AppDelegate.swift
//  Notes
//
//  Created by Лайм HD on 13.11.2020.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let coreDataStack = try! CoreDataStack(modelName: "Notes") { error in
            print("Core Data Stack is ready")
        }
        print(coreDataStack.context)
        
        return true
    }


}

