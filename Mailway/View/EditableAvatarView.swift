//
//  EditableAvatarView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI

final class EditableAvatarView: UIView {
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage.placeholder(color: .systemFill)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 72.0 * 0.5
        return imageView
    }()
    
    let editButton: UIButton = {
        let button = HitTestExpandedButton()
        button.setImage(Asset.Editing.pencil.image, for: .normal)
        button.setBackgroundImage(UIImage.placeholder(color: Asset.Color.Background.blue.color), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 24.0 * 0.5
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

extension EditableAvatarView {
    
    private func _init() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 72.0),
            avatarImageView.heightAnchor.constraint(equalToConstant: 72.0).priority(.defaultHigh),
        ])
        
        editButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(editButton)
        NSLayoutConstraint.activate([
            editButton.centerYAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            editButton.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            bottomAnchor.constraint(equalTo: editButton.bottomAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 24.0),
            editButton.heightAnchor.constraint(equalToConstant: 24.0).priority(.defaultHigh),
        ])
        
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 72, height: 72 + 0.5 * 24)
    }
    
}

#if DEBUG
struct EditableAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            return EditableAvatarView()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
