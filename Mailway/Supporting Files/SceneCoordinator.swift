//
//  SceneCoordinator.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-27.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

protocol NeedsDependency: class {
    var context: AppContext! { get set }
    var coordinator: SceneCoordinator! { get set }
}

// Template
// weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
// weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }

extension UISceneSession {
    private struct AssociatedKeys {
        //static var appDependency = "AppDependency"
        static var sceneCoordinator = "SceneCoordinator"
    }
    
    weak var sceneCoordinator: SceneCoordinator? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.sceneCoordinator) as? SceneCoordinator
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.sceneCoordinator, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

final public class SceneCoordinator {
    
    private weak var scene: UIScene!
    private weak var sceneDelegate: SceneDelegate!
    private weak var appContext: AppContext!
    
    let id = UUID().uuidString
    private var secondaryStackHashValues = Set<Int>()
    
    init(scene: UIScene, sceneDelegate: SceneDelegate, appContext: AppContext) {
        self.scene = scene
        self.sceneDelegate = sceneDelegate
        self.appContext = appContext
    
        scene.session.sceneCoordinator = self
    }
}

extension SceneCoordinator {
    enum Transition {
        case show                           // push
        case showDetail                     // replace
        case modal(animated: Bool, completion: (() -> Void)? = nil)
        // case alert
        case custom(transitioningDelegate: UIViewControllerTransitioningDelegate)
    }
    
    enum Scene {
        // chats
        case createChat
        case composeMessage(viewModel: ComposeMessageViewModel)
        case decryptMessage
        case selectChatIdentity(viewModel: SelectChatIdentityViewModel, delegate: SelectChatIdentityViewControllerDelegate)
        case chatRoom(viewModel: ChatViewModel)
        
        // contacts
        case addContact
        case contactDetail(viewModel: ContactDetailViewModel)
        
        // identities
        case identityList
        case identityDetail(viewModel: IdentityDetailViewModel)
        case addIdentity
        
        // settings
        case setting
        
        // sidebar
        case sidebar
        
        // debug only
        #if DEBUG
        case splitDemo(viewModel: SplitDemoViewModel)
        #endif
    }
}

extension SceneCoordinator {
    
    func setup() {
        let viewController = RootSplitViewController()
        setupDependency(for: viewController)
        viewController.delegate = self
        sceneDelegate.window?.rootViewController = viewController
    }
    
    @discardableResult
    func present(scene: Scene, from sender: UIViewController?, transition: Transition) -> UIViewController? {
        let viewController = get(scene: scene)
        guard let presentingViewController = sender ?? sceneDelegate.window?.rootViewController else {
            return nil
        }
        
        switch transition {
        case .show:
            if secondaryStackHashValues.contains(presentingViewController.hashValue) {
                secondaryStackHashValues.insert(viewController.hashValue)
            }
            presentingViewController.show(viewController, sender: sender)
            
        case .showDetail:
            secondaryStackHashValues.insert(viewController.hashValue)
            let navigationController = UINavigationController(rootViewController: viewController)
            presentingViewController.showDetailViewController(navigationController, sender: sender)
            
        case .modal(let animated, let completion):
            let modalNavigationController = UINavigationController(rootViewController: viewController)
            if let adaptivePresentationControllerDelegate = viewController as? UIAdaptivePresentationControllerDelegate {
                modalNavigationController.presentationController?.delegate = adaptivePresentationControllerDelegate
            }
            presentingViewController.present(modalNavigationController, animated: animated, completion: completion)
            
        case .custom(let transitioningDelegate):
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = transitioningDelegate
            sender?.present(viewController, animated: true, completion: nil)
        }
        
        return viewController
    }
}

