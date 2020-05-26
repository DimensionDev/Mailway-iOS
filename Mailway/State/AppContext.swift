//
//  AppContext.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import SwiftUI
import Combine

class AppContext: ObservableObject {
    
    @Published var viewStateStore = ViewStateStore()
    
    let documentStore = DocumentStore()
    private var documentStoreSubscription: AnyCancellable!
    
    init() {
        documentStoreSubscription = documentStore.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                self.objectWillChange.send()
            }
    }
    
}
 
