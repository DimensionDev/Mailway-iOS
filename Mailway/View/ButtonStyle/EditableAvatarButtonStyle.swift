//
//  EditableAvatarButtonStyle.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import SwiftUI

struct AvatarBottomAlignmentID: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        return context.height
    }
}

extension VerticalAlignment {
    static let avatarBottomAlignment = VerticalAlignment(AvatarBottomAlignmentID.self)
}

struct AvatarButtonStyle: ButtonStyle {
    
    @State var avatarImage = UIImage.placeholder(color: .systemFill)
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .avatarBottomAlignment)) {
            Image(uiImage: avatarImage)
                .resizable()
                .scaledToFill()
                .frame(width: 72.0, height: 72.0)
                .overlay(configuration.isPressed ? Color(UIColor(white: 0, alpha: 0.2)) : Color.clear)
                .cornerRadius(72.0 * 0.5, antialiased: true)
            Image(uiImage: Asset.Editing.pencil.image)
                .frame(width: 24.0, height: 24.0)
                .background(Color(Asset.Color.Background.blue.color))
                .overlay(configuration.isPressed ? Color(UIColor(white: 0, alpha: 0.2)) : Color.clear)
                .cornerRadius(24.0 * 0.5)
                .alignmentGuide(.avatarBottomAlignment) { dimension -> CGFloat in
                    return dimension[.avatarBottomAlignment] - 24.0 * 0.5
            }
        }
    }
}

struct EditableAvatarButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button("Edit Avatar", action: {
            print("Tap")
        })
        .buttonStyle(AvatarButtonStyle())
        .previewLayout(.sizeThatFits)
    }
}
