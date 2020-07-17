//
//  IdentitySelectionEntryTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-17.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

final class IdentitySelectionEntryTableViewCell: UITableViewCell {
    
    let entryView = IdentitySelectEntryView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
}

extension IdentitySelectionEntryTableViewCell {
    
    private func _init() {
        entryView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(entryView)
        NSLayoutConstraint.activate([
            entryView.topAnchor.constraint(equalTo: contentView.topAnchor),
            entryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            entryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            entryView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
}
