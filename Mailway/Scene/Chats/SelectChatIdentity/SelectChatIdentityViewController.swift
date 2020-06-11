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

final class SelectChatIdentityViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    let context: AppContext
//    let identities = CurrentValueSubject<[Contact], Never>([])
    
    init(context: AppContext) {
        self.context = context
        super.init()
        
//        context.documentStore.$contacts
//            .map { $0.filter { $0.isIdentity }}
//            .assign(to: \.value, on: self.identities)
//            .store(in: &disposeBag)
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
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
//        let section = Section.allCases[section]
//        switch section {
//        case .identities:
//            return identities.value.count
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
//        let section = Section.allCases[indexPath.section]
//        var cell: UITableViewCell
//        switch section {
//        case .identities:
//            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: IdentityListIdentityTableViewCell.self), for: indexPath) as! IdentityListIdentityTableViewCell
//            cell = _cell
//
//            guard indexPath.row < identities.value.count else { break }
//            let identity = identities.value[indexPath.row]
//
//            _cell.nameLabel.text = identity.name
//        }
//
//        return cell
    }
}

protocol SelectChatIdentityViewControllerDelegate: class {
//    func selectChatIdentityViewController(_ viewController: SelectChatIdentityViewController, didSelectIdentity identity: Contact)
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
    
    private(set) lazy var viewModel = SelectChatIdentityViewModel(context: context)
    
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
        
//        viewModel.identities
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//                self?.tableView.reloadData()
//            }
//            .store(in: &disposeBag)
    }
    
}


// MARK: - UITableViewDelegate
extension SelectChatIdentityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        if tableView.cellForRow(at: indexPath) is IdentityListIdentityTableViewCell,
//        indexPath.row < viewModel.identities.value.count {
//            let identity = viewModel.identities.value[indexPath.row]
//            delegate?.selectChatIdentityViewController(self, didSelectIdentity: identity)
//        }
    }
    
}
