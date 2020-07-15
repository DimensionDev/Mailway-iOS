//
//  CreateContactBannerTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-14.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

final class CreateContactBannerTableViewCell: UITableViewCell {
    
    let bannerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Asset.Banner.createContactEntry.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let promptLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = L10n.CreateContact.prompt
        label.numberOfLines = 0
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

extension CreateContactBannerTableViewCell {
    
    private func _init() {
        selectionStyle = .none
        
        bannerImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bannerImageView)
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            bannerImageView.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
            contentView.readableContentGuide.trailingAnchor.constraint(equalTo: bannerImageView.trailingAnchor),
            bannerImageView.heightAnchor.constraint(equalToConstant: 188),
        ])
        
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(promptLabel)
        NSLayoutConstraint.activate([
            promptLabel.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: 48),
            promptLabel.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
            contentView.readableContentGuide.trailingAnchor.constraint(equalTo: promptLabel.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 40),
        ])
    }
    
}
