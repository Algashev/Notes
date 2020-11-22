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
        
        self.initializeCoreDataStack() {
            print("Core Data Stack is ready")
        } onFailure: { error in
            print(error.localizedDescription)
        }
    }

    private func initializeCoreDataStack(
        onSuccess: @escaping () -> (),
        onFailure: @escaping (_ error: Error) -> ()) {
        do {
            self.coreDataStack = try CoreDataStack(modelName: "Notes") { error in
                if let error = error {
                    onFailure(error)
                    return
                }
                
                onSuccess()
            }
        } catch {
            onFailure(error)
        }
    }

}

