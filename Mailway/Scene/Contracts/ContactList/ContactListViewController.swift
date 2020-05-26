//
//  ContactListViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-22.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

final class ContactListViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    // input
    let context: AppContext
    let identities = CurrentValueSubject<[Contact], Never>([])
    let contacts = CurrentValueSubject<[Contact], Never>([])
    
    // output
    let pushIdentityListPublisher = PassthroughSubject<Void, Never>()
    
    init(context: AppContext) {
        self.context = context
        super.init()
    
        context.documentStore.$contacts
            .map { $0.filter { $0.isIdentity }}
            .assign(to: \.value, on: self.identities)
            .store(in: &disposeBag)
        
        context.documentStore.$contacts
            .map { $0.filter { !$0.isIdentity }}
            .assign(to: \.value, on: self.contacts)
            .store(in: &disposeBag)
    }
    
}

extension ContactListViewModel {
    enum Section: CaseIterable {
        case identity
        case contacts
    }
}

extension ContactListViewModel {
    
    static func configure(cell: ContactListIdentityBannerTableViewCell, with identities: [Contact]) {
        if identities.count == 0 {
            cell.bannerView.personIconImageView.image = UIImage(systemName: "person.crop.circle.fill.badge.plus")
            cell.bannerView.headerLabel.text = "No Identity"
            cell.bannerView.captionLabel.text = "Tap to add identity"
        } else if identities.count == 1 {
            cell.bannerView.personIconImageView.image = UIImage(systemName: "person.crop.square.fill")
            cell.bannerView.headerLabel.text = "My Identity"
            cell.bannerView.captionLabel.text = "1 identity"
        } else {
            cell.bannerView.personIconImageView.image = UIImage(systemName: "rectangle.stack.person.crop.fill")
            cell.bannerView.headerLabel.text = "My Identity"
            cell.bannerView.captionLabel.text = "\(identities.count) identities"
        }
    }
    
}

// MARK: - UITableViewDataSource
extension ContactListViewModel: UITableViewDataSource {
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section.allCases[section]
        switch section {
        case .identity:
            return 1
        case .contacts:
            return contacts.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section.allCases[indexPath.section]
        var cell: UITableViewCell
        switch section {
        case .identity:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ContactListIdentityBannerTableViewCell.self), for: indexPath) as! ContactListIdentityBannerTableViewCell
            cell = _cell
            self.identities
                .sink(receiveValue: { identities in
                    ContactListViewModel.configure(cell: _cell, with: identities)
                })
                .store(in: &_cell.disposeBag)
    
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

final class ContactListViewController: UIViewController {
    
    var disposeBag = Set<AnyCancellable>()
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ContactListIdentityBannerTableViewCell.self, forCellReuseIdentifier: String(describing: ContactListIdentityBannerTableViewCell.self))
        tableView.register(ContactListContactTableViewCell.self, forCellReuseIdentifier: String(describing: ContactListContactTableViewCell.self))
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private(set) lazy var viewModel = ContactListViewModel(context: context)
    
}

extension ContactListViewController {
    
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
        
        Publishers.CombineLatest(viewModel.identities, viewModel.contacts)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.tableView.reloadData()
            }
            .store(in: &disposeBag)
    }
    
}

// MARK: - UITableViewDelegate
extension ContactListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if tableView.cellForRow(at: indexPath) is ContactListIdentityBannerTableViewCell {
            if viewModel.identities.value.isEmpty {
                // create identity
                let rootViewController = CreateIdentityViewController()
                rootViewController.context = self.context
                let navigationController = UINavigationController(rootViewController: rootViewController)
                navigationController.presentationController?.delegate = rootViewController
                self.present(navigationController, animated: true, completion: nil)
            } else {
                // open list
                let viewController = IdentityListViewController()
                viewController.context = self.context
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
}

struct ContactListViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            let viewController = ContactListViewController()
            viewController.context = AppContext.shared
            return viewController
        }
    }
}
