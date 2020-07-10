//
//  ChatMemberNameStub.swift
//  CoreDataStack
//
//  Created by Cirno MainasuK on 2020-6-16.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import CoreData

final public class ChatMemberNameStub: NSManagedObject {
    
    @NSManaged public private(set) var id: UUID
    @NSManaged public private(set) var name: String?
    @NSManaged public private(set) var i18nNames: [String:String]?
    @NSManaged public private(set) var publicKey: String
    @NSManaged public private(set) var keyID: String
    
    @NSManaged public private(set) var createdAt: Date
    @NSManaged public private(set) var updatedAt: Date
    
    // many-to-many relationship
    @NSManaged public private(set) var chats: Set<Chat>
    
}

extension ChatMemberNameStub {
    public var i18nName: String? {
        var i18nName: String?
        let i18nNames = self.i18nNames ?? [:]
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
}

extension ChatMemberNameStub {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        id = UUID()
        
        let now = Date()
        createdAt = now
        updatedAt = now
    }
    
    public static func insert(into context: NSManagedObjectContext, property: Property) -> ChatMemberNameStub {
        let stub: ChatMemberNameStub = context.insertObject()
        stub.name = property.name
        stub.i18nNames = property.i18nNames
        stub.publicKey = property.publicKey
        stub.keyID = property.keyID
        return stub
    }
    
}

extension ChatMemberNameStub {
    public struct Property {
        public let name: String?
        public let i18nNames: [String: String]?
        public let publicKey: String
        public let keyID: String
        
        public init(name: String?, i18nNames: [String: String]?, publicKey: String, keyID: String) {
            self.name = name
            self.i18nNames = i18nNames
            self.publicKey = publicKey
            self.keyID = keyID
        }
    }
}

extension ChatMemberNameStub: Managed {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(keyPath: \ChatMemberNameStub.createdAt, ascending: true)]
    }
}

extension ChatMemberNameStub {
    
    public static func predicate(publicKey: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(ChatMemberNameStub.publicKey), publicKey)
    }
}

