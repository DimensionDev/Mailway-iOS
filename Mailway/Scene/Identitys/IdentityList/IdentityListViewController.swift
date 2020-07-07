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
import CoreData
import CoreDataStack

final class IdentityListViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    // input
    let context: AppContext
    weak var tableView: UITableView?

    // output
    let fetchedResultsController: NSFetchedResultsController<Contact>
    
    init(context: AppContext) {
        self.context = context
        self.fetchedResultsController = {
            let fetchRequest = Contact.sortedFetchRequest
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.fetchBatchSize = 20
            fetchRequest.predicate = Contact.isIdentityPredicate
            
            let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context.managedObjectContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            return controller
        }()
        super.init()
        
        fetchedResultsController.delegate = self
        
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
    
    static func configure(cell: IdentityListIdentityTableViewCell, with identity: Contact) {
        cell.avatarImageView.image = identity.avatar ?? UIImage.placeholder(color: .systemFill)
        // TODO: color bar
        cell.nameLabel.text = identity.name
        cell.keyIDLabel.text = String(identity.keypair.keyID.suffix(8)).separate(every: 4, with: " ")
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension IdentityListViewModel: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView?.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            break
        case .move:
            break
        case .delete:
            tableView?.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        @unknown default:
            assertionFailure()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { fatalError("Index Path should be not nil") }
            tableView?.insertRows(at: [newIndexPath], with: .fade)
            
        case .update:
            guard let indexPath = indexPath else {
                fatalError("Index Path should be not nil")
            }
            let identity = fetchedResultsController.object(at: indexPath)
            guard let cell = tableView?.cellForRow(at: indexPath) as? IdentityListIdentityTableViewCell else {
                assertionFailure()
                return
            }
            IdentityListViewModel.configure(cell: cell, with: identity)
            
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            
            tableView?.deleteRows(at: [indexPath], with: .fade)
            tableView?.insertRows(at: [newIndexPath], with: .fade)
            
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            tableView?.deleteRows(at: [indexPath], with: .fade)
            
        @unknown default:
            assertionFailure()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
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
            // one section flat results
            return fetchedResultsController.sections?.first?.numberOfObjects ?? 0
        case .addIdentity:
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

            guard indexPath.row < fetchedResultsController.sections?[indexPath.section].numberOfObjects ?? 0 else { break }
            let identity = fetchedResultsController.object(at: indexPath)
            IdentityListViewModel.configure(cell: _cell, with: identity)
            
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
        
        viewModel.tableView = tableView
        tableView.delegate = self
        do {
            try viewModel.fetchedResultsController.performFetch()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        tableView.dataSource = viewModel
        tableView.reloadData()

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
