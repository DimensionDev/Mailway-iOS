//
//  ContactListContactTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-25.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI


final class ContactListContactTableViewCell: UITableViewCell {
    
    let avatarView = AvatarView()
    
    private let avatarViewContainer = UIView()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
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

extension ContactListContactTableViewCell {
    
    private func _init() {
        avatarViewContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarViewContainer)
        NSLayoutConstraint.activate([
            avatarViewContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            avatarViewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentView.bottomAnchor.constraint(equalTo: avatarViewContainer.bottomAnchor, constant: 16),
            avatarViewContainer.widthAnchor.constraint(equalToConstant: 40),
            avatarViewContainer.heightAnchor.constraint(equalToConstant: 40).priority(.defaultHigh),
        ])

        let hostingController = UIHostingController(rootView: avatarView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        avatarViewContainer.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: avatarViewContainer.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: avatarViewContainer.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: avatarViewContainer.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: avatarViewContainer.bottomAnchor),
        ])
        
        hostingController.view.backgroundColor = .clear

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarViewContainer.trailingAnchor, constant: 32),
            nameLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: avatarViewContainer.centerYAnchor),
        ])
                
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorLine)
        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: UIView.separatorLineHeight(of: separatorLine)).priority(.defaultHigh),
        ])
    }
    
}

#if DEBUG
struct ContactListContactTableViewCell_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let cell = ContactListContactTableViewCell()
            cell.nameLabel.text = "Alice"
            return cell
        }
        .previewLayout(.fixed(width: 320, height: 44))
    }
}
#endif
