//
//  ChatMessage.swift
//  CoreDataStack
//
//  Created by Cirno MainasuK on 2020-6-16.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import CoreData

final public class ChatMessage: NSManagedObject {
    
    @NSManaged public private(set) var id: UUID
    @NSManaged public private(set) var messageID: String
    
    @NSManaged public private(set) var senderPublicKey: String?
    @NSManaged public private(set) var recipientPublicKeys: [String]
    
    @NSManaged public private(set) var version: Int64
    
    @NSManaged public private(set) var armoredMessage: String?
    @NSManaged public private(set) var payload: Data
    @NSManaged private var payloadKindRawValue: String
    
    private(set) public var payloadKind: PayloadKind {
        get {
            guard let kind = PayloadKind(rawValue: payloadKindRawValue) else {
                return .unknown
            }
            
            return kind
        }
        set {
            payloadKindRawValue = newValue.rawValue
        }
    }
    @NSManaged public private(set) var isDraft: Bool
    
    @NSManaged public private(set) var createdAt: Date
    @NSManaged public private(set) var updatedAt: Date
    
    @NSManaged public private(set) var messageTimestamp: Date?
    @NSManaged public private(set) var composeTimestamp: Date?
    @NSManaged public private(set) var receiveTimestamp: Date
    @NSManaged public private(set) var shareTimestamp: Date?
    
    // many-to-one relationship
     @NSManaged public private(set) var chat: Chat?
    
    // one-to-one relationship
    @NSManaged public private(set) var quoteMessage: QuoteMessage?

}

extension ChatMessage {
    public enum PayloadKind: String {
        case unknown
        case plaintext
        case image
        case video
        case audio
        case other
    }
}

extension ChatMessage {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        id = UUID()
        
        let now = Date()
        createdAt = now
        updatedAt = now
    }
    
    public static func insert(into context: NSManagedObjectContext, property: Property, chat: Chat?, quoteMessage: QuoteMessage?) -> ChatMessage {
        let chatMessage: ChatMessage = context.insertObject()
        
        chatMessage.messageID = property.messageID
        chatMessage.senderPublicKey = property.senderPublicKey
        chatMessage.recipientPublicKeys = property.recipientPublicKeys
        chatMessage.version = property.version
        chatMessage.armoredMessage = property.armoredMessage
        chatMessage.payload = property.payload
        chatMessage.payloadKind = property.payloadKind
        chatMessage.isDraft = property.isDraft
        chatMessage.messageTimestamp = property.messageTimestamp
        chatMessage.composeTimestamp = property.composeTimestamp
        chatMessage.receiveTimestamp = property.receiveTimestamp
        chatMessage.shareTimestamp = property.shareTimestamp
        
        chatMessage.chat = chat
        chatMessage.quoteMessage = quoteMessage
        
        return chatMessage
    }
    
    public func update(payload: Data) {
        self.payload = payload
    }
    
    public func update(recipientPublicKeys: [String]) {
        self.recipientPublicKeys = recipientPublicKeys
    }
    
    public func update(senderPublicKey: String) {
        self.senderPublicKey = senderPublicKey
    }
    
}

extension ChatMessage {
    public struct Property {
        public let messageID: String
        
        public let senderPublicKey: String?
        public let recipientPublicKeys: [String]
        
        public let version: Int64
        
        public let armoredMessage: String?
        public let payload: Data
        public let payloadKind: PayloadKind
        public let isDraft: Bool
        
        public let messageTimestamp: Date?
        public let composeTimestamp: Date?
        public let receiveTimestamp: Date
        public let shareTimestamp: Date?
        
        public init(
            messageID: String,
            senderPublicKey: String?,
            recipientPublicKeys: [String],
            version: Int,
            armoredMessage: String?,
            payload: Data,
            payloadKind: PayloadKind,
            isDraft: Bool,
            messageTimestamp: Date?,
            composeTimestamp: Date?,
            receiveTimestamp: Date,
            shareTimestamp: Date?
        ) {
            self.messageID = messageID
            self.senderPublicKey = senderPublicKey
            self.recipientPublicKeys = recipientPublicKeys
            self.version = Int64(version)
            self.armoredMessage = armoredMessage
            self.payload = payload
            self.payloadKind = payloadKind
            self.isDraft = isDraft
            self.messageTimestamp = messageTimestamp
            self.composeTimestamp = composeTimestamp
            self.receiveTimestamp = receiveTimestamp
            self.shareTimestamp = shareTimestamp
        }
    }
}

extension ChatMessage: Managed {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(keyPath: \ChatMessage.receiveTimestamp, ascending: true)]
    }
}

extension ChatMessage {
    public static var latestFirstSortFetchRequest: NSFetchRequest<ChatMessage> {
        let request = NSFetchRequest<ChatMessage>(entityName: entityName)
        request.sortDescriptors =  [NSSortDescriptor(keyPath: \ChatMessage.receiveTimestamp, ascending: false)]
        return request
    }
}

extension ChatMessage {
    
    public static func predicate(chat: Chat) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(ChatMessage.chat), chat)
    }
    
    public static func predicate(messageID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(ChatMessage.messageID), messageID)
    }
    
    public static var isDraftPredicate: NSPredicate {
        return NSPredicate(format: "%K == YES", #keyPath(ChatMessage.isDraft))
    }
    
}
