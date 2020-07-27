//
//  ContactInfo.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-21.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

struct ContactInfo: Identifiable, Hashable {
    let id: UUID = UUID()
    
    let type: InfoType
    
    var key: String
    var value: String
    var avaliable = true
    
    var isEmptyInfo: Bool {
        switch type {
        case .custom:
            return key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default:
            return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    enum InfoType: Hashable, CaseIterable {
        case email
        case twitter
        case facebook
        case telegram
        case discord
        case custom
        
        init(name: String) {
            let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            switch name {
            case InfoType.email.text:        self = .email
            case InfoType.twitter.text:      self = .twitter
            case InfoType.facebook.text:     self = .facebook
            case InfoType.telegram.text:     self = .telegram
            case InfoType.discord.text:      self = .discord
            default:                         self = .custom
            }
        }
        
        var iconImage: UIImage {
            switch self {
            case .email:    return Asset.Communication.mail.image
            case .twitter:  return Asset.Logo.twitter.image
            case .facebook: return Asset.Logo.facebook.image
            case .telegram: return Asset.Logo.telegram.image
            case .discord:  return Asset.Logo.discord.image
            case .custom:   return Asset.Editing.plusCircleFill.image
            }
        }
        
        public var text: String {
            switch self {
            case .email:                return "email"
            case .twitter:              return "twitter"
            case .facebook:             return "facebook"
            case .telegram:             return "telegram"
            case .discord:              return "discord"
            case .custom:               return ""
            }
        }
        
        var editSectionName: String {
            switch self {
            case .email:    return "E-Mail"
            case .twitter:  return "Twitter"
            case .facebook: return "Facebook"
            case .telegram: return "Telegram"
            case .discord:  return "Discord"
            case .custom:   return "Custom contact info"
            }
        }
    }
    
}
