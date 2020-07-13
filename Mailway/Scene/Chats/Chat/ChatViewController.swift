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
import CoreData
import CoreDataStack
import Floaty

final class ChatViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    let fetchedResultsController: NSFetchedResultsController<ChatMessage>
    
    // input
    let context: AppContext
    let chat: Chat
    weak var tableView: UITableView?
    
    // output
    // var diffableDataSource: UITableViewDiffableDataSource<Section, Item>!
    // var items = CurrentValueSubject<[Item], Never>([])
    
    init(context: AppContext, chat: Chat) {
        self.fetchedResultsController = {
            let fetchRequest = ChatMessage.sortedFetchRequest
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.fetchBatchSize = 20
            fetchRequest.predicate = ChatMessage.predicate(chat: chat)
            let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context.managedObjectContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            return controller
        }()
        self.context = context
        self.chat = chat
        super.init()
        
        fetchedResultsController.delegate = self
    }
    
}

extension ChatViewModel {
    
    static func configure(cell: ChatMessageTableViewCell, with chatMessage: ChatMessage) {
        cell.nameLabel.text = {
            let chat = chatMessage.chat
            guard let senderStub = chat?.memberNameStubs?.first(where: { $0.publicKey == chatMessage.senderPublicKey }) else {
                return "<Unknown>"
            }
            
            return senderStub.i18nName ?? senderStub.name ?? "<Unknown>"
        }()
        cell.messageLabel.text = {
            switch chatMessage.payloadKind {
            case .plaintext:
                guard let text = String(data: chatMessage.payload, encoding: .utf8) else {
                    return "<Empty>"
                }
                return text
            
            default:
                return "<Empty>"
            }
        }()
        // TODO: expand check
        cell.messageLabel.numberOfLines = 3
        cell.receiveTimestampLabel.text = {
            let dateFormatter = DateFormatter()
            // TODO: expand check
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: chatMessage.receiveTimestamp)
        }()
    }
    
}

extension ChatViewModel {
    enum Section: CaseIterable {
        case message
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ChatViewModel: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView?.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            break
        case .move:
            break
        case .delete:
            tableView?.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        @unknown default:
            assertionFailure()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { fatalError("Index Path should be not nil") }
            tableView?.insertRows(at: [newIndexPath], with: .fade)
            
        case .update:
            guard let indexPath = indexPath else {
                fatalError("Index Path should be not nil")
            }
            let chatMessage = fetchedResultsController.object(at: indexPath)
            guard let cell = tableView?.cellForRow(at: indexPath) as? ChatMessageTableViewCell else {
                return
            }
            
            ChatViewModel.configure(cell: cell, with: chatMessage)
            
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            
            tableView?.deleteRows(at: [indexPath], with: .fade)
            tableView?.insertRows(at: [newIndexPath], with: .fade)
            
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            tableView?.deleteRows(at: [indexPath], with: .fade)
            
        @unknown default:
            assertionFailure()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
    
}

// MARK: - UITableViewDataSource
 extension ChatViewModel: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatMessageTableViewCell.self), for: indexPath) as! ChatMessageTableViewCell
        
        let chatMessage = fetchedResultsController.object(at: indexPath)
        ChatViewModel.configure(cell: cell, with: chatMessage)
        
        return cell
    }

 }

final class ChatViewController: UIViewController, NeedsDependency {

    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var disposeBag = Set<AnyCancellable>()
    var viewModel: ChatViewModel! { willSet { precondition(!isViewLoaded) } }
    
    private var isViewAppeared = false
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatMessageTableViewCell.self, forCellReuseIdentifier: String(describing: ChatMessageTableViewCell.self))
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private lazy var floatyButton: Floaty = {
        let button = Floaty()
        button.buttonColor = UIColor(dynamicProvider: { traitCollection -> UIColor in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.white.withAlphaComponent(0.8)
            default:
                return .systemBackground
            }
        })
        button.buttonImage = Asset.Communication.arrowshapeTurnUpLeft2Fill.image
        button.handleFirstItemDirectly = true
        
        let replyAll: FloatyItem = {
            let item = FloatyItem()
            item.title = "Reply All"
            item.handler = self.replyAllFloatyItemPressed
            return item
        }()
        
        button.addItem(item: replyAll)
        
        return button
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
        
        view.addSubview(floatyButton)
                
        viewModel.tableView = tableView
        tableView.delegate = self
        do {
            try viewModel.fetchedResultsController.performFetch()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        tableView.dataSource = viewModel
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //tableView.reloadData()
        //DispatchQueue.main.async {
        //    // async it to fix keyboard transition animation bug
        //    if self.viewModel.shouldEnterEditModeAtAppear {
        //        self.messageInputView.inputTextView.becomeFirstResponder()
        //    }
        //}
    }
    
}

extension ChatViewController {
    
    @objc private func replyAllFloatyItemPressed(_ sender: FloatyItem) {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)

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

//// MARK: - MessageInputViewDelegate
//extension ChatViewController: MessageInputViewDelegate {
//
//    func messageInputView(_ inputView: MessageInputView, submitButtonPressed button: UIButton) {
//        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
////        guard let plaintext = inputView.inputTextView.text, !plaintext.isEmpty else {
////            return
////        }
////
////        viewModel.sendMessage(plaintext: plaintext)
////        inputView.inputTextView.text = ""
//    }
//
//    func messageInputView(_ inputView: MessageInputView, boundsDidUpdate bounds: CGRect) {
//        tableView.contentInset.bottom = bounds.height - view.safeAreaInsets.bottom
//        tableView.verticalScrollIndicatorInsets.bottom = bounds.height - view.safeAreaInsets.bottom
//    }
//
//}

// MARK: - ChatMessageTableViewCellDelegate
extension ChatViewController: ChatMessageTableViewCellDelegate {
    
    func chatMessageTableViewCell(_ cell: ChatMessageTableViewCell, replyButtonPressed button: UIButton) {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)

//        guard let indexPath = tableView.indexPath(for: cell), indexPath.row < viewModel.items.value.count else {
//            return
//        }
//        let item = viewModel.items.value[indexPath.row]
//        switch item {
//        case .chatMessage(let chatMessage):
//            ShareService.shared.share(chatMessage: chatMessage, sender: self, sourceView: button)
//        }
    }
    
    func chatMessageTableViewCell(_ cell: ChatMessageTableViewCell, moreButtonPressed button: UIButton) {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
}
