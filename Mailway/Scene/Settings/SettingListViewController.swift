//
//  SettingListViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-3.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit

final class SettingListViewModel {
    
}

final class SettingsViewController: UIViewController, NeedsDependency, MainTabTransitionableViewController {
    
    private(set) var transitionController: MainTabTransitionController!

    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
//    private lazy var sidebarBarButtonItem: UIBarButtonItem = {
//        let item = UIBarButtonItem()
//        item.image = Asset.Sidebar.menu.image
//        item.target = self
//        item.action = #selector(SettingListViewController.sidebarBarButtonItemPressed(_:))
//        return item
//    }()
    
    var viewModel: SettingListViewModel!
    
}

extension SettingsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Settings"
//        transitionController = MainTabTransitionController(viewController: self)
//        navigationItem.leftBarButtonItem = sidebarBarButtonItem
        
    }
    
}

extension SettingsViewController {
    
//    @objc private func sidebarBarButtonItemPressed(_ sender: UIBarButtonItem) {
//        coordinator.present(scene: .sidebar, from: self, transition: .custom(transitioningDelegate: transitionController))
//    }
//
//    @objc private func buttonPressed(_ sender: UIButton) {
//        let vm = SettingListViewModel()
//        vm.count = viewModel.count + 1
//        vm.message = viewModel.message + " from show detail,"
//        coordinator.present(scene: .setting(viewModel: vm), from: self, transition: .showDetail)
//    }
//
//    @objc private func detailButtonPressed(_ sender: UIButton) {
//        let vm = SettingListViewModel()
//        vm.count = viewModel.count + 1
//        vm.message = viewModel.message + " from show,"
//        coordinator.present(scene: .setting(viewModel: vm), from: self, transition: .show)
//    }
}

extension SettingsViewController {
    
    
    
}
