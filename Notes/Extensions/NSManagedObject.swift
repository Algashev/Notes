//
//  NSManagedObject.swift
//  Notes
//
//  Created by Александр Алгашев on 22.11.2020.
//

import CoreData

extension NSManagedObject {
    static func entity(in context: NSManagedObjectContext) -> NSEntityDescription? {
        NSEntityDescription.entity(forEntityName: "\(Self.self)", in: context)
    }
    
    convenience init?(insertInto context: NSManagedObjectContext?) {
        guard let context = context else {
            print("Failed insert \(Self.self) into managed object context. Context is nil.")
            return nil
        }
        
        guard let entity = Self.entity(in: context)  else {
            print("Failed create entity description for \(Self.self).")
            return nil
        }
        
        self.init(entity: entity, insertInto: context)
    }
}
