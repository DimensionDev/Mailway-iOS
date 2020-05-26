//
//  CreateChatGroupTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-26.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI

final class CreateChatGroupTableViewCell: UITableViewCell {
    
    let personIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.2.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .label
        return imageView
    }()
    
    let promptLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Group Chat"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
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

extension CreateChatGroupTableViewCell {
    
    private func _init() {
        let stackView = UIStackView()
        stackView.spacing = 8
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            trailingAnchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor),
            bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12),
        ])
        
        personIconImageView.translatesAutoresizingMaskIntoConstraints = false
        let personIconImageViewHeightLayoutContraint = personIconImageView.heightAnchor.constraint(equalToConstant: 20)
        personIconImageViewHeightLayoutContraint.priority = .defaultHigh
        stackView.addArrangedSubview(personIconImageView)
        NSLayoutConstraint.activate([
            personIconImageView.widthAnchor.constraint(equalToConstant: 20),
            personIconImageViewHeightLayoutContraint,
        ])
        
        stackView.addArrangedSubview(promptLabel)
    }
    
}

struct CreateChatGroupTableViewCell_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            CreateChatGroupTableViewCell()
        }
        .previewLayout(.fixed(width: 320, height: 44))
    }
}
