//
//  IdentityBannerView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-26.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI

final class IdentityBannerView: UIView {
    
    let personIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.square.fill")
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFill
        // imageView.layer.backgroundColor = UIColor.blue.cgColor
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
}

extension IdentityBannerView {
    
    private func _init() {
        backgroundColor = .systemBackground
        
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
        let personIconImageViewHeightLayoutConstraint = personIconImageView.heightAnchor.constraint(equalToConstant: 44)
        personIconImageViewHeightLayoutConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            personIconImageView.widthAnchor.constraint(equalToConstant: 44),
            personIconImageViewHeightLayoutConstraint,
        ])
        
        let textStackView = UIStackView()
        textStackView.axis = .vertical
        textStackView.distribution = .fillProportionally
        textStackView.addArrangedSubview(headerLabel)
        textStackView.addArrangedSubview(captionLabel)
        
        stackView.addArrangedSubview(textStackView)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 320, height: 44 + 16 * 2)
    }
    
}

struct IdentityBannerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                UIViewPreview {
                    IdentityBannerView()
                }
                .previewLayout(.sizeThatFits)
                .environment(\.colorScheme, colorScheme)
                .previewDisplayName("\(colorScheme)")
            }
        }
    }
}
