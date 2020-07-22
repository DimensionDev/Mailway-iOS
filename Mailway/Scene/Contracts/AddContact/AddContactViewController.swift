//
//  AddContactViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-14.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit
import AVKit
import Combine
import CoreDataStack
import NtgeCore

final class AddContactViewModel: NSObject {
    
    override init() {
        super.init()
    }
    
}

extension AddContactViewModel {
    
    enum Section: CaseIterable {
        case banner
        case entry
    }
    
    enum Entry: CaseIterable {
        case scanQR
        case importFile
    }
    
}

// MARK: - UITableViewDataSource
extension AddContactViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section.allCases[section]
        
        switch section {
        case .banner:
            return 1
        case .entry:
            return Entry.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        let section = Section.allCases[indexPath.section]
        switch section {
        case .banner:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CreateContactBannerTableViewCell.self), for: indexPath) as! CreateContactBannerTableViewCell
            cell = _cell
            
        case .entry:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CreateContactEntryTableViewCell.self), for: indexPath) as! CreateContactEntryTableViewCell
            cell = _cell

            switch Entry.allCases[indexPath.row] {
            case .scanQR:
                _cell.iconImageView.image = Asset.Objects.qrcodeViewfinder.image.withRenderingMode(.alwaysTemplate)
                _cell.entryLabel.text = L10n.CreateContact.scanQrCode
            case .importFile:
                _cell.iconImageView.image = Asset.Objects.folder.image.withRenderingMode(.alwaysTemplate)
                _cell.entryLabel.text = L10n.CreateContact.importFile
            }
        }
        
        return cell
    }
    
}

final class AddContactViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    let viewModel = AddContactViewModel()
    
    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = Asset.NavigationBar.close.image
        item.tintColor = .label
        item.target = self
        item.action = #selector(AddContactViewController.closeBarButtonItemPressed(_:))
        return item
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CreateContactBannerTableViewCell.self, forCellReuseIdentifier: String(describing: CreateContactBannerTableViewCell.self))
        tableView.register(CreateContactEntryTableViewCell.self, forCellReuseIdentifier: String(describing: CreateContactEntryTableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        return tableView
    }()
        
    lazy var documentPickerViewController: UIDocumentPickerViewController = {
        let picker = UIDocumentPickerViewController(documentTypes: ["im.dimension.Mailway.Bizcard"], in: .open)
        picker.delegate = self
        picker.modalPresentationStyle = .currentContext
        return picker
    }()
    
}

extension AddContactViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Contact"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = closeBarButtonItem
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        tableView.delegate = self
        tableView.dataSource = viewModel
    }
    
}

extension AddContactViewController {
    
