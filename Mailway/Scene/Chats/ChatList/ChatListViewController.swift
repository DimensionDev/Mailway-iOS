//
//  ChatListViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-26.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
import CoreData
import CoreDataStack

final class ChatListViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    let fetchedResultsController: NSFetchedResultsController<Chat>

    // input
    let context: AppContext
    weak var tableView: UITableView?
    
    // output
    // let chats = CurrentValueSubject<[Chat], Never>([])
    
    init(context: AppContext) {
        self.fetchedResultsController = {
            let fetchRequest = Chat.sortedFetchRequest
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.fetchBatchSize = 20
            let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context.managedObjectContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            return controller
        }()
        self.context = context
        super.init()

        fetchedResultsController.delegate = self

//        context.documentStore.$chats
//            .assign(to: \.value, on: self.chats)
//            .store(in: &disposeBag)
    }
    
}

extension ChatListViewModel {
//    enum Section: CaseIterable {
//        case inboxBanner
//        case chats
//    }
}


extension ChatListViewModel {
    
    static func configure(cell: ChatListChatRoomTableViewCell, with chat: Chat) {
        cell.titleLabel.text = chat.title
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension ChatListViewModel: NSFetchedResultsControllerDelegate {
    
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
            let chat = fetchedResultsController.object(at: indexPath)
            guard let cell = tableView?.cellForRow(at: indexPath) as? ChatListChatRoomTableViewCell else {
                return
            }
            
            ChatListViewModel.configure(cell: cell, with: chat)
            
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
extension ChatListViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatListChatRoomTableViewCell.self), for: indexPath) as! ChatListChatRoomTableViewCell
        
        let chat = fetchedResultsController.object(at: indexPath)
        
        ChatListViewModel.configure(cell: cell, with: chat)
        
        return cell
    }
    
}


final class ChatListViewController: UIViewController, NeedsDependency, MainTabTransitionableViewController {
    
    private(set) var transitionController: MainTabTransitionController!
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var disposeBag = Set<AnyCancellable>()
    private(set) lazy var viewModel = ChatListViewModel(context: context)

    private lazy var sidebarBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(systemName: "list.dash")
        item.target = self
        item.action = #selector(ChatListViewController.sidebarBarButtonItemPressed(_:))
        return item
    }()
    
    private lazy var composeBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = UIImage(systemName: "square.and.pencil")
        item.target = self
        item.action = #selector(ChatListViewController.composeBarButtonItemPressed(_:))
        return item
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatListInboxBannerTableViewCell.self, forCellReuseIdentifier: String(describing: ChatListInboxBannerTableViewCell.self))
        tableView.register(ChatListChatRoomTableViewCell.self, forCellReuseIdentifier: String(describing: ChatListChatRoomTableViewCell.self))
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
}

extension ChatListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Chats"
        transitionController = MainTabTransitionController(viewController: self)
        navigationItem.leftBarButtonItem = sidebarBarButtonItem
        navigationItem.rightBarButtonItem = composeBarButtonItem
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        viewModel.tableView = tableView
        tableView.delegate = self
        try! viewModel.fetchedResultsController.performFetch()
        tableView.dataSource = viewModel
        tableView.reloadData()
        
//        viewModel.chats
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//                self?.tableView.reloadData()
//            }
//            .store(in: &disposeBag)
    }
    
}

extension ChatListViewController {
    
    @objc private func sidebarBarButtonItemPressed(_ sender: UIBarButtonItem) {
        coordinator.present(scene: .sidebar, from: self, transition: .custom(transitioningDelegate: transitionController))
    }
    
    @objc private func composeBarButtonItemPressed(_ sender: UIBarButtonItem) {
        coordinator.present(scene: .createChat, from: self, transition: .modal(animated: true))
    }
    
}

// MARK: - UITableViewDelegate
extension ChatListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        guard let cell = tableView.cellForRow(at: indexPath) else  { return }
//        
//        if cell is ChatListInboxBannerTableViewCell {
//            coordinator.present(scene: .inbox, from: self, transition: .modal(animated: true, completion: nil))
//        }
//    
//        if cell is ChatListChatRoomTableViewCell, indexPath.row < viewModel.chats.value.count {
//            let chat = viewModel.chats.value[indexPath.row]
//            let chatViewModel = ChatViewModel(context: context, chat: chat)
//            chatViewModel.items.value = context.documentStore.chatMessages
//                .filter { chat.contains(message: $0) }
//                .map { ChatViewModel.Item.chatMessage($0) }
//            coordinator.present(scene: .chatRoom(viewModel: chatViewModel), from: self, transition: .showDetail)
//        }
    }
    
}
