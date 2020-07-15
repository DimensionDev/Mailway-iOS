//
//  BusinessCard.swift
//  CoreDataStack
//
//  Created by Cirno MainasuK on 2020-7-14.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import CoreData

final public class BusinessCard: NSManagedObject {
    
    @NSManaged public private(set) var id: UUID
    @NSManaged public private(set) var businessCard: String
    
    @NSManaged public private(set) var createdAt: Date
    @NSManaged public private(set) var updatedAt: Date
    
    // one-to-one relationship
    @NSManaged public private(set) var contact: Contact?
    
}

extension BusinessCard {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        id = UUID()
        
        let now = Date()
        createdAt = now
        updatedAt = now
    }
    
    @discardableResult
    public static func insert(into context: NSManagedObjectContext, property: Property) -> BusinessCard {
        let businessCard: BusinessCard = context.insertObject()
        businessCard.businessCard = property.businessCard
        return businessCard
    }
}

extension BusinessCard {
    public struct Property {
        public let businessCard: String
        
        public init(businessCard: String) {
            self.businessCard = businessCard
        }
    }
}

extension BusinessCard: Managed {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(keyPath: \BusinessCard.createdAt, ascending: true)]
    }
}
