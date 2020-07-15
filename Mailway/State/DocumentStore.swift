//
//  DocumentStore.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import Foundation
import Combine
import CoreData
import CoreDataStack
import NtgeCore

class DocumentStore: ObservableObject {
    
}

extension DocumentStore {
    
    static func createChatMessage(into context: NSManagedObjectContext, plaintextData plaintext: Data, recipientPublicKeys recipients: [Ed25519.PublicKey], signerPrivateKey signer: Ed25519.PrivateKey) -> Future<Result<ChatMessage, Error>, Never> {
        Future { promise in
            DispatchQueue.global().async {
                do {
                    // seal Message
                    let message = try CryptoService.seal(plaintext: plaintext, recipients: recipients, signer: signer)
                    let armoredMessage = try message.serialize()
                    
                    let signerPublicKey = signer.publicKey.serialize()
                    let recipientPublicKeys = Array(Set(recipients)).map { $0.serialize() }.filter { $0 != signerPublicKey }
                    let memberPublicKeys = Array(Set(recipientPublicKeys + [signerPublicKey]))
                    
                    assert(message.timestamp != nil)
                    let timestamp = message.timestamp ?? Date()
                    
                    let chatMessageProperty = ChatMessage.Property(
                        senderPublicKey: signerPublicKey,
                        recipientPublicKeys: recipientPublicKeys,
                        version: CryptoService.Version.current.rawValue,
                        armoredMessage: armoredMessage,
                        payload: plaintext,
                        payloadKind: .plaintext,
                        messageTimestamp: message.timestamp,
                        composeTimestamp: timestamp,
                        receiveTimestamp: timestamp,
                        shareTimestamp: nil
                    )
                    
                    var chatMessage: ChatMessage?
                    var subscription: AnyCancellable?
                    subscription = context.performChanges {
                        // query chat if exist
                        let request = Chat.sortedFetchRequest
                        request.predicate = Chat.predicate(identityPublicKey: signerPublicKey, memberPublicKeys: memberPublicKeys)
                        request.fetchLimit = 1
                        var chat: Chat? = try? context.fetch(request).first

                        var memberNameStubProperty: [ChatMemberNameStub.Property] = []
                        var memberNameStub: [ChatMemberNameStub] = []
                        
                        // A. create chat if no exist
                        if chat == nil {
                            // A.1. query stub and create stub properties
                            for memberPublicKey in memberPublicKeys {
                                // get KeyID
                                guard let keyID = Ed25519.PublicKey.deserialize(serialized: memberPublicKey)?.keyID else {
                                    continue
                                }

                                // query stub if exist
                                let stubRequest = ChatMemberNameStub.sortedFetchRequest
                                stubRequest.predicate = ChatMemberNameStub.predicate(publicKey: memberPublicKey)
                                stubRequest.fetchLimit = 1
                                if let stub = try? context.fetch(stubRequest).first {
                                    memberNameStub.append(stub)
                                    continue
                                }
                                
                                // fetch contact to retrieve stub property infos
                                let contactRequest = Contact.sortedFetchRequest
                                contactRequest.predicate = Contact.predicate(publicKey: memberPublicKey)
                                contactRequest.fetchLimit = 1
                                guard let contact = try? context.fetch(contactRequest).first else {
                                    continue
                                }
                                
                                let property = ChatMemberNameStub.Property(name: contact.name, publicKey: memberPublicKey, keyID: keyID)
                                
                                // append property
                                memberNameStubProperty.append(property)
                            }
                            
                            // A.2 validate and create stub from properties
                            guard memberNameStub.count + memberNameStubProperty.count == memberPublicKeys.count else {
                                // error occurred, interrupt operation
                                return
                            }
                            let newStubs = memberNameStubProperty.map { property in
                                ChatMemberNameStub.insert(into: context, property: property)
                            }
                            memberNameStub.append(contentsOf: newStubs)
                            
                            // A.3 create chat
                            let property = Chat.Property(title: nil, identityPublicKey: signerPublicKey)
                            chat = Chat.insert(into: context, property: property, memberNameStubs: memberNameStub, chatMessages: [])
                        }
                        
                        assert(chat != nil)
                        
                        // TODO: QuoteMessage
                        
                        // B. create chat message
                        chatMessage = ChatMessage.insert(into: context, property: chatMessageProperty, chat: chat, quoteMessage: nil)
                    }
                    .sink(receiveCompletion: { _ in
                        os_log("%{public}s[%{public}ld], %{public}s: complete subscription", ((#file as NSString).lastPathComponent), #line, #function, subscription.debugDescription)
                        subscription = nil
                    }, receiveValue: { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                guard let chatMessage = chatMessage else {
                                    // return error when output not found
                                    promise(.success(Result.failure(DocumentStoreError.internal)))
                                    return
                                }
                                promise(.success(Result.success(chatMessage)))
                                
                            case .failure(let error):
                                promise(.success(Result.failure(error)))
                            }
                        }
                    })
                    
                } catch {
                    DispatchQueue.main.async {
                        promise(.success(Result.failure(error)))
                    }
                }
            }   // end DispatchQueue.global().async
        }   // end Future
    }
    
}

extension DocumentStore {