    @objc private func closeBarButtonItemPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension AddContactViewController {
    private func parseAndSaveBizcard(from serialized: String) {
        do {
            guard let card = try Bizcard.deserialize(text: serialized).first else {
                throw Error.notBizcard
            }
            
            // check duplicate
            let request = Contact.sortedFetchRequest
            request.predicate = Contact.predicate(publicKey: card.info.publicKeyArmor)
            request.fetchLimit = 1
            do {
                let result = try context.managedObjectContext.fetch(request)
                guard result.isEmpty else {
                    throw Error.duplicateContact
                }
            } catch {
                let alertController = UIAlertController.standardAlert(of: error)
                present(alertController, animated: true, completion: nil)
                return
            }
            
            // get key ID
            guard let publicKey = Ed25519.PublicKey.deserialize(serialized: card.info.publicKeyArmor) else {
                let alertController = UIAlertController.standardAlert(of: Error.bizcardValidateFail)
                present(alertController, animated: true, completion: nil)
                return
            }
            let keyID = publicKey.keyID
            
            // validate
            let validateResult = card.validate()
            switch validateResult {
            case .success:
                let managedObjectContext = context.managedObjectContext
                var subscription: AnyCancellable?
                subscription = managedObjectContext.performChanges {
                    let businessCardProperty = BusinessCard.Property(businessCard: serialized)
                    let businessCard = BusinessCard.insert(into: managedObjectContext, property: businessCardProperty)
                    
                    let keypairProperty = Keypair.Property(privateKey: nil, publicKey: card.info.publicKeyArmor, keyID: keyID)
                    let keypair = Keypair.insert(into: managedObjectContext, property: keypairProperty)
                    
                    var channels: [ContactChannel] = []
                    let _channels = card.supplementation?.channels ?? card.info.channels ?? []
                    for _channel in _channels {
                        let property = ContactChannel.Property(name: .init(name: _channel.name), value: _channel.value)
                        let channel = ContactChannel.insert(into: managedObjectContext, property: property)
                        channels.append(channel)
                    }
                    
                    let contactProperty = Contact.Property(name: card.supplementation?.name ?? card.info.name, note: nil, avatar: nil, color: UIColor.pickPanelColors.randomElement()!)
                    Contact.insert(into: managedObjectContext, property: contactProperty, keypair: keypair, channels: channels, businessCard: businessCard)
                }
                .sink(receiveCompletion: { _ in
                    os_log("%{public}s[%{public}ld], %{public}s: complete subscription: %s", ((#file as NSString).lastPathComponent), #line, #function, subscription.debugDescription)
                    subscription = nil
                }, receiveValue: { [weak self] result in
                    switch result {
                    case .success:
                        self?.dismiss(animated: true, completion: nil)
                        
                    case .failure(let error):
                        let alertController = UIAlertController.standardAlert(of: error)
                        self?.present(alertController, animated: true, completion: nil)
                    }
                })
                
            case .failure:
                throw Error.bizcardValidateFail
            }
            
        } catch {
            os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, error.localizedDescription)
            let alertController = UIAlertController.standardAlert(of: error)
            present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDelegate
extension AddContactViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch AddContactViewModel.Section.allCases[indexPath.section] {
        case .entry:
            switch AddContactViewModel.Entry.allCases[indexPath.row] {
            case .scanQR:
                coordinator.present(scene: .bizcardScanner(delegate: self), from: self, transition: .modal(animated: true, completion: nil))
            case .importFile:
                present(documentPickerViewController, animated: true, completion: nil)
            }
        default:
            return
        }
    }
}

extension AddContactViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        
        do {
            guard url.startAccessingSecurityScopedResource() else {
                throw Error.internal
            }
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            // deserialize
            let serialized = try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines)
            parseAndSaveBizcard(from: serialized)

        } catch {
            os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, error.localizedDescription)
            let alertController = UIAlertController.standardAlert(of: error)
            present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - BizcardScannerViewControllerDelegate
extension AddContactViewController: BizcardScannerViewControllerDelegate {
    func bizcardScannerViewController(_ viewController: BizcardScannerViewController, didScanQRCode code: String) {
        parseAndSaveBizcard(from: code)
    }
}

extension AddContactViewController {
    enum Error: Swift.Error, LocalizedError {
        case `internal`
        case notBizcard
        case bizcardValidateFail
        case duplicateContact
        
        var errorDescription: String? {
            switch self {
            case .internal:
                return L10n.Error.InternalError.errorDescription
            case .notBizcard:
                return L10n.CreateContact.Error.NotBizcard.errorDescription
            case .bizcardValidateFail:
                return L10n.CreateContact.Error.BizcardValidateFail.errorDescription
            case .duplicateContact:
                return L10n.CreateContact.Error.DuplicateContact.errorDescription
            }
        }
        
        var failureReason: String? {
            switch self {
            case .internal:
                return L10n.Error.InternalError.failureReason
            case .notBizcard:
                return L10n.CreateContact.Error.NotBizcard.failureReason
            case .bizcardValidateFail:
                return L10n.CreateContact.Error.BizcardValidateFail.failureReason
            case .duplicateContact:
                return L10n.CreateContact.Error.DuplicateContact.failureReason
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .internal:
                return L10n.Error.InternalError.recoverySuggestion
            case .notBizcard:
                return L10n.CreateContact.Error.NotBizcard.recoverySuggestion
            case .bizcardValidateFail:
                return L10n.CreateContact.Error.BizcardValidateFail.recoverySuggestion
            case .duplicateContact:
                return L10n.CreateContact.Error.DuplicateContact.recoverySuggestion
            }
        }
    }
}
