//
//  IdentityCardView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-9.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI

final class IdentityCardView: UIView {
    
    let colorBarView: UIView = {
        let bar = UIView()
        bar.backgroundColor = .systemPurple
        bar.layer.masksToBounds = true
        bar.layer.cornerRadius = 6 * 0.5
        return bar
    }()
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.placeholder(color: .systemFill)
        imageView.contentMode = .scaleToFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 48 * 0.5
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Name"
        return label
    }()
    
    let keyIDLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.text = "-"
        label.textColor = .secondaryLabel
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

extension IdentityCardView {
    
    private func _init() {
        colorBarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorBarView)
        NSLayoutConstraint.activate([
            colorBarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            colorBarView.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorBarView.widthAnchor.constraint(equalToConstant: 6),
            colorBarView.heightAnchor.constraint(equalToConstant: 28).priority(.defaultHigh),
        ])
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: colorBarView.trailingAnchor, constant: 18),
            avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 48),
            avatarImageView.heightAnchor.constraint(equalToConstant: 48).priority(.defaultHigh),
        ])
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 24),
            layoutMarginsGuide.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        
        keyIDLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(keyIDLabel)
        NSLayoutConstraint.activate([
            keyIDLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            keyIDLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            keyIDLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            keyIDLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
    }
    
}

#if DEBUG
struct IdentityCardView_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            IdentityCardView()
        }
        .previewLayout(.fixed(width: 311, height: 80))
    }
}
#endif
