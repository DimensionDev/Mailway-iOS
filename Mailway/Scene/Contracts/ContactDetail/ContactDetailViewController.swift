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
    
    // input
    let contact: Contact
    
    // output
    let removeButtonPressedPublisher = PassthroughSubject<Void, Never>()
    
    init(contact: Contact) {
        self.contact = contact
    }
    
}

final class ContactDetailViewController: UIViewController, NeedsDependency {
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    lazy var contactDetailView = ContactDetailView(viewModel: viewModel)
    
    var disposeBag = Set<AnyCancellable>()
    var viewModel: ContactDetailViewModel!
    
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
        
        viewModel.removeButtonPressedPublisher
            .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: false)
            .sink { _ in
                
            }
            .store(in: &disposeBag)
    }
    
}

