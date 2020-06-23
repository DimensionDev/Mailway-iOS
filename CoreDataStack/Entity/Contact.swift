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
    @NSManaged public private(set) var i18nNames: [String: String]
    @NSManaged public private(set) var note: String?
    @NSManaged public private(set) var avatarData: Data?
    
    @NSManaged public private(set) var createdAt: Date
    @NSManaged public private(set) var updatedAt: Date
    
    // transient property
    @objc public var nameFirstInitial: String {
        willAccessValue(forKey: #keyPath(nameFirstInitial))
        let usingName = i18nName ?? name
        let mutableString = NSMutableString(string: usingName.trimmingCharacters(in: .whitespacesAndNewlines)) as CFMutableString
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
    
    public var i18nName: String? {
        var i18nName: String?
        if !i18nNames.isEmpty {
            let preferredLanguages = Locale.preferredLanguages
            for language in preferredLanguages {
                let locale = Locale(identifier: language)
                guard let languageCode = locale.languageCode else {
                    continue
                }
                
                i18nName = i18nNames[languageCode]
                break
            }
        }
        
        return i18nName
    }
    
    // primitive property
    @NSManaged private var primitiveAvatar: UIImage?
    
    // transient property
    @objc public private(set) var avatar: UIImage? {
        get {
            willAccessValue(forKey: #keyPath(avatar))
            var image = primitiveAvatar
            didAccessValue(forKey: #keyPath(avatar))
            
            if image == nil {
                image = avatarData.flatMap { UIImage(data: $0) }
                primitiveAvatar = image
            }
            
            return image
        }
        set {
            willChangeValue(forKey: #keyPath(avatar))
            primitiveAvatar = newValue
            didChangeValue(forKey: #keyPath(avatar))
            
            avatarData = newValue?.pngData()
        }
    }
    
    // one-to-one keypair
    @NSManaged public private(set) var keypair: Keypair
    // one-to-many relationship
    @NSManaged public private(set) var channels: Set<ContactChannel>
    
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
    public static func insert(into context: NSManagedObjectContext, property: Property, keypair: Keypair, channels: [ContactChannel]) -> Contact {
        let contact: Contact = context.insertObject()
        contact.name = property.name
        contact.i18nNames = property.i18nNames
        contact.note = property.note
        contact.avatar = property.avatar
        
        contact.keypair = keypair
        contact.channels = Set(channels)
//        contact.mutableSetValue(forKey: #keyPath(Contact.channels)).addObjects(from: channels)
        return contact
    }
}


extension Contact {
    public struct Property {
        public let name: String
        public let i18nNames: [String:String]
        public let note: String?
        public let avatar: UIImage?
        
        public init(name: String, i18nNames: [String: String] = [:], note: String? = nil, avatar: UIImage? = nil) {
            self.name = name
            self.i18nNames = i18nNames
            self.note = note
            self.avatar = avatar
        }
    }
}

extension Contact: Managed {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(keyPath: \Contact.name, ascending: true)]
    }
}
