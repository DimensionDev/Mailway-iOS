//
//  ShareService.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-4.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit
import CoreDataStack
import NtgeCore

final class ShareService {
    
    private init() { }
    
}

extension ShareService {
 
    static func share(chatMessage: ChatMessage, from viewController: UIViewController, anchor view: UIView? = nil) {
        guard let armor = chatMessage.armoredMessage else {
            assertionFailure()
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [armor], applicationActivities: [])
        activityViewController.completionWithItemsHandler = { type, result, items, error in
            os_log("%{public}s[%{public}ld], %{public}s: share activity complete: %s %s %s %s", ((#file as NSString).lastPathComponent), #line, #function, type.debugDescription, result.description, items?.debugDescription ?? "[]", error.debugDescription)
            // do nothing
        }
        activityViewController.setupAnchor(viewController: viewController, view: view)
        viewController.present(activityViewController, animated: true)
    }
    
}
 
extension ShareService {
    
    static func share(identity: Contact, from viewController: UIViewController, anchor view: UIView? = nil) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let toFileAction = UIAlertAction(title: L10n.ContactDetail.Alert.ShareProfile.toFile, style: .default) { _ in
            os_log("%{public}s[%{public}ld], %{public}s: share as file", ((#file as NSString).lastPathComponent), #line, #function)
            do {
                let card = try ShareService.identityCard(identity: identity)
                let serialized = try card.serialize()
                let filename = identity.name + "." + String.bizcardFileExtension
                guard let fileURL = createTempFile(filename: filename, data: Data(serialized.utf8)) else {
                    assertionFailure()
                    return
                }
                                
                let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: [])
                activityViewController.completionWithItemsHandler = { type, result, items, error in
                    os_log("%{public}s[%{public}ld], %{public}s: share activity complete: %s %s %s %s", ((#file as NSString).lastPathComponent), #line, #function, type.debugDescription, result.description, items?.debugDescription ?? "[]", error.debugDescription)
                    // do nothing
                }
                activityViewController.setupAnchor(viewController: viewController, view: view)
                viewController.present(activityViewController, animated: true)
            } catch {
                let errorAlertController = UIAlertController.standardAlert(of: error)
                viewController.present(errorAlertController, animated: true, completion: nil)
            }
        }
        alertController.addAction(toFileAction)
        
        let toQRCodeAction = UIAlertAction(title: L10n.ContactDetail.Alert.ShareProfile.toQrCode, style: .default) { _ in
            os_log("%{public}s[%{public}ld], %{public}s: share as QR Code", ((#file as NSString).lastPathComponent), #line, #function)
            
        }
        alertController.addAction(toQRCodeAction)
        
        let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        alertController.setupAnchor(viewController: viewController, view: view)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    private static func identityCard(identity: Contact) throws -> Bizcard {
        guard let keypair = identity.keypair, let privateKeyText = keypair.privateKey,
        let privateKey = Ed25519.PrivateKey.deserialize(from: privateKeyText) else {
            throw ShareProfileError.SignerKeyNotFound
        }
        
        let identityChannels = IdentityChannel.convert(from: Array(identity.channels ?? Set()))
        guard let info = IdentityInfo(privateKey: privateKey, name: identity.name, channels: identityChannels) else {
            throw ShareProfileError.internal
        }
        
        let card = Bizcard(info: info, supplementation: IdentitySupplementation())
        return card
    }
    
}

extension UIActivityViewController {
    func setupAnchor(viewController: UIViewController, view: UIView?) {
        if let presenter = popoverPresentationController {
            if let view = view {
                presenter.sourceView = view
                presenter.sourceRect = view.bounds
            } else {
                presenter.sourceView = viewController.view
                presenter.sourceRect = CGRect(origin: viewController.view.center, size: .zero)
                presenter.permittedArrowDirections = []
            }
        }
    }
}

extension UIAlertController {
    func setupAnchor(viewController: UIViewController, view: UIView?) {
        if let presenter = popoverPresentationController {
            if let view = view {
                presenter.sourceView = view
                presenter.sourceRect = view.bounds
            } else {
                presenter.sourceView = viewController.view
                presenter.sourceRect = CGRect(origin: viewController.view.center, size: .zero)
                presenter.permittedArrowDirections = []
            }
        }
    }
}


extension ShareService {
    enum ShareProfileError: Swift.Error, LocalizedError {
        case `internal`
        case SignerKeyNotFound
        
        var errorDescription: String? {
            switch self {
            case .internal:
                return L10n.Error.InternalError.errorDescription
            case .SignerKeyNotFound:
                return L10n.ContactDetail.Error.SignerKeyNotFound.errorDescription
            }
        }
        
        var failureReason: String? {
            switch self {
            case .internal:
                return L10n.Error.InternalError.failureReason
            case .SignerKeyNotFound:
                return L10n.ContactDetail.Error.SignerKeyNotFound.failureReason
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .internal:
                return L10n.Error.InternalError.recoverySuggestion
            case .SignerKeyNotFound:
                return L10n.ContactDetail.Error.SignerKeyNotFound.recoverySuggestion
            }
        }
    }
}

extension ShareService {
    static func createTempFile(filename: String, data: Data) -> URL? {
        let subDirectory: String = {
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd-HHmmss"
            return formatter.string(from: now)
        }()
        let temporaryDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(subDirectory, isDirectory: true)
        let fileURL = temporaryDirectory.appendingPathComponent(filename)
        do {
            try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true, attributes: nil)
            try data.write(to: fileURL)
            return fileURL
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }
    }
}
