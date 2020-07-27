//
//  PickColorItemCollectionViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-21.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

final class PickColorItemCollectionViewCell: UICollectionViewCell {
    
    var disposeBag = Set<AnyCancellable>()
    
    let colorWallView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        view.backgroundColor = .systemPurple
        return view
    }()
    
    let colorWallHighlightBorderView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 18
        view.backgroundColor = .clear
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.systemPurple.cgColor
        view.isHidden = true
        return view
    }()
    
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
        
        disposeBag = Set()
        colorWallHighlightBorderView.isHidden = true
    }
    
}

extension PickColorItemCollectionViewCell {
    
    private func _init() {
        colorWallHighlightBorderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorWallHighlightBorderView)
        NSLayoutConstraint.activate([
            colorWallHighlightBorderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorWallHighlightBorderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorWallHighlightBorderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorWallHighlightBorderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        colorWallView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorWallView)
        NSLayoutConstraint.activate([
            colorWallView.topAnchor.constraint(equalTo: colorWallHighlightBorderView.topAnchor, constant: 3 + 3),
            colorWallView.leadingAnchor.constraint(equalTo: colorWallHighlightBorderView.leadingAnchor, constant: 3 + 3),
            colorWallHighlightBorderView.trailingAnchor.constraint(equalTo: colorWallView.trailingAnchor, constant: 3 + 3),
            colorWallHighlightBorderView.bottomAnchor.constraint(equalTo: colorWallView.bottomAnchor, constant: 3 + 3),
        ])
    }

}

struct PickColorItemCollectionViewCell_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            PickColorItemCollectionViewCell()
        }
        .frame(width: 44, height: 44)
        .previewLayout(.fixed(width: 100, height: 100))
    }
}
