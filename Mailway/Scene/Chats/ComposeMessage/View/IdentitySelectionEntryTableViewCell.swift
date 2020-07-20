//
//  IdentitySelectionEntryTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-17.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import Combine

final class IdentitySelectionEntryTableViewCell: UITableViewCell {
    
    var disposeBag = Set<AnyCancellable>()
    let entryView = IdentitySelectEntryView()
    var entryViewHeightLayoutConstraint: NSLayoutConstraint!
    
    // workaround shadow overlap
    let topShadowView = UIView()
    let bottomShadowView = UIView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = Set()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
}

extension IdentitySelectionEntryTableViewCell {
    
    private func _init() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.backgroundColor = .systemBackground
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10     // same view controller modal corner

        entryView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(entryView)
        entryViewHeightLayoutConstraint = entryView.heightAnchor.constraint(equalToConstant: 44.0)
        entryViewHeightLayoutConstraint.priority = .required - 1
        NSLayoutConstraint.activate([
            entryView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            entryView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            entryView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            entryView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            entryViewHeightLayoutConstraint,
        ])
        
        topShadowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topShadowView)
        NSLayoutConstraint.activate([
            topShadowView.topAnchor.constraint(equalTo: topAnchor),
            topShadowView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topShadowView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        bottomShadowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomShadowView)
        NSLayoutConstraint.activate([
            bottomShadowView.topAnchor.constraint(equalTo: topShadowView.bottomAnchor),
            bottomShadowView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomShadowView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomShadowView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomShadowView.heightAnchor.constraint(equalTo: topShadowView.heightAnchor, multiplier: 1.0),
        ])
        
        bringSubviewToFront(contentView)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.contentView.backgroundColor = highlighted ? .secondarySystemBackground : .systemBackground
            }
        } else {
            self.contentView.backgroundColor = highlighted ? .secondarySystemBackground : .systemBackground
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.contentView.backgroundColor = selected ? .secondarySystemBackground : .systemBackground
            }
        } else {
            self.contentView.backgroundColor = selected ? .secondarySystemBackground : .systemBackground
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topShadowView.layer.setupShadow(color: UIColor.black.withAlphaComponent(0.12), alpha: 1, x: 0, y: 6, blur: 30, spread: 0, roundedRect: topShadowView.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 10))
        bottomShadowView.layer.setupShadow(color: UIColor.black.withAlphaComponent(0.12), alpha: 1, x: 0, y: 6, blur: 30, spread: 0, roundedRect: bottomShadowView.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 10))
    }
    
}
