//
//  DocumentStore.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Combine

class DocumentStore: ObservableObject {
    @Published private(set) var chats: [Chat] = []
    @Published private(set) var contacts: [Contact] = []
}

extension DocumentStore {
    
    func insert(contact: Contact) {
        guard !contacts.contains(where: { $0.id == contact.id }) else {
            return
        }
        contacts.append(contact)
    }
    
    #if PREVIEW
    func setupPreview() {
        guard contacts.isEmpty else { return }
        contacts.append(contentsOf: Contact.samples)
    }
    #endif
    
}
