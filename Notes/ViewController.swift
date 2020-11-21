//
//  ViewController.swift
//  Notes
//
//  Created by Лайм HD on 13.11.2020.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private var coreDataStack: CoreDataStack!
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeCoreDataStack()
    }

    private func initializeCoreDataStack() {
        do {
            self.coreDataStack = try CoreDataStack(modelName: "Notes") { error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                print("Core Data Stack is ready")
            }
        } catch {
            print(error.localizedDescription)
        }
    }

}

