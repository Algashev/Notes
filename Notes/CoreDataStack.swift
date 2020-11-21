//
//  CoreDataStack.swift
//  Notes
//
//  Created by Александр Алгашев on 21.11.2020.
//
//  Apple documentation
//  - Core Data Stack: https://developer.apple.com/documentation/coredata/core_data_stack
//  - Setting Up a Core Data Stack: https://developer.apple.com/documentation/coredata/setting_up_a_core_data_stack
//  - Setting Up a Core Data Stack Manually: https://developer.apple.com/documentation/coredata/setting_up_a_core_data_stack/setting_up_a_core_data_stack_manually
//  - Initializing the Core Data Stack: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/InitializingtheCoreDataStack.html#//apple_ref/doc/uid/TP40001075-CH4-SW1


import CoreData

final class CoreDataStack {
    
    // MARK: - Properties
    
    private let modelName: String
    let context: NSManagedObjectContext
    
    // MARK: - Initialization
    
    init(modelName: String, completion: @escaping (_ error: Swift.Error?) -> ()) throws {
        guard let modelURL = Bundle.main.url(forResource: modelName,
                                             withExtension: "momd") else {
            throw Error.dataModelSearchFailure(forModelName: modelName)
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw Error.dataModelCreationFailure(atPath: modelURL.absoluteString)
        }
        
        self.modelName = modelName
        self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        self.context.persistentStoreCoordinator = coordinator
        
        DispatchQueue.global(qos: .background).async {
            guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
                DispatchQueue.main.sync {
                    completion(Error.documentDirectorySearchFailure)
                }
                return
            }
            let storeURL = documentURL.appendingPathComponent("\(modelName).sqlite")
            do {
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                DispatchQueue.main.sync {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.sync {
                    completion(Error.storeMigrationFailure(error: error.localizedDescription))
                }
            }
        }
    }
}

// MARK: - CoreDataStack Error

extension CoreDataStack {
    enum Error: Swift.Error, LocalizedError {
        case dataModelSearchFailure(forModelName: String)
        case dataModelCreationFailure(atPath: String)
        case documentDirectorySearchFailure
        case storeMigrationFailure(error: String)
        
        public var errorDescription: String? {
            switch self {
            case let .dataModelSearchFailure(forModelName: name):
                let key = "Data model search failure"
                let comment = "Failed to find data model: \(name)"
                return NSLocalizedString(key, comment: comment)
            case let .dataModelCreationFailure(atPath: path):
                let key = "Data model creation failure"
                let comment = "Failed to create model from file: \(path)"
                return NSLocalizedString(key, comment: comment)
            case .documentDirectorySearchFailure:
                let key = "Document directory search failure"
                let comment = "Unable to resolve document directory"
                return NSLocalizedString(key, comment: comment)
            case let .storeMigrationFailure(error: error):
                let key = "Store migration failure"
                let comment = "Error migrating store: \(error)"
                return NSLocalizedString(key, comment: comment)
            }
        }
    }
}
