//
//  IdentityCardCollectionViewModel.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-10.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import CoreData
import CoreDataStack

final class IdentityCardCollectionViewModel: NSObject {
    
    // input
    let context: AppContext
    let identityFetchedResultsController: NSFetchedResultsController<Contact>
    
    private(set) weak var collectionView: UICollectionView?
    private var dataSource: DataSource?
    
    init(context: AppContext) {
        self.context = context
        self.identityFetchedResultsController = {
            let fetchRequest = Contact.createdAtDescendingSortedFetchRequest
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
        
        identityFetchedResultsController.delegate = self
    }
    
}

extension IdentityCardCollectionViewModel {
    func setup(collectionView: UICollectionView) {
        self.collectionView = collectionView
        
        // setup data source
        if dataSource == nil {
            let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, identity -> UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: IdentityCardCollectionViewCell.self), for: indexPath) as! IdentityCardCollectionViewCell
                IdentityCardCollectionViewModel.configure(cell: cell, with: identity)
                return cell
            }
            self.dataSource = dataSource
            
            // fufill data
            do {
                try identityFetchedResultsController.performFetch()
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        collectionView.dataSource = dataSource
        collectionView.reloadData()
    }
}

extension IdentityCardCollectionViewModel {
    
    static func configure(cell: IdentityCardCollectionViewCell, with identity: Contact) {
        cell.identityCardView.nameLabel.text = identity.name
        cell.identityCardView.shortKeyIDLabel.text = identity.keypair.flatMap { keypair in
            return String(keypair.keyID.suffix(8)).separate(every: 4, with: " ")
        }
        // TODO: color
    }
    
}

extension IdentityCardCollectionViewModel {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Contact>
    enum Section {
        case identity
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension IdentityCardCollectionViewModel: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        var diffable = NSDiffableDataSourceSnapshot<Section, Contact>()
        diffable.appendSections([.identity])
        diffable.appendItems(identityFetchedResultsController.fetchedObjects ?? [], toSection: .identity)
        dataSource?.apply(diffable)
    }
    
}
