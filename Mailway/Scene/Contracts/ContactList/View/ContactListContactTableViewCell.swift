//
//  ContactListContactTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-25.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

final class ContactListContactTableViewCell: UITableViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
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

extension ContactListContactTableViewCell {
    
    private func _init() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
        ])
    }
    
}
