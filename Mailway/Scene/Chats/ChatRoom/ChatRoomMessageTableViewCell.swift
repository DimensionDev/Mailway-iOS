//
//  ChatRoomMessageTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit

final class ChatRoomMessageTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
}

extension ChatRoomMessageTableViewCell {
    
    private func _init() {
        
    }
    
}
