//
//  DocumentStore.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Combine
import NtgeCore

class DocumentStore: ObservableObject {
    @Published private(set) var chats: [Chat] = []
    @Published private(set) var contacts: [Contact] = []
    @Published private(set) var keys: [Key] = []
    @Published private(set) var chatMessages: [ChatMessage] = []
}

extension DocumentStore {
    
    // create identity
    func create(identity: Contact) {
        guard !contacts.contains(where: { $0.id == identity.id }) else {
            return
        }
        
        let keypair = Ed25519.Keypair()
        let privateKey = keypair.privateKey
        let publicKey = keypair.publicKey
        
        var key = Key()
        key.keyID = publicKey.keyID
        key.privateKey = privateKey.serialize()
        key.publicKey = publicKey.serialize()
        
        var identity = identity
        identity.keyID = key.keyID
            
        contacts.append(identity)
    }
    
}

extension DocumentStore {
    
    func queryExists(chat: Chat) -> Chat? {
        let duplicated = chats
            .filter { existChat in
                existChat.identityKeyID == chat.identityKeyID &&
                Set(existChat.memberKeyIDs).elementsEqual(chat.memberKeyIDs)
            }
        return duplicated.first
    }
    
    func create(chat: Chat) {
        guard !chats.contains(where: { $0.id == chat.id }) else {
            return
        }
        
        chats.append(chat)
    }
    
    func create(chatMessage: ChatMessage, forChat chat: Chat) {
        create(chat: chat)
        chatMessages.append(chatMessage)
    }
}

#if PREVIEW

extension DocumentStore {
    
    func setupPreview() {
        let (contacts, keys) = DocumentStore.samples
        self.keys.append(contentsOf: keys)
        self.contacts.append(contentsOf: contacts)
        
        setupChat()
    }
    
    // stub chat
    private func setupChat() {
        let (alice, aliceKey) = DocumentStore.alice
        var (bob, bobKey) = DocumentStore.bob

        guard let alicePrivateKey = Ed25519.PrivateKey.deserialize(from: aliceKey.privateKey),
        let bobPrivateKey = Ed25519.PrivateKey.deserialize(from: bobKey.privateKey) else {
            assertionFailure()
            return
        }

        let alicePublicKey = alicePrivateKey.publicKey
        let bobPublicKey = bobPrivateKey.publicKey
        
        // erase bob's private key
        bob.isIdentity = false
        bobKey.privateKey = ""
        
        let chat: Chat = {
            var chat = Chat()
            chat.identityKeyID = alice.keyID
            chat.identityName = alice.name
            chat.memberKeyIDs = [alice.keyID, bob.keyID]
            chat.memberNames = [alice.name, bob.name]
            chat.title = chat.memberNames.joined(separator: ", ")
            return chat
        }()
        let recipients: [Ed25519.PublicKey] = [alicePublicKey, bobPublicKey]
        let encryptor = NtgeCore.Message.Encryptor(publicKeys: recipients.map { $0.x25519 })
        
        var i = 1.0
        let chatMessages = DocumentStore.sampleMessages
            .map { text -> ChatMessage in
                let data = Data(text.utf8)
                let extraData = Data(text.uppercased().utf8)
                let message = encryptor.encrypt(plaintext: data, extraPlaintext: extraData, signatureKey: bobPrivateKey)
                
                var chatMessage = ChatMessage()
                chatMessage.senderName = bob.name
                chatMessage.senderEmail = bob.email
                chatMessage.senderKeyID = bob.keyID
                chatMessage.composeTimestamp = Date().advanced(by: -2 * 24 * 60 * 60 + i * 8 * 60 * 60) // day hour minute second
                chatMessage.message = (try? message.serialize()) ?? ""
                chatMessage.recipientKeyIDs = recipients.map { $0.keyID }
                chatMessage.plaintextData = Data(text.utf8)
                chatMessage.plaintextKind = .text
                i += 1
                return chatMessage
        }
        
        self.contacts.append(contentsOf: [alice, bob])
        self.keys.append(contentsOf: [aliceKey, bobKey])
        self.chats.append(chat)
        self.chatMessages.append(contentsOf: chatMessages)
    }
    
}
#endif

#if PREVIEW
extension DocumentStore {
    static var samples: ([Contact], [Key]) {
        let names = zip(preview_TopFirstNames, preview_TopSurnames)
            .map { firstName, lastName -> String in
                return [firstName, lastName].joined(separator: " ")
        }
        
        var contacts: [Contact] = []
        var keys: [Key] = []
        for name in names {
            var contact = Contact()
            contact.name = name
            
            let keypair = Ed25519.Keypair()
            let publicKey = keypair.publicKey
            
            var key = Key()
            key.keyID = publicKey.keyID
            key.publicKey = publicKey.serialize()
            
            contact.keyID = key.keyID
            
            contacts.append(contact)
            keys.append(key)
        }
    
        return (contacts, keys)
    }
    
    static var alice: (Contact, Key) {
        var alice = Contact()
        alice.name = "Alice"
        alice.isIdentity = true
        
        let privateKey = Ed25519.PrivateKey.deserialize(from: "pri1jt4x2ch75q80gy32j7kuqzgrmjydy298460mthpc3gwcxp2vll9s4apzap-Ed25519")!
        let publicKey = privateKey.publicKey
        
        var key = Key()
        key.keyID = publicKey.keyID
        key.privateKey = privateKey.serialize()
        key.publicKey = publicKey.serialize()
        
        alice.keyID = key.keyID
        
        return (alice, key)
    }
    
    static var bob: (Contact, Key) {
        var contact = Contact()
        contact.name = "Bob"
        contact.isIdentity = true
        
        let privateKey = Ed25519.PrivateKey.deserialize(from: "pri1pu3uaqqvdyne0q92g09ls5u64kcupqy6ha2q6av3dnfgq94k4qdq85048p-Ed25519")!
        let publicKey = privateKey.publicKey
        
        var key = Key()
        key.keyID = publicKey.keyID
        key.privateKey = privateKey.serialize()
        key.publicKey = publicKey.serialize()
        
        contact.keyID = key.keyID
        
        return (contact, key)
    }
    
    static var sampleMessages: [String] = [
        "Hi, Alice",
        "How do you do?",
        "Have a drink tonight!",
        "Here is a poem:\nAn Irish Airman Foresees His Death\nfrom William Butler Yeats",
        """
        I know that I shall meet my fate
        Somewhere among the clouds above;

        Those that I fight I do not hate,
        Those that I guard I do not love;

        My country is Kiltartan Cross,
        My countrymen Kiltartan’s poor,
        No likely end could bring them loss
        Or leave them happier than before.
        Nor law, nor duty bade me fight,
        Nor public men, nor cheering crowds,
        A lonely impulse of delight
        Drove to this tumult in the clouds;

        I balanced all, brought all to mind,
        The years to come seemed waste of breath,
        A waste of breath the years behind
        In balance with this life, this death.
        """,
        """
        If I when my wife is sleeping
        and the baby and Kathleen
        are sleeping
        and the sun is a flame-white disc
        in silken mists
        above shining trees, —

        if I in my north room
        dance naked, grotesquely
        before my mirror
        waving my shirt round my head
        and singing softly to myself:

        “I am lonely, lonely.
        I was born to be lonely,
        I am best so!”

        If I admire my arms, my face,
        my shoulders, flanks, buttocks
        against the yellow drawn shades, —

        Who shall say I am not
        the happy genius of my household?
        """
    ]
}
#endif

