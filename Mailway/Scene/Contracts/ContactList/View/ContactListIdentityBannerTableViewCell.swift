//
//  ContactListIdentityTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-25.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

final class ContactListIdentityBannerTableViewCell: UITableViewCell {
    
    var disposeBag = Set<AnyCancellable>()
    
    let personIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.square.fill")
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "My Identity"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to add identity"
        label.font = .systemFont(ofSize: 11, weight: .regular)
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag.removeAll()
    }

}

extension ContactListIdentityBannerTableViewCell {
    
    private func _init() {        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
        ])
        
        stackView.addArrangedSubview(personIconImageView)
        NSLayoutConstraint.activate([
            personIconImageView.widthAnchor.constraint(equalToConstant: 44),
            personIconImageView.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        let textStackView = UIStackView()
        textStackView.axis = .vertical
        textStackView.distribution = .fillProportionally
        textStackView.addArrangedSubview(headerLabel)
        textStackView.addArrangedSubview(captionLabel)
        
        stackView.addArrangedSubview(textStackView)
    }
    
}

