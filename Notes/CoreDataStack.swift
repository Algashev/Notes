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

import UIKit
import CoreData

final class CoreDataStack {
    
    // MARK: - Properties
    
    private let modelName: String
    let context: NSManagedObjectContext
    var storeDirectoryURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    }
    
    // MARK: - Initialization
    
    init(modelName: String, completion: @escaping (_ error: Swift.Error?) -> ()) throws {
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
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
            guard let documentURL = self.storeDirectoryURL else {
                DispatchQueue.main.sync {
                    completion(Error.documentDirectorySearchFailure)
                }
                return
            }
            let storeURL = documentURL.appendingPathComponent("\(modelName).sqlite")
            do {
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                self.setupNotificationHandling()
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
    
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)), name: UIApplication.willTerminateNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func saveChanges(_ notification: Notification) {
        self.saveChanges()
    }
    
    private func saveChanges() {
        guard self.context.hasChanges else { return }
        
        do {
            try self.context.save()
            let storeDirectoryURL = self.storeDirectoryURL
            let storePath = storeDirectoryURL?.absoluteString ?? ""
            print("Store path: \(storePath)")
        } catch {
            print("Unable to Save Managed Object Context")
            print("\(error), \(error.localizedDescription)")
        }
    }
}

// MARK: - CoreDataStack Errors

extension CoreDataStack {
    enum Error: Swift.Error, LocalizedError {
        case dataModelSearchFailure(forModelName: String)
        case dataModelCreationFailure(atPath: String)
        case documentDirectorySearchFailure
        case storeMigrationFailure(error: String)
        
        var errorDescription: String? {
            switch self {
            case let .dataModelSearchFailure(forModelName: name):
                let key = "Failed to find data model: \(name)"
                let comment = "Data model search failure"
                return NSLocalizedString(key, comment: comment)
            case let .dataModelCreationFailure(atPath: path):
                let key = "Failed to create model from file: \(path)"
                let comment = "Data model creation failure"
                return NSLocalizedString(key, comment: comment)
            case .documentDirectorySearchFailure:
                let key = "Unable to resolve document directory"
                let comment = "Document directory search failure"
                return NSLocalizedString(key, comment: comment)
            case let .storeMigrationFailure(error: error):
                let key = "Error migrating store: \(error)"
                let comment = "Store migration failure"
                return NSLocalizedString(key, comment: comment)
            }
        }
    }
}
