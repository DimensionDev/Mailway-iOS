//
//  CoreDataStack.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-10.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import Foundation
import CoreData

public final class CoreDataStack {
    
    // MARK: - Singleton
    public static let shared: CoreDataStack = {
        let storeURL = URL.storeURL(for: "group.im.dimension.Mailway", databaseName: "CoreDataStack")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        return CoreDataStack(persistentStoreDescriptions: [storeDescription])
    }()
    
    private let storeDescriptions: [NSPersistentStoreDescription]
    
    
    init(persistentStoreDescriptions storeDescriptions: [NSPersistentStoreDescription]) {
        self.storeDescriptions = storeDescriptions
    }

    public private(set) lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let bundles = [Bundle(for: Keypair.self)]
        guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: bundles) else {
            fatalError("cannot locate bundles")
        }
        
        let container = NSPersistentCloudKitContainer(name: "CoreDataStack", managedObjectModel: managedObjectModel)
        container.persistentStoreDescriptions = storeDescriptions
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, storeDescription.debugDescription)
        })
        return container
    }()
    
}
