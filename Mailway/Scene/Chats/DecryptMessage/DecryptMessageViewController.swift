//
//  DecryptMessageViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-15.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit
import Combine
import CoreData
import CoreDataStack
import NtgeCore
import UITextView_Placeholder

final class DecryptMessageViewModel {
    
    var disposeBag = Set<AnyCancellable>()
    
    // input
    let context: AppContext
    let identities: [Contact]
    let input = CurrentValueSubject<String, Never>("")
    let saveTriggerPublisher = PassthroughSubject<Contact, Never>()
    
    // output
    let decryptStatus = CurrentValueSubject<DecryptStatus, Never>(.empty)
    var savePrelude: SavePrelude?
    let isDecryptSuccess = CurrentValueSubject<Bool, Never>(false)
    let isSaving = CurrentValueSubject<Bool, Never>(false)
    let isDoneBarButtonItemEnabled = CurrentValueSubject<Bool, Never>(false)
    let saveChatMessageResult = PassthroughSubject<Result<ChatMessage, Swift.Error>, Never>()
    
    init(context: AppContext) {
        self.context = context
        let request = Contact.sortedFetchRequest
        request.predicate = Contact.isIdentityPredicate
        self.identities = {
            do {
                let identities = try context.managedObjectContext.fetch(request)
                return identities
            } catch {
                assertionFailure(error.localizedDescription)
                return []
            }
        }()
        
        // setup combine
        input
            .removeDuplicates()
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.decryptStatus.value = .decrypting
            })
            .map { DecryptMessageViewModel.decrypt(armoredMessage: $0, identities: self.identities) }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .assign(to: \.value, on: decryptStatus)
            .store(in: &disposeBag)
        
        saveTriggerPublisher
            .throttle(for: .milliseconds(300), scheduler: DispatchQueue.main, latest: false)
            .filter { _ in !self.isSaving.value }
            .handleEvents(receiveOutput: { _ in
                self.isSaving.value = true
            })
            .map { identity in self.saveMessage(identity: identity) }
            .switchToLatest()
            .subscribe(saveChatMessageResult)
            .store(in: &disposeBag)
        
        saveChatMessageResult
            .handleEvents(receiveOutput: { _ in
                self.isSaving.value = false
            })
            .sink(receiveValue: { _ in
                // do nothing
            })
            .store(in: &disposeBag)
        
        decryptStatus
            .map { status in
                guard case DecryptStatus.decryptSuccess = status else { return false }
                return true
            }
            .assign(to: \.value, on: isDecryptSuccess)
            .store(in: &disposeBag)
        
        Publishers.CombineLatest(isDecryptSuccess.eraseToAnyPublisher(), isSaving.eraseToAnyPublisher())
            .map { $0 && !$1 }
            .assign(to: \.value, on: isDoneBarButtonItemEnabled)
            .store(in: &disposeBag)
    }
    
}

extension DecryptMessageViewModel {
    enum DecryptStatus {
        case empty
        case decrypting
        case decryptFail(Swift.Error)
        case decryptSuccess(DecryptResult)
    }
    
    enum Error: Swift.Error, LocalizedError {
        case invalidMessage
        case keyNotFound
        case payloadDecryptFail
        case signatureVerificationFail
        case decryptResultNotFound
        
        var errorDescription: String? {
            switch self {
            case .invalidMessage:
                return "Invalid Message"
            case .keyNotFound:
                return "Key Not Found"
            case .payloadDecryptFail:
                return "Decrypt Fail"
            case .signatureVerificationFail:
                return "Decrypt Fail"
            case .decryptResultNotFound:
                return "Decrypt Fail"
            }
        }
        
        var failureReason: String? {
            switch self {
            case .invalidMessage:
                return "Not valid message armor."
            case .keyNotFound:
                return "Decrypt key not found."
            case .payloadDecryptFail:
                return "Internal error when derypting."
            case .signatureVerificationFail:
                return "Cannot verify message signature."
            case .decryptResultNotFound:
                return "Decrypt result not found."
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .invalidMessage:
                return "Please input valid message armor."
            case .keyNotFound:
                return "Please check the app contains message recipients' identity."
            case .payloadDecryptFail:
                return "Please try again."
            case .signatureVerificationFail:
                return "Please try again."
            case .decryptResultNotFound:
                return "Please save result until decrypt success."
            }
        }
    }
    
