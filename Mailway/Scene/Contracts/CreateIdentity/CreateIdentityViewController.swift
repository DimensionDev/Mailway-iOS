//
//  CreateIdentityViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-21.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
import CoreDataStack
import NtgeCore

final class CreateIdentityViewController: UIViewController, NeedsDependency {
    
    var disposeBag = Set<AnyCancellable>()
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    let createIdentityView = CreateIdentityView()
    
    private(set) lazy var cancelBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(CreateIdentityViewController.cancelBarButtonItemPressed(_:)))
        return item
    }()
    
    private(set) lazy var doneBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CreateIdentityViewController.doneBarButtonItemPressed(_:)))
        return item
    }()
}

extension CreateIdentityViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Create Identity"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        navigationItem.rightBarButtonItem = doneBarButtonItem
        
        let hostingController = UIHostingController(rootView: createIdentityView)
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
                
//        createIdentityView.viewModel.contact
//            .map { $0 != nil }
//            .assign(to: \.isEnabled, on: doneBarButtonItem)
//            .store(in: &disposeBag)
    }
    
}

extension CreateIdentityViewController {
    
    @objc private func cancelBarButtonItemPressed(_ sender: UIBarButtonItem) {
        dismissModal()
    }
    
    @objc private func doneBarButtonItemPressed(_ sender: UIBarButtonItem) {
        guard let contactProperty = createIdentityView.viewModel.contactProperty.value else {
            // TODO: handler error
            return
        }
        
        let ed25519Keypair = Ed25519.Keypair()
        let privateKey = ed25519Keypair.privateKey.serialize()
        let publicKey = ed25519Keypair.publicKey.serialize()
        let keyID = ed25519Keypair.publicKey.keyID
        let keypairProperty = Keypair.Property(privateKey: privateKey, publicKey: publicKey, keyID: keyID)
        
        let managedObjectContext = context.managedObjectContext
        managedObjectContext.performChanges {
            let keypair = Keypair.insert(into: managedObjectContext, property: keypairProperty)
            _ = Contact.insert(into: managedObjectContext, property: contactProperty, keypair: keypair, channels: [])
        }
        
        dismissModal()
    }
    
    private func dismissModal() {
        dismiss(animated: true)
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension CreateIdentityViewController: UIAdaptivePresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .fullScreen
    }
    
}

#if DEBUG
struct CreateIdentityViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            let viewController = CreateIdentityViewController()
            viewController.context = AppContext.shared
            return UINavigationController(rootViewController: viewController)
        }
    }
}
#endif
