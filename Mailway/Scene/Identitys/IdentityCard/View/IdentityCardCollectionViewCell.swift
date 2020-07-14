//
//  IdentityCardCollectionViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-9.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI

final class IdentityCardCollectionViewCell: UICollectionViewCell {
    
    static let height: CGFloat = 80
    let identityCardView = IdentityCardView()
    
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
        identityCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(identityCardView)
        NSLayoutConstraint.activate([
            identityCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            identityCardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: identityCardView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: identityCardView.bottomAnchor),
        ])
        
        identityCardView.backgroundColor = .systemBackground
        identityCardView.layer.masksToBounds = true
        identityCardView.layer.cornerRadius = 16
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.setupShadow(color: UIColor.black.withAlphaComponent(0.06), alpha: 1, x: 0, y: 9, blur: 46, spread: 0, roundedRect: contentView.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 16, height: 16))
    }
    
}

#if DEBUG
struct IdentityCardCollectionViewCell_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let cell = IdentityCardCollectionViewCell()
            cell.identityCardView.nameLabel.text = "Alice"
            cell.identityCardView.shortKeyIDLabel.text = "45cc 807c"
            return cell
        }
        .frame(width: 311, height: 80)
        .padding()
        .background(Color(UIColor.systemBackground))
        .previewLayout(.sizeThatFits)
    }
}
#endif