    struct DecryptResult {
        let armoredMessage: String
        let messageTimestamp: Date?
        let privateKeys: [Ed25519.PrivateKey?]
        let fileKeys: [X25519.FileKey?]
        let payload: Data
        let extra: CryptoService.Extra
    }
    
    struct SavePrelude {
        let existMessages: [ChatMessage]
        let decryptableIdentities: [Contact]
    }
}

extension DecryptMessageViewModel {
    
    static func decrypt(armoredMessage: String, identities: [Contact]) -> Future<DecryptStatus, Never> {
        let privateKeys: [Ed25519.PrivateKey?] = identities
            .map { $0.keypair?.privateKey }
            .map { privateKey in
                guard let privateKey = privateKey else {
                    return nil
                }
                
                return Ed25519.PrivateKey.deserialize(from: privateKey)
            }
        var fileKeys: [X25519.FileKey?] = []
        
        return Future { promise in
            DispatchQueue.global().async {
                guard let message = Message.deserialize(from: armoredMessage.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                    DispatchQueue.main.async {
                        promise(.success(DecryptStatus.decryptFail(Error.invalidMessage)))
                    }
                    return
                }
                
                let decryptor = Message.Decryptor(message: message)
                
                for privateKey in privateKeys {
                    guard let privateKey = privateKey else {
                        fileKeys.append(nil)
                        continue
                    }
                    
                    guard let fileKey = decryptor.decryptFileKey(privateKey: privateKey.x25519) else {
                        fileKeys.append(nil)
                        continue
                    }
                    
                    fileKeys.append(fileKey)
                }
                
                guard !fileKeys.isEmpty, let fileKey = fileKeys.compactMap({ $0 }).first else {
                    DispatchQueue.main.async {
                        promise(.success(DecryptStatus.decryptFail(Error.keyNotFound)))
                    }
                    return
                }
                
                guard decryptor.verifyMessageMac(fileKey: fileKey) else {
                    DispatchQueue.main.async {
                        promise(.success(DecryptStatus.decryptFail(Error.signatureVerificationFail)))
                    }
                    return
                }
                
                guard let payloadData = decryptor.decryptPayload(fileKey: fileKey),
                let extraData = decryptor.decryptExtra(fileKey: fileKey) else {
                    DispatchQueue.main.async {
                        promise(.success(DecryptStatus.decryptFail(Error.payloadDecryptFail)))
                    }
                    return
                }
                
                let extra: CryptoService.Extra
                do {
                    extra = try CryptoService.parse(extra: extraData)
                } catch let error {
                    DispatchQueue.main.async {
                        promise(.success(DecryptStatus.decryptFail(error)))
                    }
                    return
                }
                
                let result = DecryptResult(
                    armoredMessage: armoredMessage,
                    messageTimestamp: message.timestamp,
                    privateKeys: privateKeys,
                    fileKeys: fileKeys,
                    payload: payloadData,
                    extra: extra
                )
                DispatchQueue.main.async {
                    promise(.success(DecryptStatus.decryptSuccess(result)))
                }
            }   // end DispatchQueue.global()…
        }   // end Future
    }
    
    func saveMessagePrelude() -> Future<Result<SavePrelude, Swift.Error>, Never> {
        guard case let DecryptStatus.decryptSuccess(result) = decryptStatus.value else {
            return Future { promise in
                promise(.success(Result.failure(Error.decryptResultNotFound)))
            }
        }
        
        return Future { promise in
            // TODO: background fetch
            let managedObjectContext = self.context.managedObjectContext
            
            let request = ChatMessage.sortedFetchRequest
            request.predicate = ChatMessage.predicate(messageID: result.extra.messageID)
            
            let existMessages: [ChatMessage]
            do {
                existMessages = try managedObjectContext.fetch(request)
            } catch {
                existMessages = []
                assertionFailure(error.localizedDescription)
            }
            
            let decryptablePrivateKeys: [String] = zip(result.privateKeys, result.fileKeys).compactMap { privateKey, fileKey in
                guard let privateKey = privateKey, fileKey != nil else {
                    return nil
                }
                
                return privateKey.serialize()
            }
            let decryptableIdentities = self.identities.filter { identity in
                decryptablePrivateKeys.contains(where: { identity.keypair?.privateKey == $0 })
            }
            
            let savePrelude = SavePrelude(existMessages: existMessages, decryptableIdentities: decryptableIdentities)
            promise(.success(Result.success(savePrelude)))
        }
    }
    
