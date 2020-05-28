//
//  ChatListInboxBannerTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

final class ChatListInboxBannerView: UIView {
    
    let inboxIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "tray.and.arrow.down.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Inbox"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
}

extension ChatListInboxBannerView {
    
    private func _init() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            trailingAnchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor),
            bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
        ])
        
        inboxIconImageView.translatesAutoresizingMaskIntoConstraints = false
        let inboxIconImageViewHeightLayoutConstraint = inboxIconImageView.heightAnchor.constraint(equalToConstant: 44)
        inboxIconImageViewHeightLayoutConstraint.priority = .defaultHigh
        stackView.addArrangedSubview(inboxIconImageView)
        NSLayoutConstraint.activate([
            inboxIconImageView.widthAnchor.constraint(equalToConstant: 44),
            inboxIconImageViewHeightLayoutConstraint,
        ])
        
        stackView.addArrangedSubview(headerLabel)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 320, height: 44 + 16 * 2)
    }
    
}

final class ChatListInboxBannerTableViewCell: UITableViewCell {
    
    let bannerView = ChatListInboxBannerView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
}

extension ChatListInboxBannerTableViewCell {
    
    private func _init() {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bannerView)
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: bannerView.trailingAnchor),
            bottomAnchor.constraint(equalTo: bannerView.bottomAnchor),
        ])
    }
    
}

