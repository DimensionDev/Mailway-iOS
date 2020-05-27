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
    
    init(scene: UIScene, sceneDelegate: SceneDelegate, appContext: AppContext) {
        self.scene = scene
        self.sceneDelegate = sceneDelegate
        self.appContext = appContext
    
        scene.session.sceneCoordinator = self
    }
}

extension SceneCoordinator {
    enum Transition {
        case root
        case modal(animated: Bool, completion: (() -> Void)? = nil)
        case detail(animated: Bool)
        case alert
        case custom
    }
    
    enum Scene {
        case main
        case createChat
        case selectChatIdentity
        case createIdentity
        case identityList
    }
}

extension SceneCoordinator {
    func present(scene: Scene, from sender: UIViewController?, transition: Transition = .detail(animated: true)) {
        switch scene {
        case .main:
            let viewController = get(scene: .main)
            sceneDelegate.window?.rootViewController = viewController
            
        default:
            let viewController = get(scene: scene)
            
            let parent = sender ?? sceneDelegate.window?.rootViewController
            let navigationController = (parent as? UINavigationController) ?? parent?.navigationController
            
            switch transition {
            case .detail(let animated):
                guard let _navigationController = navigationController else {
                    assertionFailure("cannot find navigation controller to push")
                    return
                }
                _navigationController.pushViewController(viewController, animated: animated)
                
            case .modal(let animated, let completion):
                guard let _navigationController = navigationController else {
                    assertionFailure("cannot find navigation controller to push")
                    return
                }
                
                let modalNavigationController = UINavigationController(rootViewController: viewController)
                if let adaptivePresentationControllerDelegate = viewController as? UIAdaptivePresentationControllerDelegate {
                    modalNavigationController.presentationController?.delegate = adaptivePresentationControllerDelegate
                }
                _navigationController.present(modalNavigationController, animated: animated, completion: completion)
                
            default:
                assertionFailure("TODO")
            }
        }
    }
}

extension SceneCoordinator {
    private func get(scene: Scene) -> UIViewController {
        let viewController: UIViewController
        
        switch scene {
        case .main:
            viewController = MainTabBarController(context: appContext, coordinator: self)
        case .createChat:
            viewController = CreateChatViewController()
        case .selectChatIdentity:
            viewController = SelectChatIdentityViewController()
        case .createIdentity:
            viewController = CreateIdentityViewController()
        case .identityList:
            viewController = IdentityListViewController()
        }
        
        setupDependency(for: viewController as? NeedsDependency)
        
        return viewController
    }
    
    private func setupDependency(for needs: NeedsDependency?) {
        needs?.context = appContext
        needs?.coordinator = self
    }
    
}
