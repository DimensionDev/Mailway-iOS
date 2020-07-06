//
//  IdentityCard.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-30.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import MessagePack
import NtgeCore

struct IdentityCard: Codable, Equatable {
    static let armorHeader = "IdCardBeginII"
    static let armorFooter = "IIEndIdCard"

    let info: IdentityInfo
    let supplementation: IdentitySupplementation?
    
}

extension IdentityCard {
    
    func serialize() throws -> String {
        // pack content
        let encoder = MessagePackEncoder()
        let encoded = try encoder.encode(self)
    
        // encode to base58-monero
        guard let serialized = Base58Monero.encode(data: encoded) else {
            throw Error.base58SerializeFailed
        }
        
        return [IdentityCard.armorHeader, serialized, IdentityCard.armorFooter].joined()
    }
    
    static func deserialize(text: String) throws -> [IdentityCard] {
        let scanner = Scanner(string: text)
        scanner.charactersToBeSkipped = nil
        
        var cards: [IdentityCard] = []
        while !scanner.isAtEnd {
            // pin location to header
            _ = scanner.scanUpToString(IdentityCard.armorHeader)
            
            // consume header
            guard scanner.scanString(IdentityCard.armorHeader) == IdentityCard.armorHeader else {
                // not found header
                break
            }
            
            // pin location to footer and consume content
            guard let serialized = scanner.scanUpToString(IdentityCard.armorFooter) else {
                // not found footer
                break
            }
            
            // decode serialized text from base58-monero
            guard let encoded = Base58Monero.decode(string: serialized) else {
                // get deserialize error
                throw Error.base58SerializeFailed
            }
            
            let decoder = MessagePackDecoder()
            let card = try decoder.decode(IdentityCard.self, from: encoded)

            cards.append(card)
        }
        
        return cards
    }
    
    // validate card infos
    // cannot deny key replacement attack
    // make sure user doule check the KeyID is trusted
    func validate() -> Result<Void, ValidationError> {
        guard let publicKey = Ed25519.PublicKey.deserialize(serialized: info.public_key_armor) else {
            return .failure(.keyRestoreFailed)
        }
        
        guard let mac = IdentityInfo.calculateMac(
            use: publicKey,
            public_key_armor: info.public_key_armor,
            name: info.name,
            i18nNames: info.i18nNames,
            channels: info.channels,
            updatedAt: info.updatedAt
        ) else {
            return .failure(.macCheckFailed)
        }
        
        guard mac == info.mac else {
            return .failure(.macCheckFailed)
        }
        
        guard publicKey.verify(message: mac, signature: info.signature) else {
            return .failure(.signatureVerificationFailed)
        }
        
        return .success(())
    }
    
}

extension IdentityCard {
    enum Error: Swift.Error, LocalizedError {
        case base58SerializeFailed
        case base58DeserializeFailed
        
        var errorDescription: String? {
            switch self {
            case .base58SerializeFailed, .base58DeserializeFailed:
                return "Base58 Serialization Error"
            }
        }
        
        var failureReason: String? {
            switch self {
            case .base58SerializeFailed:
                return "Internal error happened when serialize."
            case .base58DeserializeFailed:
                return "Internal error happened when deserialize."
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .base58SerializeFailed:
                return "Please try again."
            case .base58DeserializeFailed:
                return "Please try again."
            }
        }
    }
    
    enum ValidationError: Swift.Error, LocalizedError {
        case keyRestoreFailed
        case macCheckFailed
        case signatureVerificationFailed
        
        var errorDescription: String? {
            return "Validation Error"
        }
        
        var failureReason: String? {
            switch self {
            case .keyRestoreFailed:
                return "Public key restore failed."
            case .macCheckFailed:
                return "Checksum verification failed."
            case .signatureVerificationFailed:
                return "Signature verification failed."
            }
        }
        
        var recoverySuggestion: String? {
            return "Please use identity card from trusted sources."
        }
    }
}

struct IdentityChannel: Codable, Equatable {
    let name: String
    let value: String
}

struct IdentityInfo: Codable, Equatable {
    
    let public_key_armor: String
    let name: String
    let i18nNames: [String: String]?
    let channels: [IdentityChannel]?
    let updatedAt: String
    let mac: Data
    let signature: Data
    
    init?(privateKey: Ed25519.PrivateKey, name: String, i18nNames: [String : String] = [:], channels: [IdentityChannel] = []) {
        let public_key_armor = privateKey.publicKey.serialize()
        self.public_key_armor = public_key_armor
        self.name = name
        self.i18nNames = i18nNames
        self.channels = channels
        let updatedAt = ISO8601DateFormatter.fractionalSeconds.string(from: Date())
        self.updatedAt = updatedAt
    
        guard let mac = IdentityInfo.calculateMac(use: privateKey.publicKey, public_key_armor: public_key_armor, name: name, i18nNames: i18nNames, channels: channels, updatedAt: updatedAt) else {
            return nil
        }
        self.mac = mac
        
        guard let signature = privateKey.sign(message: mac) else {
            return nil
        }
        self.signature = signature
    }
    
    static func calculateMac(use publicKey: Ed25519.PublicKey, public_key_armor: String, name: String, i18nNames: [String: String]?, channels: [IdentityChannel]?, updatedAt: String) -> Data? {
        let data: Data = {
            var bytes = Data()
            bytes.append(Data(public_key_armor.utf8))
            bytes.append(Data(name.utf8))
            for (key, value) in i18nNames ?? [:] {
                bytes.append(Data(key.utf8))
                bytes.append(Data(value.utf8))
            }
            for channel in channels ?? [] {
                bytes.append(Data(channel.name.utf8))
                bytes.append(Data(channel.value.utf8))
            }
            bytes.append(Data(updatedAt.utf8))
            return bytes
        }()
        
        return HMac256.calculate(using: publicKey, data: data)
    }
    
}

struct IdentitySupplementation: Codable, Equatable {
    
    let name: String
    let i18nNames: [String: String]
    let channels: [IdentityChannel]
    let updatedAt: String
    
    init(name: String, i18nNames: [String : String], channels: [IdentityChannel]) {
        self.name = name
        self.i18nNames = i18nNames
        self.channels = channels
        self.updatedAt = ISO8601DateFormatter.fractionalSeconds.string(from: Date())
    }
    
}
