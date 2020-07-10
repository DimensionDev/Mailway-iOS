//
//  IdentityCardCollectionTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-9.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

final class IdentityCardCollectionTableViewCell: UITableViewCell {
    
    static let height: CGFloat = 80
    static let collectionViewTag = 83543
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
}

extension IdentityCardCollectionTableViewCell {
    
    private func _init() {
        
    }
    
}
