//
//  ContactListViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-22.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI
import Combine
import CoreDataStack

final class ContactListViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    let fetchedResultsController: NSFetchedResultsController<Contact>
    
    // input
    let context: AppContext
    weak var tableView: UITableView?
//    let identities = CurrentValueSubject<[Contact], Never>([])
//    let contacts = CurrentValueSubject<[Contact], Never>([])
    
    // output
    let pushIdentityListPublisher = PassthroughSubject<Void, Never>()
    
    init(context: AppContext) {
        self.fetchedResultsController = {
            let fetchRequest = Contact.sortedFetchRequest
            fetchRequest.returnsObjectsAsFaults = false
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
        
//        context.documentStore.$contacts
//            .map { $0.filter { $0.isIdentity }}
//            .assign(to: \.value, on: self.identities)
//            .store(in: &disposeBag)
//
//        context.documentStore.$contacts
//            .map { $0.filter { !$0.isIdentity }}
//            .assign(to: \.value, on: self.contacts)
//            .store(in: &disposeBag)
    }
    
}

extension ContactListViewModel {
    enum Section: CaseIterable {
        case identity
        case contacts
    }
}

extension ContactListViewModel {
    
//    static func configure(cell: ContactListIdentityBannerTableViewCell, with identities: [Contact]) {
//        if identities.count == 0 {
//            cell.bannerView.personIconImageView.image = UIImage(systemName: "person.crop.circle.fill.badge.plus")
//            cell.bannerView.headerLabel.text = "No Identity"
//            cell.bannerView.captionLabel.text = "Tap to add identity"
//        } else if identities.count == 1 {
//            cell.bannerView.personIconImageView.image = UIImage(systemName: "person.crop.square.fill")
//            cell.bannerView.headerLabel.text = "My Identity"
//            cell.bannerView.captionLabel.text = "1 identity"
//        } else {
//            cell.bannerView.personIconImageView.image = UIImage(systemName: "rectangle.stack.person.crop.fill")
//            cell.bannerView.headerLabel.text = "My Identity"
//            cell.bannerView.captionLabel.text = "\(identities.count) identities"
//        }
//    }
    
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
            let contact = fetchedResultsController.object(at: indexPath)
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
        return fetchedResultsController.sections?.count ?? 0
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
            guard let sectionInfo = fetchedResultsController.sections?[resultSection] else {
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
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ContactListIdentityBannerTableViewCell.self), for: indexPath) as! ContactListIdentityBannerTableViewCell
            cell = _cell
            
            // TODO:

        case contactsSectionRange:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ContactListContactTableViewCell.self), for: indexPath) as! ContactListContactTableViewCell
            cell = _cell
            
            let resultSection = indexPath.section - identitySectionRange.upperBound
            let resultIndexPath = IndexPath(row: indexPath.row, section: resultSection)
            let contact = fetchedResultsController.object(at: resultIndexPath)
            
            ContactListViewModel.configure(cell: _cell, with: contact)
            
        default:
            fatalError()
        }
        
        return cell
    }
    
    
    
}

final class ContactListViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
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
        
        viewModel.tableView = tableView
        tableView.delegate = self
        try! viewModel.fetchedResultsController.performFetch()
        tableView.dataSource = viewModel
        tableView.reloadData()
        
//        Publishers.CombineLatest(viewModel.identities, viewModel.contacts)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _, _ in
//                self?.tableView.reloadData()
//            }
//            .store(in: &disposeBag)
    }
    
}

// MARK: - UITableViewDelegate
extension ContactListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if tableView.cellForRow(at: indexPath) is ContactListIdentityBannerTableViewCell {
//            if viewModel.identities.value.isEmpty {
                // create identity
                coordinator.present(scene: .createIdentity, from: self, transition: .modal(animated: true))
//            } else {
//                // open list
//                coordinator.present(scene: .identityList, from: self, transition: .show)
//            }
        }
        
        if tableView.cellForRow(at: indexPath) is ContactListContactTableViewCell {
            let identitySectionRange = 0..<viewModel.identitySectionCount
            let contactsSectionRange = identitySectionRange.upperBound..<identitySectionRange.upperBound + viewModel.contactsSectionCount
            
            let resultIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - contactsSectionRange.lowerBound)
            let contact = viewModel.fetchedResultsController.object(at: resultIndexPath)
            let contactDetailViewModel = ContactDetailViewModel(contact: contact)
            coordinator.present(scene: .contactDetail(viewModel: contactDetailViewModel), from: self, transition: .showDetail)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let identitySectionRange = 0..<viewModel.identitySectionCount
        let contactsSectionRange = identitySectionRange.upperBound..<identitySectionRange.upperBound + viewModel.contactsSectionCount
        
        switch section {
        case contactsSectionRange:      return UITableView.automaticDimension
        default:                        return CGFloat.leastNonzeroMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identitySectionRange = 0..<viewModel.identitySectionCount
        let contactsSectionRange = identitySectionRange.upperBound..<identitySectionRange.upperBound + viewModel.contactsSectionCount
        
        switch section {
        case contactsSectionRange:
            let container = UIView()
            container.preservesSuperviewLayoutMargins = true
            
            let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false
            
            let titleLabel: UILabel = {
                let label = UILabel()
                label.font = .systemFont(ofSize: 17, weight: .semibold)
                label.textColor = .label
                return label
            }()
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            visualEffectView.contentView.addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: visualEffectView.topAnchor, constant: 4),
                titleLabel.leadingAnchor.constraint(equalTo: visualEffectView.readableContentGuide.leadingAnchor),
                visualEffectView.readableContentGuide.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                visualEffectView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            ])
            
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false
            visualEffectView.preservesSuperviewLayoutMargins = true
            container.addSubview(visualEffectView)
            NSLayoutConstraint.activate([
                visualEffectView.topAnchor.constraint(equalTo: container.topAnchor),
                visualEffectView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
                container.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor),
            ])
            
            // configure title label
            let indexPath = IndexPath(row: 0, section: section - contactsSectionRange.lowerBound)
            let contact = viewModel.fetchedResultsController.object(at: indexPath)
            let firstInitial = contact.nameFirstInitial
            titleLabel.text = firstInitial
                
            return container
            
        default:
            return UIView()
        }
    }
    
}

#if DEBUG
struct ContactListViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            let viewController = ContactListViewController()
            viewController.context = AppContext.shared
            return viewController
        }
    }
}
#endif
