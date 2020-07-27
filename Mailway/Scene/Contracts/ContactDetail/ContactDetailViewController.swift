//
//  ContactDetailViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-11.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit
import SwiftUI
import Combine
import CoreDataStack

final class ContactDetailViewModel: ObservableObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    // input
    let context: AppContext
    let contact: Contact
    let shareProfileActionPublisher = PassthroughSubject<Void, Never>()
    let copyKeyIDActionPublisher = PassthroughSubject<Void, Never>()
    let removeButtonPressedPublisher = PassthroughSubject<Void, Never>()
    
    // output
    @Published var avatar: UIImage?
    @Published var name: String
    @Published var keyID: String
    @Published var contactInfoDict: [ContactInfo.InfoType: [ContactInfo]] = [:]
    @Published var note: String
    @Published var isPlaceholderHidden: Bool

    let contactDidRemovedPublisher = PassthroughSubject<Void, Never>()
    let error = PassthroughSubject<Error, Never>()
    
    init(context: AppContext, contact: Contact) {
        self.context = context
        self.contact = contact
        self.avatar = contact.avatar
        self.name = contact.name
        self.keyID = contact.keypair?.keyID ?? "-"
        let contactInfoDict: [ContactInfo.InfoType: [ContactInfo]] = {
            var infoDict: [ContactInfo.InfoType: [ContactInfo]] = [:]
            
            let infos = contact.channels?.compactMap { channel -> ContactInfo in
                let type = ContactInfo.InfoType(name: channel.name)
                return ContactInfo(type: type, key: channel.name, value: channel.value)
                } ?? []
            let groupingInfos = Dictionary(grouping: infos, by: { $0.type })
            for infoType in ContactInfo.InfoType.allCases {
                infoDict[infoType] = groupingInfos[infoType]?.sorted(by: { $0.value < $1.value })
            }
            return infoDict
        }()
        self.contactInfoDict = contactInfoDict
        let note = contact.note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        self.note = note
        self.isPlaceholderHidden = contactInfoDict.isEmpty && note.isEmpty
        
        copyKeyIDActionPublisher
            .sink { _ in
                UIPasteboard.general.string = self.keyID
            }
            .store(in: &disposeBag)
        
        removeButtonPressedPublisher
            .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: false)
            .flatMap { _ -> Future<Result<Void, Error>, Never> in
                guard let managedObjectContext = self.contact.managedObjectContext else {
                    return Future<Result<Void, Error>, Never> { $0(.success(Result.success(()))) }
                }
                os_log("%{public}s[%{public}ld], %{public}s: remove contact %s", ((#file as NSString).lastPathComponent), #line, #function, self.contact.debugDescription)
                return managedObjectContext.performChanges {
                    managedObjectContext.delete(self.contact)
                }
        }
        .sink { result in
            do {
                _ = try result.get()
            } catch {
                os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, error.localizedDescription)
                self.error.send(error)
            }
        }
        .store(in: &disposeBag)
        
        ManagedObjectObserver.observe(object: contact)
            .sink(receiveCompletion: { completion in
                
            }, receiveValue: { [weak self] value in
                guard let changeType = value else { return }
                if changeType == .delete {
                    self?.contactDidRemovedPublisher.send()
                }
            })
            .store(in: &disposeBag)
    }
    
}

final class ContactDetailViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()

    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var viewModel: ContactDetailViewModel!

    lazy var contactDetailView = ContactDetailView(viewModel: viewModel)
        
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }

}

extension ContactDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        title = viewModel.contact.name
        view.backgroundColor = .systemBackground
        
        let hostingController = UIHostingController(rootView: contactDetailView)
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
        
        viewModel.shareProfileActionPublisher
            .throttle(for: .milliseconds(300), scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                ShareService.share(contact: self.viewModel.contact, from: self)
            }
            .store(in: &disposeBag)
        
        viewModel.contactDidRemovedPublisher
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &disposeBag)
        
        viewModel.error
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false)
            .sink { error in
                let alertController = UIAlertController.standardAlert(of: error)
                self.present(alertController, animated: true, completion: nil)
            }
            .store(in: &disposeBag)
    }
    
}
