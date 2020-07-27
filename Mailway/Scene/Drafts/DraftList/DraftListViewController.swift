//
//  DraftListViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-21.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import Combine
import CoreData
import CoreDataStack
import NtgeCore

final class DraftListViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    let fetchedResultsController: NSFetchedResultsController<ChatMessage>
    
    // input
    let context: AppContext
    weak var tableView: UITableView?
    
    // output
    // let identityCount = CurrentValueSubject<Int, Never>(0)
    // let chats = CurrentValueSubject<[Chat], Never>([])
    
    init(context: AppContext) {
        self.fetchedResultsController = {
            let fetchRequest = ChatMessage.sortedFetchRequest
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.fetchBatchSize = 20
            fetchRequest.predicate = ChatMessage.isDraftPredicate
            let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context.managedObjectContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            return controller
        }()
        self.context = context
        super.init()
        
        fetchedResultsController.delegate = self
    }
    
}

extension DraftListViewModel {
    
    static func configure(cell: DraftListMessageTableViewCell, with chatMessage: ChatMessage) {
        // do not display identity when not only identity in the chat
        assert(chatMessage.isDraft)

        guard let managedObjectContext = chatMessage.managedObjectContext else {
            assertionFailure()
            return
        }
        
        var recipients: [Contact] = []
        var missingRecipientKeys = [String]()
        
        for publicKey in chatMessage.recipientPublicKeys {
            let request = Contact.sortedFetchRequest
            request.predicate = Contact.predicate(publicKey: publicKey)
            request.fetchLimit = 1
            request.returnsObjectsAsFaults = false
            
            guard let recipient = try? managedObjectContext.fetch(request).first else {
                missingRecipientKeys.append(publicKey)
                continue
            }
            recipients.append(recipient)
        }
        recipients.sort(by: { $0.name < $1.name })
        
        let identity: Contact? = {
            guard let identityPublicKey = chatMessage.senderPublicKey, !identityPublicKey.isEmpty else {
                return nil
            }
            
            let request = Contact.sortedFetchRequest
            request.fetchLimit = 1
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                Contact.isIdentityPredicate,
                Contact.predicate(publicKey: identityPublicKey)
            ])
            request.returnsObjectsAsFaults = false
            return try? managedObjectContext.fetch(request).first
        }()
        
        cell.avatarViewModel.infos = {
            let infos: [AvatarViewModel.Info] = recipients.lazy.map { recipient in
                let name = recipient.name
                let image = recipient.avatar
                return AvatarViewModel.Info(name: name, image: image)
            }
            .prefix(3)
            .reversed()

            guard !infos.isEmpty else {
                // no recipients except sender (if could fetched)
                guard let identity = identity else {
                    return [AvatarViewModel.Info(name: "A", image: nil)]
                }
                
                return [AvatarViewModel.Info(name: identity.name, image: identity.avatar)]
            }
            return infos
        }()
        cell.titleLabel.text = {
            let names = recipients.compactMap { $0.name }
            let text = names.sorted().joined(separator: ", ")
            guard !text.isEmpty else {
                // no recipients but only sender
                return identity?.name ?? "<Empty>"
            }
            return text
        }()
        cell.detailLabel.text = {
            switch chatMessage.payloadKind {
            case .plaintext:
                guard let text = String(data: chatMessage.payload, encoding: .utf8) else {
                    assertionFailure()
                    return " "
                }

                return text

            default:
                return " "
            }
        }()
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension DraftListViewModel: NSFetchedResultsControllerDelegate {
    
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
            let chatMessage = fetchedResultsController.object(at: indexPath)
            guard let cell = tableView?.cellForRow(at: indexPath) as? DraftListMessageTableViewCell else {
                return
            }
            
            DraftListViewModel.configure(cell: cell, with: chatMessage)
            
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
extension DraftListViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DraftListMessageTableViewCell.self), for: indexPath) as! DraftListMessageTableViewCell
        
        let chatMessage = fetchedResultsController.object(at: indexPath)
        DraftListViewModel.configure(cell: cell, with: chatMessage)
        
        return cell
    }
    
}

final class DraftListViewController: UIViewController, NeedsDependency, MainTabTransitionableViewController {
    
    private(set) var transitionController: MainTabTransitionController!
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var disposeBag = Set<AnyCancellable>()
    private(set) lazy var viewModel = DraftListViewModel(context: context)
    
    private lazy var sidebarBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = Asset.Sidebar.menu.image
        item.target = self
        item.action = #selector(DraftListViewController.sidebarBarButtonItemPressed(_:))
        return item
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DraftListMessageTableViewCell.self, forCellReuseIdentifier: String(describing: DraftListMessageTableViewCell.self))
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
}

extension DraftListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Drafts"
        transitionController = MainTabTransitionController(viewController: self)
        navigationItem.leftBarButtonItem = sidebarBarButtonItem
        
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
    }
    
}

extension DraftListViewController {
    
    @objc private func sidebarBarButtonItemPressed(_ sender: UIBarButtonItem) {
        coordinator.present(scene: .sidebar, from: self, transition: .custom(transitioningDelegate: transitionController))
    }
    
    //    @objc private func composeBarButtonItemPressed(_ sender: UIBarButtonItem) {
    //        coordinator.present(scene: .createChat, from: self, transition: .modal(animated: true))
    //    }
    
//    @objc private func composeFloatyItemPressed(_ sender: FloatyItem) {
//        let fetchRequest = Contact.sortedFetchRequest
//        fetchRequest.predicate = Contact.isIdentityPredicate
//
//        do {
//            let count = try context.managedObjectContext.count(for: fetchRequest)
//            guard count != 0 else {
//                let alertController = UIAlertController(title: "Identity Not Found", message: "Please create idenitty before compose message.", preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alertController.addAction(okAction)
//                present(alertController, animated: true, completion: nil)
//                return
//            }
//
//            coordinator.present(scene: .createChat, from: self, transition: .modal(animated: true))
//        } catch {
//            let alertController = UIAlertController.standardAlert(of: error)
//            present(alertController, animated: true, completion: nil)
//        }
//    }
    
//    @objc private func receiveFloatyItemPressed(_ sender: FloatyItem) {
//        coordinator.present(scene: .decryptMessage, from: self, transition: .modal(animated: true, completion: nil))
//    }
    
}

// MARK: - UITableViewDelegate
extension DraftListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        if cell is DraftListMessageTableViewCell {
            let chatMessage = viewModel.fetchedResultsController.object(at: indexPath)
            let recipientPublicKeys: [Ed25519.PublicKey] = {
                chatMessage.recipientPublicKeys.compactMap { key in
                    return Ed25519.PublicKey.deserialize(serialized: key)
                }
            }()
            let composeMessageViewModel = ComposeMessageViewModel(context: context, recipientPublicKeys: recipientPublicKeys, draft: chatMessage)
            coordinator.present(scene: .composeMessage(viewModel: composeMessageViewModel), from: self, transition: .modal(animated: true, completion: nil))
        }
    }
    
}
