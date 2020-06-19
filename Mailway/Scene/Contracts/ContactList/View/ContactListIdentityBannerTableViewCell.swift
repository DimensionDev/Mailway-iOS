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
    
    let bannerView = IdentityBannerView()
    
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
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bannerView)
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: bannerView.trailingAnchor),
            bottomAnchor.constraint(equalTo: bannerView.bottomAnchor),
        ])
    }
    
}

#if DEBUG
struct ContactListIdentityBannerTableViewCell_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            ContactListIdentityBannerTableViewCell()
        }
        .previewLayout(.fixed(width: 320, height: 44 + 16 * 2))
    }
}
#endif
