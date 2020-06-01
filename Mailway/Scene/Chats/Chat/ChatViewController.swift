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

final class ChatViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    // input
    let context: AppContext
    let chat: Chat
    let chatMessages = PassthroughSubject<[ChatMessage], Never>()
    
    var shouldEnterEditModeAtAppear = false
    
    // output
    var diffableDataSource: UITableViewDiffableDataSource<Section, Item>!
    var items = CurrentValueSubject<[Item], Never>([])
    
    init(context: AppContext, chat: Chat) {
        self.context = context
        self.chat = chat
        super.init()
        
        chatMessages
            .map { $0.map { Item.chatMessage($0) } }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newItems in
                guard let `self` = self else { return }
                self.items.value = self.items.value + newItems
            }
            .store(in: &disposeBag)
        
        #if PREVIEW
        self.setupPreview()
        #endif
    }
    
}

extension ChatViewModel {
    enum Section: CaseIterable {
        case main
    }
    
    enum Item: Hashable {
        case chatMessage(ChatMessage)
    }
}

extension ChatViewModel {
    
    func configureDataSource(tableView: UITableView) {
        let dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { [weak self] tableView, indexPath, item -> UITableViewCell? in
            // guard let `self` = self else { return nil }
            switch item {
            case .chatMessage(let chatMessage):
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatMessageTableViewCell.self), for: indexPath) as! ChatMessageTableViewCell
                cell.senderContactInfoView.nameLabel.text = chatMessage.senderName
                cell.senderContactInfoView.emailLabel.text = chatMessage.senderEmail
                cell.senderContactInfoView.shortKeyIDLabel.text = String(chatMessage.senderKeyID.suffix(8)).uppercased()

                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none

                if let composeTimestamp = chatMessage.composeTimestamp.flatMap({ dateFormatter.string(from: $0) }) {
//                    cell.composeInfoContainerStackView.isHidden = false
                    cell.composeTimestampLabel.text = composeTimestamp
                } else {
//                    cell.composeInfoContainerStackView.isHidden = true
                }
                cell.receiveTimestampLabel.text = dateFormatter.string(from: chatMessage.receiveTimestamp)
                cell.messageContentTextView.text = chatMessage.plaintext.isEmpty ? "[Empty]" : chatMessage.plaintext
                return cell
            }
        }   // end let dataSource = …
        
        diffableDataSource = dataSource
    }   // end func configureDataSource(:) { … }

}

#if PREVIEW
import NtgeCore

extension ChatViewModel {
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
        var i = 1.0
        let sampleMessages = plaintexts
            .map { text -> ChatMessage in
                let data = Data(text.utf8)
                let extraData = Data(text.uppercased().utf8)
                let message = encryptor.encrypt(plaintext: data, extraPlaintext: extraData, signatureKey: unknown.privateKey)
                
                var chatMessage = ChatMessage()
                chatMessage.senderName = chat.memberKeyIDs.last.flatMap { keyID in context.documentStore.contacts.first(where: { $0.keyID == keyID })?.name } ?? "Unknown"
                chatMessage.senderEmail = ""
                chatMessage.senderKeyID = "0816fe6c1edebe9fbb83af9102ad9c899abec1a87a1d123bc24bf119035a2853"
                chatMessage.composeTimestamp = Date().advanced(by: -2 * 24 * 60 * 60 + i * 8 * 60 * 60) // day hour minute second
                chatMessage.message = (try? message.serialize_to_armor()) ?? ""
                chatMessage.plaintext = text
                i += 1
                return chatMessage
            }
        
        self.chatMessages.send(sampleMessages)
    }
}
#endif

// MARK: - UITableViewDataSource
// extension ChatViewModel: UITableViewDataSource {
//
//     func numberOfSections(in tableView: UITableView) -> Int {
//         return 1
//     }
//
//     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//         return chatMessages.value.count
//     }
//
//     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//         let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatMessageTableViewCell.self), for: indexPath) as! ChatMessageTableViewCell
//         let chatMessage = chatMessages.value[indexPath.row]
//
//         return cell
//     }
//
// }

final class ChatViewController: UIViewController, NeedsDependency {

    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var disposeBag = Set<AnyCancellable>()
    var viewModel: ChatViewModel! { willSet { precondition(!isViewLoaded) } }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatMessageTableViewCell.self, forCellReuseIdentifier: String(describing: ChatMessageTableViewCell.self))
        tableView.keyboardDismissMode = .interactive
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    lazy var messageInputView: MessageInputView = {
        let inputView = MessageInputView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        // inputView.inputTextView.delegate = self
        inputView.delegate = self
        return inputView
    }()
    
    override var inputAccessoryView: UIView? {
        return messageInputView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var canResignFirstResponder: Bool {
        return true
    }
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }

}

extension ChatViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        title = viewModel.chat.title
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
                
        tableView.delegate = self
        viewModel.configureDataSource(tableView: tableView)
        viewModel.diffableDataSource.defaultRowAnimation = .none
        tableView.dataSource = viewModel.diffableDataSource
        
        viewModel.items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let `self` = self else { return }
                guard let dataSource = self.viewModel.diffableDataSource else { return }
                var snapshot = NSDiffableDataSourceSnapshot<ChatViewModel.Section, ChatViewModel.Item>()
                snapshot.appendSections([.main])
                snapshot.appendItems(items, toSection: .main)
                
                dataSource.apply(snapshot)
            }
            .store(in: &disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            // async it to fix keyboard transition animation bug
            if self.viewModel.shouldEnterEditModeAtAppear {
                self.messageInputView.inputTextView.becomeFirstResponder()
            }
        }
    }
    
}

// MARK: - UITableViewDelegate
extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

// MARK: - MessageInputViewDelegate
extension ChatViewController: MessageInputViewDelegate {
    
    func messageInputView(_ toolbar: MessageInputView, submitButtonPressed button: UIButton) {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)

    }
    
}