    private func saveMessage(identity: Contact) -> Future<Result<ChatMessage, Swift.Error>, Never> {
        guard case let DecryptStatus.decryptSuccess(result) = decryptStatus.value else {
            return Future { promise in
                promise(.success(Result.failure(Error.decryptResultNotFound)))
            }
        }
        
        guard let identityPrivateKeyText = identity.keypair?.privateKey, let identityPrivateKey = Ed25519.PrivateKey.deserialize(from: identityPrivateKeyText) else {
            return Future { promise in
                promise(.success(Result.failure(Error.decryptResultNotFound)))
            }
        }
        
        let chatMessageProperty = ChatMessage.Property(
            messageID: result.extra.messageID,
            senderPublicKey: result.extra.senderKey,
            recipientPublicKeys: result.extra.recipientKeys,
            version: result.extra.version,
            armoredMessage: result.armoredMessage,
            payload: result.payload,
            payloadKind: ChatMessage.PayloadKind(rawValue: result.extra.payloadKind.rawValue) ?? .unknown,
            isDraft: false,
            messageTimestamp: result.messageTimestamp,
            composeTimestamp: nil,
            receiveTimestamp: Date(),
            shareTimestamp: nil
        )
        
        return DocumentStore.saveChatMessageAndCreateChat(into: context.managedObjectContext, chatMessageProperty: chatMessageProperty, identityPrivateKey: identityPrivateKey)
    }
    
}

final class DecryptMessageViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    private(set) lazy var viewModel = DecryptMessageViewModel(context: context)

    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = Asset.NavigationBar.close.image
        item.tintColor = Asset.Color.Tint.barButtonItem.color
        item.target = self
        item.action = #selector(DecryptMessageViewController.closeBarButtonPressed(_:))
        return item
    }()
    
    lazy var doneBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = Asset.NavigationBar.done.image
        // item.tintColor = Asset.Color.Tint.barButtonItem.color
        item.target = self
        item.action = #selector(DecryptMessageViewController.doneBarButtonPressed(_:))
        return item
    }()
    
    let decryptResultTextView: UITextView = {
        let textView = UITextView()
        textView.placeholder = L10n.DecryptMessage.decryptResultPlaceholder
        textView.font = .systemFont(ofSize: 17)
        textView.keyboardDismissMode = .interactive
        textView.showsVerticalScrollIndicator = false
        textView.isEditable = false
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    let leadingSeparatorLine = UIView.separatorLine
    let trailingSeparatorLine = UIView.separatorLine

    let arrowUpIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Asset.Arrows.arrowUp2.image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .secondaryLabel
        return imageView
    }()
    
    let inputTextView: UITextView = {
        let textView = UITextView()
        textView.placeholder = L10n.DecryptMessage.inputPlaceholder
        textView.font = .monospacedSystemFont(ofSize: 17, weight: .regular)
        textView.keyboardDismissMode = .interactive
        textView.showsVerticalScrollIndicator = false
        textView.textContainer.lineBreakMode = .byCharWrapping
        return textView
    }()
        
    let selectFileButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 10)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 32 * 0.5
        button.setBackgroundImage(UIImage.placeholder(color: .secondarySystemBackground), for: .normal)
        button.setImage(Asset.Editing.plusCircle.image, for: .normal)
        button.setTitle(" " + L10n.DecryptMessage.decryptFileButton, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(UIColor.label.withAlphaComponent(0.8), for: .highlighted)
        button.addTarget(self, action: #selector(DecryptMessageViewController.selectFileButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var documentPickerViewController: UIDocumentPickerViewController = {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .open)
        picker.delegate = self
        picker.modalPresentationStyle = .currentContext
        return picker
    }()
    
}

