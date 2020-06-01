//
//  ChatRoomMessageTableViewCell.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI

final class ChatMessageTableViewCell: UITableViewCell {
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .label
        return imageView
    }()
    
    let senderContactInfoView = ContactInfoView()

    // Not use stack view spacing to avoid AutoLayout warning issue
    private(set) lazy var composeInfoContainer: UIView = {
        let container = UIView()
        
        composeTimestampLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(composeTimestampLabel)
        NSLayoutConstraint.activate([
            composeTimestampLabel.topAnchor.constraint(equalTo: container.topAnchor),
            composeTimestampLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            container.bottomAnchor.constraint(equalTo: composeTimestampLabel.bottomAnchor),
        ])
        let middlePaddingView = UIView()
        middlePaddingView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(middlePaddingView)
        NSLayoutConstraint.activate([
            middlePaddingView.topAnchor.constraint(equalTo: container.topAnchor),
            middlePaddingView.leadingAnchor.constraint(equalTo: composeTimestampLabel.trailingAnchor),
            middlePaddingView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            middlePaddingView.widthAnchor.constraint(equalToConstant: 4).priority(.defaultHigh),
        ])
        composeIconImageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(composeIconImageView)
        NSLayoutConstraint.activate([
            composeIconImageView.topAnchor.constraint(equalTo: container.topAnchor),
            composeIconImageView.leadingAnchor.constraint(equalTo: middlePaddingView.trailingAnchor),
            composeIconImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        let trailingPaddingView = UIView()
        trailingPaddingView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(trailingPaddingView)
        NSLayoutConstraint.activate([
            trailingPaddingView.topAnchor.constraint(equalTo: container.topAnchor),
            trailingPaddingView.leadingAnchor.constraint(equalTo: composeIconImageView.trailingAnchor),
            trailingPaddingView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            trailingPaddingView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            trailingPaddingView.widthAnchor.constraint(equalToConstant: 8).priority(.defaultHigh),
        ])
        
        return container
    }()

    let composeIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "signature",
                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .light))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        imageView.transform = CGAffineTransform(translationX: 0, y: -2)
        return imageView
    }()
    
    let composeTimestampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.text = "YYYY/MM/DD"
        label.textColor = .secondaryLabel
        return label
    }()
    
    private(set) lazy var receiveInfoContainer: UIView = {
        let container = UIView()
        
        receiveTimestampLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(receiveTimestampLabel)
        NSLayoutConstraint.activate([
            receiveTimestampLabel.topAnchor.constraint(equalTo: container.topAnchor),
            receiveTimestampLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            container.bottomAnchor.constraint(equalTo: receiveTimestampLabel.bottomAnchor),
        ])
        let middlePaddingView = UIView()
        middlePaddingView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(middlePaddingView)
        NSLayoutConstraint.activate([
            middlePaddingView.topAnchor.constraint(equalTo: container.topAnchor),
            middlePaddingView.leadingAnchor.constraint(equalTo: receiveTimestampLabel.trailingAnchor),
            middlePaddingView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            middlePaddingView.widthAnchor.constraint(equalToConstant: 4).priority(.defaultLow),
        ])
        receiveIconImageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(receiveIconImageView)
        NSLayoutConstraint.activate([
            receiveIconImageView.topAnchor.constraint(equalTo: container.topAnchor),
            receiveIconImageView.leadingAnchor.constraint(equalTo: middlePaddingView.trailingAnchor),
            receiveIconImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            receiveIconImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        
        return container
    }()
    
    let receiveIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "tray.and.arrow.down",
                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .light))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        imageView.transform = CGAffineTransform(translationX: 0, y: -1)
        return imageView
    }()
    
    let receiveTimestampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.text = "YYYY/MM/DD"
        label.textColor = .secondaryLabel
        return label
    }()
    
    let messageContentTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.font = .preferredFont(forTextStyle: .body)
        return textView
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

extension ChatMessageTableViewCell {
    
    private func _init() {
        selectionStyle = .none
        
        // header
        let headerStackView = UIStackView()
        headerStackView.axis = .horizontal
        headerStackView.spacing = 4
        
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerStackView)
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            headerStackView.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
            contentView.readableContentGuide.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor),            
        ])
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.addArrangedSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44).priority(.defaultHigh),
        ])

        let textContainerStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.distribution = .fillProportionally
            stackView.spacing = 0
            stackView.accessibilityIdentifier = "Text Container StackView"

            senderContactInfoView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(senderContactInfoView)

            let timestampStackView = UIStackView()
            timestampStackView.accessibilityIdentifier = "Timestamp StackView"
            timestampStackView.axis = .horizontal

            timestampStackView.addArrangedSubview(composeInfoContainer)
            timestampStackView.addArrangedSubview(receiveInfoContainer)
            timestampStackView.addArrangedSubview(UIView()) // padding
            
            stackView.addArrangedSubview(timestampStackView)
            return stackView
        }()
        headerStackView.addArrangedSubview(textContainerStackView)
        
        // content
        messageContentTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageContentTextView)
        NSLayoutConstraint.activate([
            messageContentTextView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor),
            messageContentTextView.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
            contentView.readableContentGuide.trailingAnchor.constraint(equalTo: messageContentTextView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: messageContentTextView.bottomAnchor).priority(.defaultHigh),
        ])
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 320, height: 200)
    }
    
}

struct ChatMessageTableViewCell_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            let cell = ChatMessageTableViewCell()
            cell.senderContactInfoView.nameLabel.text = "Alice"
            cell.senderContactInfoView.shortKeyIDLabel.text = String("0816fe6c1edebe9fbb83af9102ad9c899abec1a87a1d123bc24bf119035a2853".suffix(8)).uppercased()
            cell.composeTimestampLabel.text = {
                let date = Date().advanced(by: -1 * 24 * 60 * 60)
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                return dateFormatter.string(from: date)
            }()
            cell.receiveTimestampLabel.text = {
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                return dateFormatter.string(from: date)
            }()
            
            cell.messageContentTextView.text = """
            You knock on the door but nobody answers. Cupping your hands around your face you peer through the side-panel of frosted glass. A kettle is whistling, a woman singing as she sets the table. This is a familiar house. You knock again. Inside, the sounds are festive. Glasses clink and a band starts up. Pressing your ear to the door, you hear the sound of your own laughter. This is the house you grew up in. You're sure of it now.
            The revelers are boisterous, their dancing shadows on the lawn. Your legs are cold, there's frost on your shoes, and the cabby calls impatiently from the street. You remember a song that eluded you all day.
            """
            return cell
        }
        .previewLayout(.fixed(width: 320, height: 500))
    }
}
