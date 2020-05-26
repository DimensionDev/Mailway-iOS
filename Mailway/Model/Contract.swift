//
//  Contact.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation

struct Contact: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    
    var keyID: [String]
}


import NtgeCore

struct KeyIdentity {
    let publicKey: Ed25519.PublicKey
    let privateKey: Ed25519.PrivateKey?
    
    var containsPrivateKey: Bool {
        return privateKey != nil
    }
    
}
