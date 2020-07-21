//
//  SelectIdentityDropdownMenuViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import Combine
import CoreDataStack

protocol SelectIdentityDropdownMenuViewControllerDelegate: class {
    func selectIdentityDropdownMenuViewController(_ controller: SelectIdentityDropdownMenuViewController, didSelectIdentity identity: Contact)
}

final class SelectIdentityDropdownMenuViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    // input
    let context: AppContext
    let identities: [Contact]
    let selectIndex: Int
    let cellEntryViewHeight = CurrentValueSubject<CGFloat, Never>(44.0)
    let cellContentInset = CurrentValueSubject<UIEdgeInsets, Never>(UIEdgeInsets())
    
    // output
    let selectedIdentity: Contact
    let reorderedIdentities: [Contact]
    
    init(context: AppContext, identities: [Contact], selectIndex: Int) {
        self.context = context
        self.identities = identities
        self.selectIndex = selectIndex
        self.selectedIdentity = identities[selectIndex]
        self.reorderedIdentities = {
            var remains = identities
            let dropped = remains.remove(at: selectIndex)
            return [dropped] + remains
        }()
        super.init()
        
    }
    
}

extension SelectIdentityDropdownMenuViewModel {
    static func configure(cell: IdentitySelectionEntryTableViewCell, identity: Contact) {
        cell.entryView.avatarViewModel.infos = [AvatarViewModel.Info(name: identity.name, image: identity.avatar)]
        cell.entryView.nameLabel.text = identity.name
        cell.entryView.shortKeyIDLabel.text = identity.keypair.flatMap { String($0.keyID.suffix(8)).separate(every: 4, with: " ") } ?? "-"
    }
}

// MARK: - UITableViewDataSource
extension SelectIdentityDropdownMenuViewModel: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reorderedIdentities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: IdentitySelectionEntryTableViewCell.self), for: indexPath) as! IdentitySelectionEntryTableViewCell
        let identity = reorderedIdentities[indexPath.row]
        
        cellEntryViewHeight
            .assign(to: \.constant, on: cell.entryViewHeightLayoutConstraint)
            .store(in: &cell.disposeBag)
        cellContentInset
            .assign(to: \.layoutMargins, on: cell.contentView)
            .store(in: &cell.disposeBag)
        
        SelectIdentityDropdownMenuViewModel.configure(cell: cell, identity: identity)
        
        let rowsCount = tableView.numberOfRows(inSection: indexPath.section)
        let isLast = indexPath.row == rowsCount - 1
        let isFirst = indexPath.row == 0
        
        switch (isFirst, isLast) {
        case (true, true):
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case (true, false):
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case (false, true):
            cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case (false, false):
            cell.contentView.layer.maskedCorners = []
        }
        
        cell.topShadowView.isHidden = !isFirst
        cell.bottomShadowView.isHidden = !isLast
        
        cell.entryView.disclosureButton.isHidden = !isFirst
        cell.entryView.disclosureButton.transform = CGAffineTransform(scaleX: 1, y: -1)     // upside down
                
        return cell
    }
    
}


final class SelectIdentityDropdownMenuViewController: UIViewController, NeedsDependency, SelectIdentityDropdownMenuTransitionableViewController {
    
    var disposeBag = Set<AnyCancellable>()
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var viewModel: SelectIdentityDropdownMenuViewModel!
    weak var delegate: SelectIdentityDropdownMenuViewControllerDelegate?
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(IdentitySelectionEntryTableViewCell.self, forCellReuseIdentifier: String(describing: IdentitySelectionEntryTableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.addTarget(self, action: #selector(SelectIdentityDropdownMenuViewController.tap(_:)))
        return tapGestureRecognizer
    }()
    
}

extension SelectIdentityDropdownMenuViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        view.layer.masksToBounds = true
        if view.traitCollection.userInterfaceIdiom == .phone {
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        view.layer.cornerRadius = 10
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        tableView.addGestureRecognizer(tapGestureRecognizer)
        tableView.delegate = self
        tableView.dataSource = viewModel
        
        // tableView.backgroundColor = .red
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // dimiss when size change
        dismiss(animated: true, completion: nil)
    }
    
}

extension SelectIdentityDropdownMenuViewController {

    @objc private func tap(_ sender: UITapGestureRecognizer) {
        guard sender === tapGestureRecognizer else { return }
        
        let location = sender.location(in: tableView)
        guard tableView.indexPathForRow(at: location) == nil else {
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDelegate
extension SelectIdentityDropdownMenuViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let identity = viewModel.reorderedIdentities[indexPath.row]
        delegate?.selectIdentityDropdownMenuViewController(self, didSelectIdentity: identity)
        
        dismiss(animated: true, completion: nil)
    }
    
}
