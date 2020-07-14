//
//  CreateContactViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-14.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import Combine

final class CreateContactViewModel: NSObject {
    
    override init() {
        super.init()
    }
    
}

extension CreateContactViewModel {
    
    enum Section: CaseIterable {
        case banner
        case entry
    }
    
    enum Entry: CaseIterable {
        case scanQR
        case file
    }
    
}

// MARK: - UITableViewDataSource
extension CreateContactViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section.allCases[section]
        
        switch section {
        case .banner:
            return 1
        case .entry:
            return Entry.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        let section = Section.allCases[indexPath.section]
        switch section {
        case .banner:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CreateContactBannerTableViewCell.self), for: indexPath) as! CreateContactBannerTableViewCell
            cell = _cell
            
        case .entry:
            switch Entry.allCases[indexPath.row] {
            case .scanQR:
                let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CreateContactScanQREntryTableViewCell.self), for: indexPath) as! CreateContactScanQREntryTableViewCell
                cell = _cell
            case .file:
                let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CreateContactFileEntryTableViewCell.self), for: indexPath) as! CreateContactFileEntryTableViewCell
                cell = _cell
            }
        }
        
        return cell
    }
    
}

final class CreateContactViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CreateContactBannerTableViewCell.self, forCellReuseIdentifier: String(describing: CreateContactBannerTableViewCell.self))
        tableView.register(CreateContactScanQREntryTableViewCell.self, forCellReuseIdentifier: String(describing: CreateContactScanQREntryTableViewCell.self))
        tableView.register(CreateContactFileEntryTableViewCell.self, forCellReuseIdentifier: String(describing: CreateContactFileEntryTableViewCell.self))
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    let viewModel = CreateContactViewModel()
    
}

extension CreateContactViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Contact"
        view.backgroundColor = .systemBackground
        
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
extension CreateContactViewController: UITableViewDelegate {

}
