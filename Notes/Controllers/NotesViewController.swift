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
    private var notes = [Note]() {
        didSet { self.verifyViewWithDataExistance() }
    }
    private var hasNotes: Bool {
        self.notes.count > 0
    }
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Notes"
        //self.setupView()
        let activityIndicator = ActivityIndicatorView()
        activityIndicator.insertInto(self.navigationController?.view)
        self.initializeCoreDataStack() { [unowned self] in
            activityIndicator.removeFromSuperview()
            self.fetchNotes()
        } onFailure: { error in
            print(error.localizedDescription)
        }
        self.coreDataStack.delegate = self
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
    
    private func fetchNotes() {
        let request = Note.classRequest
        request.sortDescriptors = [Note.SortBy.updateAt(ascending: false)]
        
        self.coreDataStack.context.performAndWait {
            do {
                let notes = try self.coreDataStack.context.fetch(request)
                self.notes = notes
                self.tableView.reloadData()
            } catch let error as NSError {
                print("Unable to Execute Fetch Request")
                print("\(error), \(error.localizedDescription)")
                
            }
        }
    }
    
    private func verifyViewWithDataExistance() {
        self.tableView.isHidden = !self.hasNotes
        self.messageLabel.isHidden = self.hasNotes
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
            destination.note = self.notes[indexPath.row]
        default: break
        }
//        if identifier == "\(NoteViewController.self)" {
//            guard let destination = segue.destination as? NoteViewController else {
//                return
//            }
//
//            destination.context = self.coreDataStack.context
//        }
    }
    
    
}

// MARK: - UITableViewDataSource

extension NotesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(NoteCell.self)", for: indexPath) as? NoteCell else {
            return UITableViewCell()
        }
        
        let note = notes[indexPath.row]
        cell.titleLabel.text = note.title
        cell.updatedAtLabel.text = note.updatedAt?.string()
        cell.contentsLabel.text = note.contents ?? " "
        
        return cell
    }
    
    
}

// MARK: - UITableViewDelegate

extension NotesViewController: UITableViewDelegate {
    
}

// MARK: - CoreDataStackDelegate

extension NotesViewController: CoreDataStackDelegate {
    func context(_ context: NSManagedObjectContext, objectsObjectsDidChange inserts: Set<NSManagedObject>?, updates: Set<NSManagedObject>?, deletes: Set<NSManagedObject>?) {
        var notesDidChange = false
        
        inserts?.forEach { insert in
            if let note = insert as? Note {
                self.notes.append(note)
                notesDidChange = true
            }
        }
        
        let updatedNote = updates?.first { update in
            let note = update as? Note
            return note != nil
        }
        if updatedNote != nil {
            notesDidChange = true
        }
        
        deletes?.forEach { delete in
            if let note = delete as? Note {
                if self.notes.remove(note) != nil {
                    notesDidChange = true
                }
            }
        }

        if notesDidChange {
            self.synchronizeViewWithContext()
        }
    }
    
    private func synchronizeViewWithContext() {
        self.notes.sort { $0.updatedAt ?? Date() > $1.updatedAt ?? Date() }
        self.tableView.reloadData()
        self.verifyViewWithDataExistance()
    }
    
    
}
