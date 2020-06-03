//
//  ChatRootSplitViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-2.
//  Copyright © 2020 Dimension. All rights reserved.
//

//import UIKit
//
//final class ChatRootSplitViewController: UISplitViewController, NeedsDependency {
//    
//    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
//    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
//    
//}
//
//extension ChatRootSplitViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//            
//        let chatListViewController = ChatListViewController()
//        chatListViewController.context = context
//        chatListViewController.coordinator = coordinator
//        let master = UINavigationController(rootViewController: chatListViewController)
//        
//        let chatViewController = ChatViewController()
//        chatViewController.context = context
//        chatViewController.coordinator = coordinator
//        chatViewController.viewModel = ChatViewModel(context: context, chat: Chat.empty)
//        let detail = UINavigationController(rootViewController: chatViewController)
//        
//        viewControllers = [master, detail]
//    }
//}
//
//// MARK: - UISplitViewControllerDelegate
//extension ChatRootSplitViewController: UISplitViewControllerDelegate {
//    
//}
