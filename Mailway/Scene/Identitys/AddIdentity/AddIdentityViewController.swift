//
//  AddIdentityViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

final class AddIdentityViewModel: NSObject {
    
}

//extension AddIdentityViewModel {
//    enum Section: CaseIterable {
//        case avatar
//        case name
//    }
//}


//extension AddIdentityViewModel: UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return Section.allCases.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let section = Section.allCases[section]
//        switch section {
//        case .avatar:   return 1
//        case .name:     return 1
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let section = Section.allCases[indexPath.section]
//        let cell: UITableViewCell
//
//        switch section {
//        case .avatar:
//            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditableAvatarTableViewCell.self), for: indexPath) as! EditableAvatarTableViewCell
//            cell = _cell
//
//        case .name:
//            cell = UITableViewCell()
//        }
//        return cell
//    }
//}

final class AddIdentityViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    let viewModel = AddIdentityViewModel()
    
    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = Asset.NavigationBar.close.image
        item.target = self
        item.action = #selector(AddIdentityViewController.closeBarButtonItemPressed(_:))
        return item
    }()
    
    let addIdentityFormView = AddIdentityFormView()
    
//    private(set) lazy var tableView: UITableView = {
//        let tableView = UITableView()
//        tableView.register(EditableAvatarTableViewCell.self, forCellReuseIdentifier: String(describing: EditableAvatarTableViewCell.self))
//        tableView.tableFooterView = UIView()
//        tableView.separatorStyle = .none
//        return tableView
//    }()
    
}

extension AddIdentityViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = closeBarButtonItem
        
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(tableView)
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
//            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
//        ])
//
//        tableView.delegate = self
//        tableView.dataSource = viewModel
        
        let hostingController = UIHostingController(rootView: addIdentityFormView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
}

extension AddIdentityViewController {
    
    @objc private func closeBarButtonItemPressed(_ sender: UIBarButtonItem) {
        // TODO: discard alert
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDelegate
extension AddIdentityViewController: UITableViewDelegate {
    
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension AddIdentityViewController: UIAdaptivePresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        if traitCollection.userInterfaceIdiom == .pad {
            return .formSheet
        } else {
            return .fullScreen
        }
    }
    
}
