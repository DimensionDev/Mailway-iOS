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
import NtgeCore

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
            .map { chatMessages -> [Item] in
                let items = chatMessages
                    .filter{ chat.contains(message: $0) }
                    .map { Item.chatMessage($0) }
                return items
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newItems in
                guard let `self` = self else {
                    assertionFailure()
                    return
                }
                self.items.value = newItems
                //print("sink: \(newItems.count)")
            }
            .store(in: &disposeBag)
    }
    
}

extension ChatViewModel {
    
    func sendMessage(plaintext: String) {
        var recipients: [Contact] = []
        var recipientKeys: [Key] = []
        var recipientPublicKeys: [Ed25519.PublicKey] = []
        
        guard let identity = context.documentStore.contacts.first(where: { $0.keyID == chat.identityKeyID }),
        let identityKey = context.documentStore.keys.first(where: { $0.keyID == chat.identityKeyID }),
        let identityPrivateKey = Ed25519.PrivateKey.deserialize(from: identityKey.privateKey) else {
            return
        }
        
        for keyID in chat.memberKeyIDs {
            guard let recipient = context.documentStore.contacts.first(where: { $0.keyID == keyID }),
            let key = context.documentStore.keys.first(where: { $0.keyID == keyID }),
            let publicKey = Ed25519.PublicKey.deserialize(serialized: key.publicKey) else {
                continue
            }
            
            recipients.append(recipient)
            recipientKeys.append(key)
            recipientPublicKeys.append(publicKey)
        }
        
        guard !recipients.isEmpty else {
            return
        }
    
        let encryptor = Message.Encryptor(publicKeys: recipientPublicKeys.map { $0.x25519 })
        let plaintextData = Data(plaintext.utf8)
        
        // TODO: extra
        do {
            let message = encryptor.encrypt(plaintext: plaintextData, extraPlaintext: nil, signatureKey: identityPrivateKey)
            guard let armor = try? message.serialize() else {
                return
            }
            
            let chatMessage = ChatMessage(plaintextData: plaintextData,
                                          composeTimestamp: Date(),
                                          receiveTimestamp: Date(),
                                          senderName: identity.name,
                                          senderEmail: identity.email,
                                          senderKeyID: identity.keyID,
                                          message: armor,
                                          createTimestamp: Date(),
                                          version: 1,
                                          recipientKeyIDs: recipientPublicKeys.map { $0.keyID })
            context.documentStore.create(chatMessage: chatMessage, forChat: chat)
        } catch {
            
        }
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
            guard let `self` = self else { return nil }
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
                    cell.composeTimestampLabel.text = composeTimestamp
                } else {
                    cell.composeTimestampLabel.text = "-"
                }
                cell.receiveTimestampLabel.text = dateFormatter.string(from: chatMessage.receiveTimestamp)
                cell.messageContentTextView.text = {
                    switch chatMessage.plaintextKind {
                    case .text:
                        return String(data: chatMessage.plaintextData, encoding: .utf8) ?? "<invalid message content>"
                    case .image:
                        return ""
                    case .file:
                        return "File: \(chatMessage.plaintextData.count)"
                    }
                }()
                return cell
            }
        }   // end let dataSource = …
        
        diffableDataSource = dataSource
    }   // end func configureDataSource(:) { … }

}

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
    
    private var isViewAppeared = false
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatMessageTableViewCell.self, forCellReuseIdentifier: String(describing: ChatMessageTableViewCell.self))
        tableView.keyboardDismissMode = .onDrag
        // FIXME:
        // system not offer real time keyboard frame anymore
        // needs some hacks when not use inputAccessoryView to update inputView frame
        // tableView.keyboardDismissMode = .interactive
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    lazy var messageInputView: MessageInputView = {
        let inputView = MessageInputView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        inputView.delegate = self
        return inputView
    }()
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }

}

