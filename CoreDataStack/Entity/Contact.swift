//
//  Contact.swift
//  CoreDataStack
//
//  Created by Cirno MainasuK on 2020-6-11.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import CoreData

final public class Contact: NSManagedObject {
    @NSManaged public private(set) var id: UUID
    @NSManaged public private(set) var name: String
    @NSManaged public private(set) var createAt: Date
    
    @objc public var nameFirstInitial: String {
        willAccessValue(forKey: #keyPath(name))
        let mutableString = NSMutableString(string: name.trimmingCharacters(in: .whitespacesAndNewlines)) as CFMutableString
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)                // to Latin
        CFStringTransform(mutableString, nil, kCFStringTransformStripCombiningMarks, false)    // remove accent
        let latin = mutableString as String
        let firstInitial: String = {
            guard let first = latin.first else {
                return "#"
            }
            guard first.isLetter else {
                return "#"
            }
            
            return String(first.uppercased())
        }()
        didAccessValue(forKey: #keyPath(name))
        return firstInitial
    }
    
    public static func insert(into context: NSManagedObjectContext, property: Property) -> Contact {
        let contact: Contact = context.insert()
        
        contact.id = UUID()
        contact.name = property.name
        contact.createAt = Date()
        
        return contact
    }
    
}

extension Contact {
    public struct Property {
        public let name: String
        
        public init(name: String) {
            self.name = name
        }
    }
}

extension Contact: Managed {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(keyPath: \Contact.name, ascending: true)]
    }
}
