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
    @NSManaged public private(set) var publicKey: String
    @NSManaged public private(set) var keyID: String
    
    @NSManaged public private(set) var createdAt: Date
    @NSManaged public private(set) var updatedAt: Date
    
    // many-to-many relationship
    @NSManaged public private(set) var chats: Set<Chat>
    
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
        stub.publicKey = property.publicKey
        stub.keyID = property.keyID
        return stub
    }
    
}

extension ChatMemberNameStub {
    public struct Property {
        public let name: String?
        public let publicKey: String
        public let keyID: String
        
        public init(name: String, publicKey: String, keyID: String) {
            self.name = name
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


