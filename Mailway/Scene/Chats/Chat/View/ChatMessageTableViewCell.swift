//
//  ChatRoomMessageTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI

protocol ChatMessageTableViewCellDelegate: class {
    func chatMessageTableViewCell(_ cell: ChatMessageTableViewCell, replyButtonPressed button: UIButton)
    func chatMessageTableViewCell(_ cell: ChatMessageTableViewCell, moreButtonPressed button: UIButton)
}

final class ChatMessageTableViewCell: UITableViewCell {
    
    weak var delegate: ChatMessageTableViewCellDelegate?
    
    private lazy var avatarView = AvatarView(viewModel: avatarViewModel)
    let avatarViewModel = AvatarViewModel()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = "<Unknown>"
        return label
    }()
    
    let replyButton: UIButton = {
        let button = HitTestExpandedButton(type: .system)
        button.expandEdgeInsets = UIEdgeInsets(top: -12, left: -12, bottom: -12, right: -12)
        let image = Asset.Communication.arrowshapeTurnUpLeftFill.image.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.label.withAlphaComponent(0.54)
        return button
    }()
    
    let moreButton: UIButton = {
        let button = HitTestExpandedButton(type: .system)
        button.expandEdgeInsets = UIEdgeInsets(top: -12, left: -12, bottom: -12, right: -12)
        let image = Asset.Editing.moreVertical.image.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.label.withAlphaComponent(0.54)
        return button
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 3
        label.textColor = .secondaryLabel
        label.contentMode = .top
        return label
    }()
    
    let receiveTimestampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.text = "-"
        label.textColor = .secondaryLabel
        return label
    }()
    
    let separatorLine = UIView.separatorLine
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
}

extension ChatMessageTableViewCell {
    
    private func _init() {
        selectionStyle = .none
        
        let hostingController = UIHostingController(rootView: avatarView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            hostingController.view.widthAnchor.constraint(equalToConstant: 32).priority(.defaultHigh),
            hostingController.view.heightAnchor.constraint(equalToConstant: 32).priority(.defaultHigh),
        ])
        hostingController.view.backgroundColor = .clear
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: hostingController.view.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: hostingController.view.trailingAnchor, constant: 16),
        ])
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        replyButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(replyButton)
        NSLayoutConstraint.activate([
            replyButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            replyButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 16),
        ])
        
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(moreButton)
        NSLayoutConstraint.activate([
            moreButton.centerYAnchor.constraint(equalTo: replyButton.centerYAnchor),
            moreButton.leadingAnchor.constraint(equalTo: replyButton.trailingAnchor, constant: 24),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: moreButton.trailingAnchor),
        ])
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: hostingController.view.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor),
        ])
        
        receiveTimestampLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(receiveTimestampLabel)
        NSLayoutConstraint.activate([
            receiveTimestampLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 13),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: receiveTimestampLabel.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: receiveTimestampLabel.bottomAnchor, constant: 13),
        ])
        
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorLine)
        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: separatorLine.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: UIView.separatorLineHeight(of: separatorLine)),
        ])
        
        replyButton.addTarget(self, action: #selector(ChatMessageTableViewCell.replyButtonPressed(_:)), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(ChatMessageTableViewCell.moreButtonPressed(_:)), for: .touchUpInside)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 320, height: 200)
    }
    
}

extension ChatMessageTableViewCell {
    
    @objc private func replyButtonPressed(_ sender: UIButton) {
        delegate?.chatMessageTableViewCell(self, replyButtonPressed: sender)
    }
    
    @objc private func moreButtonPressed(_ sender: UIButton) {
        delegate?.chatMessageTableViewCell(self, moreButtonPressed: sender)
    }
    
}

#if DEBUG
struct ChatMessageTableViewCell_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let cell = ChatMessageTableViewCell()
            cell.nameLabel.text = "Alice"
            cell.receiveTimestampLabel.text = {
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                return dateFormatter.string(from: date)
            }()
            
            cell.messageLabel.text = """
            You knock on the door but nobody answers. Cupping your hands around your face you peer through the side-panel of frosted glass. A kettle is whistling, a woman singing as she sets the table. This is a familiar house. You knock again. Inside, the sounds are festive. Glasses clink and a band starts up. Pressing your ear to the door, you hear the sound of your own laughter. This is the house you grew up in. You're sure of it now.
            The revelers are boisterous, their dancing shadows on the lawn. Your legs are cold, there's frost on your shoes, and the cabby calls impatiently from the street. You remember a song that eluded you all day.
            """
            return cell
        }
        .previewLayout(.fixed(width: 320, height: 200))
    }
}
#endif
