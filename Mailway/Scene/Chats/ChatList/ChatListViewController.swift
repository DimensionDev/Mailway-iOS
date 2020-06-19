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

final class ChatListViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()

    // input
    let context: AppContext
    
    // output
    let chats = CurrentValueSubject<[Chat], Never>([])
    
    init(context: AppContext) {
        self.context = context
        super.init()

//        context.documentStore.$chats
//            .assign(to: \.value, on: self.chats)
//            .store(in: &disposeBag)
    }
    
}

extension ChatListViewModel {
    enum Section: CaseIterable {
        case inboxBanner
        case chats
    }
}

// MARK: - UITableViewDataSource
extension ChatListViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section.allCases[section]
        switch section {
        case .inboxBanner:
            return 1
        case .chats:
            return chats.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section.allCases[indexPath.section]
        let cell: UITableViewCell
        
        switch section {
        case .inboxBanner:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatListInboxBannerTableViewCell.self), for: indexPath) as! ChatListInboxBannerTableViewCell
            cell = _cell
            
        case .chats:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatListChatRoomTableViewCell.self), for: indexPath) as! ChatListChatRoomTableViewCell
            cell = _cell
            
            let chat = chats.value[indexPath.row]
            _cell.titleLabel.text = chat.title
        }
        
        return cell
    }
    
}

final class ChatListViewController: UIViewController, NeedsDependency {
    
     weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
     weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var disposeBag = Set<AnyCancellable>()
    private(set) lazy var viewModel = ChatListViewModel(context: context)

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
        navigationItem.rightBarButtonItem = composeBarButtonItem
        
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
        
        viewModel.chats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &disposeBag)
    }
    
}

extension ChatListViewController {
    
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
