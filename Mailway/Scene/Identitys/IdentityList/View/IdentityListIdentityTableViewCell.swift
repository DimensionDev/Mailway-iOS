//
//  IdentityListIdentityTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-25.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

final class IdentityListIdentityTableViewCell: UITableViewCell {
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.placeholder(color: .systemFill)
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .label
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 40 * 0.5
        return imageView
    }()
    
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
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()
    
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
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 18),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40).priority(.defaultHigh),
        ])
        
        colorBarView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorBarView)
        NSLayoutConstraint.activate([
            colorBarView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            colorBarView.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
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
    }
    
}
