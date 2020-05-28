//
//  ChatListChatRoomTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

final class ChatListChatRoomTableViewCell: UITableViewCell {
    
    let chatRoomIconImageView: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
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

extension ChatListChatRoomTableViewCell {
    
    private func _init() {
        
    }
    
}
