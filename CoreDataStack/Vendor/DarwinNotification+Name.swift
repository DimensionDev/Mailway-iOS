//
//  DarwinNotification+Name.swift
//  CoreDataStack
//
//  Created by Cirno MainasuK on 2020-6-11.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation

extension DarwinNotification.Name {
    private static let appIsExtension = Bundle.main.bundlePath.hasSuffix(".appex")
    
    /// The relevant DarwinNotification name to observe when the managed object context has been saved in an external process.
    public static var didSaveManagedObjectContextExternally: DarwinNotification.Name {
        if appIsExtension {
            return appDidSaveManagedObjectContext
        } else {
            return extensionDidSaveManagedObjectContext
        }
    }
    
    /// The notification to post when a managed object context has been saved and stored to the persistent store.
    public static var didSaveManagedObjectContextLocally: DarwinNotification.Name {
        if appIsExtension {
            return extensionDidSaveManagedObjectContext
        } else {
            return appDidSaveManagedObjectContext
        }
    }
    
    /// Notification to be posted when the shared Core Data database has been saved to disk from an extension. Posting this notification between processes can help us fetching new changes when needed.
    private static var extensionDidSaveManagedObjectContext: DarwinNotification.Name {
        return DarwinNotification.Name("im.dimension.Mailway.extension-did-save")
    }
    
    /// Notification to be posted when the shared Core Data database has been saved to disk from the app. Posting this notification between processes can help us fetching new changes when needed.
    private static var appDidSaveManagedObjectContext: DarwinNotification.Name {
        return DarwinNotification.Name("im.dimension.Mailway.app-did-save")
    }
}
