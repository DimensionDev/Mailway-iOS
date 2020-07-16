//
//  SelectChatIdentityViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-27.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit
import Combine
import CoreDataStack

protocol SelectChatIdentityViewControllerDelegate: class {
    func selectChatIdentityViewController(_ viewController: SelectChatIdentityViewController, didSelectIdentity identity: Contact)
}

final class SelectChatIdentityViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    let context: AppContext
    let identities: [Contact]
    
    init(context: AppContext, identities: [Contact]) {
        self.context = context
        self.identities = identities
        super.init()
    }
    
}

extension SelectChatIdentityViewModel {
    enum Section: CaseIterable {
        case identities
    }
}

// MARK: - UITableViewDataSource
extension SelectChatIdentityViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return identities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: IdentityListIdentityTableViewCell.self), for: indexPath) as! IdentityListIdentityTableViewCell
        let identity = identities[indexPath.row]
        IdentityListViewModel.configure(cell: cell, with: identity)
        return cell
    }
}

final class SelectChatIdentityViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    weak var delegate: SelectChatIdentityViewControllerDelegate?

    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(IdentityListIdentityTableViewCell.self, forCellReuseIdentifier: String(describing: IdentityListIdentityTableViewCell.self))
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    var viewModel: SelectChatIdentityViewModel!
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
}

extension SelectChatIdentityViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Identity"
        
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
extension SelectChatIdentityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.cellForRow(at: indexPath) is IdentityListIdentityTableViewCell,
        indexPath.row < viewModel.identities.count {
            let identity = viewModel.identities[indexPath.row]
            delegate?.selectChatIdentityViewController(self, didSelectIdentity: identity)
        }
    }
    
}
