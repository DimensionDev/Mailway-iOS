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
    // var isKeyboardShowing: Bool = false
    
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
        
        let identityID = chat.identityKeyID
        guard let identityKey = context.documentStore.keys.first(where: { $0.keyID == identityID }) else {
            return
        }
        guard let identityPrivateKey = Ed25519.PrivateKey.deserialize(serialized: identityKey.privateKey) else {
            return
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
        // inputView.inputTextView.delegate = self
        inputView.delegate = self
        return inputView
    }()
    //let messageInputViewFrame = CurrentValueSubject<CGRect, Never>(.zero)
    //let keyboardFrame = CurrentValueSubject<CGRect, Never>(.zero)
    
    //override var inputAccessoryView: UIView? {
    //    return messageInputView
    //}
    
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
        
        //messageInputView.publisher(for: \.frame, options: [.initial, .new])
        //    .assign(to: \.value, on: messageInputViewFrame)
        //    .store(in: &disposeBag)
        //
        //Publishers.CombineLatest(messageInputViewFrame, keyboardFrame)
        //    .sink { messageInputViewFrame, keyboardFrame in
        //        print("messageInputViewFrame: \(messageInputViewFrame), keyboardFrame: \(keyboardFrame)")
        //        if keyboardFrame != .zero {
        //            // dock keyboard
        //            self.tableView.contentInset.bottom = keyboardFrame.height
        //            self.tableView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height
        //        } else {
        //            // float or split keyboard
        //            self.tableView.contentInset.bottom = messageInputViewFrame.height
        //            self.tableView.verticalScrollIndicatorInsets.bottom = messageInputViewFrame.height
        //        }
        //    }
        //    .store(in: &disposeBag)
        
        
//        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification, object: nil)
//            .receive(on: DispatchQueue.main)
//            .sink { notification in
//                os_log("%{public}s[%{public}ld], %{public}s: keyboardWillShowNotification %s", ((#file as NSString).lastPathComponent), #line, #function, notification.debugDescription)
//                guard !self.viewModel.isKeyboardShowing else { return }
//
//                guard let beginFrame = notification.userInfo?["UIKeyboardFrameBeginUserInfoKey"] as? CGRect,
//                let endFrame = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect else {
//                    return
//                }
//                guard !beginFrame.equalTo(endFrame) else { return }
//
//                // set insets
//                self.tableView.contentInset.bottom = endFrame.height
//                self.tableView.verticalScrollIndicatorInsets.bottom = endFrame.height
//
//
//                guard let duration = notification.userInfo?["UIKeyboardAnimationDurationUserInfoKey"] as? TimeInterval,
//                let curve = notification.userInfo?["UIKeyboardAnimationCurveUserInfoKey"] as? UInt else { return }
//
//                guard let lastCellFrame = self.tableView.visibleCells.last?.frame else { return }
//                let lastCellFrameOnScreen = self.tableView.convert(lastCellFrame, to: nil)
//                let targetAlignmentBottomY = min(self.view.frame.maxY - beginFrame.height, lastCellFrameOnScreen.maxY)
//                let endFrameOriginY = endFrame.origin.y
//                guard targetAlignmentBottomY > endFrameOriginY else {
//                    return
//                }
//                let offset = endFrame.origin.y - targetAlignmentBottomY
//
//                let option = UIView.AnimationOptions(rawValue: curve << 16)
//                UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, option], animations: {
//                    // set offset
//                    self.tableView.contentOffset.y -= offset
//                }, completion: { _ in
//                    self.viewModel.isKeyboardShowing = true
//                })
//                os_log("%{public}s[%{public}ld], %{public}s: keyboardWillShowNotification offse -= %s", ((#file as NSString).lastPathComponent), #line, #function, offset.description)
//
//            }
//            .store(in: &disposeBag)

            
//        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//            .sink { [weak self] notification in
//                guard let `self` = self else { return }
//                os_log("%{public}s[%{public}ld], %{public}s: keyboardWillShowNotification %s", ((#file as NSString).lastPathComponent), #line, #function, notification.debugDescription)
////                guard !self.viewModel.isKeyboardShowing else { return }
//
//                guard let beginFrame = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
//                let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
//                self.keyboardFrame.value = endFrame ?? .zero
//                let keyboardEndFrame = self.view.convert(endFrame, from: nil)
//
//                guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
//                let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

                
                // set insets
//                self.tableView.contentInset.bottom = endFrame.height
//                self.tableView.verticalScrollIndicatorInsets.bottom = endFrame.height



//                guard let lastCellFrame = self.tableView.visibleCells.last?.frame else { return }
//                let lastCellFrameOnScreen = self.tableView.convert(lastCellFrame, to: nil)
//                let targetAlignmentBottomY = min(self.view.frame.maxY - beginFrame.height, lastCellFrameOnScreen.maxY)
//                let endFrameOriginY = endFrame.origin.y
//                guard targetAlignmentBottomY > endFrameOriginY else {
//                    return
//                }
//                let offset = endFrame.origin.y - targetAlignmentBottomY
//
//                self.tableViewBottomLayoutConstraint.constant = self.view.bounds.height - keyboardEndFrame.origin.y
//
//                let option = UIView.AnimationOptions(rawValue: curve << 16)
//                UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, option], animations: {
//                    // set offset
////                    self.tableView.contentOffset.y -= offset
//                    self.view.setNeedsLayout()
//                }, completion: { _ in
////                    self.viewModel.isKeyboardShowing = true
//                })
//                //os_log("%{public}s[%{public}ld], %{public}s: keyboardWillShowNotification offse -= %s", ((#file as NSString).lastPathComponent), #line, #function, offset.description)
////                print(notification)
//            }
//            .store(in: &disposeBag)
//        self.keyboardFrameChangeObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil, using: { [weak self] notification in

//        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification, object: nil)
//            .receive(on: DispatchQueue.main)
//            .sink { notification in
//                guard self.viewModel.isKeyboardShowing else { return }
//
//                guard let beginFrame = notification.userInfo?["UIKeyboardFrameBeginUserInfoKey"] as? CGRect,
//                let endFrame = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect else {
//                    return
//                }
//
//                // set insets
//                self.tableView.contentInset.bottom = endFrame.height
//                self.tableView.verticalScrollIndicatorInsets.bottom = endFrame.height
//
//                let keyboardOffset = endFrame.origin.y - beginFrame.origin.y
//                let offset = max(-self.tableView.safeAreaInsets.top, self.tableView.contentOffset.y - keyboardOffset)
//
//                print(offset)
////
//                guard let duration = notification.userInfo?["UIKeyboardAnimationDurationUserInfoKey"] as? TimeInterval,
//                let curve = notification.userInfo?["UIKeyboardAnimationCurveUserInfoKey"] as? UInt else { return }
//
//                let option = UIView.AnimationOptions(rawValue: curve << 16)
//                UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, option], animations: {
//                    // set offset
//                    self.tableView.contentOffset.y = offset
//                }, completion: { _ in
//                    self.viewModel.isKeyboardShowing = false
//                })
////                os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, offset.description)
//
//            }
//            .store(in: &disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // print("Offset: \(scrollView.contentOffset), contentSize: \(scrollView.contentSize)")
    }

}

// MARK: - MessageInputViewDelegate
extension ChatViewController: MessageInputViewDelegate {
    
    func messageInputView(_ toolbar: MessageInputView, submitButtonPressed button: UIButton) {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
}

