//
//  NotesViewController.swift
//  Notes
//
//  Created by Лайм HD on 13.11.2020.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {
    
    // MARK: - Properties
    
    private var coreDataStack: CoreDataStack!
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeCoreDataStack() { [unowned self] in
            
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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        if identifier == "\(AddNoteViewController.self)" {
            guard let destination = segue.destination as? AddNoteViewController else {
                return
            }
            
            destination.managedObjectContext = self.coreDataStack.context
        }
    }
    
    
}

// MARK: - UITableViewDataSource

extension NotesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
    
    
}

// MARK: - UITableViewDelegate

extension NotesViewController: UITableViewDelegate {
    
}
