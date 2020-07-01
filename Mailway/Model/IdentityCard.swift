//
//  IdentityCard.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-30.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import NtgeCore

struct IdentityCard: Codable, Equatable {
    let info: IdentityInfo
    let supplementation: IdentitySupplementation?
}

struct IdentityChannel: Codable, Equatable {
    let name: String
    let value: String
}

struct IdentityInfo: Codable, Equatable {
    
    let public_key_armor: String
    let name: String
    let i18nNames: [String: String]
    let channels: [IdentityChannel]
    let updatedAt: String
    let mac: Data
    let signature: Data
    
    init(privateKey: Ed25519.PrivateKey, name: String, i18nNames: [String : String], channels: [IdentityChannel]) {
        self.public_key_armor = privateKey.publicKey.serialize()
        self.name = name
        self.i18nNames = i18nNames
        self.channels = channels
        self.updatedAt = ISO8601DateFormatter.fractionalSeconds.string(from: Date())
        self.mac = Data()
        self.signature = Data()
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
