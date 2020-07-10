//
//  CryptoService.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-7.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import NtgeCore
import MessagePack

enum CryptoService {
    
    static func seal(plaintext: Data, recipients: [Ed25519.PublicKey], signer: Ed25519.PrivateKey) throws -> Message {
        // prepare extra
        let messageID = UUID().uuidString
        let extra = Extra(version: Version.current.rawValue,
                          senderKey: signer.publicKey.serialize(),
                          recipientKeys: recipients.map { $0.serialize() },
                          messageID: messageID,
                          quoteMessage: nil)
        let extraData = try MessagePackEncoder().encode(extra)
        
        // append signer as recipent for encryptor
        let publicKeys = Array(Set(recipients + [signer.publicKey]))
        let encryptor = Message.Encryptor(publicKeys: publicKeys.map { $0.x25519 })
        
        // encrypt message
        let message = encryptor.encrypt(plaintext: plaintext, extraPlaintext: extraData, signatureKey: signer)
        
        return message
    }
    
}

extension CryptoService {
    
    enum Version: Int {
        case v1 = 1
        
        static var current: Version {
            return .v1
        }
    }
    
    struct Extra: Codable {
        let version: Int
        let senderKey: String
        let recipientKeys: [String]
        let messageID: String
        let quoteMessage: QuoteMessage?
        
        enum CodingKeys: String, CodingKey {
            case version
            case senderKey = "sender_key"
            case recipientKeys = "recipient_keys"
            case messageID = "message_id"
            case quoteMessage = "quote_message"
        }
        
    }
    
    struct QuoteMessage: Codable {
        let id: String
        let digest: Data?
        let digestKind: PayloadKind
        let digestDescription: String
        let senderName: String
        let senderPublicKey: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case digest
            case digestKind = "digest_kind"
            case digestDescription = "digest_description"
            case senderName = "sender_name"
            case senderPublicKey = "sender_public_key"
        }
    }
    
    enum PayloadKind: String, Codable {
        case plaintext
        case image
        case video
        case audio
        case other
    }

}
