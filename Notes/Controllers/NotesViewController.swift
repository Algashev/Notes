//
//  NotesViewController.swift
//  Notes
//
//  Created by Лайм HD on 13.11.2020.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - Properties
    
    private var coreDataStack: CoreDataStack!
    private var fetchedResultsController: NSFetchedResultsController<Note>!
    private var hasNotes: Bool {
        self.fetchedResultsController.fetchedObjects?.count ?? 0 > 0
    }
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Notes"
        //self.setupView()
        let activityIndicator = ActivityIndicatorView()
        activityIndicator.insertInto(self.navigationController?.view)
        self.coreDataStack = CoreDataStack(modelName: "Notes") { [unowned self] error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.initializeFetchedResultsController()
            self.fetchNotes()
            self.verifyViewWithDataExistance()
            activityIndicator.removeFromSuperview()
        }
        
        
    }
    
    private func initializeFetchedResultsController() {
        let request = Note.classRequest
        request.sortDescriptors = [Note.SortBy.updateAt(ascending: false)]
        
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: self.coreDataStack.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        self.fetchedResultsController.delegate = self
    }
    
    private func fetchNotes() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Unable to Execute Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    private func verifyViewWithDataExistance() {
        self.tableView.isHidden = !self.hasNotes
        self.messageLabel.isHidden = self.hasNotes
        if self.hasNotes {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case NoteViewController.Mode.addNote.rawValue:
            guard let destination = segue.destination as? NoteViewController
            else { return }
            destination.mode = .addNote
            destination.context = self.coreDataStack.context
        case NoteViewController.Mode.editNote.rawValue:
            guard let destination = segue.destination as? NoteViewController
            else { return }
            guard let indexPath = tableView.indexPathForSelectedRow
            else { return }
            destination.mode = .editNote
            destination.note = self.fetchedResultsController.object(at: indexPath)
        default: break
        }

        
    }
    
    
}

// MARK: - UITableViewDataSource

extension NotesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(NoteCell.self, for: indexPath) else {
            return UITableViewCell()
        }
        
        self.configure(cell, at: indexPath)
        
        return cell
    }
    
    private func configure(_ cell: NoteCell, at indexPath: IndexPath) {
        let note = self.fetchedResultsController.object(at: indexPath)
        cell.configure(with: note)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let note = self.fetchedResultsController.object(at: indexPath)
        self.coreDataStack.context.delete(note)
    }
    
    
}

// MARK: - UITableViewDelegate

extension NotesViewController: UITableViewDelegate {
    
}

// MARK: - CoreDataStackDelegate

//extension NotesViewController: CoreDataStackDelegate {
//    func context(_ context: NSManagedObjectContext, objectsDidChange inserts: Set<NSManagedObject>?, updates: Set<NSManagedObject>?, deletes: Set<NSManagedObject>?) {
//        var notesDidChange = false
//
//        inserts?.forEach { insert in
//            if let note = insert as? Note {
//                self.notes.append(note)
//                notesDidChange = true
//            }
//        }
//
//        let updatedNote = updates?.first { update in
//            let note = update as? Note
//            return note != nil
//        }
//        if updatedNote != nil {
//            notesDidChange = true
//        }
//
//        deletes?.forEach { delete in
//            if let note = delete as? Note {
//                if self.notes.remove(note) != nil {
//                    notesDidChange = true
//                }
//            }
//        }
//
//        if notesDidChange {
//            self.synchronizeViewWithContext()
//        }
//    }
//
//    private func synchronizeViewWithContext() {
//        self.notes.sort { $0.updatedAt ?? Date() > $1.updatedAt ?? Date() }
//        self.tableView.reloadData()
//        self.verifyViewWithDataExistance()
//    }
//
//
//}

// MARK: - NSFetchedResultsControllerDelegate

extension NotesViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        func insertRow(_ indexPath: IndexPath?) {
            if let indexPath = indexPath {
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            }
        }
        func deleteRow(_ indexPath: IndexPath?) {
            if let indexPath = indexPath {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        
        switch type {
        case .insert:
            insertRow(newIndexPath)
        case .delete:
            deleteRow(indexPath)
        case .move:
            insertRow(newIndexPath)
            deleteRow(indexPath)
        case .update:
            if let indexPath = indexPath,
               let cell = self.tableView.cellForRow(at: indexPath) as? NoteCell {
                self.configure(cell, at: indexPath)
            }
        @unknown default:
            print("\(Self.self).\(#function) Неизвестный NSFetchedResultsChangeType")
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        
    }
    
    
}
