//
//  ProfileView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-9.
//  Copyright © 2020 Dimension. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    
    @Binding var avatar: UIImage
    @Binding var name: String
    @Binding var shortKeyID: String
    var shareProfileAction: () -> ()
    @Binding var contactInfoDict: [ContactInfo.InfoType: [ContactInfo]]
    @Binding var note: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // avatar
                ProfileAvatarView(avatar: $avatar)
                // 32pt padding
                Color.clear.frame(width: .leastNonzeroMagnitude, height: 32)
                // name
                Text(name)
                    .font(.system(size: 24, weight: .regular))
                // 16pt padding
                Color.clear.frame(width: .leastNonzeroMagnitude, height: 16)
                // KeyID
                VStack(spacing: 4) {
                    Text("KeyID")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.secondaryLabel))
                    Text(shortKeyID)
                        .font(.system(size: 14))
                }
                // 16pt padding
                Color.clear.frame(width: .leastNonzeroMagnitude, height: 16)
                // share button
                Button("Share Profile", action: {
                    self.shareProfileAction()
                }).buttonStyle(LargeRoundedButtonStyle(title: "Share Profile"))
                // 32pt padding
                Color.clear.frame(width: .leastNonzeroMagnitude, height: 32)
                // info section
                infoSections
                // note section
                noteSection
            }
        }
    }
    
    var infoSections: some View {
        ForEach(ContactInfo.InfoType.allCases, id: \.self) { type in
            Group {
                // section header
                if !((self.contactInfoDict[type] ?? []).isEmpty) {
                    Text(type.editSectionName)
                        .modifier(TextSectionHeaderStyleModifier())
                    // info cell
                    ForEach(Array((self.contactInfoDict[type] ?? []).enumerated()), id: \.1.id) { index, info in
                        Group {
                            // top padding
                            Color.clear.frame(width: .leastNonzeroMagnitude, height: 8.0)
                            if type == .custom {
                                Text(info.key)
                                    .font(.system(size: 16))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Text(info.value)
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            // bottom padding
                            Color.clear.frame(width: .leastNonzeroMagnitude, height: 8.0)
                        }
                    }
                    // 24pt padding
                    Color.clear.frame(width: .leastNonzeroMagnitude, height: 24)
                }
            }
        }
        .padding([.leading, .trailing])
    }
    
    var noteSection: some View {
        Group {
            if !note.isEmpty {
                Text("Note")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(UIColor.label.withAlphaComponent(0.6)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                // 8pt padding
                Color.clear.frame(width: .leastNonzeroMagnitude, height: 8.0)
                Text(note)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                // 24pt padding
                Color.clear.frame(width: .leastNonzeroMagnitude, height: 24)
            }
        }
        .padding([.leading, .trailing])
    }
    
}

fileprivate struct TextSectionHeaderStyleModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        return content
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(Color(UIColor.label.withAlphaComponent(0.6)))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

struct ProfileAvatarView: View {
    @Binding var avatar: UIImage
    
    var body: some View {
        Image(uiImage: avatar)
            .resizable()
            .frame(width: 135, height: 135)
            .cornerRadius(135 * 0.5)
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let contactInfoDict: [ContactInfo.InfoType: [ContactInfo]] = [
            .email: [
                ContactInfo(type: .email, key: "email", value: "alice@mail.me")
            ],
            .twitter: [
                ContactInfo(type: .twitter, key: "twitter", value: "@Alice"),
                ContactInfo(type: .twitter, key: "twitter", value: "@realAlice"),
            ],
            .telegram: [
                ContactInfo(type: .telegram, key: "telegram", value: "teleAlice")
            ],
            .discord: [
                ContactInfo(type: .discord, key: "discord", value: "Alice#1234")
            ]
        ]
        return ProfileView(
            avatar: .constant(UIImage.placeholder(color: .systemFill)),
            name: .constant("Alice"),
            shortKeyID: .constant("9035 a2853"),
            shareProfileAction: { print("Tap") },
            contactInfoDict: .constant(contactInfoDict),
            note: .constant("Alice in the Book\nPhone Number: +00 123-456-7890")
        )
    }
}
#endif
