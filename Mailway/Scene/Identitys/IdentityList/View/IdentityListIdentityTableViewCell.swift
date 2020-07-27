//
//  IdentityListIdentityTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-25.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI

final class IdentityListIdentityTableViewCell: UITableViewCell {

    private lazy var avatarView = AvatarView(viewModel: avatarViewModel)
    let avatarViewModel = AvatarViewModel()
    
    let colorBarView: UIView = {
        let bar = UIView()
        bar.backgroundColor = .systemPurple
        return bar
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    let keyIDLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    let separatorLine = UIView.separatorLine
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
}

extension IdentityListIdentityTableViewCell {
    
    private func _init() {
        let hostingController = UIHostingController(rootView: avatarView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: hostingController.view.bottomAnchor, constant: 18),
            hostingController.view.widthAnchor.constraint(equalToConstant: 40),
            hostingController.view.heightAnchor.constraint(equalToConstant: 40).priority(.defaultHigh),
        ])
        hostingController.view.backgroundColor = .clear
        
        colorBarView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorBarView)
        NSLayoutConstraint.activate([
            colorBarView.leadingAnchor.constraint(equalTo: hostingController.view.trailingAnchor, constant: 16),
            colorBarView.centerYAnchor.constraint(equalTo: hostingController.view.centerYAnchor),
            colorBarView.widthAnchor.constraint(equalToConstant: 2),
            colorBarView.heightAnchor.constraint(equalToConstant: 40 - 2 * 4),
        ])
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: colorBarView.trailingAnchor, constant: 16),
            container.centerYAnchor.constraint(equalTo: colorBarView.centerYAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        
        keyIDLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(keyIDLabel)
        NSLayoutConstraint.activate([
            keyIDLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            keyIDLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            keyIDLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            keyIDLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorLine)
        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: UIView.separatorLineHeight(of: separatorLine)).priority(.defaultHigh),
        ])
    }
    
}
