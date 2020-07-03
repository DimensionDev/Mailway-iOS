//
//  MainTabBarController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-22.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
    
// Use UIKit UITabBarController to avoid the SwiftUI TabView deinit the tab when switching tab issue
final class MainTabBarController: UITabBarController {
    
    var disposeBag = Set<AnyCancellable>()
        
    weak var context: AppContext!
    weak var coordinator: SceneCoordinator!
    
    enum Tabs: Int, CaseIterable {
        case chats
        case contacts
        case settings
        
        var title: String {
            switch self {
            case .chats:    return "Chats"
            case .contacts: return "Contacts"
            case .settings: return "Settings"
            }
        }
        
        var image: UIImage {
            switch self {
            case .chats:    return UIImage(systemName: "message.fill")!
            case .contacts: return UIImage(systemName: "person.crop.circle")!
            case .settings: return UIImage(systemName: "gear")!
            }
        }
        
        func viewController(context: AppContext, coordinator: SceneCoordinator) -> UIViewController {
            let navigationController: UINavigationController
            switch self {
            case .chats:
                let viewController = ChatListViewController()
                viewController.context = context
                viewController.coordinator = coordinator
                navigationController = UINavigationController(rootViewController: viewController)
            case .contacts:
                let viewController = ContactListViewController()
                viewController.context = context
                viewController.coordinator = coordinator
                navigationController = UINavigationController(rootViewController: viewController)
            case .settings:
                let viewController = SettingsViewController()
                viewController.context = context
                viewController.coordinator = coordinator
                viewController.viewModel = SettingsViewModel()
                navigationController = UINavigationController(rootViewController: viewController)
            }
            return navigationController
        }
    }
    
    // TabBar will immediately load view without interval
    init(context: AppContext, coordinator: SceneCoordinator) {
        self.context = context
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.publisher(for: SidebarViewController.didSelectEntry)
            .sink { [weak self] notification in
                guard let `self` = self else { return }
                guard let entry = notification.object as? SidebarViewController.Entry else {
                    return
                }
                
                switch entry {
                case .inbox:
                    self.selectedIndex = Tabs.chats.rawValue
                case .contacts:
                    self.selectedIndex = Tabs.contacts.rawValue
                case .settings:
                    coordinator.present(scene: .setting, from: nil, transition: .modal(animated: true, completion: nil))
                default:
                    break   // TODO:
                }
            }
            .store(in: &disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MainTabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .systemBackground
        
        let tabs = Tabs.allCases
        
        let viewControllers: [UIViewController] = tabs.map { tab in
            let viewController = tab.viewController(context: context, coordinator: coordinator)
            viewController.tabBarItem.title = tab.title
            viewController.tabBarItem.image = tab.image
            return viewController
        }
        setViewControllers(viewControllers, animated: false)
        selectedIndex = 0
        tabBar.isHidden = true
    }
    
}
