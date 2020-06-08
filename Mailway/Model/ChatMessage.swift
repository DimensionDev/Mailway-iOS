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
    
    var plaintextKind = PlaintextKind.text
    var plaintextData = Data()
    var composeTimestamp: Date?
    var receiveTimestamp = Date()
    
    var senderName = ""
    var senderEmail = ""
    var senderKeyID = ""
    
    // MARK: - ntge
    var message = ""
    
    // * version 1 *
    
    // meta
    var createTimestamp: Date?
    
    // extra
    var version = 1
    var recipientKeyIDs: [KeyID] = []
    
}

extension ChatMessage {
    enum PlaintextKind: String, Codable {
        case text
        case image
        case file
    }
}
