//
//  ContactListIdentityCardCollectionTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-9.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI

final class ContactListIdentityCardCollectionTableViewCell: UITableViewCell {
    
    static let collectionViewTag = 83543
    
    static let itemHeight: CGFloat = IdentityCardCollectionViewCell.height
    static let itemTopPadding: CGFloat = 12
    static let itemBottomPadding: CGFloat = 24
    static let itemSpacing: CGFloat = 16
    static let itemPeeking: CGFloat = 16
    
    static let sectionHeight: CGFloat = itemHeight + itemTopPadding + itemBottomPadding
    
    let collectionViewLayout: UICollectionViewFlowLayout = {
        let collectionFlowLayout = SnappingCollectionViewLayout()
        collectionFlowLayout.scrollDirection = .horizontal      // scroll horizontal
        return collectionFlowLayout
    }()
    
    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(IdentityCardCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: IdentityCardCollectionViewCell.self))
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.tag = ContactListIdentityCardCollectionTableViewCell.collectionViewTag
        collectionView.decelerationRate = .fast
        return collectionView
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

extension ContactListIdentityCardCollectionTableViewCell {
    
    private func _init() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: ContactListIdentityCardCollectionTableViewCell.sectionHeight).priority(.defaultHigh),
        ])
        
        collectionView.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionViewLayout.invalidateLayout()
    }
    
}

#if DEBUG
struct ContactListIdentityCardCollectionTableViewCell_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            ContactListIdentityCardCollectionTableViewCell()
        }
        .frame(width: 375, height: 100)
        .previewLayout(.sizeThatFits)
    }
}
#endif
