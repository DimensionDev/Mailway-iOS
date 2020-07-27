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
import Floaty

final class ContactListViewController: UIViewController, NeedsDependency, MainTabTransitionableViewController {

    private(set) var transitionController: MainTabTransitionController!

    var disposeBag = Set<AnyCancellable>()
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    private lazy var sidebarBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = Asset.Sidebar.menu.image
        item.target = self
        item.action = #selector(ContactListViewController.sidebarBarButtonItemPressed(_:))
        return item
    }()
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ContactListIdentityCardCollectionTableViewCell.self, forCellReuseIdentifier: String(describing: ContactListIdentityCardCollectionTableViewCell.self))
        tableView.register(ContactListContactTableViewCell.self, forCellReuseIdentifier: String(describing: ContactListContactTableViewCell.self))
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private lazy var floatyButton: Floaty = {
        let button = Floaty()
        button.plusColor = .white
        button.buttonColor = Asset.Color.Background.blue.color
        button.handleFirstItemDirectly = true
        
        let addContact: FloatyItem = {
            let item = FloatyItem()
            item.title = "Add Contact"
            item.handler = self.createContactFloatyItemPressed
            return item
        }()
        
        button.addItem(item: addContact)
        
        return button
    }()
    
    private(set) lazy var viewModel = ContactListViewModel(context: context)
    
}

extension ContactListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Contacts"
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
        
        view.addSubview(floatyButton)
        
        viewModel.tableView = tableView
        tableView.delegate = self
        do {
            try viewModel.contactFetchedResultsController.performFetch()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        tableView.dataSource = viewModel
        tableView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        defer {
            super.viewWillTransition(to: size, with: coordinator)
        }
        
        // center identity card after rotate
        guard let collectionView = viewModel.identityCardCollectionViewModel.collectionView else {
            return
        }
        
        let displayCenterOffsetX = collectionView.contentOffset.x + 0.5 * collectionView.bounds.width
        let displayCenterOffset = CGPoint(x: displayCenterOffsetX, y: 0.5 * collectionView.bounds.height)
        guard let currentIndexPath = collectionView.indexPathForItem(at: displayCenterOffset) else {
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: false)
        }, completion: nil)
    }
    
}

extension ContactListViewController {
    
    @objc private func sidebarBarButtonItemPressed(_ sender: UIBarButtonItem) {
        coordinator.present(scene: .sidebar, from: self, transition: .custom(transitioningDelegate: transitionController))
    }
    
    @objc private func createContactFloatyItemPressed(_ sender: FloatyItem) {
        coordinator.present(scene: .addContact, from: self, transition: .modal(animated: true, completion: nil))
    }
    
}

// MARK: - UITableViewDelegate
extension ContactListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Set collection and flow layout delegate
        if let cell = cell as? ContactListIdentityCardCollectionTableViewCell {
            cell.collectionView.delegate = self
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if tableView.cellForRow(at: indexPath) is ContactListContactTableViewCell {
            let identitySectionRange = 0..<viewModel.identitySectionCount
            let contactsSectionRange = identitySectionRange.upperBound..<identitySectionRange.upperBound + viewModel.contactsSectionCount
            
            let resultIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - contactsSectionRange.lowerBound)
            let contact = viewModel.contactFetchedResultsController.object(at: resultIndexPath)
            let contactDetailViewModel = ContactDetailViewModel(context: context, contact: contact)
            coordinator.present(scene: .contactDetail(viewModel: contactDetailViewModel), from: self, transition: .showDetail)
        }
    }
    
    /*
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let identitySectionRange = 0..<viewModel.identitySectionCount
        let contactsSectionRange = identitySectionRange.upperBound..<identitySectionRange.upperBound + viewModel.contactsSectionCount
        
        switch section {
        case contactsSectionRange:      return UITableView.automaticDimension
        default:                        return CGFloat.leastNonzeroMagnitude
        }
    }
     */
    
    /*
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
            let contact = viewModel.contactFetchedResultsController.object(at: indexPath)
            let firstInitial = contact.nameFirstInitial
            titleLabel.text = firstInitial
                
            return container
            
        default:
            return UIView()
        }
    }
     */
}

// MARK: - UICollectionViewDelegate
extension ContactListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // print(indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let identityFetchedResultsController = viewModel.identityCardCollectionViewModel.identityFetchedResultsController
        guard indexPath.section < identityFetchedResultsController.sections?.count ?? 0,
        indexPath.item < identityFetchedResultsController.sections?[indexPath.section].numberOfObjects ?? 0 else {
            return
        }
        let identity = identityFetchedResultsController.object(at: indexPath)
        let identityDetailViewModel = IdentityDetailViewModel(context: context, identity: identity)
        coordinator.present(scene: .identityDetail(viewModel: identityDetailViewModel), from: self, transition: .showDetail)
    }
}

// MAKR: - UICollectionViewDelegateFlowLayout
extension ContactListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = max(0, collectionView.frame.size.width - 2 * (ContactListIdentityCardCollectionTableViewCell.itemSpacing + ContactListIdentityCardCollectionTableViewCell.itemPeeking))
        return CGSize(width: itemWidth, height: ContactListIdentityCardCollectionTableViewCell.itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let margin = ContactListIdentityCardCollectionTableViewCell.itemSpacing + ContactListIdentityCardCollectionTableViewCell.itemPeeking
        return UIEdgeInsets(top: ContactListIdentityCardCollectionTableViewCell.itemTopPadding, left: margin, bottom: ContactListIdentityCardCollectionTableViewCell.itemBottomPadding, right: margin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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
