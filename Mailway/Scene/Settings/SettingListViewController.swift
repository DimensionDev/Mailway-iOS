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
    var count = 0
    var message = "root"
}

final class SettingListViewController: UIViewController, NeedsDependency {
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var viewModel: SettingListViewModel!
    
    let showDetailButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    let detailButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
}

extension SettingListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let count = viewModel.count
        let message = viewModel.message
    
        showDetailButton.setTitle("showDetail", for: .normal)
        showDetailButton.setTitleColor(.systemBlue, for: .normal)
        
        showDetailButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(showDetailButton)
        NSLayoutConstraint.activate([
            showDetailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showDetailButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        showDetailButton.addTarget(self, action: #selector(SettingListViewController.buttonPressed(_:)), for: .touchUpInside)
        
        let messageLabel = UILabel()
        messageLabel.textColor = .label
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.bottomAnchor.constraint(equalTo: showDetailButton.topAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        messageLabel.textAlignment = .center
        messageLabel.text = "\(count): " + message
        messageLabel.numberOfLines = 0
        
        detailButton.setTitle("show", for: .normal)
        detailButton.setTitleColor(.systemBlue, for: .normal)
        
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailButton)
        NSLayoutConstraint.activate([
            detailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            detailButton.topAnchor.constraint(equalTo: showDetailButton.bottomAnchor),
        ])
        detailButton.addTarget(self, action: #selector(SettingListViewController.detailButtonPressed(_:)), for: .touchUpInside)
    }
    
    
    @objc private func buttonPressed(_ sender: UIButton) {
        let vm = SettingListViewModel()
        vm.count = viewModel.count + 1
        vm.message = viewModel.message + " from show detail,"
        coordinator.present(scene: .setting(viewModel: vm), from: self, transition: .showDetail)
    }
    
    @objc private func detailButtonPressed(_ sender: UIButton) {
        let vm = SettingListViewModel()
        vm.count = viewModel.count + 1
        vm.message = viewModel.message + " from show,"
        coordinator.present(scene: .setting(viewModel: vm), from: self, transition: .show)
    }
}
