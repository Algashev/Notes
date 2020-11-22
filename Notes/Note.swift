//
//  Note.swift
//  Notes
//
//  Created by Александр Алгашев on 22.11.2020.
//

import CoreData

extension Note {
    convenience init?(title: String?, in context: NSManagedObjectContext?) {
        self.init(insertInto: context)
        self.title = title
        
        let date = Date()
        self.createdAt = date
        self.updatedAt = date
    }
}