extension SceneCoordinator {
    private func get(scene: Scene) -> UIViewController {
        let viewController: UIViewController
        switch scene {
        case .createChat:
            viewController = CreateChatViewController()
        case .composeMessage(let viewModel):
            let _viewController = ComposeMessageViewController()
            _viewController.viewModel = viewModel
            viewController = _viewController
        case .decryptMessage:
            viewController = DecryptMessageViewController()
        case .addContact:
            viewController = AddContactViewController()
        case .contactDetail(let viewModel):
            let _viewController = ContactDetailViewController()
            _viewController.viewModel = viewModel
            viewController = _viewController
        case .selectChatIdentity(let viewModel, let delegate):
            let _viewController = SelectChatIdentityViewController()
            _viewController.viewModel = viewModel
            _viewController.delegate = delegate
            viewController = _viewController
        case .chatRoom(let viewModel):
            let _viewController = ChatViewController()
            _viewController.viewModel = viewModel
            viewController = _viewController
        case .identityList:
            viewController = IdentityListViewController()
        case .identityDetail(let viewModel):
            let _viewController = IdentityDetailViewController()
            _viewController.viewModel = viewModel
            viewController = _viewController
        case .addIdentity:
            viewController = AddIdentityViewController()
        case .setting:
            viewController = SettingsViewController()
        case .sidebar:
            viewController = SidebarViewController()
            
        #if DEBUG
        case .splitDemo(viewModel: let viewModel):
            let _viewController = SplitDemoViewController()
            _viewController.viewModel = viewModel
            viewController = _viewController
        #endif
        }
        
        setupDependency(for: viewController as? NeedsDependency)
        
        return viewController
    }
    
    private func setupDependency(for needs: NeedsDependency?) {
        needs?.context = appContext
        needs?.coordinator = self
    }
    
}

// MARK: - UISplitViewControllerDelegate
extension SceneCoordinator: UISplitViewControllerDelegate {
    
    public func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        if splitViewController.isCollapsed {
            let selectedNavigationController = ((splitViewController.viewControllers.first as? UITabBarController)?.selectedViewController as? UINavigationController)
            if let navigationController = vc as? UINavigationController, let topViewController = navigationController.topViewController {
                selectedNavigationController?.pushViewController(topViewController, animated: true)
            } else {
                selectedNavigationController?.pushViewController(vc, animated: true)
            }
            return true
        } else {
            return false
        }
    }
    
    public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let primaeryTabBarController = primaryViewController as? UITabBarController,
        let selectedNavigationController = primaeryTabBarController.selectedViewController as? UINavigationController else {
            return false
        }
        
        guard let secondaryNavigationController = secondaryViewController as? UINavigationController else {
            return false
        }
        
        guard !(secondaryNavigationController.topViewController is PlaceholderDetailViewController) else {
            // discard collapse operation
            return true
        }
        
        let secondaryNavigationStack = secondaryNavigationController.viewControllers
        let collapsedNavigationStack = [selectedNavigationController.viewControllers, secondaryNavigationStack].flatMap { $0 }
        selectedNavigationController.setViewControllers(collapsedNavigationStack, animated: false)
        
        return true
    }
    
    public func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        guard let primaeryTabBarController = primaryViewController as? UITabBarController,
        let selectedNavigationController = primaeryTabBarController.selectedViewController as? UINavigationController else {
            return nil
        }
        
        var primaryViewControllerStack: [UIViewController] = []
        var secondaryViewControllerStack: [UIViewController] = []
        for viewController in selectedNavigationController.viewControllers {
            if secondaryStackHashValues.contains(viewController.hashValue) {
                secondaryViewControllerStack.append(viewController)
            } else {
                primaryViewControllerStack.append(viewController)
            }
        }
        
        selectedNavigationController.setViewControllers(primaryViewControllerStack, animated: false)
        
        let secondaryNavigationController = UINavigationController()
        if secondaryViewControllerStack.isEmpty {
            secondaryNavigationController.setViewControllers([PlaceholderDetailViewController()], animated: false)
        } else {
            secondaryNavigationController.setViewControllers(secondaryViewControllerStack, animated: false)
        }
        
        return secondaryNavigationController
    }
    
}
