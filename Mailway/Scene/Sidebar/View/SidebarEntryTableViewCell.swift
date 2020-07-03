//
//  SidebarEntryTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-23.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI

final class SidebarEntryView: UIView {
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .label
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

extension SidebarEntryView {
    
    private func _init() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor,constant: 16),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
        ])
        iconImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        iconImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 32),
            trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
    }
}


struct SidebarEntryView_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let view = SidebarEntryView()
            view.iconImageView.image = Asset.Sidebar.inbox.image
            view.titleLabel.text = "Inbox"
            return view
        }
        .previewLayout(.fixed(width: 320, height: 320))
    }
}


final class SidebarEntryTableViewCell: UITableViewCell {
    
    let entryView = SidebarEntryView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
}

extension SidebarEntryTableViewCell {
    
    private func _init() {
        backgroundColor = .clear
        
        entryView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(entryView)
        NSLayoutConstraint.activate([
            entryView.topAnchor.constraint(equalTo: contentView.topAnchor),
            entryView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: entryView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: entryView.bottomAnchor),
        ])
    }
    
}
