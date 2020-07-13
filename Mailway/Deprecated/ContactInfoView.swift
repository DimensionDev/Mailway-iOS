//
//  ContactInfoView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-1.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI
//
//final class ContactInfoView: UIView {
//    
//    let nameLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 14, weight: .semibold)
//        label.textColor = .label
//        return label
//    }()
//    
//    let emailLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 14, weight: .regular)
//        label.textColor = .secondaryLabel
//        return label
//    }()
//    
//    let shortKeyIDLabel: UILabel = {
//        let label = UILabel()
//        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .semibold)
//        label.textColor = .systemGreen
//        label.textAlignment = .right
//        return label
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        _init()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        _init()
//    }
//    
//    private func _init() {
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(nameLabel)
//        NSLayoutConstraint.activate([
//            nameLabel.topAnchor.constraint(equalTo: topAnchor),
//            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//            bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor).priority(.defaultHigh),
//        ])
//        nameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        
//        emailLabel.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(emailLabel)
//        NSLayoutConstraint.activate([
//            emailLabel.topAnchor.constraint(equalTo: topAnchor),
//            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor,constant: 2),
//            bottomAnchor.constraint(equalTo: emailLabel.bottomAnchor).priority(.defaultHigh),
//        ])
//        emailLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        emailLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        
//        shortKeyIDLabel.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(shortKeyIDLabel)
//        NSLayoutConstraint.activate([
//            shortKeyIDLabel.topAnchor.constraint(equalTo: topAnchor),
//            shortKeyIDLabel.leadingAnchor.constraint(equalTo: emailLabel.trailingAnchor),
//            trailingAnchor.constraint(equalTo: shortKeyIDLabel.trailingAnchor).priority(.defaultHigh),
//            bottomAnchor.constraint(equalTo: shortKeyIDLabel.bottomAnchor).priority(.defaultHigh),
//        ])
//        shortKeyIDLabel.setContentHuggingPriority(.required, for: .horizontal)
//        shortKeyIDLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
//    }
//    
//}
//
//#if DEBUG
//struct ContactInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            UIViewPreview {
//                let view = ContactInfoView()
//                view.nameLabel.text = "Alice"
//                view.emailLabel.text = "alice@alice.com"
//                view.shortKeyIDLabel.text = String("0816fe6c1edebe9fbb83af9102ad9c899abec1a87a1d123bc24bf119035a2853".suffix(8)).uppercased()
//                return view
//            }
//            .environment(\.colorScheme, .light)
//            .previewLayout(.fixed(width: 320, height: 44))
//            
//            UIViewPreview {
//                let view = ContactInfoView()
//                view.nameLabel.text = "Alice"
//                view.emailLabel.text = "alice@alice.com"
//                view.shortKeyIDLabel.text = String("0816fe6c1edebe9fbb83af9102ad9c899abec1a87a1d123bc24bf119035a2853".suffix(8)).uppercased()
//                return view
//            }
//            .background(Color(.systemBackground))
//            .environment(\.colorScheme, .dark)
//            .previewLayout(.fixed(width: 320, height: 44))
//        }
//    }
//}
//#endif
