//
//  SettingEntryTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

final class SettingEntryTableViewCell: UITableViewCell {
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.tintColor = .label
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
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

extension SettingEntryTableViewCell {
    
    private func _init() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconImageView)
        let chatRoomIconImageViewHeightLayoutConstraint = iconImageView.heightAnchor.constraint(equalToConstant: 24)
        chatRoomIconImageViewHeightLayoutConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            chatRoomIconImageViewHeightLayoutConstraint,
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 32),
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            contentView.readableContentGuide.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
        
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorLine)
        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: separatorLine.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: UIView.separatorLineHeight(of: separatorLine)).priority(.defaultHigh),
        ])
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 320, height: 44 + 8 * 2)
    }
    
}
