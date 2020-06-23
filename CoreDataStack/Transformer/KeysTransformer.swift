//
//  KeysTransformer.swift
//  CoreDataStack
//
//  Created by jk234ert on 6/23/20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation

@objc(KeysTransformer)
class KeysTransformer: NSSecureUnarchiveFromDataTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            return nil
        }
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String]
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let keys = value as? [String] else {
            return nil
        }
        
        return try? NSKeyedArchiver.archivedData(withRootObject: keys, requiringSecureCoding: true)
    }
}

