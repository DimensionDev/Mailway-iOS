//
//  ChatMessage.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation

struct ChatMessage: Codable, Identifiable, Hashable {
    
    let id: UUID = UUID()
    
    var version = 1

    var composeTimestamp: Date?
    var receiveTimestamp = Date()
    
    var senderName = ""
    var recipientKeyIDs: [KeyID] = []
    var message = ""
    var plaintext = ""
    
    // version 1 required
    var createTimestamp: Date?
    
}
