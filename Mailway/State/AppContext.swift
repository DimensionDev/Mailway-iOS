//
//  AppContext.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI
import Combine
import CoreDataStack

class AppContext: ObservableObject {
    
    @Published var viewStateStore = ViewStateStore()
    
    let documentStore = DocumentStore()
    private var documentStoreSubscription: AnyCancellable!
    
    let managedObjectContext: NSManagedObjectContext

    init() {
        let coreDataStack = CoreDataStack.shared
        managedObjectContext = coreDataStack.persistentContainer.viewContext
        
        coreDataStack.persistentContainer.observeAppExtensionDataChanges()

        documentStoreSubscription = documentStore.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                self.objectWillChange.send()
            }
    }
    
}
 
