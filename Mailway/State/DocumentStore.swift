//
//  DocumentStore.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Combine
import NtgeCore

class DocumentStore: ObservableObject {
    @Published private(set) var chats: [Chat] = []
    @Published private(set) var contacts: [Contact] = []
    @Published private(set) var keys: [Key] = []
    @Published private(set) var messages: [Message] = []
}

extension DocumentStore {
    
    // create identity
    func create(identity: Contact) {
        guard !contacts.contains(where: { $0.id == identity.id }) else {
            return
        }
        
        let keypair = Ed25519.Keypair()
        let privateKey = keypair.privateKey
        let publicKey = keypair.publicKey
        
        var key = Key()
        key.keyID = publicKey.keyID()
        key.privateKey = privateKey.serialize()
        key.publicKey = publicKey.serialize()
        
        var identity = identity
        identity.keyID = key.keyID
            
        contacts.append(identity)
    }
    
}

extension DocumentStore {
    
    func queryExists(chat: Chat) -> Chat? {
        let duplicated = chats
            .filter { existChat in
                existChat.identityKeyID == chat.identityKeyID &&
                Set(existChat.memberKeyIDs).elementsEqual(chat.memberKeyIDs)
            }
        return duplicated.first
    }
    
    func create(chat: Chat) {
        guard !chats.contains(where: { $0.id == chat.id }) else {
            return
        }
        
        chats.append(chat)
    }
}

#if PREVIEW

extension DocumentStore {
    
    func setupPreview() {
        let (contacts, keys) = DocumentStore.samples
        self.keys.append(contentsOf: keys)
        self.contacts.append(contentsOf: contacts)
        
        // stub chat
        let identity = self.contacts
            .first(where: { $0.isIdentity })
        
        let identityKey = identity
            .flatMap { identity in
                self.keys.first(where: { $0.keyID == identity.keyID })
            }
        
        let contact = self.contacts
            .first(where: { !$0.isIdentity })

        if let identity = identity, let identityKey = identityKey {
            var chat = Chat()
            chat.identityKeyID = identityKey.keyID
            chat.identityName = identity.name
            chat.memberKeyIDs = [identityKey.keyID, contact?.keyID].compactMap { $0 }
            chat.memberNames = [identity.name, contact?.name].compactMap { $0 }
            chat.title = chat.memberNames.joined(separator: ", ")
            self.chats.append(chat)
        }
        
    }
    
}
#endif

#if PREVIEW
extension DocumentStore {
    static var samples: ([Contact], [Key]) {
        let names = zip(preview_TopFirstNames, preview_TopSurnames)
            .map { firstName, lastName -> String in
                return [firstName, lastName].joined(separator: " ")
        }
        
        var contacts: [Contact] = []
        var keys: [Key] = []
        for name in names {
            var contact = Contact()
            contact.name = name
            
            let keypair = Ed25519.Keypair()
            let publicKey = keypair.publicKey
            
            var key = Key()
            key.keyID = publicKey.keyID()
            key.publicKey = publicKey.serialize()
            
            contact.keyID = key.keyID
            
            contacts.append(contact)
            keys.append(key)
        }
        
        var alice = Contact()
        alice.name = "Alice"
        alice.isIdentity = true
        
        let keypair = Ed25519.Keypair()
        let privateKey = keypair.privateKey
        let publicKey = keypair.publicKey
        
        var key = Key()
        key.keyID = publicKey.keyID()
        key.privateKey = privateKey.serialize()
        key.publicKey = publicKey.serialize()
        
        alice.keyID = key.keyID
        
        contacts.append(alice)
        keys.append(key)
        
        return (contacts, keys)
    }
}
#endif
