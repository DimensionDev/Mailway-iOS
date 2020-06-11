//
//  Keypair.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-10.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import CoreData

final class Keypair: NSManagedObject {
    @NSManaged private(set) var id: UUID
    @NSManaged private(set) var createAt: Date
}

extension Keypair: Managed {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(keyPath: \Keypair.createAt, ascending: false)]
    }
}
