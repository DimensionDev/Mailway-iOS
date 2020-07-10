//
//  IdentityCardCollectionViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-9.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

final class IdentityCardCollectionViewCell: UICollectionViewCell {
    
    // static let cardVerticalMargin: CGFloat = 8
    // let walletCardView = WalletCardView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
}

extension IdentityCardCollectionViewCell {
    
    private func _init() {
        // Setup appearance
        clipsToBounds = false
        
//        walletCardView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(walletCardView)
//        NSLayoutConstraint.activate([
//            walletCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: WalletCardCollectionViewCell.cardVerticalMargin),
//            walletCardView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: walletCardView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: walletCardView.bottomAnchor, constant: WalletCardCollectionViewCell.cardVerticalMargin),
//        ])
    }
    
}
