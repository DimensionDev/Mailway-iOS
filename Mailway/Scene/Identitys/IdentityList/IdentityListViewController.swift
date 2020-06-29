//
//  IdentityListViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-25.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit
import Combine

final class IdentityListViewModel: NSObject {
    
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

extension IdentityListViewModel {
    enum Section: CaseIterable {
        case identities
        case addIdentity
    }
}

extension IdentityListViewModel {
    
//    static func configure(cell: ContactListIdentityBannerTableViewCell, with identities: [Contact]) {
//        // set to no identities style
//        ContactListViewModel.configure(cell: cell, with: [])
//
//        // override header
//        if identities.count == 0 {
//            cell.bannerView.headerLabel.text = "No Identity"
//        } else if identities.count == 1 {
//            cell.bannerView.headerLabel.text = "1 Identity"
//        } else {
//            cell.bannerView.headerLabel.text = "\(identities.count) Identity"
//        }
//    }
}

// MARK: - UITableViewDataSource
extension IdentityListViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section.allCases[section]
        switch section {
        case .identities:
            return 0
//            return identities.value.count
        case .addIdentity:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section.allCases[indexPath.section]
        var cell: UITableViewCell

        switch section {
        case .identities:
            cell = UITableViewCell()
//            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: IdentityListIdentityTableViewCell.self), for: indexPath) as! IdentityListIdentityTableViewCell
//            cell = _cell
//
//            guard indexPath.row < identities.value.count else { break }
//            let identity = identities.value[indexPath.row]
//
//            _cell.nameLabel.text = identity.name
            
        case .addIdentity:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: IdentityListAddIdentityTableViewCell.self), for: indexPath) as! IdentityListAddIdentityTableViewCell
            cell = _cell
        }

        return cell
    }
}

final class IdentityListViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(IdentityListIdentityTableViewCell.self, forCellReuseIdentifier: String(describing: IdentityListIdentityTableViewCell.self))
        tableView.register(IdentityListAddIdentityTableViewCell.self, forCellReuseIdentifier: String(describing: IdentityListAddIdentityTableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private(set) lazy var viewModel = IdentityListViewModel(context: context)
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }

}

extension IdentityListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Identites"
        
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
extension IdentityListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? IdentityListAddIdentityTableViewCell {
            cell.delegate = self
        }
    }
    
}

// MARK: - IdentityListAddIdentityTableViewCellDelegate
extension IdentityListViewController: IdentityListAddIdentityTableViewCellDelegate {
    
    func identityListAddIdentityTableViewCell(_ cell: IdentityListAddIdentityTableViewCell, addButtonDidPressed button: UIButton) {
        coordinator.present(scene: .addIdentity, from: self, transition: .modal(animated: true, completion: nil))
    }
    
}
