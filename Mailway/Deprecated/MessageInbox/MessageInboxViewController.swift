//
//  MessageInboxViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-4.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit
import Combine
import UITextView_Placeholder
import NtgeCore

final class MessageInboxViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    let inboxTextView: UITextView = {
        let textView = UITextView()
        textView.placeholder = "Message…"
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.textContainer.lineBreakMode = .byCharWrapping
        textView.keyboardDismissMode = .interactive
        textView.showsVerticalScrollIndicator = false
        return textView
    }()

    lazy var doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(MessageInboxViewController.doneBarButtonPressed(_:)))
    
    let selectFileButton: UIButton = {
        let button = UIButton()
        button.setTitle("Select File…", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(UIColor.systemBlue.withAlphaComponent(0.8), for: .highlighted)
        button.addTarget(self, action: #selector(MessageInboxViewController.selectFileButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var documentPickerViewController: UIDocumentPickerViewController = {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .open)
        picker.delegate = self
        picker.modalPresentationStyle = .currentContext
        return picker
    }()
    
}

extension MessageInboxViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Inbox"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(MessageInboxViewController.cancelBarButtonPressed(_:)))
        navigationItem.rightBarButtonItem = doneBarButtonItem
        
        
        selectFileButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectFileButton)
        NSLayoutConstraint.activate([
            selectFileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            selectFileButton.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            view.readableContentGuide.trailingAnchor.constraint(equalTo: selectFileButton.trailingAnchor),
        ])
        
        inboxTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inboxTextView)
        NSLayoutConstraint.activate([
            inboxTextView.topAnchor.constraint(equalTo: selectFileButton.bottomAnchor),
            inboxTextView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            view.readableContentGuide.trailingAnchor.constraint(equalTo: inboxTextView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: inboxTextView.bottomAnchor),
        ])
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            .sink { notification in
                guard let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }
                
                self.inboxTextView.contentInset.bottom = endFrame.height
            }
            .store(in: &disposeBag)
        
        inboxTextView.text = UIPasteboard.general.string
        inboxTextView.becomeFirstResponder()
    }
    
}

extension MessageInboxViewController {
    
    @objc private func cancelBarButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneBarButtonPressed(_ sender: UIBarButtonItem) {
        guard let ciphertext = inboxTextView.text, !ciphertext.isEmpty,
        let message = Message.deserialize(from: ciphertext) else {
            return
        }
        
        let decryptor = Message.Decryptor(message: message)
        
//        var identityKeys: [Key] = []
        var identityPrivateKeys: [Ed25519.PrivateKey] = []
        var identityFileKeys: [X25519.FileKey] = []
        
//        for key in context.documentStore.keys where !key.privateKey.isEmpty {
//            guard let privateKey = Ed25519.PrivateKey.deserialize(from: key.privateKey) else {
//                continue
//            }
//            
//            guard let fileKey = decryptor.decryptFileKey(privateKey: privateKey.x25519) else {
//                continue
//            }
//            
//            identityKeys.append(key)
//            identityPrivateKeys.append(privateKey)
//            identityFileKeys.append(fileKey)
//        }
//        
//        guard !identityKeys.isEmpty, let filekey = identityFileKeys.first else {
//            let alertController = UIAlertController(title: "Decrypt Fail", message: "Can not find available key", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alertController.addAction(okAction)
//            present(alertController, animated: true, completion: nil)
//            
//            return
//        }
//        
//        guard let plaintextData = decryptor.decryptPayload(fileKey: filekey) else {
//            let alertController = UIAlertController(title: "Decrypt Fail", message: "Decrypt fail due to internal error", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alertController.addAction(okAction)
//            present(alertController, animated: true, completion: nil)
//            return
//        }
//        
//        let plaintext = String(data: plaintextData, encoding: .utf8) ?? "<nil>"
//        
//        let alertController = UIAlertController(title: "Message Content", message: plaintext, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(okAction)
//        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func selectFileButtonPressed(_ sender: UIButton) {
        present(documentPickerViewController, animated: true, completion: nil)
    }
    
}

// MARK: - UIDocumentPickerDelegate
extension MessageInboxViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        
        do {
            guard url.startAccessingSecurityScopedResource() else {
                // TODO: alert
                return
            }
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            let message = try String(contentsOf: url)
            inboxTextView.text = message
        } catch {
            os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, error.localizedDescription)

        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension MessageInboxViewController: UIAdaptivePresentationControllerDelegate {
    
    
}
