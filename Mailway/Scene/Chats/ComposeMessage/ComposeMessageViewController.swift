//
//  ComposeMessageViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-6.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import Combine
import CoreData
import CoreDataStack
import NtgeCore

final class ComposeMessageViewModel: NSObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    let fetchedResultsController: NSFetchedResultsController<Contact>
    
    // input
    let context: AppContext
    let recipientPublicKeys: [Ed25519.PublicKey]
    let message = CurrentValueSubject<String, Never>("")
    
    // output
    let isComposeBarButtonEnabled = CurrentValueSubject<Bool, Never>(false)
    
    let selectedIdentityPrivateKey = CurrentValueSubject<Ed25519.PrivateKey?, Never>(nil)
    
    init(context: AppContext, recipientPublicKeys: [Ed25519.PublicKey]) {
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
        self.context = context
        self.recipientPublicKeys = recipientPublicKeys
        
        super.init()
        
        fetchedResultsController.delegate = self
        
        message
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .assign(to: \.value, on: isComposeBarButtonEnabled)
            .store(in: &disposeBag)
    }
    
}

extension ComposeMessageViewModel {
    
    func composeMessage() -> Future<Result<ChatMessage, Swift.Error>, Never> {
        guard let signer = selectedIdentityPrivateKey.value else {
            return Future { promise in
                promise(.success(.failure(Error.identityNotFound)))
            }
        }
        
        guard !recipientPublicKeys.isEmpty else {
            return Future { promise in
                promise(.success(.failure(Error.recipientNotFound)))
            }
        }
        
        let plaintext = message.value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !plaintext.isEmpty else {
            return Future { promise in
                promise(.success(.failure(Error.emptyMessage)))
            }
        }
        let plaintextData = Data(plaintext.utf8)
                
        return DocumentStore.createChatMessage(into: context.managedObjectContext, plaintextData: plaintextData, recipientPublicKeys: recipientPublicKeys, signerPrivateKey: signer)
    }
    
}

extension ComposeMessageViewModel {
    
    enum Error: Swift.Error, LocalizedError {
        case identityNotFound
        case recipientNotFound
        case emptyMessage
        
        var errorDescription: String? {
            switch self {
            case .identityNotFound:
                return L10n.ComposeMessage.Error.IdentityNotFound.errorDescription
            case .recipientNotFound:
                return L10n.ComposeMessage.Error.RecipientNotFound.errorDescription
            case .emptyMessage:
                return L10n.ComposeMessage.Error.EmptyMessage.errorDescription
            }
        }
        
        var failureReason: String? {
            switch self {
            case .identityNotFound:
                return L10n.ComposeMessage.Error.IdentityNotFound.failureReason
            case .recipientNotFound:
                return L10n.ComposeMessage.Error.RecipientNotFound.failureReason
            case .emptyMessage:
                return L10n.ComposeMessage.Error.EmptyMessage.failureReason
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .identityNotFound:
                return L10n.ComposeMessage.Error.IdentityNotFound.recoverySuggestion
            case .recipientNotFound:
                return L10n.ComposeMessage.Error.RecipientNotFound.recoverySuggestion
            case .emptyMessage:
                return L10n.ComposeMessage.Error.EmptyMessage.recoverySuggestion
            }
        }
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension ComposeMessageViewModel: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        // let snapshot = snapshot as NSDiffableDataSourceSnapshot<Contact, NSManagedObjectID>
        
        if selectedIdentityPrivateKey.value == nil {
            let identities = fetchedResultsController.sections?.first?.objects as? [Contact] ?? []
            selectedIdentityPrivateKey.value = identities.first.flatMap { identity in
                guard let privateKeyText = identity.keypair?.privateKey,
                    let privateKey = Ed25519.PrivateKey.deserialize(from: privateKeyText) else {
                        return nil
                }
                return privateKey
            }
        }
    }
    
}

final class ComposeMessageViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var viewModel: ComposeMessageViewModel!
    
    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = Asset.NavigationBar.close.image
        item.tintColor = Asset.Color.Tint.barButtonItem.color
        item.target = self
        item.action = #selector(ComposeMessageViewController.closeBarButtonItemPressed(_:))
        return item
    }()
    
    private lazy var composeBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = Asset.Communication.paperplane.image
        //item.tintColor = Asset.Color.Tint.barButtonItem.color
        item.target = self
        item.action = #selector(ComposeMessageViewController.composeBarButtonItemPressed(_:))
        return item
    }()
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 17)
        return textView
    }()
    
}

extension ComposeMessageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = closeBarButtonItem
        navigationItem.rightBarButtonItem = composeBarButtonItem
        
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageTextView)
        NSLayoutConstraint.activate([
            messageTextView.topAnchor.constraint(equalTo: view.topAnchor),
            messageTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        do {
            try viewModel.fetchedResultsController.performFetch()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        
        viewModel.isComposeBarButtonEnabled
            .assign(to: \.isEnabled, on: composeBarButtonItem)
            .store(in: &disposeBag)
        
        // handle keyboard overlap
        Publishers.CombineLatest3(
            KeyboardResponderService.shared.isShow.eraseToAnyPublisher(),
            KeyboardResponderService.shared.state.eraseToAnyPublisher(),
            KeyboardResponderService.shared.endFrame.eraseToAnyPublisher()
        )
        .sink(receiveValue: { isShow, state, endFrame in
            guard isShow, state == .dock else {
                self.messageTextView.contentInset.bottom = 0.0
                self.messageTextView.verticalScrollIndicatorInsets.bottom = 0.0
                return
            }
            
            // isShow AND dock state
            let textViewFrame = self.view.convert(self.messageTextView.frame, to: nil)
            let padding = textViewFrame.maxY - endFrame.minY
            guard padding > 0 else {
                self.messageTextView.contentInset.bottom = 0.0
                self.messageTextView.verticalScrollIndicatorInsets.bottom = 0.0
                return
            }
            
            self.messageTextView.contentInset.bottom = padding
            self.messageTextView.verticalScrollIndicatorInsets.bottom = padding
        })
        .store(in: &disposeBag)
        
        messageTextView.delegate = self
        messageTextView.becomeFirstResponder()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        messageTextView.contentInset.left = view.layoutMargins.left
        messageTextView.contentInset.right = view.layoutMargins.right
    }
    
}

extension ComposeMessageViewController {
    
    @objc private func closeBarButtonItemPressed(_ sender: UIBarButtonItem) {
        guard viewModel.message.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let alertController = UIAlertController(title: "Discard Compose", message: "Please confirm discard message composing.", preferredStyle: .alert)
            let discardAction = UIAlertAction(title: "Confirm Discard", style: .destructive) { _ in
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(discardAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func composeBarButtonItemPressed(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        viewModel.composeMessage()
            .sink(
                receiveCompletion: { _ in
                    sender.isEnabled = true
                }, receiveValue: { [weak self] result in
                    switch result {
                    case .success(let chatMessage):
                        self?.dismiss(animated: true) {
                            // TODO: open chat
                        }
                    case .failure(let error):
                        let alertController = UIAlertController.standardAlert(of: error)
                        self?.present(alertController, animated: true, completion: nil)
                    }
                }
            )
            .store(in: &disposeBag)
    }
    
}

// MARK: - UITextViewDelegate
extension ComposeMessageViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView === messageTextView else {
            return
        }
        
        viewModel.message.value = textView.text ?? ""
    }
    
}
