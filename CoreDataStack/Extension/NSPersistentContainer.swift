//
//  NSPersistentContainer.swift
//  CoreDataStack
//
//  Created by Cirno MainasuK on 2020-6-11.
//

import Foundation
import CoreData

extension NSPersistentContainer {
    // Configure change event handling from external processes.
    public func observeAppExtensionDataChanges() {
        DarwinNotificationCenter.shared.addObserver(self, for: .didSaveManagedObjectContextExternally, using: { [weak self] (_) in
            // Since the viewContext is our root context that's directly connected to the persistent store, we need to update our viewContext.
            self?.viewContext.perform {
                self?.viewContextDidSaveExternally()
            }
        })
    }
}

extension NSPersistentContainer {
    
    /// Called when a certain managed object context has been saved from an external process. It should also be called on the context's queue.
    func viewContextDidSaveExternally() {
        // `refreshAllObjects` only refreshes objects from which the cache is invalid. With a staleness intervall of -1 the cache never invalidates.
        // We set the `stalenessInterval` to 0 to make sure that changes in the app extension get processed correctly.
        viewContext.stalenessInterval = 0
        viewContext.refreshAllObjects()
        viewContext.stalenessInterval = -1
    }
}
