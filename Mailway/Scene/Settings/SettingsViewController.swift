//
//  SettingsViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-3.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit

final class SettingsViewModel {
    
}

final class SettingsViewController: UIViewController, NeedsDependency {

    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = Asset.NavigationBar.close.image
        item.target = self
        item.action = #selector(SettingsViewController.closeBarButtonItemPressed(_:))
        return item
    }()
    
    var viewModel: SettingsViewModel!
    
}

extension SettingsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Settings"
        navigationItem.leftBarButtonItem = closeBarButtonItem
        
    }
    
}

extension SettingsViewController {
    
    @objc private func closeBarButtonItemPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
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

// MARK: - UIAdaptivePresentationControllerDelegate
extension SettingsViewController: UIAdaptivePresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        if traitCollection.userInterfaceIdiom == .pad {
            return .pageSheet
        } else {
            return .fullScreen
        }
    }
    
}
