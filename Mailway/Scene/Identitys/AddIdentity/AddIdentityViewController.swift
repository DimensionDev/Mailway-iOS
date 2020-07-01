//
//  AddIdentityViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit
import SwiftUI
import Combine
import CoreDataStack
import NtgeCore

final class AddIdentityViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    let context: AppContext
    
    // output
    let isAddBarButtonItemEnabled = CurrentValueSubject<Bool, Never>(false)
    let insertedContact = PassthroughSubject<Contact, Never>()
    
    init(context: AppContext) {
        context.viewStateStore.addIdentityView = ViewState.AddIdentityView()    // reset state
        self.context = context
        
        super.init()
        
        context.viewStateStore.addIdentityView.namePublisher
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .assign(to: \.value, on: isAddBarButtonItemEnabled)
            .store(in: &disposeBag)
    }
    
    func createIdentity() -> Future<Result<Void, Swift.Error>, Never> {
        let viewState = context.viewStateStore.addIdentityView
        
        // 1. check name
        let name = viewState.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            return Future { $0(.success(Result.failure(Error.nameEmpty))) }
        }
        guard name.count <= 80 else {
            return Future { $0(.success(Result.failure(Error.nameTooLong))) }
        }
        
        // 2. check channel
        var orderedContactInfo: [ContactInfo] = []
        var validContactInfo: [ContactInfo] = []
        for infoType in ContactInfo.InfoType.allCases {
            orderedContactInfo.append(contentsOf: viewState.contactInfos[infoType] ?? [])
        }
        for info in orderedContactInfo {
            guard info.avaliable else { continue }      // skip removed info
            guard !info.isEmptyInfo else { continue }   // skip empty info
            if ContactInfo.InfoType.custom == info.type {
                let key = info.key.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !key.isEmpty else {
                    return Future { $0(.success(Result.failure(Error.channelKeyEmpty))) }
                }
                guard key.count <= 128 else {
                    return Future { $0(.success(Result.failure(Error.channelKeyTooLong))) }
                }
            }
            
            let value = info.value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !value.isEmpty else {
                return Future { $0(.success(Result.failure(Error.channelValueEmpty))) }
            }
            guard value.count <= 128 else {
                return Future { $0(.success(Result.failure(Error.channelValueTooLong))) }
            }
            
            validContactInfo.append(info)
        }

        // 3. check note
        // TODO:
        
        // 4. avatar
        // TODO:
        
        // prepare database stuff
        let contactProperty = Contact.Property(name: name,i18nNames: [:], note: nil, avatar: nil)
        
        let ed25519Keypair = Ed25519.Keypair()
        let privateKey = ed25519Keypair.privateKey
        let publicKey = ed25519Keypair.publicKey
        let keypairProperty = Keypair.Property(privateKey: privateKey.serialize(), publicKey: publicKey.serialize(), keyID: publicKey.keyID)
        
        let managedObjectContext = context.managedObjectContext
        return managedObjectContext.performChanges { [weak self] in
            let keypair = Keypair.insert(into: managedObjectContext, property: keypairProperty)
            let contact = Contact.insert(into: managedObjectContext, property: contactProperty, keypair: keypair, channels: [])
            
            self?.insertedContact.send(contact)
        }
    }

}

extension AddIdentityViewModel {
    
    enum Error: Swift.Error, LocalizedError {
        
        case nameEmpty
        case nameTooLong
        case channelKeyEmpty
        case channelKeyTooLong
        case channelValueEmpty
        case channelValueTooLong
        
        var errorDescription: String? {
            switch self {
            case .nameEmpty, .nameTooLong:
                return "Invalid Name Format"
            case .channelKeyEmpty, .channelKeyTooLong,
                 .channelValueEmpty, .channelValueTooLong:
                return "Invalid Contact Info Format"
            }
        }
        
        var failureReason: String? {
            switch self {
            case .nameEmpty:
                return "Name cannot be empty."
            case .nameTooLong:
                return "Name is too long."
            case .channelKeyEmpty:
                return "Custom network cannot be empty."
            case .channelKeyTooLong:
                return "Custom network is too long."
            case .channelValueEmpty:
                return "Custom ID cannot be empty."
            case .channelValueTooLong:
                return "Custom ID is too long."
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .nameEmpty:
                return "Please input name."
            case .nameTooLong:
                return "Please input name no more than 80 characters."
            case .channelKeyEmpty:
                return "Please input custom network."
            case .channelKeyTooLong:
                return "Please input custom network no more than 128 characters."
            case .channelValueEmpty:
                return "Please input custom ID."
            case .channelValueTooLong:
                return "Please input custom ID no more than 128 characters."
            }
        }
    }
    
}

final class AddIdentityViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    private(set) lazy var viewModel = AddIdentityViewModel(context: context)
    
    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = Asset.NavigationBar.close.image
        item.tintColor = Asset.Color.Tint.barButtonItem.color
        item.target = self
        item.action = #selector(AddIdentityViewController.closeBarButtonItemPressed(_:))
        return item
    }()
    
    private lazy var addBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.title = "Add".uppercased()
        let states: [UIControl.State] = [.normal, .highlighted, .focused, .selected, .disabled]
        for state in states {
            item.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .medium)], for: state)
        }
        item.target = self
        item.action = #selector(AddIdentityViewController.addBarButtonItemPressed(_:))
        return item
    }()
    
    let addIdentityView = AddIdentityView()
    
}

extension AddIdentityViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = closeBarButtonItem
        navigationItem.rightBarButtonItem = addBarButtonItem
        
        let hostingController = UIHostingController(rootView: addIdentityView.environmentObject(context))
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        viewModel.isAddBarButtonItemEnabled
            .assign(to: \.isEnabled, on: addBarButtonItem)
            .store(in: &disposeBag)
        
        viewModel.insertedContact
            .sink { [weak self] contact in
                os_log("%{public}s[%{public}ld], %{public}s: did insert contact %s", ((#file as NSString).lastPathComponent), #line, #function, contact.debugDescription)
                self?.dismiss(animated: true, completion: nil)
            }
            .store(in: &disposeBag)
    }
    
}

extension AddIdentityViewController {

    @objc private func closeBarButtonItemPressed(_ sender: UIBarButtonItem) {
        // TODO: discard alert
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func addBarButtonItemPressed(_ sender: UIBarButtonItem) {
        viewModel.createIdentity().sink { [weak self] result in
            switch result {
            case .success:
                // do nothing
                break
            case .failure(let error):
                let alertController = UIAlertController.standardAlert(of: error)
                self?.present(alertController, animated: true, completion: nil)
            }
        }
        .store(in: &disposeBag)
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension AddIdentityViewController: UIAdaptivePresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        if traitCollection.userInterfaceIdiom == .pad {
            return .formSheet
        } else {
            return .fullScreen
        }
    }
    
}
