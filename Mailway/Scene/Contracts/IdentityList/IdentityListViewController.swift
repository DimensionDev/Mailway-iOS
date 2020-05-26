//
//  IdentityListViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-25.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import Combine

final class IdentityListViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    let context: AppContext
    let identities = CurrentValueSubject<[Contact], Never>([])
    
    init(context: AppContext) {
        self.context = context
        super.init()
        
        context.documentStore.$contacts
            .map { $0.filter { $0.isIdentity }}
            .assign(to: \.value, on: self.identities)
            .store(in: &disposeBag)
    }
    
}

extension IdentityListViewModel {
    enum Section: CaseIterable {
        case identities
        case createIdentityFooter
    }
}

extension IdentityListViewModel {
    static func configure(cell: ContactListIdentityBannerTableViewCell, with identities: [Contact]) {
        // set to no identities style
        ContactListViewModel.configure(cell: cell, with: [])
        
        // override header
        if identities.count == 0 {
            cell.bannerView.headerLabel.text = "No Identity"
        } else if identities.count == 1 {
            cell.bannerView.headerLabel.text = "1 Identity"
        } else {
            cell.bannerView.headerLabel.text = "\(identities.count) Identity"
        }
    }
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
            return identities.value.count
        case .createIdentityFooter:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section.allCases[indexPath.section]
        var cell: UITableViewCell
        switch section {
        case .identities:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: IdentityListIdentityTableViewCell.self), for: indexPath) as! IdentityListIdentityTableViewCell
            cell = _cell
            
            guard indexPath.row < identities.value.count else { break }
            let identity = identities.value[indexPath.row]
            
            _cell.nameLabel.text = identity.name
            
            
        case .createIdentityFooter:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ContactListIdentityBannerTableViewCell.self), for: indexPath) as! ContactListIdentityBannerTableViewCell
            cell = _cell
            
            identities
                .sink { identities in
                    IdentityListViewModel.configure(cell: _cell, with: identities)
                }
                .store(in: &_cell.disposeBag)
        }
        
        return cell
    }
}

final class IdentityListViewController: UIViewController {
    
    var disposeBag = Set<AnyCancellable>()
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(IdentityListIdentityTableViewCell.self, forCellReuseIdentifier: String(describing: IdentityListIdentityTableViewCell.self))
        tableView.register(ContactListIdentityBannerTableViewCell.self, forCellReuseIdentifier: String(describing: ContactListIdentityBannerTableViewCell.self))
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private(set) lazy var viewModel = IdentityListViewModel(context: context)
    
}

extension IdentityListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Contacts"
        
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

        viewModel.identities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &disposeBag)
    }
    
}

// MARK: - UITableViewDelegate
extension IdentityListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.cellForRow(at: indexPath) is ContactListIdentityBannerTableViewCell {
            // create identity
            let rootViewController = CreateIdentityViewController()
            rootViewController.context = self.context
            let navigationController = UINavigationController(rootViewController: rootViewController)
            navigationController.presentationController?.delegate = rootViewController
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
}
