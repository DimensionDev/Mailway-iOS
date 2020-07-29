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
import CoreData
import CoreDataStack
import NtgeCore

final class CreateChatViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    let fetchedResultsController: NSFetchedResultsController<Contact>

    // input
    let context: AppContext
    weak var tableView: UITableView?
    let selectedContacts = CurrentValueSubject<Set<Contact>, Never>([])
    
    // output
    let isDoneBarButtonEnabled = CurrentValueSubject<Bool, Never>(false)
    
    init(context: AppContext) {
        self.fetchedResultsController = {
            let fetchRequest = Contact.sortedFetchRequest
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.predicate = Contact.notIdentityPredicate
            fetchRequest.fetchBatchSize = 20
            let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context.managedObjectContext,
                sectionNameKeyPath: #keyPath(Contact.nameFirstInitial),
                cacheName: nil
            )
            
            return controller
        }()
        self.context = context
        super.init()

        fetchedResultsController.delegate = self
        
        selectedContacts
            .map { !$0.isEmpty }
            .assign(to: \.value, on: isDoneBarButtonEnabled)
            .store(in: &disposeBag)
    }
    
}

extension CreateChatViewModel {
    
    func configure(cell: ContactListContactTableViewCell, with contact: Contact) {
        ContactListViewModel.configure(cell: cell, with: contact)
        
        cell.checkmarkImageView.isHidden = false
        selectedContacts.sink { contacts in
            if contacts.contains(contact) {
                cell.checkmarkImageView.image = Asset.Editing.checkmarkCircleFill.image
                cell.checkmarkImageView.tintColor = nil
            } else {
                cell.checkmarkImageView.image = Asset.Editing.circle.image.withRenderingMode(.alwaysTemplate)
                cell.checkmarkImageView.tintColor = .label
            }
        }
        .store(in: &cell.disposeBag)
    }
    
}


// MARK: - NSFetchedResultsControllerDelegate
extension CreateChatViewModel: NSFetchedResultsControllerDelegate {
    
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
            let contact = fetchedResultsController.object(at: indexPath)
            guard let cell = tableView?.cellForRow(at: indexPath) as? ContactListContactTableViewCell else {
                assertionFailure()
                return
            }
            configure(cell: cell, with: contact)
            
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
extension CreateChatViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ContactListContactTableViewCell.self), for: indexPath) as! ContactListContactTableViewCell
        
        guard indexPath.section < fetchedResultsController.sections?.count ?? 0,
        indexPath.row < fetchedResultsController.sections?[indexPath.section].numberOfObjects ?? 0 else {
            return cell
        }
        let contact = fetchedResultsController.object(at: indexPath)
        configure(cell: cell, with: contact)
        
        return cell
    }
    
}

final class CreateChatViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = Asset.NavigationBar.close.image
        item.tintColor = Asset.Color.Tint.barButtonItem.color
        item.target = self
        item.action = #selector(CreateChatViewController.closeBarButtonItemPressed(_:))
        return item
    }()
    
    private lazy var doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CreateChatViewController.doneBarButtonItemPressed(_:)))
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ContactListContactTableViewCell.self, forCellReuseIdentifier: String(describing: ContactListContactTableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = true
        return tableView
    }()
    
    private(set) lazy var viewModel = CreateChatViewModel(context: context)
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
}

extension CreateChatViewController {
    
    @objc private func closeBarButtonItemPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneBarButtonItemPressed(_ sender: UIBarButtonItem) {
        guard !viewModel.selectedContacts.value.isEmpty else {
            assertionFailure()
            return
        }
        
        let recipientPublicKeys: [Ed25519.PublicKey] = Array(viewModel.selectedContacts.value)
            .compactMap { contact in
                guard let publicKeyText = contact.keypair?.publicKey,
                let publicKey = Ed25519.PublicKey.deserialize(serialized: publicKeyText) else {
                    return nil
                }
                
                return publicKey
            }
        let composeMessageViewModel = ComposeMessageViewModel(context: context, recipientPublicKeys: recipientPublicKeys)
        coordinator.present(scene: .composeMessage(viewModel: composeMessageViewModel), from: self, transition: .show)
    }
    
}

extension CreateChatViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Contacts"
        navigationItem.leftBarButtonItem = closeBarButtonItem
        navigationItem.rightBarButtonItem = doneBarButtonItem
        
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
        
        viewModel.isDoneBarButtonEnabled
            .assign(to: \.isEnabled, on: doneBarButtonItem)
            .store(in: &disposeBag)
    }

}

// MARK: - UITableViewDelegate
extension CreateChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        os_log("%{public}s[%{public}ld], %{public}s: didSelectRowAt: %s", ((#file as NSString).lastPathComponent), #line, #function, indexPath.debugDescription)

        guard indexPath.section < viewModel.fetchedResultsController.sections?.count ?? 0,
        indexPath.row < viewModel.fetchedResultsController.sections?[indexPath.section].numberOfObjects ?? 0 else {
            return
        }
        let contact = viewModel.fetchedResultsController.object(at: indexPath)
        var contacts = viewModel.selectedContacts.value
        contacts.insert(contact)
        viewModel.selectedContacts.value = contacts
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        os_log("%{public}s[%{public}ld], %{public}s: didSelectRowAt: %s", ((#file as NSString).lastPathComponent), #line, #function, indexPath.debugDescription)

        guard indexPath.section < viewModel.fetchedResultsController.sections?.count ?? 0,
            indexPath.row < viewModel.fetchedResultsController.sections?[indexPath.section].numberOfObjects ?? 0 else {
                return
        }
        let contact = viewModel.fetchedResultsController.object(at: indexPath)
        var contacts = viewModel.selectedContacts.value
        contacts.remove(contact)
        viewModel.selectedContacts.value = contacts
    }
    
}
