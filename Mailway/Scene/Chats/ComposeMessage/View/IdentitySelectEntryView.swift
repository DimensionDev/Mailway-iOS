//
//  IdentitySelectEntryView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-17.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI

final class IdentitySelectEntryView: UIView {
    
    let colorBarView: UIView = {
        let bar = UIView()
        bar.backgroundColor = .systemPurple
        return bar
    }()
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.placeholder(color: .systemFill)
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = "-"
        return label
    }()
    
    let shortKeyIDLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.text = "-"
        label.textColor = .secondaryLabel
        return label
    }()
    
    let disclosureButton: UIButton = {
        let button = UIButton()
        button.setImage(Asset.Arrows.arrowtriangleDownFill.image, for: .normal)
        button.isHidden = true
        return button
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

extension IdentitySelectEntryView {
    
    private func _init() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 4),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor, multiplier: 1.0),
        ])
        
        colorBarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorBarView)
        NSLayoutConstraint.activate([
            colorBarView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            colorBarView.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            colorBarView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            colorBarView.widthAnchor.constraint(equalToConstant: 2),
            colorBarView.heightAnchor.constraint(equalToConstant: 32).priority(.defaultHigh),
        ])
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: colorBarView.trailingAnchor, constant: 16).priority(.defaultHigh),
            container.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 4),
        ])
        container.setContentHuggingPriority(.defaultLow, for: .horizontal)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        shortKeyIDLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(shortKeyIDLabel)
        NSLayoutConstraint.activate([
            shortKeyIDLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            shortKeyIDLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            shortKeyIDLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            shortKeyIDLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        
        disclosureButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(disclosureButton)
        NSLayoutConstraint.activate([
            disclosureButton.leadingAnchor.constraint(equalTo: container.trailingAnchor),
            disclosureButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            layoutMarginsGuide.trailingAnchor.constraint(equalTo: disclosureButton.trailingAnchor),
            disclosureButton.widthAnchor.constraint(equalToConstant: 24).priority(.defaultHigh),
            disclosureButton.heightAnchor.constraint(equalToConstant: 24).priority(.defaultHigh),
        ])
        

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width * 0.5
    }
    
}

#if DEBUG
struct IdentitySelectEntryView_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let entryView = IdentitySelectEntryView()
            entryView.nameLabel.text = "Alice"
            entryView.shortKeyIDLabel.text = "45cc 807c"
            return entryView
        }
        .previewLayout(.fixed(width: 311, height: 60))
    }
}
#endif