extension DecryptMessageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.DecryptMessage.title
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = closeBarButtonItem
        navigationItem.rightBarButtonItem = doneBarButtonItem
        
        decryptResultTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(decryptResultTextView)
        NSLayoutConstraint.activate([
            decryptResultTextView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            decryptResultTextView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            view.readableContentGuide.trailingAnchor.constraint(equalTo: decryptResultTextView.trailingAnchor),
            decryptResultTextView.heightAnchor.constraint(equalToConstant: view.frame.height <= 568 ? 70 : 100),
        ])
        
        arrowUpIconImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arrowUpIconImageView)
        NSLayoutConstraint.activate([
            arrowUpIconImageView.topAnchor.constraint(equalTo: decryptResultTextView.bottomAnchor, constant: 16),
            arrowUpIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            arrowUpIconImageView.widthAnchor.constraint(equalToConstant: 24).priority(.defaultHigh),
            arrowUpIconImageView.heightAnchor.constraint(equalToConstant: 24).priority(.defaultHigh),
        ])
        
        leadingSeparatorLine.translatesAutoresizingMaskIntoConstraints = false
        trailingSeparatorLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leadingSeparatorLine)
        view.addSubview(trailingSeparatorLine)
        NSLayoutConstraint.activate([
            leadingSeparatorLine.centerYAnchor.constraint(equalTo: arrowUpIconImageView.centerYAnchor),
            trailingSeparatorLine.centerYAnchor.constraint(equalTo: arrowUpIconImageView.centerYAnchor),
            leadingSeparatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arrowUpIconImageView.leadingAnchor.constraint(equalTo: leadingSeparatorLine.trailingAnchor, constant: 16),
            trailingSeparatorLine.leadingAnchor.constraint(equalTo: arrowUpIconImageView.trailingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: trailingSeparatorLine.trailingAnchor),
            leadingSeparatorLine.heightAnchor.constraint(equalToConstant: UIView.separatorLineHeight(of: leadingSeparatorLine)),
            trailingSeparatorLine.heightAnchor.constraint(equalToConstant: UIView.separatorLineHeight(of: trailingSeparatorLine)),
        ])
        
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputTextView)
        NSLayoutConstraint.activate([
            inputTextView.topAnchor.constraint(equalTo: arrowUpIconImageView.bottomAnchor, constant: 16),
            inputTextView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            view.readableContentGuide.trailingAnchor.constraint(equalTo: inputTextView.trailingAnchor),
            view.layoutMarginsGuide.bottomAnchor.constraint(equalTo: inputTextView.bottomAnchor),
        ])
        
        selectFileButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectFileButton)
        NSLayoutConstraint.activate([
            selectFileButton.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            view.layoutMarginsGuide.bottomAnchor.constraint(equalTo: selectFileButton.bottomAnchor, constant: 16),
            selectFileButton.heightAnchor.constraint(equalToConstant: 32).priority(.defaultHigh),
        ])
        
        inputTextView.delegate = self
        
        // handle keyboard overlap
        Publishers.CombineLatest3(
            KeyboardResponderService.shared.isShow.eraseToAnyPublisher(),
            KeyboardResponderService.shared.state.eraseToAnyPublisher(),
            KeyboardResponderService.shared.endFrame.eraseToAnyPublisher()
        )
            .sink(receiveValue: { isShow, state, endFrame in
                guard isShow, state == .dock else {
                    self.inputTextView.contentInset.bottom = 0.0
                    return
                }

                // isShow AND dock state
                let textViewFrame = self.view.convert(self.inputTextView.frame, to: nil)
                let padding = textViewFrame.maxY - endFrame.minY
                guard padding > 0 else {
                    self.inputTextView.contentInset.bottom = 0.0
                    return
                }

                self.inputTextView.contentInset.bottom = padding
            })
            .store(in: &disposeBag)
        
        viewModel.decryptStatus
            .print()
            .sink { [weak self] status in
                guard let `self` = self else { return }
                switch status {
                case .empty:
                    self.decryptResultTextView.text = ""
                case .decrypting:
                    self.decryptResultTextView.text = "Decrypting"
                case .decryptFail(let error):
                    let text: String = {
                        guard let localizedError = error as? LocalizedError else {
                            return error.localizedDescription
                        }
                        
                        let description = [localizedError.failureReason, localizedError.recoverySuggestion].compactMap { $0 }.joined(separator: " ")
                        if description.isEmpty {
                            return [localizedError.errorDescription, description].compactMap { $0 }.joined(separator: ": ")
                        } else {
                            return error.localizedDescription
                        }
                    }()
                    self.decryptResultTextView.text = text
                    
                case .decryptSuccess(let result):
                    switch result.extra.payloadKind {
                    case .plaintext:
                        self.decryptResultTextView.text = String(data: result.payload, encoding: .utf8) ?? "<Raw Data>"
                    default:
                        self.decryptResultTextView.text = "<Raw Data>"
                    }
                }
            }
            .store(in: &disposeBag)
        
        viewModel.isDoneBarButtonItemEnabled
            .assign(to: \.isEnabled, on: doneBarButtonItem)
            .store(in: &disposeBag)
        
        viewModel.saveChatMessageResult
            .sink { result in
                switch result {
                case .success(let chatMessage):
                    // create success, present chat scene
                    self.dismiss(animated: true) {
                        guard let chat = chatMessage.chat else {
                            assertionFailure()
                            return
                        }
                        let chatViewModel = ChatViewModel(context: self.context, chat: chat)
                        self.coordinator.present(scene: .chatRoom(viewModel: chatViewModel), from: nil, transition: .showDetail)
                    }
                case .failure(let error):
                    // create failure
                    let alertController = UIAlertController.standardAlert(of: error)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            .store(in: &self.disposeBag)
    }
    
}

