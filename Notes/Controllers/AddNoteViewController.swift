//
//  AddNoteViewController.swift
//  Notes
//
//  Created by Александр Алгашев on 22.11.2020.
//

import UIKit
import CoreData

class AddNoteViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentsTextView: UITextView!
    
    var managedObjectContext: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard let context = self.managedObjectContext else { return }
        guard let title = titleTextField.text, !title.isEmpty else {
            let alert = UIAlertController(title: "Title Missing", message: "Your note doesn't have a title.")
            alert.addAction(title: "Ok", style: .default)
            self.present(alert, animated: true)
            
            return
        }
        
        if let note = Note(title: title, in: context) {
            note.contents = self.contentsTextView.text
            print(note)
        } else {
            print("Failed create Note")
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
