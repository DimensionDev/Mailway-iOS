//
//  QuoteMessage.swift
//  CoreDataStack
//
//  Created by Cirno MainasuK on 2020-6-18.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import CoreData

final public class QuoteMessage: NSManagedObject {
    @NSManaged public private(set) var id: UUID
    
    @NSManaged public private(set) var messageID: UUID
    @NSManaged public private(set) var digest: Data?
    @NSManaged private var digestKindRawValue: String
    
    private(set) public var digestKind: ChatMessage.PayloadKind {
        get {
            guard let kind = ChatMessage.PayloadKind(rawValue: digestKindRawValue) else {
                return .unknwon
            }
            
            return kind
        }
        set {
            digestKindRawValue = newValue.rawValue
        }
    }
    
    @NSManaged public private(set) var digestDescription: String?
    
    @NSManaged public private(set) var senderName: String?
    @NSManaged public private(set) var senderPublicKey: String
    
    @NSManaged public private(set) var createdAt: Date
    @NSManaged public private(set) var updatedAt: Date
    
    // many-to-one relationship
    @NSManaged public private(set) var chatMessage: ChatMessage
    
}

extension QuoteMessage {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        id = UUID()
        
        let now = Date()
        createdAt = now
        updatedAt = now
    }
    
    @discardableResult
    public static func insert(into context: NSManagedObjectContext, property: Property) -> QuoteMessage {
        let quoteMessage: QuoteMessage = context.insertObject()
        // TODO:
        return quoteMessage
    }
    
}

extension QuoteMessage {
    public struct Property {
        
        public let messageID: String
        public let digest: Data?
        public let digestKind: ChatMessage.PayloadKind
        public let digestDescription: String?
        public let senderName: String?
        public let senderPublicKey: String
        
        public init(messageID: String, digest: Data?, digestKind: ChatMessage.PayloadKind, digestDescription: String?, senderName: String?, senderPublicKey: String) {
            self.messageID = messageID
            self.digest = digest
            self.digestKind = digestKind
            self.digestDescription = digestDescription
            self.senderName = senderName
            self.senderPublicKey = senderPublicKey
        }
    }
}


extension QuoteMessage: Managed {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(keyPath: \QuoteMessage.createdAt, ascending: true)]
    }
}
