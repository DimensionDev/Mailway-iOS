//
//  Contact.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import NtgeCore

struct Contact: Codable, Identifiable, Hashable {
    let id: UUID = UUID()
    
    var name: String = ""
    
    // optional
    var email: String = ""
    var note: String = ""
    
    var isIdentity: Bool = false
    var keyID: KeyID = ""
    
}

//import NtgeCore
//
//struct KeyIdentity {
//    let publicKey: Ed25519.PublicKey
//    let privateKey: Ed25519.PrivateKey?
//
//    var containsPrivateKey: Bool {
//        return privateKey != nil
//    }
//
//}
