//
//  Chat.swift
//  CoreDataStack
//
//  Created by Cirno MainasuK on 2020-6-16.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import CoreData

final public class Chat: NSManagedObject {
    
    @NSManaged public private(set) var id: UUID
    @NSManaged public private(set) var title: String
    @NSManaged public private(set) var identityPublicKey: String
    
    @NSManaged public private(set) var createdAt: Date
    @NSManaged public private(set) var updatedAt: Date
    
    // many-to-many relationship
    @NSManaged public private(set) var memberNameStubs: Set<ChatMemberNameStub>
    
}

extension Chat {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        id = UUID()
        
        let now = Date()
        createdAt = now
        updatedAt = now
    }
    
    public static func insert(into context: NSManagedObjectContext, property: Property, memberNameStubs: [ChatMemberNameStub]) -> Chat {
        let chat: Chat = context.insertObject()
        chat.title = property.title
        chat.identityPublicKey = property.identityPublicKey
        chat.mutableSetValue(forKey: #keyPath(Chat.memberNameStubs)).addObjects(from: memberNameStubs)
        return chat
    }
    
}

extension Chat {
    public struct Property {
        public let title: String
        public let identityPublicKey: String
        
        public init(title: String, identityPublicKey: String) {
            self.title = title
            self.identityPublicKey = identityPublicKey
        }
    }
}

extension Chat: Managed {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(keyPath: \Chat.createdAt, ascending: true)]
    }
}

