//
//  CreateChatViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-26.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

final class CreateChatViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    // input
    let context: AppContext
    
    // output
    let contacts = CurrentValueSubject<[Contact], Never>([])
    
    init(context: AppContext) {
        self.context = context
        super.init()

        context.documentStore.$contacts
            .assign(to: \.value, on: self.contacts)
            .store(in: &disposeBag)
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
        let section = CreateChatViewModel.Section.allCases[section]
        switch section {
        case .createChatGroup:
            return 1
        case .contacts:
            return contacts.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section.allCases[indexPath.section]
        var cell: UITableViewCell
        
        switch section {
        case .createChatGroup:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CreateChatGroupTableViewCell.self), for: indexPath) as! CreateChatGroupTableViewCell
            cell = _cell
            
            
        case .contacts:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ContactListContactTableViewCell.self), for: indexPath) as! ContactListContactTableViewCell
            cell = _cell
            
            guard indexPath.row < contacts.value.count else { break }
            let contact = contacts.value[indexPath.row]
            _cell.nameLabel.text = contact.name
        }
        
        return cell
    }
    
}

final class CreateChatViewController: UIViewController {
    
    var disposeBag = Set<AnyCancellable>()
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    
//    private lazy var composeBarButtonItem: UIBarButtonItem = {
//        let item = UIBarButtonItem()
//        item.image = UIImage(systemName: "square.and.pencil")
//        item.action = #selector(ChatListViewController.composeBarButtonItemPressed(_:))
//        return item
//    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CreateChatGroupTableViewCell.self, forCellReuseIdentifier: String(describing: CreateChatGroupTableViewCell.self))
        tableView.register(ContactListContactTableViewCell.self, forCellReuseIdentifier: String(describing: ContactListContactTableViewCell.self))
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private(set) lazy var viewModel = CreateChatViewModel(context: context)
    
}

extension CreateChatViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Message"
        // navigationItem.rightBarButtonItem = composeBarButtonItem
        
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
        
        viewModel.contacts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &disposeBag)
    }
    
}

// MARK: - UITableViewDelegate
extension CreateChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
