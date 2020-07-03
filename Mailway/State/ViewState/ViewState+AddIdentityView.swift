//
//  ViewState+AddIdentityView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-1.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import Combine

extension ViewState {
    struct AddIdentityView {
        // trigger edit avatar modal
        let presentAvatarPhotoPickerPublisher = PassthroughSubject<Void, Never>()
        
        var avatarImage = Avatar.placeholder(UIImage.placeholder(color: .systemFill))
        var name = "" {
            didSet {
                namePublisher.send(name)
            }
        }
        let namePublisher = PassthroughSubject<String, Never>()
        
        var color = UIColor.systemPurple
        var contactInfos: [ContactInfo.InfoType: [ContactInfo]] = [:]
        
        var note = Note()
    }
}

extension ViewState.AddIdentityView {
    enum Avatar {
        case placeholder(UIImage)
        case image(UIImage)
        
        var image: UIImage {
            switch self {
            case .placeholder(let image), .image(let image):
                return image
            }
        }
    }
    
    struct Note {
        var isEnabled = false
        var input = "" {
            didSet {
                publisher.send(input)
            }
        }
        let publisher = PassthroughSubject<String, Never>()
    }
}

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
    
    enum InfoType: CaseIterable {
        case email
        case twitter
        case facebook
        case telegram
        case discord
        case custom
        
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
        
        var typeName: String {
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