extension ChatViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        title = viewModel.chat.title
        view.backgroundColor = .systemBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageInputView)
        NSLayoutConstraint.activate([
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: messageInputView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: messageInputView.bottomAnchor),
        ])
                
        tableView.delegate = self
        viewModel.configureDataSource(tableView: tableView)
        viewModel.diffableDataSource.defaultRowAnimation = .none
        tableView.dataSource = viewModel.diffableDataSource
        
        context.documentStore.$chatMessages
            .sink { [weak self] chatMessages in
                self?.viewModel.chatMessages.send(chatMessages)
            }
            .store(in: &disposeBag)
        
        viewModel.items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let `self` = self else { return }
                guard let dataSource = self.viewModel.diffableDataSource else { return }
                var snapshot = NSDiffableDataSourceSnapshot<ChatViewModel.Section, ChatViewModel.Item>()
                snapshot.appendSections([.main])
                snapshot.appendItems(items, toSection: .main)
                
                dataSource.apply(snapshot)
                
                let numberOfSections = self.tableView.numberOfSections
                guard numberOfSections > 0 else { return }
                let numberOfRowsInLastSection = self.tableView.numberOfRows(inSection: numberOfSections - 1)
                guard numberOfRowsInLastSection > 0 else { return }
                self.tableView.scrollToRow(
                    at: IndexPath(row: numberOfRowsInLastSection - 1, section: numberOfSections - 1),
                    at: .bottom,
                    animated: self.isViewAppeared
                )
                self.isViewAppeared = true
            }
            .store(in: &disposeBag)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification, object: nil)
            .sink { notification in
                // os_log("%{public}s[%{public}ld], %{public}s: keyboardWillShowNotification %s", ((#file as NSString).lastPathComponent), #line, #function, notification.debugDescription)

                guard let beginFrame = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
                let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }

                guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

                let option = UIView.AnimationOptions(rawValue: curve << 16)
                self.messageInputView.keyboardPaddingViewHeightLayoutConstraint.constant = endFrame.size != .zero ? endFrame.height + 8 : 0
                UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, option], animations: {
                    let oldInputViewHeight = self.messageInputView.frame.height
                    self.messageInputView.setNeedsLayout()
                    self.messageInputView.layoutIfNeeded()
                
                    // move tableView content when visible cell overlapped
                    self.tableView.visibleCells.last?.layoutIfNeeded()
                    if let lastCellFrame = self.tableView.visibleCells.last?.frame {
                        let inputViewMinYInTable = self.tableView.contentOffset.y + self.tableView.frame.height - self.messageInputView.frame.height
                        let lastCellMaxYInTable = lastCellFrame.maxY
                        
                        if lastCellMaxYInTable > inputViewMinYInTable {
                            let offset = min(lastCellMaxYInTable - inputViewMinYInTable, self.messageInputView.frame.height - oldInputViewHeight)
                            self.tableView.contentOffset.y += offset
                        }
                    }
                }, completion: { _ in

                })
            }
            .store(in: &disposeBag)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification, object: nil)
            .sink { notification in
                guard let beginFrame = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
                let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }

                guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                    let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
                
                let option = UIView.AnimationOptions(rawValue: curve << 16)
                self.messageInputView.keyboardPaddingViewHeightLayoutConstraint.constant = .leastNonzeroMagnitude
                UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, option], animations: {
                    self.messageInputView.setNeedsLayout()
                    self.messageInputView.layoutIfNeeded()
                }, completion: { _ in
                    
                })
            }
            .store(in: &disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
        //DispatchQueue.main.async {
        //    // async it to fix keyboard transition animation bug
        //    if self.viewModel.shouldEnterEditModeAtAppear {
        //        self.messageInputView.inputTextView.becomeFirstResponder()
        //    }
        //}
    }
    
}

// MARK: - UITableViewDelegate
extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ChatMessageTableViewCell {
            cell.delegate = self
        }
    }

}

// MARK: - MessageInputViewDelegate
extension ChatViewController: MessageInputViewDelegate {
        
    func messageInputView(_ inputView: MessageInputView, submitButtonPressed button: UIButton) {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
        guard let plaintext = inputView.inputTextView.text, !plaintext.isEmpty else {
            return
        }
        
        viewModel.sendMessage(plaintext: plaintext)
        inputView.inputTextView.text = ""
    }
    
    func messageInputView(_ inputView: MessageInputView, boundsDidUpdate bounds: CGRect) {
        tableView.contentInset.bottom = bounds.height - view.safeAreaInsets.bottom
        tableView.verticalScrollIndicatorInsets.bottom = bounds.height - view.safeAreaInsets.bottom
    }
}

// MARK: - ChatMessageTableViewCellDelegate
extension ChatViewController: ChatMessageTableViewCellDelegate {
    func chatMessageTableViewCell(_ cell: ChatMessageTableViewCell, shareButtonPressed button: UIButton) {
        guard let indexPath = tableView.indexPath(for: cell), indexPath.row < viewModel.items.value.count else {
            return
        }
        let item = viewModel.items.value[indexPath.row]
        switch item {
        case .chatMessage(let chatMessage):
            ShareService.shared.share(chatMessage: chatMessage, sender: self, sourceView: button)
        }
    }
}
