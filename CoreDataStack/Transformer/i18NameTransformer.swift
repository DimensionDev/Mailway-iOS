//
//  i18NameTransformer.swift
//  CoreDataStack
//
//  Created by jk234ert on 6/23/20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation

//@objc(i18NameTransformer)
//class i18NameTransformer: NSSecureUnarchiveFromDataTransformer {
//    override class func transformedValueClass() -> AnyClass {
//        return NSData.self
//    }
//    
//    override class func allowsReverseTransformation() -> Bool {
//        return true
//    }
//    
//    override func reverseTransformedValue(_ value: Any?) -> Any? {
//        guard let data = value as? Data else {
//            return nil
//        }
//        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: String]
//    }
//    
//    override func transformedValue(_ value: Any?) -> Any? {
//        guard let names = value as? [String: String] else {
//            return nil
//        }
//        
//        return try? NSKeyedArchiver.archivedData(withRootObject: names, requiringSecureCoding: true)
//    }
//}
