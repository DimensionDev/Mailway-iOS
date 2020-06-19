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
    
    var title = "Chat Room"
    
//    var identityKeyID: KeyID = ""
//    var identityName = ""
//
//    var memberKeyIDs: [KeyID] = []
//    var memberNames: [String] = []

}

extension Chat {
    static var empty: Chat {
        return Chat()
    }
}

extension Chat {
//    func contains(message: ChatMessage) -> Bool {
//        let isSame = Set(memberKeyIDs) == Set(message.recipientKeyIDs + [identityKeyID])
//        return isSame
//    }
}
