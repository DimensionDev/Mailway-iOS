//
//  RootSplitViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-2.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit

final class RootSplitViewController: UISplitViewController, NeedsDependency {
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var emptyDetail: UIViewController!
        
}

extension RootSplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let mainTabBarViewController = MainTabBarController(context: context, coordinator: coordinator)
        let master = mainTabBarViewController
        
        let detailViewController = PlaceholderDetailViewController()
        let detail = UINavigationController(rootViewController: detailViewController)
        emptyDetail = detail
        
        viewControllers = [master, detail]
        preferredDisplayMode = .allVisible
        presentsWithGesture = false        
    }

}
