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
    
    private lazy var avatarView = AvatarView(viewModel: avatarViewModel)
    let avatarViewModel = AvatarViewModel()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Name"
        return label
    }()
    
    let shortKeyIDLabel: UILabel = {
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
        
        let hostingController = UIHostingController(rootView: avatarView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: colorBarView.trailingAnchor, constant: 18),
            hostingController.view.centerYAnchor.constraint(equalTo: centerYAnchor),
            hostingController.view.widthAnchor.constraint(equalToConstant: 48).priority(.defaultHigh),
            hostingController.view.heightAnchor.constraint(equalToConstant: 48).priority(.defaultHigh),
        ])
        hostingController.view.backgroundColor = .clear
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: hostingController.view.trailingAnchor, constant: 24).priority(.defaultHigh),
            layoutMarginsGuide.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        container.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        
        shortKeyIDLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(shortKeyIDLabel)
        NSLayoutConstraint.activate([
            shortKeyIDLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            shortKeyIDLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            shortKeyIDLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            shortKeyIDLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
    }
    
}

#if DEBUG
struct IdentityCardView_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let card = IdentityCardView()
            card.nameLabel.text = "Alice"
            card.shortKeyIDLabel.text = "45cc 807c"
            return card
        }
        .previewLayout(.fixed(width: 311, height: 80))
    }
}
#endif
