//
//  CreateContactEntryTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-14.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

final class CreateContactEntryTableViewCell: UITableViewCell {
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()
    
    let entryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
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

extension CreateContactEntryTableViewCell {
    
    private func _init() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 24).priority(.defaultHigh),
            iconImageView.heightAnchor.constraint(equalToConstant: 24).priority(.defaultHigh),
        ])
        
        entryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(entryLabel)
        NSLayoutConstraint.activate([
            entryLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            entryLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 32),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: entryLabel.trailingAnchor),
        ])
        
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorLine)
        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: entryLabel.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: entryLabel.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: UIView.separatorLineHeight(of: separatorLine)),
        ])
    }
    
}
