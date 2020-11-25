//
//  Note.swift
//  Notes
//
//  Created by Александр Алгашев on 22.11.2020.
//

import CoreData

extension Note {
    struct SortBy {
        static func updateAt(ascending: Bool = true) -> NSSortDescriptor {
            NSSortDescriptor(key: #keyPath(Note.updatedAt), ascending: ascending)
        }
    }
    
    class var classRequest: NSFetchRequest<Note> { Note.fetchRequest() }
    
    convenience init?(title: String?, in context: NSManagedObjectContext?) {
        self.init(insertInto: context)
        self.title = title
        
        let date = Date()
        self.createdAt = date
        self.updatedAt = date
    }
}
