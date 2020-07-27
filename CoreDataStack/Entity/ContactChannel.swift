//
//  ContactChannel.swift
//  CoreDataStack
//
//  Created by Cirno MainasuK on 2020-6-15.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import CoreData

final public class ContactChannel: NSManagedObject {
    
    @NSManaged public private(set) var id: UUID
    @NSManaged public private(set) var name: String
    @NSManaged public private(set) var value: String
    
    @NSManaged public private(set) var createdAt: Date
    @NSManaged public private(set) var updatedAt: Date
    
    // many-to-one relationship
    @NSManaged public private(set) var contact: Contact
    
}

extension ContactChannel {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        id = UUID()
        
        let now = Date()
        createdAt = now
        updatedAt = now
    }
    
    public static func insert(into context: NSManagedObjectContext, property: Property) -> ContactChannel {
        let channel: ContactChannel = context.insertObject()
        channel.name = property.name.text
        channel.value = property.value
        return channel
    }
    
}

extension ContactChannel {
    public struct Property {
        public let name: ChannelName
        public let value: String
        
        public init(name: ChannelName, value: String) {
            self.name = name
            self.value = value
        }
        
        public enum ChannelName: Hashable {
            case email
            case twitter
            case facebook
            case telegram
            case discord
            case custom(String)
            
            public init(name: String) {
                let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                switch name {
                case ChannelName.email.text:        self = .email
                case ChannelName.twitter.text:      self = .twitter
                case ChannelName.facebook.text:     self = .facebook
                case ChannelName.telegram.text:     self = .telegram
                case ChannelName.discord.text:      self = .discord
                default:                            self = .custom(name)
                }
            }
            
            public var text: String {
                switch self {
                case .email:                return "email"
                case .twitter:              return "twitter"
                case .facebook:             return "facebook"
                case .telegram:             return "telegram"
                case .discord:              return "discord"
                case .custom(let name):     return name.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            
            public var isCustom: Bool {
                switch self {
                case .custom:
                    return true
                default:
                    return false
                }
            }
            
            public static var fixed: [Self] {
                return [.email, .twitter, .facebook, .telegram, .discord]
            }
        }
    }
}

extension ContactChannel: Managed {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(keyPath: \ContactChannel.createdAt, ascending: true)]
    }
}
