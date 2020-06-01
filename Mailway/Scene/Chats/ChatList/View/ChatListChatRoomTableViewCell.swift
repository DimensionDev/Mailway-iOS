//
//  ChatListChatRoomTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

final class ChatListChatRoomTableViewCell: UITableViewCell {
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.tintColor = .label
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
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

extension ChatListChatRoomTableViewCell {
    
    private func _init() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)
        let chatRoomIconImageViewHeightLayoutConstraint = iconImageView.heightAnchor.constraint(equalToConstant: 44)
        chatRoomIconImageViewHeightLayoutConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            iconImageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            iconImageView.widthAnchor.constraint(equalToConstant: 44),
            chatRoomIconImageViewHeightLayoutConstraint,
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 320, height: 44 + 8 * 2)
    }
    
}
