//
//  Keypair.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-10.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import CoreData

final public class Keypair: NSManagedObject {
    @NSManaged public private(set) var id: UUID
    
    @NSManaged public private(set) var privateKey: String?
    @NSManaged public private(set) var publicKey: String
    @NSManaged public private(set) var keyID: String
    
    @NSManaged public private(set) var createdAt: Date
    @NSManaged public private(set) var updatedAt: Date
    
    // many-to-one relationship
    @NSManaged public private(set) var contact: Contact
}

extension Keypair {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
            
        id = UUID()
        
        let now = Date()
        createdAt = now
        updatedAt = now
    }
    
    public static func insert(into context: NSManagedObjectContext, property: Property) -> Keypair {
        let keypair: Keypair = context.insertObject()
        keypair.privateKey = property.privateKey
        keypair.publicKey = property.publicKey
        keypair.keyID = property.keyID
        return keypair
    }
    
}

extension Keypair {
    public struct Property {
        public let privateKey: String?
        public let publicKey: String
        public let keyID: String
        
        public init(privateKey: String?, publicKey: String, keyID: String) {
            self.privateKey = privateKey
            self.publicKey = publicKey
            self.keyID = keyID
        }
    }
}


extension Keypair: Managed {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(keyPath: \Keypair.createdAt, ascending: true)]
    }
}
