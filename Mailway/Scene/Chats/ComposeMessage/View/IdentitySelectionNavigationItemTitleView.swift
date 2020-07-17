//
//  IdentitySelectionNavigationItemTitleView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-17.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
import CoreData
import CoreDataStack

final class IdentitySelectionNavigationItemTitleViewModel: NSObject {
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
    }
}

extension IdentitySelectionNavigationItemTitleViewModel {
    enum Section: CaseIterable {
        case identities
    }
}

extension IdentitySelectionNavigationItemTitleViewModel {

    static func configure(cell: IdentitySelectionEntryTableViewCell, with identity: Contact) {
        cell.entryView.avatarImageView.image = identity.avatar ?? UIImage.placeholder(color: .systemFill)
        // TODO: color bar
        cell.entryView.nameLabel.text = identity.name
        cell.entryView.shortKeyIDLabel.text = identity.keypair.flatMap { String($0.keyID.suffix(8)).separate(every: 4, with: " ") } ?? "-"
    }

}

// MARK: - NSFetchedResultsControllerDelegate
extension IdentitySelectionNavigationItemTitleViewModel: NSFetchedResultsControllerDelegate {

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
            guard let cell = tableView?.cellForRow(at: indexPath) as? IdentitySelectionEntryTableViewCell else {
                assertionFailure()
                return
            }
            IdentitySelectionNavigationItemTitleViewModel.configure(cell: cell, with: identity)

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
extension IdentitySelectionNavigationItemTitleViewModel: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section.allCases[section]
        switch section {
        case .identities:
            return fetchedResultsController.sections?.first?.numberOfObjects != 0 ? 1 : 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section.allCases[indexPath.section]
        var cell: UITableViewCell

        switch section {
        case .identities:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: IdentitySelectionEntryTableViewCell.self), for: indexPath) as! IdentitySelectionEntryTableViewCell
            cell = _cell

            guard indexPath.row < fetchedResultsController.sections?[indexPath.section].numberOfObjects ?? 0 else { break }
            let identity = fetchedResultsController.object(at: indexPath)
            IdentitySelectionNavigationItemTitleViewModel.configure(cell: _cell, with: identity)
        }

        return cell
    }
}


final class IdentitySelectionNavigationItemTitleView: UIView {
    
    let entryView = IdentitySelectEntryView()

    // var viewModel: IdentitySelectionNavigationItemTitleViewModel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
}

extension IdentitySelectionNavigationItemTitleView {
    
    private func _init() {
        entryView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(entryView)
        NSLayoutConstraint.activate([
            entryView.topAnchor.constraint(equalTo: topAnchor),
            entryView.leadingAnchor.constraint(equalTo: leadingAnchor),
            entryView.trailingAnchor.constraint(equalTo: trailingAnchor),
            entryView.bottomAnchor.constraint(equalTo: bottomAnchor),
            entryView.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).priority(.defaultHigh),
        ])
    }
    
}
