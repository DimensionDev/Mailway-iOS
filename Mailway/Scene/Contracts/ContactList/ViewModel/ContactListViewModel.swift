//
//  ContactListViewModel.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-10.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import Combine
import CoreData
import CoreDataStack

final class ContactListViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    // input
    let context: AppContext
    weak var tableView: UITableView?
    let contactFetchedResultsController: NSFetchedResultsController<Contact>
    
    let identityCardCollectionViewModel: IdentityCardCollectionViewModel
    
    // output
    let pushIdentityListPublisher = PassthroughSubject<Void, Never>()
    
    init(context: AppContext) {
        self.context = context
        self.contactFetchedResultsController = {
            let fetchRequest = Contact.sortedFetchRequest
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.fetchBatchSize = 20
            // fetchRequest.predicate = Contact.notIdentityPredicate
            let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: context.managedObjectContext,
                sectionNameKeyPath: nil,
                // sectionNameKeyPath: #keyPath(Contact.nameFirstInitial),
                cacheName: nil
            )
            
            return controller
        }()
        self.identityCardCollectionViewModel = IdentityCardCollectionViewModel(context: context)
        super.init()
        
        contactFetchedResultsController.delegate = self
    }
    
}

extension ContactListViewModel {
    enum Section: CaseIterable {
        case identity
        case contacts
    }
}

extension ContactListViewModel {
    
    static func configure(cell: ContactListContactTableViewCell, with contact: Contact) {
        cell.nameLabel.text = contact.name
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension ContactListViewModel: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let identitySectionRange = 0..<identitySectionCount
        let contactsSectionRange = identitySectionRange.upperBound..<identitySectionRange.upperBound+contactsSectionCount
        
        switch type {
        case .insert:
            tableView?.insertSections(IndexSet(integer: contactsSectionRange.lowerBound + sectionIndex), with: .fade)
        case .update:
            break
        case .move:
            break
        case .delete:
            tableView?.deleteSections(IndexSet(integer: contactsSectionRange.lowerBound + sectionIndex), with: .fade)
        @unknown default:
            assertionFailure()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let identitySectionRange = 0..<identitySectionCount
        let contactsSectionRange = identitySectionRange.upperBound..<identitySectionRange.upperBound+contactsSectionCount
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { fatalError("Index Path should be not nil") }
            let resultIndexPath = IndexPath(row: newIndexPath.row, section: contactsSectionRange.lowerBound + newIndexPath.section)
            
            tableView?.insertRows(at: [resultIndexPath], with: .fade)
            
        case .update:
            guard let indexPath = indexPath else {
                fatalError("Index Path should be not nil")
            }
            let resultIndexPath = IndexPath(row: indexPath.row, section: contactsSectionRange.lowerBound + indexPath.section)
            let contact = contactFetchedResultsController.object(at: indexPath)
            guard let cell = tableView?.cellForRow(at: resultIndexPath) as? ContactListContactTableViewCell else {
                return
            }
            ContactListViewModel.configure(cell: cell, with: contact)
            
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            let resultIndexPath = IndexPath(row: indexPath.row, section: contactsSectionRange.lowerBound + indexPath.section)
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            let newResultIndexPath = IndexPath(row: newIndexPath.row, section: contactsSectionRange.lowerBound + newIndexPath.section)
            
            tableView?.deleteRows(at: [resultIndexPath], with: .fade)
            tableView?.insertRows(at: [newResultIndexPath], with: .fade)
            
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            let resultIndexPath = IndexPath(row: indexPath.row, section: contactsSectionRange.lowerBound + indexPath.section)
            
            tableView?.deleteRows(at: [resultIndexPath], with: .fade)
            
        @unknown default:
            assertionFailure()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
    
}

// MARK: - UITableViewDataSource
extension ContactListViewModel: UITableViewDataSource {
    
    var identitySectionCount: Int {
        return 1
    }
    
    var contactsSectionCount: Int {
        return contactFetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.reduce(0) { (result, section) -> Int in
            switch section {
            case .identity:
                return result + identitySectionCount
            case .contacts:
                return result + contactsSectionCount
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let identitySectionRange = 0..<identitySectionCount
        let contactsSectionRange = identitySectionRange.upperBound..<identitySectionRange.upperBound+contactsSectionCount
        
        switch section {
        case identitySectionRange:
            return 1
        case contactsSectionRange:
            let resultSection = section - identitySectionRange.upperBound
            guard let sectionInfo = contactFetchedResultsController.sections?[resultSection] else {
                return 0
            }
            return sectionInfo.numberOfObjects
        default:
            assertionFailure()
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identitySectionRange = 0..<identitySectionCount
        let contactsSectionRange = identitySectionRange.upperBound..<identitySectionRange.upperBound+contactsSectionCount
        
        var cell: UITableViewCell
        
        switch indexPath.section {
        case identitySectionRange:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ContactListIdentityCardCollectionTableViewCell.self), for: indexPath) as! ContactListIdentityCardCollectionTableViewCell
            cell = _cell
            
            identityCardCollectionViewModel.setup(collectionView: _cell.collectionView)
            
        case contactsSectionRange:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ContactListContactTableViewCell.self), for: indexPath) as! ContactListContactTableViewCell
            cell = _cell
            
            let resultSection = indexPath.section - identitySectionRange.upperBound
            let resultIndexPath = IndexPath(row: indexPath.row, section: resultSection)
            let contact = contactFetchedResultsController.object(at: resultIndexPath)
            
            ContactListViewModel.configure(cell: _cell, with: contact)
            
        default:
            fatalError()
        }
        
        return cell
    }
    
}
