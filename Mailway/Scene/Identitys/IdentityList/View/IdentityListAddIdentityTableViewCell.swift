//
//  IdentityListAddIdentityTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

protocol IdentityListAddIdentityTableViewCellDelegate: class {
    func identityListAddIdentityTableViewCell(_ cell: IdentityListAddIdentityTableViewCell, addButtonDidPressed button: UIButton)
}

final class IdentityListAddIdentityTableViewCell: UITableViewCell {
    
    weak var delegate: IdentityListAddIdentityTableViewCellDelegate?
    
    let addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage.placeholder(color: Asset.Color.Background.blue.color), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Add Identity".uppercased(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.0, weight: .medium)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4
        return button
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

extension IdentityListAddIdentityTableViewCell {
    
    private func _init() {
        selectionStyle = .none
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40.0),
            addButton.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: addButton.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: addButton.bottomAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 36.0).priority(.defaultHigh),
        ])
        
        addButton.addTarget(self, action: #selector(IdentityListAddIdentityTableViewCell.addButtonPressed(_:)), for: .touchUpInside)
    }
    
}

extension IdentityListAddIdentityTableViewCell {
    
    @objc private func addButtonPressed(_ sender: UIButton) {
        delegate?.identityListAddIdentityTableViewCell(self, addButtonDidPressed: sender)
    }
    
}
