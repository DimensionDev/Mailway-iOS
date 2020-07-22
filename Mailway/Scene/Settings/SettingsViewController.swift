//
//  SettingsViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-3.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit

final class SettingsViewModel: NSObject {
    
}

extension SettingsViewModel {
    enum Section: CaseIterable {
        case identity
    }
}

extension SettingsViewModel {
    static func configure(cell: SettingEntryTableViewCell, section: Section) {
        switch section {
        case .identity:
            cell.iconImageView.image = Asset.Human.personCropCircle.image.withRenderingMode(.alwaysTemplate)
            cell.iconImageView.tintColor = .label
            cell.titleLabel.text = "Identity"
        }
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section.allCases[indexPath.section]
        let cell: UITableViewCell
        
        switch section {
        case .identity:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingEntryTableViewCell.self), for: indexPath) as! SettingEntryTableViewCell
            cell = _cell
            SettingsViewModel.configure(cell: _cell, section: section)
        }
        
        return cell
    }
    
}

final class SettingsViewController: UIViewController, NeedsDependency {

    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    var viewModel = SettingsViewModel()

    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.image = Asset.NavigationBar.close.image
        item.target = self
        item.action = #selector(SettingsViewController.closeBarButtonItemPressed(_:))
        return item
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SettingEntryTableViewCell.self, forCellReuseIdentifier: String(describing: SettingEntryTableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
}

extension SettingsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Settings"
        navigationItem.leftBarButtonItem = closeBarButtonItem
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
        ])
        
        tableView.delegate = self
        tableView.dataSource = viewModel
    }
    
}

extension SettingsViewController {
    
    @objc private func closeBarButtonItemPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = SettingsViewModel.Section.allCases[indexPath.section]
        switch section {
        case .identity:
            coordinator.present(scene: .identityList, from: self, transition: .show)
        }
    }
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
