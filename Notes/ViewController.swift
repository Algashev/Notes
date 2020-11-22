//
//  ViewController.swift
//  Notes
//
//  Created by Лайм HD on 13.11.2020.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private var coreDataStack: CoreDataStack!
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeCoreDataStack() { [unowned self] in
            self.createAndSaveNote()
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
    
    private func createAndSaveNote() {
        if let note = Note(insertInto: self.coreDataStack.context) {
            note.title = "My Second Note"
            note.createdAt = Date()
            note.updatedAt = Date()
            
            print(note)
            
            do {
                try self.coreDataStack.context.save()
                let storeDirectoryURL = self.coreDataStack.storeDirectoryURL
                let storePath = storeDirectoryURL?.absoluteString ?? ""
                print("Store path: \(storePath)")
            } catch {
                print("Unable to Save Managed Object Context")
                print("\(error), \(error.localizedDescription)")
            }
        } else {
            print("Failed create Note")
        }
        
    }

}

