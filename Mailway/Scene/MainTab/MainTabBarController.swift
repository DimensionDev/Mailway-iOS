//
//  MainTabBarController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-22.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI

// Use UIKit TabBarController to avoid SwiftUI.TabView deinit the tab when switching issue
final class MainTabBarController: UITabBarController {
        
    weak var context: AppContext!
    weak var coordinator: SceneCoordinator!
    
    enum Tabs: CaseIterable {
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
            switch self {
            case .chats:
                let viewController = ChatListViewController()
                viewController.context = context
                viewController.coordinator = coordinator
                return UINavigationController(rootViewController: viewController)
            case .contacts:
                let viewController = ContactListViewController()
                viewController.context = context
                viewController.coordinator = coordinator
                return UINavigationController(rootViewController: viewController)
            case .settings:
                return UIHostingController(rootView: SettingsView().environmentObject(context))
            }
        }
    }
    
    // TabBar will immediately load view without interval
    init(context: AppContext, coordinator: SceneCoordinator) {
        self.context = context
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MainTabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabs = Tabs.allCases
        
        let viewControllers: [UIViewController] = tabs.map { tab in
            let viewController = tab.viewController(context: context, coordinator: coordinator)
            viewController.tabBarItem.title = tab.title
            viewController.tabBarItem.image = tab.image
            return viewController
        }
        setViewControllers(viewControllers, animated: false)
        selectedIndex = 0
    }
    
}
