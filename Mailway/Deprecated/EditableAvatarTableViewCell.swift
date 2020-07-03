//
//  EditableAvatarTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

final class EditableAvatarTableViewCell: UITableViewCell {
    
    let editableAvatarView = EditableAvatarView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
}

extension EditableAvatarTableViewCell {
    
    private func _init() {
        selectionStyle = .none
        
        editableAvatarView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(editableAvatarView)
        NSLayoutConstraint.activate([
            editableAvatarView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            editableAvatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            contentView.bottomAnchor.constraint(equalTo: editableAvatarView.bottomAnchor, constant: 16),
        ])
    }
    
}
