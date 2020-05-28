//
//  Chat.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation

struct Chat: Codable, Identifiable, Hashable {
    
    let id: UUID = UUID()
    
    var identityKeyID: KeyID = ""
    var memberKeyIDs: [KeyID] = []

}
