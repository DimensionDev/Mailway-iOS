//
//  Contact.swift
//  CoreDataStack
//
//  Created by Cirno MainasuK on 2020-6-11.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import CoreData

final public class Contact: NSManagedObject {
    
    @NSManaged public private(set) var id: UUID
    @NSManaged public private(set) var name: String
    @NSManaged public private(set) var note: String?
    @NSManaged public private(set) var avatarData: Data?
    @NSManaged public private(set) var color: UIColor
    
    @NSManaged public private(set) var createdAt: Date
    @NSManaged public private(set) var updatedAt: Date
    
    // transient property
    @objc public var nameFirstInitial: String {
        willAccessValue(forKey: #keyPath(nameFirstInitial))
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
        didAccessValue(forKey: #keyPath(nameFirstInitial))
        return firstInitial
    }
    
    // transient property
    @objc public var avatar: UIImage? {
        get {
            willAccessValue(forKey: #keyPath(avatar))
            let image = avatarData.flatMap { UIImage(data: $0) }
            didAccessValue(forKey: #keyPath(avatar))
            
            return image
        }
        set {
            willChangeValue(forKey: #keyPath(avatar))
            avatarData = newValue?.pngData()
            didChangeValue(forKey: #keyPath(avatar))
        }
    }
    
    // one-to-one keypair
    @NSManaged public private(set) var keypair: Keypair?
    
    // one-to-one keypair
    @NSManaged public private(set) var businessCard: BusinessCard?
    
    // one-to-many relationship
    @NSManaged public private(set) var channels: Set<ContactChannel>?
    
}

extension Contact {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        id = UUID()
        
        let now = Date()
        createdAt = now
        updatedAt = now
    }
    
    @discardableResult
    public static func insert(into context: NSManagedObjectContext, property: Property, keypair: Keypair, channels: [ContactChannel], businessCard: BusinessCard?) -> Contact {
        let contact: Contact = context.insertObject()
        contact.name = property.name
        contact.note = property.note
        contact.avatar = property.avatar
        contact.color = property.color
        
        contact.keypair = keypair
        contact.businessCard = businessCard
        contact.channels = Set(channels)
//        contact.mutableSetValue(forKey: #keyPath(Contact.channels)).addObjects(from: channels)
        return contact
    }
    
    public func update(color: UIColor) {
        self.color = color
    }
    
}


extension Contact {
    public struct Property {
        public let name: String
        public let note: String?
        public let avatar: UIImage?
        public let color: UIColor
        
        public init(name: String, note: String? = nil, avatar: UIImage? = nil, color: UIColor) {
            self.name = name
            self.note = note
            self.avatar = avatar
            self.color = color
        }
    }
}

extension Contact: Managed {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(keyPath: \Contact.name, ascending: true)]
    }
}

extension Contact {
    public static var createdAtAscendingSortedFetchRequest: NSFetchRequest<Contact> {
        let request = NSFetchRequest<Contact>(entityName: entityName)
        request.sortDescriptors =  [NSSortDescriptor(keyPath: \Contact.createdAt, ascending: true)]
        return request
    }
    
    public static var createdAtDescendingSortedFetchRequest: NSFetchRequest<Contact> {
        let request = NSFetchRequest<Contact>(entityName: entityName)
        request.sortDescriptors =  [NSSortDescriptor(keyPath: \Contact.createdAt, ascending: false)]
        return request
    }
}

extension Contact {
    
    public static var notIdentityPredicate: NSPredicate {
        return NSPredicate(format: "%K != nil AND %K.%K == nil", #keyPath(Contact.keypair), #keyPath(Contact.keypair), #keyPath(Keypair.privateKey))
    }
    
    public static var isIdentityPredicate: NSPredicate {
        return NSPredicate(format: "%K != nil AND %K.%K != nil", #keyPath(Contact.keypair), #keyPath(Contact.keypair), #keyPath(Keypair.privateKey))
    }
    
    public static func predicate(publicKey: String) -> NSPredicate {
        return NSPredicate(format: "%K != nil AND %K.%K == %@", #keyPath(Contact.keypair), #keyPath(Contact.keypair), #keyPath(Keypair.publicKey), publicKey)
    }
    
}
