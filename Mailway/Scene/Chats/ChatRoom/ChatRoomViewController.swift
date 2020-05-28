//
//  ChatRoomViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-27.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit
import Combine

final class ChatRoomViewModel: NSObject {
    
    // input
    let context: AppContext
    let chat: Chat
    let chatMessages = CurrentValueSubject<[ChatMessage], Never>([])
    
    init(context: AppContext, chat: Chat) {
        self.context = context
        self.chat = chat
        super.init()
        
        #if PREVIEW
        self.setupPreview()
        #endif
    }
    
}

#if PREVIEW
import NtgeCore

extension ChatRoomViewModel {
    private func setupPreview() {
        let plaintexts = [
            "Hi, Alice",
            "How do you do?",
            "Have a drink tonight!",
        ]
        
        let identityID = chat.identityKeyID
        guard let identityKey = context.documentStore.keys.first(where: { $0.keyID == identityID }) else {
            fatalError()
        }
        guard let identityPrivateKey = Ed25519.PrivateKey.deserialize(serialized: identityKey.privateKey) else {
            fatalError()
        }
                
        let unknown = Ed25519.Keypair()
        let unknownPublicKey = unknown.publicKey.toX25519()
        let identityX25519PublicKey = identityPrivateKey.publicKey.toX25519()
        
        let encryptor = NtgeCore.Message.Encryptor(publicKeys: [unknownPublicKey, identityX25519PublicKey])
        let sampleMessages = plaintexts
            .map { text -> ChatMessage in
                let data = Data(text.utf8)
                let extraData = Data(text.uppercased().utf8)
                let message = encryptor.encrypt(plaintext: data, extraPlaintext: extraData, signatureKey: unknown.privateKey)
                
                var chatMessage = ChatMessage()
                chatMessage.message = (try? message.serialize_to_armor()) ?? ""
                chatMessage.plaintext = text
                
                return chatMessage
            }
        
        self.chatMessages.value = sampleMessages
    }
}
#endif

// MARK: - UITableViewDataSource
extension ChatRoomViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatRoomMessageTableViewCell.self), for: indexPath) as! ChatRoomMessageTableViewCell
        let chatMessage = chatMessages.value[indexPath.row]
        cell.textLabel?.text = chatMessage.plaintext
        return cell
    }
    
}

final class ChatRoomViewController: UIViewController, NeedsDependency {

    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var viewModel: ChatRoomViewModel! { willSet { precondition(!isViewLoaded) } }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatRoomMessageTableViewCell.self, forCellReuseIdentifier: String(describing: ChatRoomMessageTableViewCell.self))
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }

}

extension ChatRoomViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        title = "Chat Room"
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        tableView.delegate = self
        tableView.dataSource = viewModel
    }
    
}

// MARK: - UITableViewDelegate
extension ChatRoomViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