// MARK: - UITextViewDelegate
extension DecryptMessageViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView === inputTextView else {
            return
        }
        
        viewModel.input.value = textView.text ?? ""
    }
    
}


extension DecryptMessageViewController {
    
    @objc private func closeBarButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneBarButtonPressed(_ sender: UIBarButtonItem) {
        viewModel.saveMessagePrelude()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let `self` = self else { return }
                
                do {
                    let savePrelude = try result.get()
                    self.viewModel.savePrelude = savePrelude
                    
                    guard !savePrelude.decryptableIdentities.isEmpty else {
                        throw DecryptMessageViewModel.Error.keyNotFound
                    }
                    
                    if savePrelude.decryptableIdentities.count == 1, let identity = savePrelude.decryptableIdentities.first {
                        // one decryptor. if not exist then create new
                        
                        guard let publicKey = identity.keypair?.publicKey else {
                            throw DecryptMessageViewModel.Error.keyNotFound
                        }
                        
                        if let existMessage = savePrelude.existMessages.first(where: { $0.chat?.identityPublicKey == publicKey }) {
                            // use exist message
                            self.viewModel.saveChatMessageResult.send(.success(existMessage))
                        } else {
                            // save new message
                            self.viewModel.saveTriggerPublisher.send(identity)
                        }
                        
                    } else {
                        // multiple decryptors. select identity then check exist or create new
                        let selectChatIdentityViewModel = SelectChatIdentityViewModel(context: self.context, identities: savePrelude.decryptableIdentities)
                        self.coordinator.present(scene: .selectChatIdentity(viewModel: selectChatIdentityViewModel, delegate: self), from: self, transition: .modal(animated: true, completion: nil))
                    }
                    
                } catch {
                    self.viewModel.savePrelude = nil
                    let alertController = UIAlertController.standardAlert(of: error)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            .store(in: &disposeBag)
    }
    
    @objc private func selectFileButtonPressed(_ sender: UIButton) {
        present(documentPickerViewController, animated: true, completion: nil)
    }
    
}

// MARK: - SelectChatIdentityViewControllerDelegate
extension DecryptMessageViewController: SelectChatIdentityViewControllerDelegate {
    func selectChatIdentityViewController(_ viewController: SelectChatIdentityViewController, didSelectIdentity identity: Contact) {
        viewController.dismiss(animated: true) {
            // identity selected. check exist
            guard let savePrelude = self.viewModel.savePrelude else {
                assertionFailure()
                return
            }
            guard let identityPublicKey = identity.keypair?.publicKey else {
                assertionFailure()
                return
            }
            
            if let existMessage = savePrelude.existMessages.first(where: { $0.chat?.identityPublicKey == identityPublicKey }) {
                self.viewModel.saveChatMessageResult.send(.success(existMessage))
            } else {
                self.viewModel.saveTriggerPublisher.send(identity)
            }
        }
    }
}

// MARK: - UIDocumentPickerDelegate
extension DecryptMessageViewController: UIDocumentPickerDelegate {
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
            let message = try String(contentsOf: url)
            inputTextView.text = message
            viewModel.input.value = message
        } catch {
            os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, error.localizedDescription)
            let alertController = UIAlertController.standardAlert(of: error)
            present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension DecryptMessageViewController: UIAdaptivePresentationControllerDelegate {
    
    
}

extension DecryptMessageViewController {
    enum Error: Swift.Error, LocalizedError {
        case `internal`
        
        var errorDescription: String? {
            switch self {
            case .internal:
                return L10n.Error.InternalError.errorDescription
            }
        }
        
        var failureReason: String? {
            switch self {
            case .internal:
                return L10n.Error.InternalError.failureReason
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .internal:
                return L10n.Error.InternalError.recoverySuggestion
            }
        }
    }
}
