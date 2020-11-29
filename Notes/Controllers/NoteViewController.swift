//
//  NoteViewController.swift
//  Notes
//
//  Created by Александр Алгашев on 22.11.2020.
//

import UIKit
import CoreData

class NoteViewController: UIViewController {
    enum Mode: String {
        case addNote
        case editNote
        
        var title: String {
            switch self {
            case .addNote: return "Add Note"
            case .editNote: return "Edit Note"
            }
        }
    }
    
    // MARK: - Properties
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentsTextView: UITextView!
    
    var mode = Mode.addNote
    var context: NSManagedObjectContext?
    var note: Note?
    var completion: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.mode.title
        
        if self.mode == .editNote {
            self.setupNoteValues()
        }
    }
    
    private func setupNoteValues() {
        self.titleTextField.text = self.note?.title
        self.contentsTextView.text = self.note?.contents
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.completion?()
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard let title = titleTextField.text, !title.isEmpty else {
            let alert = UIAlertController(title: "Title Missing", message: "Your note doesn't have a title.")
            alert.addAction(title: "Ok", style: .default)
            self.present(alert, animated: true)
            
            return
        }
        
        self.completion = {
            let contents = self.contentsTextView.text
            
            switch self.mode {
            case .addNote:
                guard let context = self.context else { return }
                if let note = Note(title: title, in: context) {
                    note.contents = contents
                    print(note)
                } else {
                    print("Failed create Note")
                }
            case .editNote:
                self.note?.title = title
                self.note?.updatedAt = Date()
                self.note?.contents = contents
            }
        }
        
        
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
