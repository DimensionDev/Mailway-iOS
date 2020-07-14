//
//  IdentityDetailViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-9.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit
import SwiftUI
import Combine
import CoreDataStack

final class IdentityDetailViewModel: ObservableObject {
    
    var disposeBag = Set<AnyCancellable>()

    // input
    let context: AppContext
    let shareProfileActionPublisher = PassthroughSubject<Void, Never>()
    let copyKeyIDActionPublisher = PassthroughSubject<Void, Never>()
    
    // output
    @Published var avatar: UIImage
    @Published var color: UIColor
    @Published var name: String
    @Published var keyID: String
    @Published var contactInfoDict: [ContactInfo.InfoType: [ContactInfo]] = [:]
    @Published var note: String

    init(context: AppContext, identity: Contact) {
        self.context = context
        
        self.avatar = identity.avatar ?? UIImage.placeholder(color: .systemFill)
        self.color = .systemPurple
        self.name = identity.name
        self.keyID = identity.keypair?.keyID ?? "-"
        self.contactInfoDict = {
            var infoDict: [ContactInfo.InfoType: [ContactInfo]] = [:]
            
            let infos = identity.channels?.compactMap { channel -> ContactInfo in
                let type = ContactInfo.InfoType(name: channel.name)
                return ContactInfo(type: type, key: channel.name, value: channel.value)
                } ?? []
            let groupingInfos = Dictionary(grouping: infos, by: { $0.type })
            for infoType in ContactInfo.InfoType.allCases {
                infoDict[infoType] = groupingInfos[infoType]?.sorted(by: { $0.value < $1.value })
            }
            return infoDict
        }()
        self.note = identity.note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        copyKeyIDActionPublisher
            .sink { _ in
                UIPasteboard.general.string = self.keyID
            }
            .store(in: &disposeBag)
    }
    
}

final class IdentityDetailViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var viewModel: IdentityDetailViewModel!

    private lazy var moreBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = Asset.Editing.moreVertical.image
        // TODO: target & action
        return item
    }()
    
    lazy var identityDetailView = IdentityDetailView(viewModel: viewModel)
}

extension IdentityDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = moreBarButtonItem
        
        let hostingController = UIHostingController(rootView: identityDetailView.environmentObject(context))
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        viewModel.shareProfileActionPublisher
            .throttle(for: .milliseconds(300), scheduler: DispatchQueue.main, latest: false)
            .sink { _ in
                os_log("%{public}s[%{public}ld], %{public}s: share profile", ((#file as NSString).lastPathComponent), #line, #function)
            }
            .store(in: &disposeBag)
    }
    
}
