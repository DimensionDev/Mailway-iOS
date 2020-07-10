//
//  SidebarViewController.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-22.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import UIKit
import Combine
import CoreDataStack

final class SidebarViewModel: NSObject {

    let context: AppContext

    init(context: AppContext) {
        self.context = context
    }
}

extension SidebarViewModel {
    enum Section: CaseIterable {
        case inbox
        case subInbox
        case drafts
        case contacts
        case plugins
    }
}

extension SidebarViewModel {
    
    static func configure(cell: SidebarEntryTableViewCell, section: Section) {
        switch section {
        case .inbox:
            cell.entryView.iconImageView.image = Asset.Sidebar.inbox.image
            cell.entryView.titleLabel.text = "Inbox"
        case .subInbox:
            break   // TODO:
        case .drafts:
            cell.entryView.iconImageView.image = Asset.Sidebar.drafts.image
            cell.entryView.titleLabel.text = "Drafts"
        case .contacts:
            cell.entryView.iconImageView.image = Asset.Sidebar.contacts.image
            cell.entryView.titleLabel.text = "Contacts"
        case .plugins:
            cell.entryView.iconImageView.image = Asset.Sidebar.plugins.image
            cell.entryView.titleLabel.text = "Plugins"
        }
    }
}

extension SidebarViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView is SidebarViewController.SettingsEntryTableView ? 1 : Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView is SidebarViewController.SettingsEntryTableView {
            return 1
        }
        
        let section = Section.allCases[section]
        switch section {
        case .inbox:        return 1
        case .subInbox:     return 0    // TODO:
        case .drafts:       return 1
        case .contacts:     return 1
        case .plugins:      return 0    // TODO:
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView is SidebarViewController.SettingsEntryTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SidebarEntryTableViewCell.self), for: indexPath) as! SidebarEntryTableViewCell
            cell.entryView.iconImageView.image = Asset.Sidebar.settings.image
            cell.entryView.titleLabel.text = "Settings"
            return cell
        }
        
        let section = Section.allCases[indexPath.section]
        let cell: UITableViewCell
        
        switch section {
        case .inbox, .drafts, .contacts, .plugins:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SidebarEntryTableViewCell.self), for: indexPath) as! SidebarEntryTableViewCell
            cell = _cell
            
            SidebarViewModel.configure(cell: _cell, section: section)

        case .subInbox:
            return UITableViewCell()    // TODO:
        }
        
        return cell
    }
}


final class SidebarViewController: UIViewController, NeedsDependency, SidebarTransitionableViewController {
    
    var disposeBag = Set<AnyCancellable>()
    
    weak var context: AppContext! { willSet { precondition(!isViewLoaded) } }
    weak var coordinator: SceneCoordinator! { willSet { precondition(!isViewLoaded) } }
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SidebarEntryTableViewCell.self, forCellReuseIdentifier: String(describing: SidebarEntryTableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    class SettingsEntryTableView: UITableView { }

    private(set) lazy var settingsTableView: SettingsEntryTableView = {
        let tableView = SettingsEntryTableView()
        tableView.register(SidebarEntryTableViewCell.self, forCellReuseIdentifier: String(describing: SidebarEntryTableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        return tableView
    }()
    
    let settingsSeparatorLine = UIView.separatorLine
    
    private(set) lazy var viewModel = SidebarViewModel(context: context)
    
    deinit {
        os_log("%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)
    }
    
}

extension SidebarViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
                
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.layoutMarginsGuide.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),       // make not cross settings bottom
        ])
        
        settingsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settingsTableView)
        NSLayoutConstraint.activate([
            settingsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: settingsTableView.trailingAnchor),
            view.layoutMarginsGuide.bottomAnchor.constraint(equalTo: settingsTableView.bottomAnchor),
            settingsTableView.heightAnchor.constraint(equalToConstant: 56).priority(.defaultHigh),
        ])
        
        settingsSeparatorLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settingsSeparatorLine)
        NSLayoutConstraint.activate([
            settingsSeparatorLine.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            view.layoutMarginsGuide.trailingAnchor.constraint(equalTo: settingsSeparatorLine.trailingAnchor),
            settingsTableView.topAnchor.constraint(equalTo: settingsSeparatorLine.bottomAnchor),
            settingsSeparatorLine.heightAnchor.constraint(equalToConstant: UIView.separatorLineHeight(of: settingsSeparatorLine)).priority(.defaultHigh),
        ])
        
        tableView.delegate = self
        tableView.dataSource = viewModel
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = viewModel
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        print(view.frame)
//        view.layoutIfNeeded()
//    }

}

// MARK: - UITableViewDelegate
extension SidebarViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView === tableView {
            let section = SidebarViewModel.Section.allCases[indexPath.section]
            switch section {
            case .inbox:
                NotificationCenter.default.post(name: SidebarViewController.didSelectEntry, object: Entry.inbox)
            case .subInbox:
                break   // TODO:
            case .drafts:
                break   // TODO:
            case .contacts:
                NotificationCenter.default.post(name: SidebarViewController.didSelectEntry, object: Entry.contacts)
            case .plugins:
                break   // TODO:
            }
            
            dismiss(animated: true, completion: nil)
        }
        
        if tableView === settingsTableView {
            NotificationCenter.default.post(name: SidebarViewController.didSelectEntry, object: Entry.settings)
            dismiss(animated: true, completion: nil)
        }
    }
    
}

extension SidebarViewController {
    static let didSelectEntry = Notification.Name("SidebarViewController.didSelectEntry")
    enum Entry {
        case inbox
        case subinbox(contact: Contact)
        case drafts
        case contacts
        case plugins
        case settings
    }
}
