//
//  Contact.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation

struct Contact: Codable, Identifiable, Hashable {
    let id: UUID = UUID()
    
    var name: String = ""
    
    // optional
    var email: String = ""
    var note: String = ""
    
    var isIdentity: Bool = false
    // var keyID: String = String
    
}

#if PREVIEW
extension Contact {
    static var samples: [Contact] {
        var contact = zip(preview_TopFirstNames, preview_TopSurnames)
            .map { firstName, lastName -> Contact in
                var contact = Contact()
                contact.name = [firstName, lastName].joined(separator: " ")
                return contact
            }
        
        var alice = Contact()
        alice.name = "Alice"
        alice.isIdentity = true
        contact.append(alice)
        
        return contact
    }
}
#endif

import NtgeCore

struct KeyIdentity {
    let publicKey: Ed25519.PublicKey
    let privateKey: Ed25519.PrivateKey?
    
    var containsPrivateKey: Bool {
        return privateKey != nil
    }
    
}
