//
//  CreateChatViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-26.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit
import SwiftUI
import Combine

final class CreateChatViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    // input
    let context: AppContext
//    let selectContact = CurrentValueSubject<Contact?, Never>(nil)
    
    // output
//    let contacts = CurrentValueSubject<[Contact], Never>([])
    
    init(context: AppContext) {
        self.context = context
        super.init()

//        context.documentStore.$contacts
//            .assign(to: \.value, on: self.contacts)
//            .store(in: &disposeBag)
    }
    
}

extension CreateChatViewModel {
    enum Section: CaseIterable {
        case createChatGroup
        case contacts
    }
}

// MARK: - UITableViewDataSource
extension CreateChatViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return CreateChatViewModel.Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
//        let section = CreateChatViewModel.Section.allCases[section]
//        switch section {
//        case .createChatGroup:
//            return 1
//        case .contacts:
//            return contacts.value.count
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
//        let section = Section.allCases[indexPath.section]
//        var cell: UITableViewCell
//
//        switch section {
//        case .createChatGroup:
//            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CreateChatGroupTableViewCell.self), for: indexPath) as! CreateChatGroupTableViewCell
//            cell = _cell
//
//
//        case .contacts:
//            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ContactListContactTableViewCell.self), for: indexPath) as! ContactListContactTableViewCell
//            cell = _cell
//
//            guard indexPath.row < contacts.value.count else { break }
//            let contact = contacts.value[indexPath.row]
//            _cell.nameLabel.text = contact.name
//        }
//
//        return cell
    }
    
}

final class CreateChatViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    private lazy var cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(CreateChatViewController.cancelBarButtonItemPressed(_:)))
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CreateChatGroupTableViewCell.self, forCellReuseIdentifier: String(describing: CreateChatGroupTableViewCell.self))
        tableView.register(ContactListContactTableViewCell.self, forCellReuseIdentifier: String(describing: ContactListContactTableViewCell.self))
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private(set) lazy var viewModel = CreateChatViewModel(context: context)
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
}

extension CreateChatViewController {
    @objc private func cancelBarButtonItemPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension CreateChatViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Message"
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        
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
        
//        viewModel.contacts
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//                self?.tableView.reloadData()
//            }
//            .store(in: &disposeBag)
    }

}

// MARK: - UITableViewDelegate
extension CreateChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        if tableView.cellForRow(at: indexPath) is ContactListContactTableViewCell, indexPath.row < viewModel.contacts.value.count {
//            viewModel.selectContact.value = viewModel.contacts.value[indexPath.row]
//            coordinator.present(scene: .selectChatIdentity(delegate: self), from: self, transition: .show)
//        }
    }
    
}

// MARK: - SelectChatIdentityViewControllerDelegate
//extension CreateChatViewController: SelectChatIdentityViewControllerDelegate {
//
//    func selectChatIdentityViewController(_ viewController: SelectChatIdentityViewController, didSelectIdentity identity: Contact) {
//
//        guard let recipent = viewModel.selectContact.value else {
//            return
//        }
//        let chatMembers = Set([recipent, identity])
//        var chat = Chat()
//        chat.identityKeyID = identity.keyID
//        chat.identityName = identity.name
//        chat.memberKeyIDs = chatMembers.map { $0.keyID }
//        chat.memberNames = chatMembers.map { $0.name }
//        chat.title = chat.memberNames.joined(separator: ", ")
//        
//        let targetChat = context.documentStore.queryExists(chat: chat) ?? chat
//        let chatRoomViewModel = ChatViewModel(context: context, chat: targetChat)
//        chatRoomViewModel.shouldEnterEditModeAtAppear = true
//        
//        dismiss(animated: true) { [weak self] in
//            self?.coordinator.present(scene: .chatRoom(viewModel: chatRoomViewModel), from: nil, transition: .showDetail)
//        }
//    }
//
//}