    enum DocumentStoreError: Swift.Error {
        case `internal`
    }

}

#if PREVIEW

extension DocumentStore {
    
    func setupPreview(for context: NSManagedObjectContext) {
        do {
            if try context.count(for: Contact.sortedFetchRequest) == 0 {
                setupAlice(for: context)
                setupBob(for: context)
            } else {
                os_log("%{public}s[%{public}ld], %{public}s: skip alice & bob setup", ((#file as NSString).lastPathComponent), #line, #function)
            }
            
            if try context.count(for: Chat.sortedFetchRequest) == 0 {
                setupChat(for: context)
            } else {
                os_log("%{public}s[%{public}ld], %{public}s: skip chat setup", ((#file as NSString).lastPathComponent), #line, #function)
            }
        } catch {
            assertionFailure()
            return
        }
    }
    
    private func setupAlice(for context: NSManagedObjectContext) {
        let (contactProperty, keypairProperty) = DocumentStore.alice
        
        var subscription: AnyCancellable?
        subscription = context.performChanges {
            let keypair = Keypair.insert(into: context, property: keypairProperty)
            let twitterContactChannel = ContactChannel.insert(into: context, property: ContactChannel.Property(name: .twitter, value: "@alice"))
            Contact.insert(into: context, property: contactProperty, keypair: keypair, channels: [twitterContactChannel])
        }
        .sink(receiveCompletion: { _ in
            os_log("%{public}s[%{public}ld], %{public}s: finish subscription: %s", ((#file as NSString).lastPathComponent), #line, #function, subscription.debugDescription)
            subscription = nil
        }, receiveValue: { result in
            os_log("%{public}s[%{public}ld], %{public}s: setup alice: %s", ((#file as NSString).lastPathComponent), #line, #function, String(describing: result))
        })
    }
    
    private func setupBob(for context: NSManagedObjectContext) {
        let (contactProperty, keypairProperty) = DocumentStore.bob
        
        var subscription: AnyCancellable?
        subscription = context.performChanges {
            let keypair = Keypair.insert(into: context, property: keypairProperty)
            let twitterContactChannel = ContactChannel.insert(into: context, property: ContactChannel.Property(name: .twitter, value: "@bob"))
            Contact.insert(into: context, property: contactProperty, keypair: keypair, channels: [twitterContactChannel])
        }
        .sink(receiveCompletion: { _ in
            os_log("%{public}s[%{public}ld], %{public}s: finish subscription: %s", ((#file as NSString).lastPathComponent), #line, #function, subscription.debugDescription)
            subscription = nil
        }, receiveValue: { result in
            os_log("%{public}s[%{public}ld], %{public}s: setup bob: %s", ((#file as NSString).lastPathComponent), #line, #function, String(describing: result))
        })
    }
    
}
#endif

#if PREVIEW
extension DocumentStore {
    
    static var alice: (Contact.Property, Keypair.Property) {
        let contactProperty = Contact.Property(name: "Alice",
                                               note: "Her is Alice.",
                                               avatar: UIImage(named: "elena-putina-GFhqDlwTSmI-unsplash"))

        
        let ed25519PrivateKey = Ed25519.PrivateKey.deserialize(from: "pri1jt4x2ch75q80gy32j7kuqzgrmjydy298460mthpc3gwcxp2vll9s4apzap-Ed25519")!
        let ed25519PublicKey = ed25519PrivateKey.publicKey
        let keypairProperty = Keypair.Property(privateKey: ed25519PrivateKey.serialize(),
                                               publicKey: ed25519PublicKey.serialize(),
                                               keyID: ed25519PublicKey.keyID)
        
        return (contactProperty, keypairProperty)
    }
    
    static var bob: (Contact.Property, Keypair.Property) {
        let contactProperty = Contact.Property(name: "Bob",
                                               note: "He is Bob.",
                                               avatar: UIImage(named: "elena-putina-GFhqDlwTSmI-unsplash"))
        
        
        let ed25519PrivateKey = Ed25519.PrivateKey.deserialize(from: "pri1pu3uaqqvdyne0q92g09ls5u64kcupqy6ha2q6av3dnfgq94k4qdq85048p-Ed25519")!
        let ed25519PublicKey = ed25519PrivateKey.publicKey
        let keypairProperty = Keypair.Property(privateKey: nil,
                                               publicKey: ed25519PublicKey.serialize(),
                                               keyID: ed25519PublicKey.keyID)
        
        return (contactProperty, keypairProperty)
    }
    
}
#endif

