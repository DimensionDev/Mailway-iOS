//
//  ChatListChatRoomTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI

final class ChatListChatRoomTableViewCell: UITableViewCell {
    
    private lazy var avatarView = AvatarView(viewModel: avatarViewModel)
    let avatarViewModel = AvatarViewModel()

    let colorBarView: UIView = {
        let bar = UIView()
        bar.backgroundColor = .systemPurple
        return bar
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.text = "Detail"
        label.font = .systemFont(ofSize: 12, weight: .regular)
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

extension ChatListChatRoomTableViewCell {
    
    private func _init() {
        let hostingController = UIHostingController(rootView: avatarView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: hostingController.view.bottomAnchor, constant: 16),
            hostingController.view.widthAnchor.constraint(equalToConstant: 40),
            hostingController.view.heightAnchor.constraint(equalToConstant: 40).priority(.defaultHigh),
        ])
        hostingController.view.backgroundColor = .clear
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: hostingController.view.trailingAnchor, constant: 24),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            containerView.centerYAnchor.constraint(equalTo: hostingController.view.centerYAnchor),
        ])
        
        colorBarView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorBarView)
        NSLayoutConstraint.activate([
            colorBarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            colorBarView.widthAnchor.constraint(equalToConstant: 2),
            colorBarView.heightAnchor.constraint(equalToConstant: 12).priority(.defaultHigh),
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: colorBarView.trailingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: colorBarView.centerYAnchor),
        ])
        
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(detailLabel)
        NSLayoutConstraint.activate([
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            detailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            detailLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 320, height: 44 + 8 * 2)
    }
    
}

#if DEBUG
struct ChatListChatRoomTableViewCell_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            ChatListChatRoomTableViewCell()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
