//
//  NSManagedObjectContext.swift
//  CoreDataStack
//
//  Created by Cirno MainasuK on 2020-6-11.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import Foundation
import CoreData

extension NSManagedObjectContext {
    public func insert<T: NSManagedObject>() -> T where T: Managed {
        guard let object = NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: self) as? T else {
            fatalError("cannot insert object: \(T.self)")
        }
        
        return object
    }
    
    public func saveOrRollback() -> Bool {
        do {
            try save()
        } catch {
            os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, error.localizedDescription)

            rollback()
            return false
        }
        
        return true
    }
    
    public func performChanges(block: @escaping () -> Void) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }
}
