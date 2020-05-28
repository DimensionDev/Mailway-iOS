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
        
        let hostingController = UIHostingController(rootView: createIdentityView.environmentObject(context))
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
                
        createIdentityView.viewModel.contact
            .map { $0 != nil }
            .assign(to: \.isEnabled, on: doneBarButtonItem)
            .store(in: &disposeBag)
    }
    
}

extension CreateIdentityViewController {
    
    @objc private func cancelBarButtonItemPressed(_ sender: UIBarButtonItem) {
        dismissModal()
    }
    
    @objc private func doneBarButtonItemPressed(_ sender: UIBarButtonItem) {
        guard let contact = createIdentityView.viewModel.contact.value else {
            // TODO: handler error
            return
        }
        
        context.documentStore.create(identity: contact)
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

struct CreateIdentityViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            let viewController = CreateIdentityViewController()
            viewController.context = AppContext.shared
            return UINavigationController(rootViewController: viewController)
        }
    }
}
